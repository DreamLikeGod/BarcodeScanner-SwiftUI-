//
//  Extensions.swift
//  BarcodeScanner
//
//  Created by Егор Ершов on 31.10.2025.
//

import Foundation

extension Date {
    func short() -> String {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        return f.string(from: self)
    }
}
