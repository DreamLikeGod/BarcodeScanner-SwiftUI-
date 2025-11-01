//
//  Models.swift
//  BarcodeScanner
//
//  Created by Егор Ершов on 31.10.2025.
//

import Foundation

struct OFFResponse: Codable {
    let status: Int?
    let product: OFFProduct?
}

struct OFFProduct: Codable {
    let product_name: String?
    let brands: String?
    let ingredients_text: String?
    let nutriscore_grade: String?
}
