//
//  StartCommand.swift
//  SwiftSystemd
//
//  Created by Mihael Isaev on 10.10.2024.
//

import ConsoleKit
import Bash
import Foundation

final class StartCommand: Command {
    struct Signature: CommandSignature {
        init() {}
    }
    
    var help: String { "Starts the existing systemd service" }
    
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
                    context.console.warning("Your app is already running.")
                    guard context.console.choose(
                        "Would you like to restart it?",
                        from: ["yes", "no"],
                        display: { .init(stringLiteral: $0) }
                    ) == "yes" else { return console.success("OK, not touching it.") }
                    try systemctl.restart()
                    console.success("Restarted successfully.")
                } else {
                    try systemctl.start()
                    console.success("Started successfully.")
                }
            }
        } catch {
            console.error("\(error)")
        }
    }
}
