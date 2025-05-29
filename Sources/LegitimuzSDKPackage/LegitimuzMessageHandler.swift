import Foundation
import WebKit

// MARK: - Message Handler

internal class LegitimuzMessageHandler: NSObject, WKScriptMessageHandler {
    private let eventHandlers: LegitimuzEventHandlers
    
    init(eventHandlers: LegitimuzEventHandlers) {
        self.eventHandlers = eventHandlers
        super.init()
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("[LegitimuzSDK] Received message: \(message.name) with body: \(message.body)")
        
        switch message.name {
        case "consoleLog":
            handleConsoleLog(message: message)
        case "legitimuzEvent":
            handleLegitimuzEvent(message: message)
        case "onSuccess":
            handleSuccess(message: message)
        case "onError":
            handleError(message: message)
        default:
            print("[LegitimuzSDK] Unknown message type: \(message.name)")
        }
    }
    
    // MARK: - Message Handlers
    
    private func handleConsoleLog(message: WKScriptMessage) {
        guard let body = message.body as? [String: Any],
              let type = body["type"] as? String,
              let content = body["content"] as? String else {
            print("[LegitimuzSDK] Invalid console log message format")
            return
        }
        
        let logLevel: LegitimuzLogLevel
        switch type {
        case "error": logLevel = .error
        case "warn": logLevel = .warning
        case "info": logLevel = .info
        case "debug": logLevel = .debug
        default: logLevel = .log
        }
        
        print("[LegitimuzSDK] JS \(type): \(content)")
        eventHandlers.onLog?(content, logLevel)
    }
    
    private func handleLegitimuzEvent(message: WKScriptMessage) {
        guard let eventData = message.body as? [String: Any] else {
            print("[LegitimuzSDK] Invalid event message format")
            return
        }
        
        let event = LegitimuzEvent(from: eventData)
        print("[LegitimuzSDK] Event received: \(event.name) (\(event.status))")
        
        // Call the main event handler
        eventHandlers.onEvent?(event)
        
        // Also call success/error handlers for backward compatibility
        if event.status == "success" {
            eventHandlers.onSuccess?(event.name)
        } else if event.status == "error" {
            eventHandlers.onError?(event.name)
        } else if !event.name.contains("error") && !event.name.contains("fail") {
            // Assume success if no explicit error status
            eventHandlers.onSuccess?(event.name)
        } else {
            eventHandlers.onError?(event.name)
        }
    }
    
    private func handleSuccess(message: WKScriptMessage) {
        let eventName: String
        
        if let name = message.body as? String {
            eventName = name
        } else if let dict = message.body as? [String: Any],
                  let name = dict["event"] as? String {
            eventName = name
        } else {
            eventName = "unknown_success"
        }
        
        print("[LegitimuzSDK] Success: \(eventName)")
        eventHandlers.onSuccess?(eventName)
    }
    
    private func handleError(message: WKScriptMessage) {
        let eventName: String
        
        if let name = message.body as? String {
            eventName = name
        } else if let dict = message.body as? [String: Any],
                  let name = dict["event"] as? String {
            eventName = name
        } else {
            eventName = "unknown_error"
        }
        
        print("[LegitimuzSDK] Error: \(eventName)")
        eventHandlers.onError?(eventName)
    }
} 