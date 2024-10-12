import ConsoleKit
import Foundation
import Bash

typealias SError = Error

let console: Console = Terminal()
var input = CommandInput(arguments: CommandLine.arguments)
var context = CommandContext(console: console, input: input)

guard Bash.whichBool("systemctl") else {
    console.error("Unable to find systemctl in the system. Aborting.")
    exit(1)
}

var commands = Commands(enableAutocomplete: false)
commands.use(InstallCommand(), as: "install", isDefault: false)
commands.use(UninstallCommand(), as: "uninstall", isDefault: false)
commands.use(StartCommand(), as: "start", isDefault: false)
commands.use(StopCommand(), as: "stop", isDefault: false)
commands.use(RestartCommand(), as: "restart", isDefault: false)
commands.use(EnableCommand(), as: "enable", isDefault: false)
commands.use(DisableCommand(), as: "disable", isDefault: false)
commands.use(KillCommand(), as: "kill", isDefault: false)
commands.use(StatusCommand(), as: "status", isDefault: false)
commands.use(ReloadDaemonCommand(), as: "reload-daemon", isDefault: false)
commands.use(EditCommand(), as: "edit", isDefault: false)
commands.use(LogsCommand(), as: "logs", isDefault: false)
// install
// uninstall
// enable
// disable
// edit in nano/vim

do {
    let group = commands
        .group(help: "This tool will help you to deal with systemd and journalctl 🚀")
    try console.run(group, input: input)
} catch let error {
    console.error("\(error)")
    exit(1)
}
