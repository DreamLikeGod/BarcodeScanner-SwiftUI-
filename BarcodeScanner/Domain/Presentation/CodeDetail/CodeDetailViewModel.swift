//
//  CodeDetailViewModel.swift
//  BarcodeScanner
//
//  Created by Егор Ершов on 31.10.2025.
//

import Foundation
import Combine

@MainActor
final class CodeDetailViewModel: ObservableObject {
    @Published var scanned: ScannedCode
    @Published var isEditingTitle = false
    @Published var editedTitle: String = ""
    
    private let repository = CodeRepository()
    
    init(scanned: ScannedCode) {
        self.scanned = scanned
        self.editedTitle = scanned.title ?? ""
    }
    
    func saveTitle() {
        do {
            try repository.updateTitle(scanned, title: editedTitle)
            scanned.title = editedTitle.isEmpty ? nil : editedTitle
            isEditingTitle = false
        } catch {
            print("Failed to save title: \(error)")
        }
    }
    
    func cancelEditing() {
        editedTitle = scanned.title ?? ""
        isEditingTitle = false
    }
    
    func shareText() -> String {
        var s = "Code: \(self.scanned.code)\nType: \(self.scanned.type)\n"
        if let t = self.scanned.title { s += "Title: \(t)\n" }
        if let b = self.scanned.brand { s += "Brand: \(b)\n" }
        if let c = self.scanned.content { s += "Content: \(c)\n" }
        if let n = self.scanned.nutriScore { s += "NutriScore: \(n)\n" }
        return s
    }
}
