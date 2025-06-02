# LegitimuzSDK

A Swift Package Manager library for integrating Legitimuz identity verification services into iOS applications. This SDK generates verification sessions dynamically and displays them in a WebView, just like the JavaScript SDK.

## Overview

LegitimuzSDK provides a clean, SwiftUI-based interface for integrating Legitimuz's identity verification and KYC (Know Your Customer) services into your iOS app. The library handles session generation, WebView setup, JavaScript communication, permission management, and event handling for a seamless integration.

## Features

- 🚀 **Session Generation**: Automatically generates verification sessions via API calls
- 📱 **Multiple Verification Types**: Support for KYC, SOW (Source of Wealth), and Face Index verification
- 🔍 **Debug Support**: Complete JavaScript console logging and WebView inspection capabilities
- 🎯 **Event Handling**: Comprehensive event system for tracking SDK operations
- 🔒 **Secure**: Automatic camera, microphone, and location permission management
- 📦 **Zero Dependencies**: Pure SwiftUI/WebKit implementation with no external dependencies
- ✅ **CPF Validation**: Built-in Brazilian CPF validation

## Requirements

- iOS 16.0+
- Xcode 14.0+
- Swift 5.9+

## Installation

### Swift Package Manager

Add LegitimuzSDK to your project using Xcode:

1. In Xcode, go to **File → Add Package Dependencies**
2. Enter the repository URL: `https://github.com/yourusername/LegitimuzSDKPackage`
3. Choose your version requirements
4. Add the package to your target

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/LegitimuzSDKPackage", from: "1.0.0")
]
```

## Required Permissions

Add these permissions to your app's `Info.plist`:

```xml
<!-- Camera Permission - Required for document scanning and liveness detection -->
<key>NSCameraUsageDescription</key>
<string>This app needs camera access for identity verification</string>

<!-- Microphone Permission - May be required for certain verification features -->
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for identity verification</string>

<!-- Location Permissions - Required if using geolocation features -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access for identity verification</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app may need location access for verification features</string>
```

## Quick Start

### Basic KYC Verification

```swift
import SwiftUI
import LegitimuzSDK

struct ContentView: View {
    @State private var currentEvent: String = "Ready"
    
    var body: some View {
        VStack {
            Text("Status: \(currentEvent)")
                .padding()
            
            LegitimuzWebView.forKYCVerification(
                configuration: LegitimuzConfiguration(
                    host: URL(string: "https://api.yourdomain.com")!,
                    token: "your-api-token"
                ),
                cpf: "12345678901",
                referenceId: "user-ref-123",
                action: .signup,
                eventHandlers: LegitimuzEventHandlers(
                    onEvent: { event in
                        currentEvent = "\(event.name) (\(event.status))"
                    },
                    onSuccess: { eventName in
                        print("✅ Success: \(eventName)")
                    },
                    onError: { eventName in
                        print("❌ Error: \(eventName)")
                    }
                )
            )
        }
    }
}
```

### Using the SDK Class Directly

```swift
import SwiftUI
import LegitimuzSDK

struct VerificationView: View {
    @StateObject private var sdk = LegitimuzSDK(
        configuration: LegitimuzConfiguration(
            host: URL(string: "https://api.yourdomain.com")!,
            token: "your-api-token"
        ),
        eventHandlers: LegitimuzEventHandlers(
            onEvent: { event in
                print("Event: \(event.name)")
            }
        )
    )
    
    var body: some View {
        VStack {
            if sdk.isLoading {
                ProgressView("Generating session...")
            } else if let error = sdk.errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            } else {
                LegitimuzWebView(sdk: sdk)
            }
            
            HStack {
                Button("Start KYC") {
                    sdk.verifyDocument(cpf: "12345678901")
                }
                Button("Start SOW") {
                    sdk.openVerifySOWFlow(cpf: "12345678901")
                }
                Button("Face Index") {
                    sdk.startFaceIndex(cpf: "12345678901")
                }
            }
        }
    }
}
```

### Demo Configuration

```swift
import SwiftUI
import LegitimuzSDK

