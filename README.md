# LegitimuzSDK

A Swift Package Manager library for integrating Legitimuz identity verification services into iOS applications.

## Installation

Add LegitimuzSDK to your project using Xcode:

1. In Xcode, go to **File → Add Package Dependencies**
2. Enter the repository URL: `https://github.com/Legitimuz-Tech/legitimuz-sdk-ios`
3. Choose your version requirements
4. Add the package to your target

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Legitimuz-Tech/legitimuz-sdk-ios", from: "2.3.0")
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

### Complete Configuration Options

```swift
let config = LegitimuzConfiguration(
    host: URL(string: "https://api.legitimuz.com")!,        // Your API host
    token: "your-api-token",                                  // Authentication token
    appURL: URL(string: "https://widget.legitimuz.com")!,    // Widget URL (optional)
    language: "pt",                                           // Language: "pt", "en", "es"
    enableDebugLogging: true,                                 // Enable JS console logs
    enableInspection: true                                    // Enable WebView debugging
)
```

### Actions and Reference IDs

```swift
LegitimuzWebView.forKYCVerification(
    configuration: config,
    cpf: "12345678901",
    referenceId: "user-ref-123",      // Optional: your internal user ID
    action: .signup,                   // Context: .signup, .signin, .withdraw, etc.
    eventHandlers: handlers
)
```

## Features

- 🚀 **Session Generation**: Automatically generates verification sessions via API calls
- 📱 **Multiple Verification Types**: Support for KYC, and Face Index verification
- 🔍 **Debug Support**: Complete JavaScript console logging and WebView inspection capabilities
- 🎯 **Event Handling**: Comprehensive event system for tracking SDK operations
- 🔒 **Secure**: Automatic camera, microphone, and location permission management
- 📦 **Zero Dependencies**: Pure SwiftUI/WebKit implementation with no external dependencies
- ✅ **CPF Validation**: Built-in Brazilian CPF validation

## Event Types

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

## Testing

The library includes a comprehensive test suite. Run tests with:

```bash
swift test
```

## License

This library is available under the Apache 2.0 License. See LICENSE file for details.

## Support

For questions about Legitimuz services, contact Legitimuz support directly.