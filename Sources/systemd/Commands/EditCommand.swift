//
//  EditCommand.swift
//  SwiftSystemd
//
//  Created by Mihael Isaev on 12.10.2024.
//

import ConsoleKit
import Bash

final class EditCommand: Command {
    struct Signature: CommandSignature {
        init() {}
    }
    
    var help: String { "Prints the command to manually edit the configuration file" }
    
    func run(using context: ConsoleKit.CommandContext, signature: Signature) throws {
        guard let cwd = Swift.cwd(context) else { return }
        do {
            // Getting package name
            let package = try Swift.dumpPackage()
            guard let systemctl = Systemctl(
                context: context,
                cwd: cwd,
                serviceName: package.name
            ) else { return }
            struct Editor {
                let name, path: String
            }
            var editors: [Editor] = []
            do {
                editors.append(Editor(name: "nano", path: try Bash.which("nano")))
            } catch {}
            do {
                editors.append(Editor(name: "vim", path: try Bash.which("vim")))
            } catch {}
            guard editors.count > 0 else {
                context.console.warning("nano or vim editors not found")
                context.console.aborting()
                return
            }
            // Checking systemd file
            if !systemctl.doesConfigExists() {
                console.warning("The service \"\(systemctl.serviceName)\" hasn't been installed yet.")
                console.info("Call `swift run systemd install` to install it first.")
            } else {
                try systemctl.enable()
            }
            console.info("To edit the config manually call:")
            editors.enumerated().forEach { index, editor in
                if index > 0 {
                    console.warning("  or")
                }
                console.warning("    \(editor.name) \(systemctl.pathToConfig)")
            }
        } catch {
            console.error("\(error)")
        }
    }
}
