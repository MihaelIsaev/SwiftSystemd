//
//  ReloadDaemonCommand.swift
//  SwiftSystemd
//
//  Created by Mihael Isaev on 12.10.2024.
//

import ConsoleKit

final class ReloadDaemonCommand: Command {
    struct Signature: CommandSignature {
        init() {}
    }
    
    var help: String { "Reloads systemd daemon" }
    
    func run(using context: ConsoleKit.CommandContext, signature: Signature) throws {
        guard let cwd = Swift.cwd(context) else { return }
        do {
            guard let systemctl = Systemctl(
                context: context,
                cwd: cwd,
                serviceName: ""
            ) else { return }
            try systemctl.reloadDaemon()
            context.console.success("Reloaded successfully.")
        } catch {
            console.error("\(error)")
        }
    }
}
