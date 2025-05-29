# LegitimuzSDK

A Swift Package Manager library for integrating Legitimuz identity verification services into iOS applications using WebView technology.

## Overview

LegitimuzSDK provides a clean, SwiftUI-based interface for integrating Legitimuz's identity verification and KYC (Know Your Customer) services into your iOS app. The library handles all the complex WebView setup, JavaScript communication, permission management, and event handling required for a seamless integration.

## Features

- 🚀 **Easy Integration**: Simple SwiftUI component that drops into any view
- 📱 **Native Performance**: Optimized WebView implementation with automatic permission handling
- 🔍 **Debug Support**: Complete JavaScript console logging and WebView inspection capabilities
- 🎯 **Event Handling**: Comprehensive event system for tracking SDK operations
- 🔒 **Secure**: Automatic camera, microphone, and location permission management
- 📦 **Zero Dependencies**: Pure SwiftUI/WebKit implementation with no external dependencies

## Requirements

- iOS 16.0+
- Xcode 14.0+
- Swift 5.9+

## Installation

### Swift Package Manager

Add LegitimuzSDK to your project using Xcode:

1. In Xcode, go to **File → Add Package Dependencies**
2. Enter the repository URL: `https://github.com/yourusername/LegitimuzSDK`
3. Choose your version requirements
4. Add the package to your target

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/LegitimuzSDK", from: "1.0.0")
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

### Basic Implementation

```swift
import SwiftUI
import LegitimuzSDK

struct ContentView: View {
    @State private var currentEvent: String = "Ready"
    
    var body: some View {
        VStack {
            Text("Status: \(currentEvent)")
                .padding()
            
            LegitimuzWebView(
                configuration: .demo(), // Uses demo URL
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

### Production Configuration

```swift
import SwiftUI
import LegitimuzSDK

struct VerificationView: View {
    @State private var verificationStatus: String = "Starting verification..."
    @State private var isComplete: Bool = false
    
    var body: some View {
        if isComplete {
            VerificationCompleteView()
        } else {
            LegitimuzWebView(
                configuration: LegitimuzConfiguration(
                    sdkURL: URL(string: "https://your-domain.com/verification")!,
                    enableDebugLogging: false, // Disable for production
                    enableInspection: false
                ),
                eventHandlers: LegitimuzEventHandlers(
                    onEvent: { event in
                        handleEvent(event)
                    },
                    onSuccess: { eventName in
                        if eventName == "verification_complete" {
                            isComplete = true
                        }
                    },
                    onError: { eventName in
                        // Handle errors
                        showErrorAlert(for: eventName)
                    },
                    onLog: { message, level in
                        // Custom logging in production
                        if level == .error {
                            logError(message)
                        }
                    }
                )
            )
        }
    }
    
    private func handleEvent(_ event: LegitimuzEvent) {
        verificationStatus = event.name
        
        // Access complete event data
        if let refId = event.refId {
            print("Reference ID: \(refId)")
        }
        
        // Access raw data for custom processing
        print("Raw event data: \(event.rawData)")
    }
}
```

## Configuration Options

### LegitimuzConfiguration

```swift
let config = LegitimuzConfiguration(
    sdkURL: URL(string: "https://your-verification-url.com")!,
    enableDebugLogging: true,  // Enable JavaScript console logging
    enableInspection: true     // Enable WebView debugging (iOS 16.4+)
)

// Or use the demo configuration
let demoConfig = LegitimuzConfiguration.demo(
    enableDebugLogging: true,
    enableInspection: false
)
```

### Event Handlers

```swift
let handlers = LegitimuzEventHandlers(
    onEvent: { event in
        // Handle all events with complete data
        print("Event: \(event.name), Status: \(event.status)")
        if let refId = event.refId {
            print("Reference ID: \(refId)")
        }
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

## Event Types

The SDK emits various events during the verification process:

- **`page_loaded`**: WebView finished loading
- **`ocr`**: Document OCR processing
- **`facematch`**: Face matching operation
- **`liveness`**: Liveness detection
- **`close-modal`**: User closed the verification modal
- **`verification_complete`**: Entire verification process completed

Each event includes:
- `name`: Event identifier
- `status`: "success", "error", or custom status
- `refId`: Optional reference ID for tracking
- `rawData`: Complete event data from the SDK

## Debug Mode

Enable debug mode for development:

```swift
let config = LegitimuzConfiguration.demo(
    enableDebugLogging: true,  // See all JavaScript console output
    enableInspection: true     // Enable Safari Web Inspector (iOS 16.4+)
)
```

Debug mode provides:
- JavaScript console output in Xcode console
- Uncaught error capturing
- Promise rejection handling
- WebView inspection capabilities

## Advanced Usage

### Custom URL Handling

```swift
struct CustomVerificationView: View {
    let userToken: String
    
    var body: some View {
        LegitimuzWebView(
            configuration: LegitimuzConfiguration(
                sdkURL: URL(string: "https://api.legitimuz.com/verify?token=\(userToken)")!
            ),
            eventHandlers: LegitimuzEventHandlers(
                onEvent: { event in
                    // Custom event processing
                    processVerificationEvent(event)
                }
            )
        )
    }
}
```

### State Management

```swift
class VerificationViewModel: ObservableObject {
    @Published var currentStep: VerificationStep = .starting
    @Published var errorMessage: String?
    @Published var isComplete: Bool = false
    
    func handleEvent(_ event: LegitimuzEvent) {
        DispatchQueue.main.async {
            switch event.name {
            case "document_capture":
                self.currentStep = .documentCapture
            case "liveness_check":
                self.currentStep = .livenessCheck
            case "verification_complete":
                self.currentStep = .complete
                self.isComplete = true
            default:
                break
            }
        }
    }
    
    func handleError(_ eventName: String) {
        DispatchQueue.main.async {
            self.errorMessage = "Error in \(eventName)"
        }
    }
}
```

## Testing

The library includes a test suite. Run tests with:

```bash
swift test
```

For testing in your app, use the demo configuration:

```swift
let testConfig = LegitimuzConfiguration.demo(enableDebugLogging: true)
```

## Troubleshooting

### Common Issues

**Camera not working:**
- Ensure camera permissions are added to Info.plist
- Test on a physical device (simulator has limited camera support)
- Check that the WebView has permission to access camera

**No events received:**
- Enable debug logging to see JavaScript console output
- Verify the SDK URL is correct and accessible
- Check network connectivity

**JavaScript errors:**
- Enable debug logging and WebView inspection
- Look for JavaScript console errors in Xcode output

**Page not loading:**
- Verify the SDK URL is accessible
- Check network permissions and connectivity
- Ensure the URL returns valid HTML content

### Debug Logging

Enable comprehensive logging:

```swift
let config = LegitimuzConfiguration(
    sdkURL: yourURL,
    enableDebugLogging: true,
    enableInspection: true
)
```

This will output detailed logs with `[LegitimuzSDK]` prefix in Xcode console.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This library is available under the MIT License. See LICENSE file for details.

## Support

For questions about the LegitimuzSDK library, please open an issue on GitHub.
For questions about Legitimuz services, contact Legitimuz support directly.