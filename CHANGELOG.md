# Changelog

All notable changes to LegitimuzSDK will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.3.0] - 2025-06-03

### Fixed
- **Origin Header**: Updated Origin header handling in session generation requests
- **User Agent**: Enhanced user agent version information for better API compatibility

### Enhanced
- **Network Communication**: Improved HTTP header configuration for more reliable API communication

## [2.2.9] - 2025-06-03

### Fixed
- **API Headers**: Added proper Origin header to session generation requests for improved server compatibility

## [2.2.8] - 2025-06-03

### Enhanced
- **Performance**: Optimized LegitimuzSDK for improved performance and thread safety
- **Concurrency**: Enhanced concurrent operations handling
- **Memory Management**: Improved memory usage patterns

## [2.2.7] - 2025-06-03

### Enhanced
- **Type Safety**: Enhanced LegitimuzSDK types with Sendable conformance for better Swift concurrency support
- **Thread Safety**: Improved thread safety across all SDK components
- **Concurrent Programming**: Better support for async/await patterns

## [2.2.5] - 2025-06-03

### Refactored
- **Access Control**: Changed access level of internal properties in LegitimuzSDK to improve encapsulation
- **API Design**: Enhanced internal API structure for better maintainability

### Security
- **Property Access**: Improved security by restricting access to internal SDK properties

## [2.2.4] - 2025-06-03

### Refactored
- **Code Organization**: Extracted view content into separate computed properties in LegitimuzWebView for better code organization and reusability

### Performance
- **View Rendering**: Optimized view rendering performance through better component separation

## [2.2.3] - 2025-06-03

### Enhanced
- **Type System**: Wrapped view components in AnyView for improved type erasure in LegitimuzWebView
- **SwiftUI Compatibility**: Better SwiftUI integration and view composition

## [2.2.1] - 2025-06-03

### Improved
- **UI Layout**: Simplified ignoresSafeArea usage in LegitimuzWebView for more predictable layout behavior
- **Safe Area Handling**: Enhanced safe area management across different device types

## [2.2.0] - 2025-06-03

### Enhanced
- **Async Support**: Updated LegitimuzSDK to support asynchronous data handling
- **Data Flow**: Improved asynchronous data processing and state management
- **Error Handling**: Enhanced error handling for async operations

### Performance
- **Async Operations**: Better performance for long-running operations through proper async/await implementation

## [2.1.0] - 2025-06-03

### Enhanced
- **Session Management**: Updated LegitimuzSDK to support asynchronous session URL building
- **API Integration**: Improved session creation with async URL generation
- **Performance**: Better handling of session initialization timing

### Technical
- **Async Architecture**: Enhanced async/await support for session URL building operations

## [2.0.0] - 2025-06-03

### Added - Major Refactor 🎉
- **Session Generation**: SDK now generates verification sessions dynamically via API calls, matching JavaScript SDK behavior
- **Multiple Verification Types**: Support for KYC, SOW (Source of Wealth), and Face Index verification flows
- **LegitimuzSDK Class**: New main SDK class for managing verification sessions programmatically
- **Verification Parameters**: Structured parameters for CPF, reference ID, action context, and verification type
- **Action Enum**: Predefined action contexts (signup, signin, withdraw, password_change, account_details_change)
- **CPF Validation**: Built-in Brazilian CPF validation with test CPF support (55555555555)
- **Convenience Methods**: `verifyDocument()`, `openVerifySOWFlow()`, `startFaceIndex()` matching JS SDK
- **Static Factory Methods**: `forKYCVerification()`, `forSOWVerification()`, `forFaceIndexVerification()`
- **Error Handling**: Comprehensive error handling for session generation failures
- **Loading States**: Built-in loading and error state management
- **Device Info Collection**: Automatic device information collection for API calls

### Changed - Breaking Changes ⚠️
- **Configuration Structure**: `LegitimuzConfiguration` now requires `host`, `token` instead of static `sdkURL`
- **Initialization**: WebView now requires verification parameters or pre-configured SDK instance
- **Demo Configuration**: Now requires authentication token parameter
- **API Pattern**: Changed from static URL loading to dynamic session generation

### Migration Guide
```swift
// Before (v1.0)
LegitimuzWebView(
    configuration: LegitimuzConfiguration(sdkURL: URL(string: "https://your-url.com")!),
    eventHandlers: handlers
)

// After (v2.0)  
LegitimuzWebView.forKYCVerification(
    configuration: LegitimuzConfiguration(
        host: URL(string: "https://api.your-domain.com")!,
        token: "your-api-token"
    ),
    cpf: "12345678901",
    eventHandlers: handlers
)
```

### Enhanced
- **Event System**: Enhanced event handling with new session-related events
- **Testing**: Comprehensive test suite covering new functionality
- **Documentation**: Updated README with extensive examples and migration guide
- **Type Safety**: Improved type safety with enums and structured parameters

## [1.0.0] - 2025-06-03

### Added
- Initial release of LegitimuzSDK
- SwiftUI-based WebView component for identity verification
- Complete JavaScript-to-Swift event handling system
- Automatic camera, microphone, and location permission management
- Debug logging and WebView inspection capabilities
- Demo configuration for testing and development
- Comprehensive event system for tracking SDK operations
- Zero external dependencies implementation

### Features
- **LegitimuzWebView**: Main SwiftUI component for easy integration
- **LegitimuzConfiguration**: Flexible configuration with demo and production modes
- **LegitimuzEvent**: Complete event data structure with status tracking
- **LegitimuzEventHandlers**: Comprehensive callback system for all operations
- **Debug Support**: JavaScript console logging and WebView inspection
- **iOS 16.0+ Support**: Optimized for modern iOS versions

### Security
- Automatic permission handling for camera and microphone access
- Secure WebView configuration with JavaScript injection protection
- URL validation and HTTPS support 