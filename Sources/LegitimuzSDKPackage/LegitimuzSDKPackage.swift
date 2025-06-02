// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import SwiftUI

// MARK: - Public API

/// Verification types supported by Legitimuz SDK
public enum LegitimuzVerificationType {
    case kyc
    case sow
    case faceIndex
}

/// Valid actions for verification context
public enum LegitimuzAction: String, CaseIterable {
    case signup = "signup"
    case signin = "signin"
    case withdraw = "withdraw"
    case passwordChange = "password_change"
    case accountDetailsChange = "account_details_change"
}

/// Main configuration object for the Legitimuz SDK
public struct LegitimuzConfiguration {
    /// The API host URL for session generation
    public let host: URL
    /// Authentication token for API requests
    public let token: String
    /// The app URL where the widget is hosted (defaults to Legitimuz widget URL)
    public let appURL: URL
    /// Language for the SDK interface
    public let language: String
    /// Enable debug logging (console logs from JavaScript)
    public let enableDebugLogging: Bool
    /// Enable inspectable WebView for development
    public let enableInspection: Bool
    
    /// Initialize Legitimuz configuration
    /// - Parameters:
    ///   - host: The API host URL for session generation
    ///   - token: Authentication token for API requests
    ///   - appURL: The widget URL (defaults to Legitimuz widget)
    ///   - language: Language code ("pt", "en", "es")
    ///   - enableDebugLogging: Whether to log JavaScript console output to Xcode console
    ///   - enableInspection: Whether to enable WebView inspection for debugging (iOS 16.4+)
    public init(
        host: URL,
        token: String,
        appURL: URL = URL(string: "https://widget.legitimuz.com")!,
        language: String = "pt",
        enableDebugLogging: Bool = true,
        enableInspection: Bool = false
    ) {
        self.host = host
        self.token = token
        self.appURL = appURL
        self.language = language
        self.enableDebugLogging = enableDebugLogging
        self.enableInspection = enableInspection
    }
    
    /// Convenience initializer with demo configuration
    /// - Parameters:
    ///   - token: Authentication token for API requests
    ///   - enableDebugLogging: Whether to log JavaScript console output to Xcode console
    ///   - enableInspection: Whether to enable WebView inspection for debugging (iOS 16.4+)
    public static func demo(
        token: String,
        enableDebugLogging: Bool = true,
        enableInspection: Bool = false
    ) -> LegitimuzConfiguration {
        return LegitimuzConfiguration(
            host: URL(string: "https://demo.legitimuz.com")!,
            token: token,
            appURL: URL(string: "https://widget.legitimuz.com")!,
            language: "pt",
            enableDebugLogging: enableDebugLogging,
            enableInspection: enableInspection
        )
    }
}

/// Parameters for starting verification
public struct LegitimuzVerificationParameters {
    /// CPF number for verification
    public let cpf: String
    /// Optional reference ID for tracking
    public let referenceId: String?
    /// Optional action context
    public let action: LegitimuzAction?
    /// Type of verification to perform
    public let verificationType: LegitimuzVerificationType
    
    public init(
        cpf: String,
        referenceId: String? = nil,
        action: LegitimuzAction? = nil,
        verificationType: LegitimuzVerificationType = .kyc
    ) {
        self.cpf = cpf
        self.referenceId = referenceId
        self.action = action
        self.verificationType = verificationType
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

/// Main Legitimuz SDK class for managing verification sessions
@available(iOS 16.0, *)
public class LegitimuzSDK: ObservableObject {
    internal let configuration: LegitimuzConfiguration
    internal let eventHandlers: LegitimuzEventHandlers
    
    @Published public var isLoading: Bool = false
    @Published public var sessionURL: URL?
    @Published public var errorMessage: String?
    
    /// Initialize the Legitimuz SDK
    /// - Parameters:
    ///   - configuration: SDK configuration including API host and token
    ///   - eventHandlers: Event handling closures
    public init(
        configuration: LegitimuzConfiguration,
        eventHandlers: LegitimuzEventHandlers
    ) {
        self.configuration = configuration
        self.eventHandlers = eventHandlers
    }
    
    /// Start verification process by generating a session
    /// - Parameter parameters: Verification parameters including CPF and type
    public func startVerification(with parameters: LegitimuzVerificationParameters) {
        Task {
            await generateSession(with: parameters)
        }
    }
    
    /// Generate verification session
    @MainActor
    private func generateSession(with parameters: LegitimuzVerificationParameters) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let sessionId = try await performSessionGeneration(with: parameters)
            sessionURL = await buildSessionURL(sessionId: sessionId, parameters: parameters)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            eventHandlers.onError?("session_generation_failed")
        }
    }
    
    /// Perform the actual session generation API call
    private func performSessionGeneration(with parameters: LegitimuzVerificationParameters) async throws -> String {
        let url = configuration.host.appendingPathComponent("external/kyc/session")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Create form data
        let formData = await createFormData(with: parameters)
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = formData.data(using: boundary)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw LegitimuzError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw LegitimuzError.httpError(httpResponse.statusCode)
        }
        
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        guard let sessionId = json?["session_id"] as? String else {
            let message = json?["message"] as? String
            let errors = json?["errors"] as? [String] ?? []
            let errorMessage = errors.first ?? message ?? "Unknown error"
            throw LegitimuzError.sessionGenerationFailed(errorMessage)
        }
        
