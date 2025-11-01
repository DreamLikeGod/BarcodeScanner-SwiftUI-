//
//  ScanCodeUseCase.swift
//  BarcodeScanner
//
//  Created by Егор Ершов on 31.10.2025.
//

import Foundation
import AVFoundation

final class ScanCodeUseCase {
    private let repo = CodeRepository()

    func process(code: String, type: AVMetadataObject.ObjectType) async throws {
        if let existing = try repo.exists(code: code) {
            existing.date = Date()
            try repo.save(context: existing)
            return
        }
        
        if type == .qr {
            try repo.save(code: code, type: "QR", content: code)
            return
        } else {
            let product = try await NetworkService.shared.fetchProduct(barcode: code)
            try repo.save(
                code: code,
                type: "Barcode",
                title: product?.product_name,
                brand: product?.brands,
                content: product?.ingredients_text,
                nutriScore: product?.nutriscore_grade
            )
        }
    }
}
