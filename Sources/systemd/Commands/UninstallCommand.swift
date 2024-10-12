//
//  UninstallCommand.swift
//  SwiftSystemd
//
//  Created by Mihael Isaev on 12.10.2024.
//

import ConsoleKit
import Bash
import Foundation

final class UninstallCommand: Command {
    struct Signature: CommandSignature {
        init() {}
    }
    
    var help: String { "Deletes the systemd configuration file and stops the service if it is active" }
    
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
                console.warning("The service \"\(systemctl.serviceName)\" hasn't been installed yet")
                console.info("Call `swift run systemd install` to install it")
            } else {
                if try systemctl.isActive() {
                    try systemctl.stop()
                }
                try systemctl.clean()
                systemctl.removeConfig()
                console.success("Sucessfully uninstalled \"\(systemctl.serviceName)\" service")
            }
        } catch {
            console.error("\(error)")
        }
    }
}
