//
//  BarcodeScannerApp.swift
//  BarcodeScanner
//
//  Created by Егор Ершов on 31.10.2025.
//

import SwiftUI
import CoreData

@main
struct BarcodeScannerApp: App {
    let persistence = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ScannerView()
            }
            .environment(\.managedObjectContext, persistence.container.viewContext)
        }
    }
}
