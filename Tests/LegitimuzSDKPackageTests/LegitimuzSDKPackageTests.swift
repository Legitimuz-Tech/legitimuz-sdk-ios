import Testing
@testable import LegitimuzSDKPackage

@Test func example() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
}

@Test func testConfigurationInitialization() async throws {
    // Test basic configuration
    let config = LegitimuzConfiguration(
        sdkURL: URL(string: "https://example.com")!,
        enableDebugLogging: true,
        enableInspection: false
    )
    
    #expect(config.sdkURL.absoluteString == "https://example.com")
    #expect(config.enableDebugLogging == true)
    #expect(config.enableInspection == false)
}

@Test func testDemoConfiguration() async throws {
    // Test demo configuration
    let demoConfig = LegitimuzConfiguration.demo()
    
    #expect(demoConfig.sdkURL.absoluteString == "https://demo.legitimuz.com/teste-kyc/")
    #expect(demoConfig.enableDebugLogging == true)
    #expect(demoConfig.enableInspection == false)
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
