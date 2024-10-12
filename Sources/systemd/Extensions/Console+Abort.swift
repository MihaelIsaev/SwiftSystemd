//
//  Console+Abort.swift
//  SwiftSystemd
//
//  Created by Mihael Isaev on 12.10.2024.
//

import ConsoleKit

extension Console {
    func aborting() {
        self.output("Aborting.".consoleText(color: .red, isBold: true))
    }
}
