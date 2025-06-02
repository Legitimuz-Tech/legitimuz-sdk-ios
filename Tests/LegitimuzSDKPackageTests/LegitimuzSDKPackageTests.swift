import Testing
@testable import LegitimuzSDKPackage

@Test func example() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
}

@Test func testConfigurationInitialization() async throws {
    // Test basic configuration
    let config = LegitimuzConfiguration(
        host: URL(string: "https://api.example.com")!,
        token: "test-token",
        appURL: URL(string: "https://widget.example.com")!,
        language: "en",
        enableDebugLogging: true,
        enableInspection: false
    )
    
    #expect(config.host.absoluteString == "https://api.example.com")
    #expect(config.token == "test-token")
    #expect(config.appURL.absoluteString == "https://widget.example.com")
    #expect(config.language == "en")
    #expect(config.enableDebugLogging == true)
    #expect(config.enableInspection == false)
}

@Test func testDemoConfiguration() async throws {
    // Test demo configuration
    let demoConfig = LegitimuzConfiguration.demo(token: "demo-token")
    
    #expect(demoConfig.host.absoluteString == "https://demo.legitimuz.com")
    #expect(demoConfig.token == "demo-token")
    #expect(demoConfig.appURL.absoluteString == "https://widget.legitimuz.com")
    #expect(demoConfig.language == "pt")
    #expect(demoConfig.enableDebugLogging == true)
    #expect(demoConfig.enableInspection == false)
}

@Test func testVerificationParameters() async throws {
    // Test verification parameters initialization
    let parameters = LegitimuzVerificationParameters(
        cpf: "12345678901",
        referenceId: "ref123",
        action: .signup,
        verificationType: .kyc
    )
    
    #expect(parameters.cpf == "12345678901")
    #expect(parameters.referenceId == "ref123")
    #expect(parameters.action == .signup)
    #expect(parameters.verificationType == .kyc)
}

@Test func testVerificationParametersDefaults() async throws {
    // Test verification parameters with defaults
    let parameters = LegitimuzVerificationParameters(cpf: "12345678901")
    
    #expect(parameters.cpf == "12345678901")
    #expect(parameters.referenceId == nil)
    #expect(parameters.action == nil)
    #expect(parameters.verificationType == .kyc)
}

@Test func testActionEnum() async throws {
    // Test action enum values
    #expect(LegitimuzAction.signup.rawValue == "signup")
    #expect(LegitimuzAction.signin.rawValue == "signin")
    #expect(LegitimuzAction.withdraw.rawValue == "withdraw")
    #expect(LegitimuzAction.passwordChange.rawValue == "password_change")
    #expect(LegitimuzAction.accountDetailsChange.rawValue == "account_details_change")
}

@Test func testVerificationTypes() async throws {
    // Test verification type enum
    let kycType: LegitimuzVerificationType = .kyc
    let sowType: LegitimuzVerificationType = .sow
    let faceIndexType: LegitimuzVerificationType = .faceIndex
    
    #expect(kycType == .kyc)
    #expect(sowType == .sow)
    #expect(faceIndexType == .faceIndex)
}

@Test func testEventInitialization() async throws {
    // Test event initialization from raw data
    let eventData: [String: Any] = [
        "name": "ocr",
        "status": "success",
        "refId": "123456"
    ]
    
    let event = LegitimuzEvent(from: eventData)
    
    #expect(event.name == "ocr")
    #expect(event.status == "success")
    #expect(event.refId == "123456")
}

@Test func testEventHandlersInitialization() async throws {
    // Test event handlers initialization
    var eventReceived: LegitimuzEvent?
    var successCalled: String?
    var errorCalled: String?
    var logMessage: String?
    
    let handlers = LegitimuzEventHandlers(
        onEvent: { event in
            eventReceived = event
        },
        onSuccess: { eventName in
            successCalled = eventName
        },
        onError: { eventName in
            errorCalled = eventName
        },
        onLog: { message, level in
            logMessage = message
        }
    )
    
    // Test that handlers are properly initialized
    #expect(handlers.onEvent != nil)
    #expect(handlers.onSuccess != nil)
    #expect(handlers.onError != nil)
    #expect(handlers.onLog != nil)
}

@Test func testLogLevel() async throws {
    // Test log level enumeration
    let logLevel: LegitimuzLogLevel = .error
    
    #expect(logLevel == .error)
}

@Test func testCPFValidation() async throws {
    // Test CPF validation
    #expect(LegitimuzSDK.validateCPF("55555555555") == true) // Test CPF
    #expect(LegitimuzSDK.validateCPF("00000000000") == false) // Invalid CPF
    #expect(LegitimuzSDK.validateCPF("123") == false) // Too short
    #expect(LegitimuzSDK.validateCPF("") == false) // Empty
    
    // Test formatted CPF
    #expect(LegitimuzSDK.validateCPF("555.555.555-55") == true)
}

@Test func testCPFCleaning() async throws {
    // Test CPF cleaning
    #expect(LegitimuzSDK.cleanCPF("555.555.555-55") == "55555555555")
    #expect(LegitimuzSDK.cleanCPF("555 555 555 55") == "55555555555")
    #expect(LegitimuzSDK.cleanCPF("55555555555") == "55555555555")
}
