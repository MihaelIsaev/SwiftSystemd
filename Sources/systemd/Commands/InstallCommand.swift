//
//  InstallCommand.swift
//  SwiftSystemd
//
//  Created by Mihael Isaev on 10.10.2024.
//

import ConsoleKit
import Bash
import Foundation

final class InstallCommand: Command {
    struct Signature: CommandSignature {
        @Option(
            name: "cwd",
            help: "Path to current working directory"
        )
        var cwd: String?
        
        @Option(
            name: "target",
            short: "t",
            help: "Executable target name"
        )
        var target: String?
        
        @Option(
            name: "config",
            short: "c",
            help: "Type of configuration: release or debug",
            completion: .values(["release", "debug"])
        )
        var config: String?
        
        @Option(
            name: "user",
            short: "u",
            help: "User under which the service will run",
            completion: .values(["root", "www-data"])
        )
        var user: String?
        
        init() {}
    }
    
    var help: String { "Generates a systemd configuration file" }
    
    func run(using context: ConsoleKit.CommandContext, signature: Signature) throws {
        guard let cwd = signature.cwd ?? Swift.cwd(context) else { return }
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
                create(targets: package.targets, systemctl: systemctl, signature: signature)
                guard context.console.choose(
                    "Would you like to start it?",
                    from: ["yes", "no"],
                    display: { .init(stringLiteral: $0) }
                ) == "yes" else {
                    context.console.success("Successfully created systemd service.")
                    context.console.info("To start the app service call:")
                    context.console.warning("    swift run systemd start")
                    return
                }
                try systemctl.start()
                context.console.success("Successfully installed and started the app.")
            } else {
                context.console.warning("Configuration file for \"\(systemctl.serviceName)\" already exists.")
            }
        } catch {
            console.error("\(error)")
        }
    }
    
    private func create(targets: [Swift.SwiftPackage.Target]?, systemctl: Systemctl, signature: Signature) {
        let target: String
        if let t = signature.target {
            target = t
        } else {
            guard let targets = targets, targets.count > 0 else {
                return context.console.aborting()
            }
            if targets.count == 1 {
                target = targets[0].name
            } else {
                target = context.console.choose(
                    "Please choose the target of your app",
                    from: targets.map { $0.name }
                ) { .init(stringLiteral: $0) }
            }
        }
        let buildType = signature.config ?? context.console.choose(
            "Please choose the target configuration",
            from: ["release", "debug"]
        ) { .init(stringLiteral: $0) }
        let user = signature.user ?? context.console.choose(
            "Please choose the user under which the service will run",
            from: Users.list(console: console)
        ) { .init(stringLiteral: $0) }
        let config = systemctl.generateConfig(
            user: user,
            buildType: buildType,
            target: target
        )
        guard systemctl.writeConfig(config) else { return }
    }
}