struct DemoView: View {
    var body: some View {
        LegitimuzWebView.forKYCVerification(
            configuration: LegitimuzConfiguration.demo(token: "demo-token"),
            cpf: "55555555555", // Test CPF
            eventHandlers: LegitimuzEventHandlers(
                onEvent: { event in
                    print("Demo event: \(event.name)")
                }
            )
        )
    }
}
```

## Configuration Options

### LegitimuzConfiguration

```swift
let config = LegitimuzConfiguration(
    host: URL(string: "https://api.yourdomain.com")!,        // Your API host
    token: "your-api-token",                                  // Authentication token
    appURL: URL(string: "https://widget.legitimuz.com")!,    // Widget URL (optional)
    language: "pt",                                           // Language: "pt", "en", "es"
    enableDebugLogging: true,                                 // Enable JS console logs
    enableInspection: true                                    // Enable WebView debugging
)

// Or use the demo configuration
let demoConfig = LegitimuzConfiguration.demo(
    token: "your-demo-token",
    enableDebugLogging: true,
    enableInspection: false
)
```

### Verification Types

```swift
// Standard KYC verification
LegitimuzWebView.forKYCVerification(configuration: config, cpf: "12345678901", eventHandlers: handlers)

// SOW (Source of Wealth) verification
LegitimuzWebView.forSOWVerification(configuration: config, cpf: "12345678901", eventHandlers: handlers)

// Face indexing/liveness verification
LegitimuzWebView.forFaceIndexVerification(configuration: config, cpf: "12345678901", eventHandlers: handlers)
```

### Actions

```swift
// Available action contexts
let action: LegitimuzAction = .signup              // "signup"
let action: LegitimuzAction = .signin              // "signin"
let action: LegitimuzAction = .withdraw            // "withdraw"
let action: LegitimuzAction = .passwordChange      // "password_change"
let action: LegitimuzAction = .accountDetailsChange // "account_details_change"
```

## CPF Validation

```swift
// Validate CPF
let isValid = LegitimuzSDK.validateCPF("123.456.789-01")
let isValidTest = LegitimuzSDK.validateCPF("555.555.555-55") // Test CPF returns true

// Clean CPF (remove formatting)
let cleanCPF = LegitimuzSDK.cleanCPF("123.456.789-01") // Returns "12345678901"
```

## Event Handling

### Complete Event Handling

```swift
let handlers = LegitimuzEventHandlers(
    onEvent: { event in
        // Handle all events with complete data
        print("Event: \(event.name), Status: \(event.status)")
        if let refId = event.refId {
            print("Reference ID: \(refId)")
        }
        print("Raw data: \(event.rawData)")
    },
    onSuccess: { eventName in
        // Handle successful operations
        print("Success: \(eventName)")
    },
    onError: { eventName in
        // Handle errors
        print("Error: \(eventName)")
    },
    onLog: { message, level in
        // Handle JavaScript console logs
        switch level {
        case .error:
            print("JS Error: \(message)")
        case .warning:
            print("JS Warning: \(message)")
        default:
            print("JS Log: \(message)")
        }
    }
)
```

### Event Types

The SDK emits various events during the verification process:

- **`page_loaded`**: WebView finished loading
- **`session_generation_failed`**: Session generation failed
- **`ocr`**: Document OCR processing
- **`facematch`**: Face matching operation
- **`liveness`**: Liveness detection
- **`sow`**: Source of Wealth verification
- **`faceindex`**: Face indexing verification
- **`close-modal`**: User closed the verification modal
- **`modal`**: Modal open/close events

Each event includes:
- `name`: Event identifier
- `status`: "success", "error", or custom status  
- `refId`: Optional reference ID for tracking
- `rawData`: Complete event data from the SDK

## Advanced Usage

### Custom Session Management

```swift
class VerificationManager: ObservableObject {
    @Published var currentStep: VerificationStep = .idle
    private let sdk: LegitimuzSDK
    
