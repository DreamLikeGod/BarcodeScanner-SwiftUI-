//
//  ScannerView.swift
//  BarcodeScanner
//
//  Created by Егор Ершов on 31.10.2025.
//

import SwiftUI
import AVFoundation

struct ScannerView: View {
    @StateObject private var vm = ScannerViewModel()
    @State private var showHistory = false
    @State private var detectedNormalizedRect: CGRect? = nil

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geo in
                ZStack {
                    CameraScannerView(
                        torchOn: $vm.isTorchOn,
                        onDetect: vm.handleScanned,
                        onDetectNormalizedRect: { rect, _ in
                            detectedNormalizedRect = rect
                        },
                        onNoDetection: {
                            detectedNormalizedRect = nil
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.6), lineWidth: 1))
                    .padding()

                    if let norm = detectedNormalizedRect {
                        let r = CGRect(
                            x: norm.origin.x * geo.size.width,
                            y: norm.origin.y * geo.size.height,
                            width: norm.width * geo.size.width,
                            height: norm.height * geo.size.height
                        )
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.green, lineWidth: 3)
                            .frame(width: r.width, height: r.height)
                            .position(x: r.midX, y: r.midY)
                            .animation(.easeOut(duration: 0.15), value: detectedNormalizedRect)
                    }

                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: { vm.isTorchOn.toggle() }) {
                                Image(systemName: vm.isTorchOn ? "flashlight.off.fill" : "flashlight.on.fill")
                                    .padding(10)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                            }
                            .padding()
                            Spacer()
                        }
                    }

                    if vm.isScanningFeedbackVisible {
                        VStack {
                            Spacer()
                            Text("Отсканировано")
                                .padding(10)
                                .background(.ultraThinMaterial)
                                .cornerRadius(10)
                                .padding(.bottom, 36)
                        }
                        .transition(.opacity)
                    }
                }
            }
            .frame(minHeight: 320)

            Spacer()

            VStack(spacing: 16) {
                Button(action: { 
                    Task { @MainActor in
                        vm.isScanningActive = true
                    }
                }) {
                    Label("Сканировать", systemImage: "camera.viewfinder")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)

                Button(action: { showHistory = true }) {
                    Label("История", systemImage: "list.bullet")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationTitle("Сканер")
        .onAppear { vm.checkCameraPermission() }
        .sheet(isPresented: $showHistory, onDismiss: { showHistory = false }) {
            NavigationStack {
                CodeListView()
                    .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Закрыть") { showHistory = false } } }
            }
        }
        .alert("Камера недоступна", isPresented: $vm.cameraDenied) {
            Button("Настройки") { vm.openSettings() }
            Button("Отмена", role: .cancel) { vm.cameraDenied = false }
        } message: {
            Text("Разрешите доступ к камере в настройках, чтобы использовать сканер.")
        }
        .alert("Ошибка", isPresented: .constant(vm.alertMessage != nil), actions: {
            Button("OK") { vm.alertMessage = nil }
        }, message: {
            Text(vm.alertMessage ?? "")
        })
    }
}
