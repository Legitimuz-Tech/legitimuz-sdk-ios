// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import SwiftUI

// MARK: - Public API

/// Main configuration object for the Legitimuz SDK
public struct LegitimuzConfiguration {
    /// The URL where the Legitimuz SDK is hosted
    public let sdkURL: URL
    /// Enable debug logging (console logs from JavaScript)
    public let enableDebugLogging: Bool
    /// Enable inspectable WebView for development
    public let enableInspection: Bool
    
    /// Initialize Legitimuz configuration
    /// - Parameters:
    ///   - sdkURL: The URL where your Legitimuz SDK instance is hosted
    ///   - enableDebugLogging: Whether to log JavaScript console output to Xcode console
    ///   - enableInspection: Whether to enable WebView inspection for debugging (iOS 16.4+)
    public init(
        sdkURL: URL,
        enableDebugLogging: Bool = true,
        enableInspection: Bool = false
    ) {
        self.sdkURL = sdkURL
        self.enableDebugLogging = enableDebugLogging
        self.enableInspection = enableInspection
    }
    
    /// Convenience initializer with demo URL
    /// - Parameters:
    ///   - enableDebugLogging: Whether to log JavaScript console output to Xcode console
    ///   - enableInspection: Whether to enable WebView inspection for debugging (iOS 16.4+)
    public static func demo(
        enableDebugLogging: Bool = true,
        enableInspection: Bool = false
    ) -> LegitimuzConfiguration {
        return LegitimuzConfiguration(
            sdkURL: URL(string: "https://demo.legitimuz.com/teste-kyc/")!,
            enableDebugLogging: enableDebugLogging,
            enableInspection: enableInspection
        )
    }
}

/// Event data received from the Legitimuz SDK
public struct LegitimuzEvent {
    /// The name of the event (e.g., "ocr", "facematch", "close-modal")
    public let name: String
    /// The status of the event ("success", "error", or custom status)
    public let status: String
    /// Optional reference ID for tracking
    public let refId: String?
    /// Complete raw event data
    public let rawData: [String: Any]
    
    internal init(from data: [String: Any]) {
        self.name = data["name"] as? String ?? "unknown"
        self.status = data["status"] as? String ?? "unknown"
        self.refId = data["refId"] as? String
        self.rawData = data
    }
}

/// Log level for JavaScript console messages
public enum LegitimuzLogLevel {
    case log
    case error
    case warning
    case info
    case debug
}

/// Event handlers for the Legitimuz SDK integration
public struct LegitimuzEventHandlers {
    /// Called when an event is received from the SDK
    public let onEvent: ((LegitimuzEvent) -> Void)?
    /// Called when the SDK reports a successful operation
    public let onSuccess: ((String) -> Void)?
    /// Called when the SDK reports an error
    public let onError: ((String) -> Void)?
    /// Called when JavaScript console logs are captured (if debug logging is enabled)
    public let onLog: ((String, LegitimuzLogLevel) -> Void)?
    
    /// Initialize event handlers
    /// - Parameters:
    ///   - onEvent: Handler for all SDK events
    ///   - onSuccess: Handler for successful operations
    ///   - onError: Handler for errors
    ///   - onLog: Handler for JavaScript console logs
    public init(
        onEvent: ((LegitimuzEvent) -> Void)? = nil,
        onSuccess: ((String) -> Void)? = nil,
        onError: ((String) -> Void)? = nil,
        onLog: ((String, LegitimuzLogLevel) -> Void)? = nil
    ) {
        self.onEvent = onEvent
        self.onSuccess = onSuccess
        self.onError = onError
        self.onLog = onLog
    }
}

/// Main LegitimuzSDK SwiftUI view component
@available(iOS 16.0, *)
public struct LegitimuzWebView: View {
    private let configuration: LegitimuzConfiguration
    private let eventHandlers: LegitimuzEventHandlers
    
    /// Initialize the Legitimuz WebView
    /// - Parameters:
    ///   - configuration: SDK configuration including URL and options
    ///   - eventHandlers: Event handling closures
    public init(
        configuration: LegitimuzConfiguration,
        eventHandlers: LegitimuzEventHandlers
    ) {
        self.configuration = configuration
        self.eventHandlers = eventHandlers
    }
    
    public var body: some View {
        LegitimuzWebViewInternal(
            configuration: configuration,
            eventHandlers: eventHandlers
        )
        .ignoresSafeArea(SafeAreaRegions.all)
    }
}
