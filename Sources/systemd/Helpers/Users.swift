//
//  Users.swift
//  SwiftSystemd
//
//  Created by Mihael Isaev on 10.10.2024.
//

import Foundation
import Bash
import ConsoleKit

struct Users {
    /// Returns an array of all users in the system
    static func list(console: Console) -> [String] {
        let defaultUsers = ["root"]
        do {
            let stdout = Pipe()
            let stderr = Pipe()
            let process = Process()
            process.launchPath = try Bash.which("awk")
            process.arguments = ["-F:", "\"{ print $1}\"", "/etc/passwd"]
            process.standardOutput = stdout
            process.standardError = stderr
            
            let outHandle = stdout.fileHandleForReading

            process.launch()
            process.waitUntilExit()
            
            guard process.terminationStatus == 0 else {
                console.warning("process.terminationStatus: \(process.terminationStatus)")
                let errData = stderr.fileHandleForReading.readDataToEndOfFile()
                if errData.count > 0 {
                    let errString = String(data: errData, encoding: .utf8)?.trimmingCharacters(in: .whitespaces) ?? "exit code \(process.terminationStatus)"
                    console.warning("errString: \(errString)")
                } else {
                    console.warning("unable to parse error")
                }
                return defaultUsers
            }
            
            let data = outHandle.readDataToEndOfFile()
            guard data.count > 0, let users = String(data: data, encoding: .utf8) else {
                console.warning("data.count: \(data.count)")
                return defaultUsers
            }
            return users.components(separatedBy: "\n").compactMap {
                let u = $0.trimmingCharacters(in: .whitespacesAndNewlines)
                if u.hasPrefix("_") { return nil }
                if u.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 { return nil }
                let name = u.components(separatedBy: ":").first ?? u
                if [
                    "daemon",
                    "bin",
                    "sys",
                    "sync",
                    "games",
                    "man",
                    "lp",
                    "mail",
                    "news",
                    "uucp",
                    "proxy",
                    "backup",
                    "list",
                    "irc",
                    "gnats",
                    "nobody",
                    "systemd-network",
                    "systemd-resolve",
                    "systemd-timesync",
                    "messagebus",
                    "syslog",
                    "tss",
                    "uuidd",
                    "tcpdump",
                    "landscape",
                    "pollinate",
                    "sshd",
                    "fwupd-refresh",
                    "systemd-coredump",
                    "lxd",
                    "postgres"
                ].contains(name) { return nil }
                return name
            }
        } catch {
            console.warning("Error happened: \(error)")
            return ["root"]
        }
    }
}
