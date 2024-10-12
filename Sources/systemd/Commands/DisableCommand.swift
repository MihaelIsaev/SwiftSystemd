//
//  DisableCommand.swift
//  SwiftSystemd
//
//  Created by Mihael Isaev on 12.10.2024.
//

import ConsoleKit

final class DisableCommand: Command {
    struct Signature: CommandSignature {
        init() {}
    }
    
    var help: String { "Disables the existing systemd service" }
    
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
            // Checking systemd file
            if !systemctl.doesConfigExists() {
                console.warning("The service \"\(systemctl.serviceName)\" hasn't been installed yet.")
                console.info("Call `swift run systemd install` to install it first.")
            } else {
                try systemctl.disable()
            }
        } catch {
            console.error("\(error)")
        }
    }
}
