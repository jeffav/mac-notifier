# Mac Network Monitor - Setup Instructions

## Creating the Xcode Project

1. Open Xcode and select **File > New > Project**
2. Choose **macOS > App** and click Next
3. Configure the project:
   - Product Name: `MacNotifier`
   - Team: Your development team
   - Organization Identifier: `com.yourname` (or your preferred identifier)
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Uncheck "Include Tests"
4. Click Next and save to the `mac-notifier` folder

## Adding Source Files

1. In Xcode, right-click on the `MacNotifier` folder in the navigator
2. Select **Add Files to "MacNotifier"...**
3. Navigate to `mac-notifier/MacNotifier` and select all the folders:
   - `Models/`
   - `Services/`
   - `Views/`
   - `Storage/`
4. Make sure "Copy items if needed" is unchecked (files are already in place)
5. Click Add

6. Replace the default `MacNotifierApp.swift` with the one in the `MacNotifier/` folder

## Configure Info.plist

1. Select the project in the navigator
2. Select the MacNotifier target
3. Go to the **Info** tab
4. Add a new row with key `Application is agent (UIElement)` and set value to `YES`
   - This makes the app run in the menu bar only (no dock icon)

Or use the provided Info.plist:
1. In the project navigator, delete the existing Info.plist (if any)
2. Add the `MacNotifier/Info.plist` file to the project

## Configure Signing & Capabilities

1. Select the project in the navigator
2. Select the MacNotifier target
3. Go to **Signing & Capabilities**
4. Add capabilities (click + Capability):
   - **App Sandbox** (disable it or configure for network access)
   - **Outgoing Connections (Client)** - if using sandbox

**Important for Ping**: The app uses `/sbin/ping` which requires either:
- Disable App Sandbox entirely, OR
- Sign with hardened runtime but not sandboxed

## Build and Run

1. Select **Product > Build** (Cmd+B)
2. Select **Product > Run** (Cmd+R)
3. Look for the network icon in your menu bar

## Features

- Click the menu bar icon to see host status
- Right-click a host to edit, disable, or delete
- Add hosts with custom labels
- Choose ping or TCP port check per host
- Configure check interval in Settings
- View status change history
- Notifications when hosts come online or go offline

## File Structure

```
MacNotifier/
├── MacNotifierApp.swift      # App entry, menu bar setup
├── Info.plist                # App configuration
├── Models/
│   ├── Host.swift            # Host data model
│   ├── HostStatus.swift      # Status and history models
│   └── AppSettings.swift     # User preferences
├── Services/
│   ├── NetworkMonitor.swift  # Main monitoring coordinator
│   ├── PingService.swift     # ICMP ping implementation
│   ├── TCPCheckService.swift # TCP port check
│   └── NotificationManager.swift
├── Views/
│   ├── MenuBarView.swift     # Main popover UI
│   ├── HostRowView.swift     # Individual host row
│   ├── AddHostView.swift     # Add/edit host sheet
│   ├── SettingsView.swift    # Preferences window
│   └── HistoryView.swift     # Status change log
└── Storage/
    └── DataStore.swift       # JSON persistence
```

## Data Storage

Host data and history are stored in:
```
~/Library/Application Support/MacNotifier/
├── hosts.json
└── history.json
```
