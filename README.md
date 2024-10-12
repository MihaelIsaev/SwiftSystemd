<p align="center">
    <a href="LICENSE">
        <img src="https://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License">
    </a>
    <a href="https://swift.org">
        <img src="https://img.shields.io/badge/swift-5.8-brightgreen.svg" alt="Swift 5.8">
    </a>
    <a href="https://discord.gg/q5wCPYv">
        <img src="https://img.shields.io/discord/612561840765141005" alt="Swift.Stream">
    </a>
</p>

<br>

#### Support this lib by giving a ⭐️

A simple plugin for any executable Swift package that provides the ability to manage it via `systemd`.

## How to install

To install `systemd` as a SwiftPM plugin, first add the following line to your Package.swift file:

```swift
.package(url: "https://github.com/MihaelIsaev/SwiftSystemd.git", from:"1.0.0")
```

## Usage

The purpose of `systemd` is to run your app as a daemon and monitor it.

The first step is to generate the appropriate config file and save it.

### Install

```
swift run systemd install
```
It will prompt you with a few questions to generate and save the correct config file.

Or you could use parameters to predefine values

| Parameter   |      Description      |
|--------------|---------------------:|
| -c,--config  | Type of configuration: release or debug |
| -t,--target  | Executable target name |
| -u,--user    | User under which the service will run |

```
swift run systemd install -c release -t App -u mike 
```

### Uninstall

```
swift run systemd uninstall
```
Deletes the `systemd` configuration file and stops the service if it is active.

### Start

```
swift run systemd start
```
Starts your app using `systemctl start`

### Restart

```
swift run systemd restart
```
Restarts your app using `systemctl restart`

### Stop

```
swift run systemd stop
```
Stops your app if it is running via `systemd`, using `systemctl stop`.

### Enable

```
swift run systemd enable
```
Enables the existing service configuration via `systemctl enable`.

### Disable

```
swift run systemd disable
```
Disables the existing service configuration via `systemctl disable`.

### Kill

```
swift run systemd kill
```
Sends kill signal to the running service via `systemctl kill`.

### Status

```
swift run systemd status
```
Shows status of your app via `systemctl status`.

### Daemon Reload

```
swift run systemd daemon-reload
```
Reloads all `systemd` services via `systemctl daemon-reload`.

### Logs

```
swift run systemd logs
```
Displays live logs of your app via `journalctl`.

```
swift run systemd logs --limit 100
```
Displays the last `100` lines from your app's log via `journalctl`

## Contributing

Please feel free to contribute!
