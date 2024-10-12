//
//  VersionCommand.swift
//  SwiftSystemd
//
//  Created by Mihael Isaev on 10.10.2024.
//

import ConsoleKit

final class VersionCommand: Command {
    static var currentVersion = "1.0.0"
    
    struct Signature: CommandSignature {
        init() {}
    }
    
    var help: String { "Prints current version of SwiftSystemd" }
    
    func run(using context: ConsoleKit.CommandContext, signature: Signature) throws {
        #if DEBUG
        let mode = "DEBUG"
        #else
        let mode = "RELEASE"
        #endif
        context.console.output([
            ConsoleTextFragment(string: "SwiftSystemd", style: .init(color: .magenta, isBold: true)),
            ConsoleTextFragment(string: " \(Self.currentVersion)-\(mode)", style: .init(color: .yellow, isBold: true))
        ])
    }
}