    init() {
        self.sdk = LegitimuzSDK(
            configuration: LegitimuzConfiguration(
                host: URL(string: "https://api.yourdomain.com")!,
                token: "your-token"
            ),
            eventHandlers: LegitimuzEventHandlers(
                onEvent: { [weak self] event in
                    self?.handleEvent(event)
                }
            )
        )
    }
    
    func startKYCVerification(for user: User) {
        guard LegitimuzSDK.validateCPF(user.cpf) else {
            currentStep = .error("Invalid CPF")
            return
        }
        
        currentStep = .generating
        sdk.verifyDocument(
            cpf: LegitimuzSDK.cleanCPF(user.cpf),
            referenceId: user.id,
            action: .signup
        )
    }
    
    private func handleEvent(_ event: LegitimuzEvent) {
        DispatchQueue.main.async {
            switch event.name {
            case "ocr":
                if event.status == "success" {
                    self.currentStep = .documentScanned
                }
            case "facematch":
                if event.status == "success" {
                    self.currentStep = .faceMatched
                }
            case "close-modal":
                self.currentStep = .completed
            default:
                break
            }
        }
    }
}
```

### Error Handling

```swift
struct VerificationView: View {
    @StateObject private var sdk: LegitimuzSDK
    
    var body: some View {
        Group {
            if sdk.isLoading {
                LoadingView()
            } else if let error = sdk.errorMessage {
                ErrorView(error: error) {
                    retryVerification()
                }
            } else if let sessionURL = sdk.sessionURL {
                LegitimuzWebView(sdk: sdk)
            } else {
                IdleView()
            }
        }
        .alert("Verification Error", isPresented: .constant(sdk.errorMessage != nil)) {
            Button("Retry") { retryVerification() }
            Button("Cancel") { /* Handle cancel */ }
        }
    }
    
    private func retryVerification() {
        sdk.verifyDocument(cpf: "12345678901")
    }
}
```

## Testing

The library includes a comprehensive test suite. Run tests with:

```bash
swift test
```

### Using Test CPF

For testing, use the special test CPF that always validates:

```swift
let testCPF = "55555555555"
let isValid = LegitimuzSDK.validateCPF(testCPF) // Returns true

LegitimuzWebView.forKYCVerification(
    configuration: .demo(token: "test-token"),
    cpf: testCPF,
    eventHandlers: handlers
)
```

## Migration from Previous Version

If you were using the previous version that took a static URL, here's how to migrate:

### Before (v1.0):
```swift
LegitimuzWebView(
    configuration: LegitimuzConfiguration(
        sdkURL: URL(string: "https://your-url.com")!
    ),
    eventHandlers: handlers
)
```

### After (v2.0):
```swift
LegitimuzWebView.forKYCVerification(
    configuration: LegitimuzConfiguration(
        host: URL(string: "https://api.your-domain.com")!,
        token: "your-api-token"
    ),
    cpf: "12345678901",
    eventHandlers: handlers
)
```

## Troubleshooting

### Common Issues

**Session generation fails:**
- Verify your API host URL is correct
- Check that your authentication token is valid
- Ensure the CPF is valid (use `LegitimuzSDK.validateCPF()`)
- Check network connectivity

**Camera not working:**
- Ensure camera permissions are added to Info.plist
- Test on a physical device (simulator has limited camera support)
- Check that the WebView has permission to access camera

**No events received:**
- Enable debug logging to see JavaScript console output
- Verify the widget URL is accessible
- Check that events are properly configured in your Legitimuz dashboard

### Debug Logging

Enable comprehensive logging:

```swift
let config = LegitimuzConfiguration(
    host: yourHost,
    token: yourToken,
    enableDebugLogging: true,
    enableInspection: true
)
```

This will output detailed logs with `[LegitimuzSDK]` prefix in Xcode console.

## License

This library is available under the MIT License. See LICENSE file for details.

## Support

For questions about the LegitimuzSDK library, please open an issue on GitHub.
For questions about Legitimuz services, contact Legitimuz support directly.