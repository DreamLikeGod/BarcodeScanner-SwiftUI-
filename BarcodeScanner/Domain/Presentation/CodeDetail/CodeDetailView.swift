//
//  CodeDetailView.swift
//  BarcodeScanner
//
//  Created by Егор Ершов on 31.10.2025.
//

import SwiftUI

struct CodeDetailView: View {
    @ObservedObject var vm: CodeDetailViewModel
    @State private var showShare = false

    init(scanned: ScannedCode) {
        self.vm = CodeDetailViewModel(scanned: scanned)
    }
    
    private var shareText: String {
        vm.shareText()
    }

    var body: some View {
        Form {
            Section {
                HStack(spacing: 16) {
                    Image(systemName: vm.scanned.type == "Barcode" ? "barcode" : "qrcode")
                        .font(.system(size: 40))
                        .foregroundColor(.accentColor)
                        .frame(width: 60, height: 60)
                        .background(Color.accentColor.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        if vm.isEditingTitle {
                            TextField("Название", text: $vm.editedTitle)
                                .textFieldStyle(.roundedBorder)
                                .submitLabel(.done)
                                .onSubmit {
                                    vm.saveTitle()
                                }
                        } else {
                            Text(vm.scanned.title ?? "Без названия")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        Text(vm.scanned.brand ?? "Бренд не указан")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if !vm.isEditingTitle {
                        Button(action: {
                            vm.isEditingTitle = true
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.accentColor)
                        }
                    } else {
                        HStack(spacing: 8) {
                            Button(action: {
                                vm.saveTitle()
                            }) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                            }
                            Button(action: {
                                vm.cancelEditing()
                            }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            
            Section("Информация") {
                LabeledContent("Код") {
                    Text(vm.scanned.code)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.trailing)
                }
                
                LabeledContent("Тип") {
                    Text(vm.scanned.type)
                        .foregroundColor(.secondary)
                }
                
                if let ns = vm.scanned.nutriScore {
                    LabeledContent("Nutri-Score") {
                        Text(ns.uppercased())
                            .foregroundColor(.secondary)
                            .fontWeight(.semibold)
                    }
                }
            }
            
            if let content = vm.scanned.content, !content.isEmpty {
                Section("Содержимое") {
                    Text(content)
                        .font(.body)
                }
            }
        }
        .navigationTitle("Детали")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    Task { @MainActor in
                        showShare = true
                    }
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showShare) {
            ActivityView(activityItems: [shareText])
        }
    }
}
