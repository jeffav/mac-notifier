# Mac Network Monitor

A macOS menu bar application that monitors network hosts and notifies you when their availability changes.

![macOS](https://img.shields.io/badge/macOS-14.0+-blue) ![Swift](https://img.shields.io/badge/Swift-5.0-orange) ![License](https://img.shields.io/badge/license-MIT-green)

## Features

- **Menu bar app** - Runs quietly in your menu bar with no dock icon
- **Multiple check methods** - ICMP ping, TCP port check, or both per host
- **Smart notifications** - Only notifies when a host's status changes
- **Custom labels** - Give hosts friendly names for easy identification
- **Configurable intervals** - Check every 10s, 30s, 1m, 2m, or 5m
- **Status history** - View a log of all status changes with timestamps
- **Response times** - See ping/connection latency for each host
- **Persistent storage** - Hosts and settings survive app restarts
- **Launch at login** - Optionally start monitoring when you log in

## Screenshot

The app appears as a network icon in your menu bar. Click to see host status:

- Green dot = online
- Red dot = offline
- Gray dot = not checked yet or disabled

## Installation

### From Release

1. Download the latest `MacNotifier.app` from Releases
2. Move to your Applications folder
3. Right-click and select **Open** (required first time for unsigned apps)

### Build from Source

Requires Xcode 15+ and macOS 14+.

```bash
git clone https://github.com/yourusername/mac-notifier.git
cd mac-notifier
open MacNotifier.xcodeproj
```

In Xcode:
1. Select **Product > Archive**
2. Click **Distribute App > Copy App**
3. Move the exported app to Applications

## Usage

### Adding a Host

1. Click the menu bar icon
2. Click the **+** button
3. Enter hostname or IP address
4. Optionally add a custom label
5. Choose check method:
   - **Ping** - Standard ICMP ping
   - **TCP Port** - Check if a specific port is open
   - **Both** - Online if either succeeds
6. Click **Add**

### Managing Hosts

Right-click any host to:
- Edit settings
- Enable/disable monitoring
- Check immediately
- Delete

### Settings

Access via the gear icon:

- **General** - Check interval, response time display, launch at login
- **Notifications** - Enable/disable status change alerts
- **Advanced** - History retention, data location

## Data Storage

Host configuration and history are stored in:

```
~/Library/Application Support/MacNotifier/
├── hosts.json
└── history.json
```

## Requirements

- macOS 14.0 or later
- App Sandbox must be disabled (required for ping)

## License

MIT
