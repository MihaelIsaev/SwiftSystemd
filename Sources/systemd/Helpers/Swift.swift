//
//  Swift.swift
//  SwiftSystemd
//
//  Created by Mihael Isaev on 10.10.2024.
//

import Foundation
import Bash
import ConsoleKit

struct Swift {
    enum SwiftError: Error, CustomStringConvertible {
        case text(String)
        
        public var description: String {
            switch self {
            case .text(let text): return text
            }
        }
        
        public var localizedDescription: String { description }
    }
    
    static func cwd(_ context: ConsoleKit.CommandContext? = nil) -> String? {
        let cwd = getcwd(nil, Int(PATH_MAX))
        defer {
            if let cwd = cwd {
                free(cwd)
            }
        }
        if let cwd = cwd, let string = String(validatingUTF8: cwd) {
            return string
        } else {
            context?.console.output([
                "Unable to determine current working directory.".fragment(color: .brightRed, isBold: true),
                " Aborting.".fragment(color: .red, isBold: true)
            ])
            return nil
        }
    }
    
    struct SwiftPackage: Decodable {
        let name: String
        public struct Target: Decodable {
            public let name: String
        }
        public let targets: [Target]?
    }
    
    static func dumpPackage() throws -> SwiftPackage {
        guard let cwd = Swift.cwd() else {
            throw SwiftError.text("Unable to detect current working directory, can't make swift package dump")
        }
        let stdout = Pipe()
        let stderr = Pipe()
        let process = Process()
        
        process.currentDirectoryURL = URL(fileURLWithPath: cwd)
        process.executableURL = URL(fileURLWithPath: try Bash.which("swift"))
        process.arguments = ["package", "dump-package"]
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
                    throw SwiftError.text(errString)
                } else {
                    throw SwiftError.text("Error, exit code \(process.terminationStatus)")
                }
            }
            throw SwiftError.text(rawError)
        }
        guard resultData.count > 0 else {
            throw SwiftError.text("Error, exit code \(process.terminationStatus)")
        }
        return try JSONDecoder().decode(SwiftPackage.self, from: resultData)
    }
}
