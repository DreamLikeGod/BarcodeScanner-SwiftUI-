//
//  CodeListViewModel.swift
//  BarcodeScanner
//
//  Created by Егор Ершов on 31.10.2025.
//

import Foundation
import CoreData
import Combine

@MainActor
final class CodeListViewModel: ObservableObject {
    @Published var items: [ScannedCode] = []
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let repository = CodeRepository()

    init() {
        NotificationCenter.default.publisher(
            for: .NSManagedObjectContextDidSave,
            object: PersistenceController.shared.container.viewContext
        )
        .sink { [weak self] _ in
            Task { @MainActor in
                self?.load()
            }
        }
        .store(in: &cancellables)
    }

    func load() {
        do {
            items = try repository.all()
        } catch {
            print(error.localizedDescription)
        }
    }

    func delete(at offsets: IndexSet) {
        for i in offsets {
            let obj = items[i]
            do {
                try CoreDataManager.shared.delete(obj)
            } catch {
                print(error.localizedDescription)
            }
        }
        load()
    }
}

