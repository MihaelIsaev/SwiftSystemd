//
//  Systemctl.swift
//  SwiftSystemd
//
//  Created by Mihael Isaev on 12.10.2024.
//

import Foundation
import Bash
import ConsoleKit

struct Systemctl {
    let context: ConsoleKit.CommandContext
    let binPath: String
    let cwd: String
    let serviceName: String
    let pathToConfig: String
    
    init? (
        context: ConsoleKit.CommandContext,
        cwd: String,
        serviceName: String
    ) {
        guard let path = try? Bash.which("systemctl") else {
            context.console.output([
                "Unable to find path to ".fragment(color: .brightRed, isBold: true),
                "systemd".fragment(color: .yellow, isBold: true)
            ])
            context.console.aborting()
            return nil
        }
        self.context = context
        self.binPath = path
        self.cwd = cwd
        self.serviceName = serviceName.lowercased()
        self.pathToConfig = "/etc/systemd/system/\(self.serviceName).service"
    }
    
    func generateConfig(
        user: String,
        buildType: String,
        target: String
    ) -> String {
        return """
        [Unit]
        Description="\(serviceName)"
        After=network.target

        # 2
        [Service]
        User=\(user)
        EnvironmentFile=\(cwd)/.env
        WorkingDirectory=\(cwd)
        TimeoutStopSec=2

        # 3
        Restart=always

        # 4
        ExecStart=\(cwd)/.build/\(buildType)/\(target)

        [Install]
        WantedBy=multi-user.target
        """
    }
    
    func doesConfigExists() -> Bool {
        FileManager.default.fileExists(atPath: pathToConfig)
    }
    
    func removeConfig() {
        try? FileManager.default.removeItem(atPath: pathToConfig)
    }
    
    func writeConfig(_ config: String) -> Bool {
        guard
            let data = config.data(using: .utf8),
            FileManager.default.createFile(atPath: pathToConfig, contents: data)
        else {
            context.console.output([
                "Unable to save systemd configuration file at ".fragment(color: .brightRed, isBold: true),
                pathToConfig.fragment(color: .yellow, isBold: true)
            ])
            context.console.aborting()
            return false
        }
        return true
    }
    
    func enable() throws {
        let output = try execute("enable", "\(serviceName).service")
        if output.count > 0 {
            context.console.info(output)
        }
    }
    
    func disable() throws {
        let output = try execute("disable", "\(serviceName).service")
        if output.count > 0 {
            context.console.info(output)
        }
    }
    
    func start() throws {
        let output = try execute("start", "\(serviceName).service")
        if output.count > 0 {
            context.console.info(output)
        }
    }
    
    func stop() throws {
        let output = try execute("stop", "\(serviceName).service")
        if output.count > 0 {
            context.console.info(output)
        }
    }
    
    func restart() throws {
        let output = try execute("restart", "\(serviceName).service")
        if output.count > 0 {
            context.console.info(output)
        }
    }
    
    func kill() throws {
        let output = try execute("kill", "\(serviceName).service")
        if output.count > 0 {
            context.console.info(output)
        }
    }
    
    func clean() throws {
        let output = try execute("clean", "--all", "\(serviceName).service")
        if output.count > 0 {
            context.console.info(output)
        }
    }
    
    func status() throws {
        let output = try execute("status", "\(serviceName).service")
        if output.count > 0 {
            context.console.info(output)
        }
    }
    
    func isActive() throws -> Bool {
        do {
            let output = try execute("is-active", "\(serviceName).service")
            return output.trimmingCharacters(in: .whitespacesAndNewlines) == "active"
        } catch {
            return false
        }
    }
    
    func reloadDaemon() throws {
        let output = try execute("daemon-reload")
        if output.count > 0 {
            context.console.info(output)
        }
    }
}

extension Systemctl {
    enum Error: SError, CustomStringConvertible {
        case text(String)
        
        public var description: String {
            switch self {
            case .text(let text): return text
            }
        }
        
        public var localizedDescription: String { description }
    }
    
    private func execute(_ args: String...) throws -> String {
        return try execute(args)
    }
    
    @discardableResult
    private func execute(_ args: [String]) throws -> String {
        let stdout = Pipe()
        let stderr = Pipe()
        let process = Process()
        
        process.currentDirectoryURL = URL(fileURLWithPath: cwd)
        process.executableURL = URL(fileURLWithPath: binPath)
        process.arguments = args
        process.standardOutput = stdout
        process.standardError = stderr
        
        var resultData = Data()
        let group = DispatchGroup()
        group.enter()
        stderr.fileHandleForReading.readabilityHandler = { fh in }
        stdout.fileHandleForReading.readabilityHandler = { fh in
            let data = fh.availableData
            if data.isEmpty { // EOF on the pipe
                stdout.fileHandleForReading.readabilityHandler = nil
                group.leave()
            } else {
                resultData.append(data)
            }
        }
        try process.run()
        process.waitUntilExit()
        group.wait()
        guard process.terminationStatus == 0 else {
            guard resultData.count > 0, let rawError = String(data: resultData, encoding: .utf8) else {
                let errData = stderr.fileHandleForReading.readDataToEndOfFile()
                if errData.count > 0 {
                    let errString = String(data: errData, encoding: .utf8)?.trimmingCharacters(in: .whitespaces) ?? "exit code \(process.terminationStatus)"
                    throw Error.text(errString)
                } else {
                    throw Error.text("Error, exit code \(process.terminationStatus)")
                }
            }
            throw Error.text(rawError)
        }
        guard resultData.count > 0, let stringData = String(data: resultData, encoding: .utf8) else {
            return ""
        }
        return stringData.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
