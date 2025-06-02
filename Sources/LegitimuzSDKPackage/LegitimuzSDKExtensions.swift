import Foundation
import SwiftUI

// MARK: - Convenience Extensions

@available(iOS 16.0, *)
extension LegitimuzSDK {
    
    /// Verify document using standard KYC flow (equivalent to verifyDocument in JS SDK)
    /// - Parameters:
    ///   - cpf: CPF number for verification
    ///   - referenceId: Optional reference ID for tracking
    ///   - action: Optional action context
    public func verifyDocument(cpf: String, referenceId: String? = nil, action: LegitimuzAction? = nil) {
        let parameters = LegitimuzVerificationParameters(
            cpf: cpf,
            referenceId: referenceId,
            action: action,
            verificationType: .kyc
        )
        startVerification(with: parameters)
    }
    
    /// Open SOW (Source of Wealth) verification flow (equivalent to openVerifySOWFlow in JS SDK)
    /// - Parameters:
    ///   - cpf: CPF number for verification
    ///   - referenceId: Optional reference ID for tracking
    ///   - action: Optional action context
    public func openVerifySOWFlow(cpf: String, referenceId: String? = nil, action: LegitimuzAction? = nil) {
        let parameters = LegitimuzVerificationParameters(
            cpf: cpf,
            referenceId: referenceId,
            action: action,
            verificationType: .sow
        )
        startVerification(with: parameters)
    }
    
    /// Start face indexing/liveness verification (equivalent to startFaceIndex in JS SDK)
    /// - Parameters:
    ///   - cpf: CPF number for verification
    ///   - referenceId: Optional reference ID for tracking
    ///   - action: Optional action context
    public func startFaceIndex(cpf: String, referenceId: String? = nil, action: LegitimuzAction? = nil) {
        let parameters = LegitimuzVerificationParameters(
            cpf: cpf,
            referenceId: referenceId,
            action: action,
            verificationType: .faceIndex
        )
        startVerification(with: parameters)
    }
}

// MARK: - SwiftUI Convenience Views

@available(iOS 16.0, *)
extension LegitimuzWebView {
    
    /// Create a WebView for standard KYC verification
    /// - Parameters:
    ///   - configuration: SDK configuration
    ///   - cpf: CPF number for verification
    ///   - referenceId: Optional reference ID for tracking
    ///   - action: Optional action context
    ///   - eventHandlers: Event handling closures
    public static func forKYCVerification(
        configuration: LegitimuzConfiguration,
        cpf: String,
        referenceId: String? = nil,
        action: LegitimuzAction? = nil,
        eventHandlers: LegitimuzEventHandlers
    ) -> LegitimuzWebView {
        let parameters = LegitimuzVerificationParameters(
            cpf: cpf,
            referenceId: referenceId,
            action: action,
            verificationType: .kyc
        )
        return LegitimuzWebView(
            configuration: configuration,
            parameters: parameters,
            eventHandlers: eventHandlers
        )
    }
    
    /// Create a WebView for SOW (Source of Wealth) verification
    /// - Parameters:
    ///   - configuration: SDK configuration
    ///   - cpf: CPF number for verification
    ///   - referenceId: Optional reference ID for tracking
    ///   - action: Optional action context
    ///   - eventHandlers: Event handling closures
    public static func forSOWVerification(
        configuration: LegitimuzConfiguration,
        cpf: String,
        referenceId: String? = nil,
        action: LegitimuzAction? = nil,
        eventHandlers: LegitimuzEventHandlers
    ) -> LegitimuzWebView {
        let parameters = LegitimuzVerificationParameters(
            cpf: cpf,
            referenceId: referenceId,
            action: action,
            verificationType: .sow
        )
        return LegitimuzWebView(
            configuration: configuration,
            parameters: parameters,
            eventHandlers: eventHandlers
        )
    }
    
    /// Create a WebView for face indexing/liveness verification
    /// - Parameters:
    ///   - configuration: SDK configuration
    ///   - cpf: CPF number for verification
    ///   - referenceId: Optional reference ID for tracking
    ///   - action: Optional action context
    ///   - eventHandlers: Event handling closures
    public static func forFaceIndexVerification(
        configuration: LegitimuzConfiguration,
        cpf: String,
        referenceId: String? = nil,
        action: LegitimuzAction? = nil,
        eventHandlers: LegitimuzEventHandlers
    ) -> LegitimuzWebView {
        let parameters = LegitimuzVerificationParameters(
            cpf: cpf,
            referenceId: referenceId,
            action: action,
            verificationType: .faceIndex
        )
        return LegitimuzWebView(
            configuration: configuration,
            parameters: parameters,
            eventHandlers: eventHandlers
        )
    }
}

// MARK: - CPF Validation

extension LegitimuzSDK {
    
    /// Validate CPF number (equivalent to checkCPF in JS SDK)
    /// - Parameter cpf: CPF string to validate
    /// - Returns: true if CPF is valid, false otherwise
    public static func validateCPF(_ cpf: String) -> Bool {
        let cpfOnlyNumber = cpf.replacingOccurrences(of: #"[^\d]"#, with: "", options: .regularExpression)
        
        // Allow test CPF
        if cpfOnlyNumber == "55555555555" {
            return true
        }
        
        if cpfOnlyNumber.isEmpty { return false }
        
        // Eliminate known invalid CPFs
        let invalidCPFs = [
            "00000000000", "11111111111", "22222222222", "33333333333", "44444444444",
            "66666666666", "77777777777", "88888888888", "99999999999"
        ]
        
        if cpfOnlyNumber.count != 11 || invalidCPFs.contains(cpfOnlyNumber) {
            return false
        }
        
        // Validate first digit
        var add = 0
        for i in 0..<9 {
            let digit = Int(String(cpfOnlyNumber[cpfOnlyNumber.index(cpfOnlyNumber.startIndex, offsetBy: i)]))!
            add += digit * (10 - i)
        }
        var rev = 11 - (add % 11)
        if rev == 10 || rev == 11 { rev = 0 }
        let firstDigit = Int(String(cpfOnlyNumber[cpfOnlyNumber.index(cpfOnlyNumber.startIndex, offsetBy: 9)]))!
        if rev != firstDigit { return false }
        
        // Validate second digit
        add = 0
        for i in 0..<10 {
            let digit = Int(String(cpfOnlyNumber[cpfOnlyNumber.index(cpfOnlyNumber.startIndex, offsetBy: i)]))!
            add += digit * (11 - i)
        }
        rev = 11 - (add % 11)
        if rev == 10 || rev == 11 { rev = 0 }
        let secondDigit = Int(String(cpfOnlyNumber[cpfOnlyNumber.index(cpfOnlyNumber.startIndex, offsetBy: 10)]))!
        
        return rev == secondDigit
    }
    
    /// Clean CPF string to only numbers
    /// - Parameter cpf: CPF string to clean
    /// - Returns: CPF with only numbers
    public static func cleanCPF(_ cpf: String) -> String {
        return cpf.replacingOccurrences(of: #"[^\d]"#, with: "", options: .regularExpression)
    }
} 