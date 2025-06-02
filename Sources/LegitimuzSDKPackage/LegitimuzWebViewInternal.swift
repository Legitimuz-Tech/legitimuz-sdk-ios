import SwiftUI
import WebKit
import CoreLocation

// MARK: - Internal WebView Implementation

#if os(iOS)
@available(iOS 16.0, *)
internal struct LegitimuzWebViewInternal: UIViewRepresentable {
    let sessionURL: URL
    let configuration: LegitimuzConfiguration
    let eventHandlers: LegitimuzEventHandlers
    
    typealias UIViewType = WKWebView
    
    @MainActor
    func makeCoordinator() -> Coordinator {
        Coordinator(configuration: configuration, eventHandlers: eventHandlers)
    }
    
    @MainActor
    func makeUIView(context: Context) -> WKWebView {
        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.allowsInlineMediaPlayback = true
        webViewConfiguration.mediaTypesRequiringUserActionForPlayback = []
        webViewConfiguration.allowsPictureInPictureMediaPlayback = false
        webViewConfiguration.preferences.javaScriptEnabled = true
        
        // Setup JavaScript message handlers
        let contentController = WKUserContentController()
        contentController.add(context.coordinator.messageHandler, name: "onSuccess")
        contentController.add(context.coordinator.messageHandler, name: "onError")
        contentController.add(context.coordinator.messageHandler, name: "legitimuzEvent")
        
        if configuration.enableDebugLogging {
            contentController.add(context.coordinator.messageHandler, name: "consoleLog")
        }
        
        webViewConfiguration.userContentController = contentController
        
        // Inject console logging script if enabled
        if configuration.enableDebugLogging {
            contentController.addUserScript(createConsoleLoggingScript())
        }
        
        // Inject event handling script
        contentController.addUserScript(createEventHandlingScript())
        
        // Create WebView
        let webView = WKWebView(frame: .zero, configuration: webViewConfiguration)
        webView.uiDelegate = context.coordinator
        webView.navigationDelegate = context.coordinator
        
        // Enable inspection if requested and available
        if configuration.enableInspection {
            if #available(iOS 16.4, *) {
                webView.isInspectable = true
            }
        }
        
        // Load the session URL
        let request = URLRequest(url: sessionURL)
        webView.load(request)
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    // MARK: - JavaScript Injection
    
    @MainActor
    private func createConsoleLoggingScript() -> WKUserScript {
        let source = """
        (function() {
            function captureLog(type, originalFunc) {
                return function() {
                    // Call the original console function
                    originalFunc.apply(console, arguments);
                    
                    // Convert all arguments to strings
                    const args = Array.from(arguments).map(arg => {
                        if (typeof arg === 'object') {
                            try {
                                return JSON.stringify(arg);
                            } catch (e) {
                                return String(arg);
                            }
                        }
                        return String(arg);
                    });
                    
                    // Send to native code
                    window.webkit.messageHandlers.consoleLog.postMessage({
                        type: type,
                        content: args.join(' ')
                    });
                };
            }
            
            // Capture all console methods
            console.log = captureLog('log', console.log);
            console.error = captureLog('error', console.error);
            console.warn = captureLog('warn', console.warn);
            console.info = captureLog('info', console.info);
            console.debug = captureLog('debug', console.debug);
            
            // Capture uncaught errors
            window.addEventListener('error', function(event) {
                window.webkit.messageHandlers.consoleLog.postMessage({
                    type: 'error',
                    content: 'UNCAUGHT ERROR: ' + event.message + ' at ' + event.filename + ':' + event.lineno
                });
            });
            
            // Capture promise rejections
            window.addEventListener('unhandledrejection', function(event) {
                let reason = event.reason ? event.reason.message || String(event.reason) : 'Unknown Promise Error';
                window.webkit.messageHandlers.consoleLog.postMessage({
                    type: 'error',
                    content: 'UNHANDLED PROMISE: ' + reason
                });
            });
        })();
        """
        
        return WKUserScript(
            source: source,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
    }
    
    @MainActor
    private func createEventHandlingScript() -> WKUserScript {
        let source = """
        // Listen for Legitimuz events via postMessage
        window.addEventListener('message', function(event) {
            if (event.data && typeof event.data === 'object' && event.data.name) {
                window.webkit.messageHandlers.legitimuzEvent.postMessage(event.data);
            }
        });
        
        // Helper functions for manual event triggering
        window.notifySuccessToNative = function(eventName) {
            window.webkit.messageHandlers.onSuccess.postMessage(eventName);
        };
        
        window.notifyErrorToNative = function(eventName) {
            window.webkit.messageHandlers.onError.postMessage(eventName);
        };
        """
        
        return WKUserScript(
            source: source,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
    }
}

// MARK: - Coordinator

@available(iOS 16.0, *)
extension LegitimuzWebViewInternal {
    @MainActor
    class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate, CLLocationManagerDelegate {
        private let configuration: LegitimuzConfiguration
        private let eventHandlers: LegitimuzEventHandlers
        let messageHandler: LegitimuzMessageHandler
        private let locationManager = CLLocationManager()
        
        init(configuration: LegitimuzConfiguration, eventHandlers: LegitimuzEventHandlers) {
            self.configuration = configuration
            self.eventHandlers = eventHandlers
            self.messageHandler = LegitimuzMessageHandler(eventHandlers: eventHandlers)
            
            super.init()
            
            // Setup location manager
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
        }
        
        // MARK: - WKUIDelegate
        
        @available(iOS 15.0, *)
        func webView(_ webView: WKWebView,
                     requestMediaCapturePermissionFor origin: WKSecurityOrigin,
                     initiatedByFrame frame: WKFrameInfo,
                     type: WKMediaCaptureType,
                     decisionHandler: @escaping (WKPermissionDecision) -> Void) {
            print("[LegitimuzSDK] Camera permission granted automatically")
            decisionHandler(.grant)
        }
        
        func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            if configuration.enableDebugLogging {
                print("[LegitimuzSDK] JS Alert: \(message)")
                eventHandlers.onLog?(message, .info)
            }
            completionHandler()
        }
        
        func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
            if configuration.enableDebugLogging {
                print("[LegitimuzSDK] JS Confirm: \(message)")
                eventHandlers.onLog?(message, .info)
            }
            completionHandler(true)
        }
        
        // MARK: - WKNavigationDelegate
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if configuration.enableDebugLogging {
                print("[LegitimuzSDK] Page loaded: \(webView.url?.absoluteString ?? "")")
            }
            eventHandlers.onSuccess?("page_loaded")
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            if configuration.enableDebugLogging {
                print("[LegitimuzSDK] Navigation failed: \(error.localizedDescription)")
            }
            eventHandlers.onError?("navigation_failed")
        }
        
        func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
#else
// Provide a stub for non-iOS platforms
@available(iOS 16.0, *)
internal struct LegitimuzWebViewInternal: View {
    let sessionURL: URL
    let configuration: LegitimuzConfiguration
    let eventHandlers: LegitimuzEventHandlers
    
    var body: some View {
        Text("LegitimuzSDK is only available on iOS")
            .foregroundColor(.red)
    }
}
#endif 