        return sessionId
    }
    
    /// Create form data for session generation
    private func createFormData(with parameters: LegitimuzVerificationParameters) async -> FormData {
        var formData = FormData()
        
        formData.append("cpf", value: parameters.cpf)
        formData.append("token", value: configuration.token)
        formData.append("deviceinfo", value: await getDeviceInfo())
        formData.append("user_agent", value: await getUserAgent())
        
        if let deviceMemory = getDeviceMemory() {
            formData.append("device_memory", value: deviceMemory)
        }
        
        formData.append("hardware_concurrency", value: getHardwareConcurrency())
        
        if parameters.verificationType == .faceIndex {
            formData.append("flow", value: "kyc-faceindex")
        }
        
        if let referenceId = parameters.referenceId {
            formData.append("ref_id", value: referenceId)
        }
        
        if let action = parameters.action {
            formData.append("action_ref", value: action.rawValue)
        }
        
        return formData
    }
    
    /// Build the session URL for the WebView
    private func buildSessionURL(sessionId: String, parameters: LegitimuzVerificationParameters) async -> URL {
        let isMobile = await MainActor.run {
            UIDevice.current.userInterfaceIdiom == .phone
        }
        let feature: String
        
        switch parameters.verificationType {
        case .kyc:
            feature = isMobile ? "" : "qr-code"
        case .sow:
            feature = isMobile ? "sow" : "qr-code"
        case .faceIndex:
            feature = isMobile ? "" : "qr-code"
        }
        
        var urlComponents = URLComponents(url: configuration.appURL, resolvingAgainstBaseURL: false)!
        urlComponents.path = "/\(sessionId)" + (feature.isEmpty ? "" : "/\(feature)")
        
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "lang", value: configuration.language)
        ]
        
        if parameters.verificationType == .faceIndex {
            queryItems.append(URLQueryItem(name: "onlyliveness", value: "1"))
        }
        
        if let referenceId = parameters.referenceId {
            queryItems.append(URLQueryItem(name: "refId", value: referenceId))
        }
        
        if let action = parameters.action {
            queryItems.append(URLQueryItem(name: "action", value: action.rawValue))
        }
        
        urlComponents.queryItems = queryItems
        
        return urlComponents.url!
    }
    
    // MARK: - Device Info Helpers
    
    private func getDeviceInfo() async -> String {
        return await MainActor.run {
            "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
        }
    }
    
    private func getUserAgent() async -> String {
        return await MainActor.run {
            "LegitimuzSDK/2.1.0 (iOS \(UIDevice.current.systemVersion))"
        }
    }
    
    private func getDeviceMemory() -> String? {
        return ProcessInfo.processInfo.physicalMemory > 0 ? "\(ProcessInfo.processInfo.physicalMemory)" : nil
    }
    
    private func getHardwareConcurrency() -> String {
        return "\(ProcessInfo.processInfo.processorCount)"
    }
}

/// Main LegitimuzSDK SwiftUI view component
@available(iOS 16.0, *)
public struct LegitimuzWebView: View {
    @StateObject private var sdk: LegitimuzSDK
    private let parameters: LegitimuzVerificationParameters?
    
    /// Initialize the Legitimuz WebView with manual session generation
    /// - Parameters:
    ///   - sdk: Pre-configured LegitimuzSDK instance
    public init(sdk: LegitimuzSDK) {
        self._sdk = StateObject(wrappedValue: sdk)
        self.parameters = nil
    }
    
    /// Initialize the Legitimuz WebView with automatic session generation
    /// - Parameters:
    ///   - configuration: SDK configuration including API host and token
    ///   - parameters: Verification parameters
    ///   - eventHandlers: Event handling closures
    public init(
        configuration: LegitimuzConfiguration,
        parameters: LegitimuzVerificationParameters,
        eventHandlers: LegitimuzEventHandlers
    ) {
        let sdkInstance = LegitimuzSDK(configuration: configuration, eventHandlers: eventHandlers)
        self._sdk = StateObject(wrappedValue: sdkInstance)
        self.parameters = parameters
    }
    
    public var body: some View {
        content
            .onAppear {
                if let parameters = parameters {
                    sdk.startVerification(with: parameters)
                }
            }
    }
    
    @ViewBuilder
    private var content: some View {
        if sdk.isLoading {
            VStack {
                ProgressView()
                Text("Generating session...")
                    .foregroundColor(.gray)
            }
        } else if let errorMessage = sdk.errorMessage {
            VStack {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(.red)
                    .font(.largeTitle)
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
            .padding()
        } else if let sessionURL = sdk.sessionURL {
            LegitimuzWebViewInternal(
                sessionURL: sessionURL,
                configuration: sdk.configuration,
                eventHandlers: sdk.eventHandlers
            )
            .ignoresSafeArea(.all)
        } else {
            VStack {
                Text("Ready to start verification")
                    .foregroundColor(.gray)
            }
        }
    }
}

// MARK: - Error Handling

public enum LegitimuzError: LocalizedError {
    case invalidResponse
    case httpError(Int)
    case sessionGenerationFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .sessionGenerationFailed(let message):
            return "Session generation failed: \(message)"
        }
    }
}

// MARK: - Form Data Helper

private struct FormData {
    private var data: [String: String] = [:]
    
    mutating func append(_ key: String, value: String) {
        data[key] = value
    }
    
    func data(using boundary: String) -> Data {
        var body = Data()
        
        for (key, value) in data {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
}
