//
//  LogsCommand.swift
//  SwiftSystemd
//
//  Created by Mihael Isaev on 10.10.2024.
//

import ConsoleKit

final class LogsCommand: Command {
    struct Signature: CommandSignature {
        @Option(
            name: "limit",
            help: "Displays the app's log limited to the last x lines"
        )
        var limit: Int?
        
        init() {}
    }
    
    var help: String { "Opens journalctl for the service" }
    
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
            guard let journalctl = Journalctl(
                context: context,
                cwd: cwd,
                serviceName: package.name
            ) else { return }
            // Checking systemd file
            if !systemctl.doesConfigExists() {
                console.warning("The service \"\(systemctl.serviceName)\" hasn't been installed yet")
                console.info("Call `swift run systemd install` to install it first")
            } else {
                if let limit = signature.limit {
                    try journalctl.showLast("\(limit)")
                } else {
                    try journalctl.showLive()
                }
            }
        } catch {
            console.error("\(error)")
        }
    }
}
