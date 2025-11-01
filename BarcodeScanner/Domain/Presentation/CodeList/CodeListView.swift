//
//  CodeListView.swift
//  BarcodeScanner
//
//  Created by Егор Ершов on 31.10.2025.
//

import SwiftUI

struct CodeListView: View {
    @StateObject private var vm = CodeListViewModel()

    var body: some View {
        Group {
            if vm.items.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "barcode.viewfinder")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary)
                    
                    Text("Нет отсканированных кодов")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Отсканируйте QR-код или штрих-код, чтобы увидеть его здесь")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(vm.items, id: \.id) { item in
                        NavigationLink(value: item) {
                            HStack(spacing: 12) {
                                Image(systemName: item.type == "Barcode" ? "barcode" : "qrcode")
                                    .font(.title2)
                                    .foregroundColor(.accentColor)
                                    .frame(width: 44, height: 44)
                                    .background(Color.accentColor.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.title ?? (item.type == "QR" ? (item.content ?? "QR-код") : "Штрих-код"))
                                        .font(.headline)
                                        .lineLimit(1)
                                    
                                    HStack(spacing: 6) {
                                        Text(item.type)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text("•")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(item.date.short())
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete(perform: vm.delete)
                }
            }
        }
        .navigationTitle("История")
        .navigationBarTitleDisplayMode(.large)
        .onAppear { vm.load() }
        .refreshable {
            vm.load()
        }
        .navigationDestination(for: ScannedCode.self) { code in
            CodeDetailView(scanned: code)
        }
    }
}
