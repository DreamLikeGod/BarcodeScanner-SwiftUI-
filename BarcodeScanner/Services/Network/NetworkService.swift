//
//  NetworkManager.swift
//  BarcodeScanner
//
//  Created by Егор Ершов on 31.10.2025.
//

import Foundation

final class NetworkService {
    static let shared = NetworkService()
    private init() {}

    enum NetworkError: Error {
        case invalidURL
        case noData
        case httpError(status: Int)
    }

    func fetchProduct(barcode: String) async throws -> OFFProduct? {
        let urlString = "https://world.openfoodfacts.org/api/v0/product/\(barcode).json"
        guard let url = URL(string: urlString) else { throw NetworkError.invalidURL }
        let (data, response) = try await URLSession.shared.data(from: url)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            if http.statusCode == 404 { return nil }
            throw NetworkError.httpError(status: http.statusCode)
        }
        let decoded = try JSONDecoder().decode(OFFResponse.self, from: data)
        return decoded.product
    }
}
