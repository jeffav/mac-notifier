import SwiftUI

struct AddHostView: View {
    @Environment(\.dismiss) private var dismiss

    var editingHost: Host?

    @State private var address: String = ""
    @State private var label: String = ""
    @State private var checkMethod: CheckMethod = .ping
    @State private var tcpPort: String = ""
    @State private var isEnabled: Bool = true

    @State private var showingError = false
    @State private var errorMessage = ""

    private var isEditing: Bool { editingHost != nil }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Text(isEditing ? "Edit Host" : "Add Host")
                    .font(.headline)

                Spacer()

                Button(isEditing ? "Save" : "Add") {
                    saveHost()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(address.isEmpty)
            }
            .padding()

            Divider()

            // Form
            Form {
                Section {
                    TextField("Hostname or IP Address", text: $address)
                        .textFieldStyle(.roundedBorder)

                    TextField("Label (optional)", text: $label)
                        .textFieldStyle(.roundedBorder)
                }

                Section("Check Method") {
                    Picker("Method", selection: $checkMethod) {
                        ForEach(CheckMethod.allCases, id: \.self) { method in
                            Text(method.rawValue).tag(method)
                        }
                    }
                    .pickerStyle(.segmented)

                    if checkMethod != .ping {
                        HStack {
                            Text("TCP Port")
                            TextField("Port", text: $tcpPort)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 80)
                        }
                    }
                }

                Section {
                    Toggle("Enabled", isOn: $isEnabled)
                }
            }
            .formStyle(.grouped)
            .padding()
        }
        .frame(width: 400, height: 320)
        .onAppear {
            if let host = editingHost {
                address = host.address
                label = host.label ?? ""
                checkMethod = host.checkMethod
                tcpPort = host.tcpPort.map { String($0) } ?? ""
                isEnabled = host.isEnabled
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") {}
        } message: {
            Text(errorMessage)
        }
    }

    private func saveHost() {
        // Validate
        let trimmedAddress = address.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedAddress.isEmpty else {
            errorMessage = "Address is required"
            showingError = true
            return
        }

        var port: Int? = nil
        if checkMethod != .ping {
            guard let portNum = Int(tcpPort), portNum > 0, portNum <= 65535 else {
                errorMessage = "Please enter a valid port number (1-65535)"
                showingError = true
                return
            }
            port = portNum
        }

        let trimmedLabel = label.trimmingCharacters(in: .whitespacesAndNewlines)

        if var existing = editingHost {
            existing.address = trimmedAddress
            existing.label = trimmedLabel.isEmpty ? nil : trimmedLabel
            existing.checkMethod = checkMethod
            existing.tcpPort = port
            existing.isEnabled = isEnabled
            DataStore.shared.updateHost(existing)
        } else {
            let newHost = Host(
                address: trimmedAddress,
                label: trimmedLabel.isEmpty ? nil : trimmedLabel,
                checkMethod: checkMethod,
                tcpPort: port,
                isEnabled: isEnabled
            )
            DataStore.shared.addHost(newHost)
        }

        dismiss()
    }
}

#Preview {
    AddHostView()
}

#Preview("Editing") {
    AddHostView(editingHost: Host(
        address: "192.168.1.1",
        label: "Router",
        checkMethod: .tcpPort,
        tcpPort: 80
    ))
}
