//
//  String+Fragment.swift
//  SwiftSystemd
//
//  Created by Mihael Isaev on 12.10.2024.
//

import ConsoleKit

extension String {
    public func fragment(
        color: ConsoleColor? = nil,
        background: ConsoleColor? = nil,
        isBold: Bool = false
    ) -> ConsoleTextFragment {
        return ConsoleTextFragment(
            string: self,
            style: ConsoleStyle(color: color, background: background, isBold: isBold)
        )
    }
}
