//
//  ScannerViewModel.swift
//  BarcodeScanner
//
//  Created by Егор Ершов on 31.10.2025.
//

import Combine
import Foundation
import AVFoundation
import UIKit
import AudioToolbox

@MainActor
final class ScannerViewModel: ObservableObject {
    @Published var isTorchOn: Bool = false
    @Published var alertMessage: String?
    @Published var cameraDenied: Bool = false
    @Published var isScanningFeedbackVisible: Bool = false
    @Published var isScanningActive: Bool = false

    private let useCase = ScanCodeUseCase()
    private var lastScanned: String?

    func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            cameraDenied = false
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                Task { @MainActor in self.cameraDenied = !granted }
            }
        default:
            cameraDenied = true
        }
    }

    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    func handleScanned(code: String, type: AVMetadataObject.ObjectType) {
        guard isScanningActive else { return }
        isScanningActive = false

        Task {
            do {
                try await useCase.process(code: code, type: type)
                showScanFeedback()
            } catch {
                alertMessage = error.localizedDescription
            }
        }
    }
    
    private func showScanFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        AudioServicesPlaySystemSound(1057)
        isScanningFeedbackVisible = true

        Task {
            try? await Task.sleep(nanoseconds: 800_000_000)
            await MainActor.run { self.isScanningFeedbackVisible = false }
        }
    }
}
