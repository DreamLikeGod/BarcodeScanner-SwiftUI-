//
//  CameraScannerView.swift
//  BarcodeScanner
//
//  Created by Егор Ершов on 31.10.2025.
//

import SwiftUI
import AVFoundation
import UIKit

struct CameraScannerView: UIViewRepresentable {
    @Binding var torchOn: Bool
    var onDetect: (String, AVMetadataObject.ObjectType) -> Void
    var onDetectNormalizedRect: (CGRect, AVMetadataObject.ObjectType) -> Void
    var onNoDetection: (() -> Void)? = nil

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> ScannerPreviewView {
        let view = ScannerPreviewView()
        view.delegate = context.coordinator
        view.normalizedFrameCallback = { rect, type in
            DispatchQueue.main.async {
                self.onDetectNormalizedRect(rect, type)
            }
        }
        view.noDetectionCallback = {
            DispatchQueue.main.async {
                self.onNoDetection?()
            }
        }
        Task { @MainActor in
            view.startSession()
        }
        return view
    }

    func updateUIView(_ uiView: ScannerPreviewView, context: Context) {
        uiView.setTorch(on: torchOn)
    }

    static func dismantleUIView(_ uiView: ScannerPreviewView, coordinator: Coordinator) {
        uiView.stopSession()
    }

    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        let parent: CameraScannerView
        init(_ parent: CameraScannerView) { self.parent = parent }

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            guard let first = metadataObjects.compactMap({ $0 as? AVMetadataMachineReadableCodeObject }).first,
                  let str = first.stringValue else { return }
            parent.onDetect(str, first.type)
        }
    }
}

// MARK: - ScannerPreviewView (UIView)
final class ScannerPreviewView: UIView {
    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    weak var delegate: AVCaptureMetadataOutputObjectsDelegate?
    var normalizedFrameCallback: ((CGRect, AVMetadataObject.ObjectType) -> Void)?
    var noDetectionCallback: (() -> Void)?
    private var detectionTimer: Timer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func startSession() {
        guard !session.isRunning else { return }
        
        Task { [weak self] in
            await self?.configureSession()
        }
    }

    func stopSession() {
        detectionTimer?.invalidate()
        session.stopRunning()
    }

    func setTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            device.unlockForConfiguration()
        } catch { }
    }

    private func configureSession() async {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        if status == .notDetermined {
            _ = await withCheckedContinuation { cont in
                AVCaptureDevice.requestAccess(for: .video) { _ in cont.resume() }
            }
        }
        
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else { return }

        await MainActor.run { [weak self] in
            guard let self = self else { return }
            self.session.beginConfiguration()
            self.session.sessionPreset = .high

            guard let device = AVCaptureDevice.default(for: .video),
                  let input = try? AVCaptureDeviceInput(device: device) else { 
                self.session.commitConfiguration()
                return 
            }
            if self.session.canAddInput(input) { 
                self.session.addInput(input) 
            }

            let output = AVCaptureMetadataOutput()
            if self.session.canAddOutput(output) {
                self.session.addOutput(output)
                output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                output.metadataObjectTypes = output.availableMetadataObjectTypes
            }

            self.session.commitConfiguration()

            let layer = AVCaptureVideoPreviewLayer(session: self.session)
            layer.videoGravity = .resizeAspectFill
            layer.frame = self.bounds
            layer.needsDisplayOnBoundsChange = true
            self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
            self.layer.addSublayer(layer)
            self.previewLayer = layer
            self.session.startRunning()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }
}

extension ScannerPreviewView: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        detectionTimer?.invalidate()
        
        let codeObjects = metadataObjects.compactMap { $0 as? AVMetadataMachineReadableCodeObject }
        
        guard let first = codeObjects.first,
              let layer = previewLayer else {
            if !metadataObjects.isEmpty {
                return
            }
            detectionTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: false) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.noDetectionCallback?()
                }
            }
            return
        }

        if let transformed = layer.transformedMetadataObject(for: first) {
            let b = transformed.bounds
            let previewBounds = layer.bounds
            if previewBounds.width > 0 && previewBounds.height > 0 {
                let normalized = CGRect(x: b.origin.x / previewBounds.width,
                                        y: b.origin.y / previewBounds.height,
                                        width: b.width / previewBounds.width,
                                        height: b.height / previewBounds.height)
                normalizedFrameCallback?(normalized, first.type)
            }
        }

        delegate?.metadataOutput!(output, didOutput: metadataObjects, from: connection)
    }
}

