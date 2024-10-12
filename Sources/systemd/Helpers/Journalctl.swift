//
//  Journalctl.swift
//  SwiftSystemd
//
//  Created by Mihael Isaev on 12.10.2024.
//

import Foundation
import Bash
import ConsoleKit

struct Journalctl {
    let context: ConsoleKit.CommandContext
    let binPath: String
    let serviceName: String
    
    init? (
        context: ConsoleKit.CommandContext,
        cwd: String,
        serviceName: String
    ) {
        guard let path = try? Bash.which("journalctl") else {
            context.console.output([
                "Unable to find path to ".fragment(color: .brightRed, isBold: true),
                "journalctl".fragment(color: .yellow, isBold: true)
            ])
            context.console.aborting()
            return nil
        }
        self.context = context
        self.binPath = path
        self.serviceName = serviceName.lowercased()
    }
    
    func showLive() throws {
        try execute("-u", serviceName, "-f")
    }
    
    func showLast(_ limit: String) throws {
        try execute("-u", serviceName, "-n", limit, "--no-pager")
    }
}

extension Journalctl {
    enum Error: SError, CustomStringConvertible {
        case text(String)
        
        public var description: String {
            switch self {
            case .text(let text): return text
            }
        }
        
        public var localizedDescription: String { description }
    }
    
    private func execute(_ args: String...) throws {
        return try execute(args)
    }
    
    private func execute(_ args: [String]) throws {
        let stdout = Pipe()
        let stderr = Pipe()
        let process = Process()
        
        process.executableURL = URL(fileURLWithPath: binPath)
        process.arguments = args
        process.standardOutput = stdout
        process.standardError = stderr
        
        let group = DispatchGroup()
        group.enter()
        stderr.fileHandleForReading.readabilityHandler = { fh in }
        stdout.fileHandleForReading.readabilityHandler = { fh in
            let data = fh.availableData
            if data.isEmpty { // EOF on the pipe
                stdout.fileHandleForReading.readabilityHandler = nil
                group.leave()
            } else if let str = String(data: data, encoding: .utf8) {
                console.info(str)
            }
        }
        try process.run()
        process.waitUntilExit()
        group.wait()
    }
}
