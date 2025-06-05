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
    .package(url: "https://github.com/Legitimuz-Tech/legitimuz-sdk-ios", from: "2.3.2")
]
```

## Developer Requirements

### Platform & System Requirements

- **iOS Version**: iOS 16.0 or later
- **Swift Version**: Swift 6.1 or later  
- **Xcode**: Xcode 15.0 or later recommended
- **Device**: Physical iOS device required for camera-based verification (iOS Simulator has limited camera functionality)
- **Architecture**: Supports both arm64 and x86_64 architectures

### Framework Dependencies

- **SwiftUI**: Core UI framework (iOS 16.0+)
- **WebKit**: For WebView integration
- **Foundation**: Basic system services
- **CoreLocation**: For location-based verification features
- **No External Dependencies**: Pure iOS implementation

### API Integration Requirements

Before integrating the SDK, ensure you have:

1. **API Host URL**: Your Legitimuz API endpoint (e.g., `https://api.legitimuz.com`)
2. **Authentication Token**: Valid API token for session generation
3. **Origin Header**: Origin value for API requests (required parameter)
4. **Network Connectivity**: HTTPS-enabled internet connection
5. **Legitimuz Account**: Active Legitimuz service account with configured verification flows

### Code Integration Requirements

#### 1. Import Statement
```swift
import LegitimuzSDK
```

#### 2. Minimum Configuration
```swift
let config = LegitimuzConfiguration(
    host: URL(string: "https://api.legitimuz.com")!,
    token: "your-api-token",
    origin: "https://ios.app.legitimuz.com"
)
```

#### 3. Event Handling Implementation
```swift
let handlers = LegitimuzEventHandlers(
    onEvent: { event in
        // Handle verification events
    },
    onSuccess: { eventName in
        // Handle successful operations
    },
    onError: { eventName in
        // Handle errors
    }
)
```

### Required App Permissions

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

### Development Environment Setup

#### For Debug/Development:
```swift
let config = LegitimuzConfiguration(
    host: yourAPIHost,
    token: yourToken,
    enableDebugLogging: true,    // Enable JavaScript console logging
    enableInspection: true       // Enable Safari Web Inspector (iOS 16.4+)
)
```

#### For Production:
```swift
let config = LegitimuzConfiguration(
    host: yourAPIHost,
    token: yourToken,
    origin: yourOrigin,
    enableDebugLogging: false,   // Disable logging in production
    enableInspection: false      // Disable inspection in production
)
```

### Testing Requirements

#### Test Data Support:
- **Test CPF**: Use `55555555555` for development/testing
- **CPF Validation**: Built-in validation via `LegitimuzSDK.validateCPF()`
- **Demo Configuration**: Available for initial testing

#### Device Testing:
- Camera-based features require physical iOS device
- Test on multiple device sizes (iPhone, iPad)
- Test different iOS versions within supported range

### Architecture Considerations

#### Threading:
- SDK operations are performed on main thread (`@MainActor`)
- Async/await support for session generation
- Event callbacks executed on main thread

#### Memory Management:
- SDK uses `@StateObject` for SwiftUI integration
- Automatic cleanup of WebView resources
- No manual memory management required

#### Network Requirements:
- HTTPS endpoints required for API calls
- Handles network failures gracefully
- Built-in retry logic for session generation

### Integration Patterns

#### SwiftUI Integration:
```swift
struct YourView: View {
    var body: some View {
        LegitimuzWebView.forKYCVerification(
            configuration: config,
            cpf: cpf,
            eventHandlers: handlers
        )
    }
}
```

#### Programmatic Control:
```swift
let sdk = LegitimuzSDK(configuration: config, eventHandlers: handlers)
sdk.verifyDocument(cpf: "12345678901")
```

### Security Considerations

- Store API tokens securely (consider using Keychain)
- Validate CPF numbers before sending to API
- Handle sensitive user data according to privacy regulations
- Use HTTPS for all network communications
- Camera/microphone permissions granted automatically by SDK

### Performance Considerations

- WebView loading time varies with network conditions
- JavaScript execution may impact performance on older devices
- Consider loading states for better user experience
- Optimize for different screen sizes and orientations

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
                    host: URL(string: "https://api.legitimuz.com")!,
                    token: "your-api-token",
                    origin: "https://ios.app.legitimuz.com"
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
    origin: "https://ios.app.legitimuz.com",                 // Origin header (required)
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
        host: URL(string: "https://api.legitimuz.com")!,
        token: "your-api-token",
        origin: "https://ios.app.legitimuz.com"
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
    origin: yourOrigin,
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
