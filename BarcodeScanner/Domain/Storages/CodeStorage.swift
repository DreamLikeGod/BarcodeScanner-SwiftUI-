//
//  CodeStorage.swift
//  BarcodeScanner
//
//  Created by Егор Ершов on 31.10.2025.
//

import Foundation

final class CodeRepository {
    private let core = CoreDataManager.shared

    func exists(code: String) throws -> ScannedCode? {
        return try core.exists(code: code)
    }

    func save(code: String, type: String, title: String? = nil, brand: String? = nil, content: String? = nil, nutriScore: String? = nil) throws {
        try core.saveScanned(code: code, type: type, title: title, brand: brand, content: content, nutriScore: nutriScore)
    }

    func save(context: ScannedCode) throws {
        try core.update(context)
    }

    func updateTitle(_ code: ScannedCode, title: String) throws {
        try core.updateTitle(code, title: title)
    }

    func all() throws -> [ScannedCode] {
        try core.fetchAll()
    }
}
