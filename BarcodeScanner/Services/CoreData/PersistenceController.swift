//
//  PersistenceController.swift
//  BarcodeScanner
//
//  Created by Егор Ершов on 31.10.2025.
//

import Foundation
import CoreData

final class PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer

    private init(inMemory: Bool = false) {
        // Programmatic model
        let model = NSManagedObjectModel()
        let entity = NSEntityDescription()
        entity.name = "ScannedCode"
        entity.managedObjectClassName = "ScannedCode"

        func attr(_ name: String, _ type: NSAttributeType, _ optional: Bool = true) -> NSAttributeDescription {
            let a = NSAttributeDescription()
            a.name = name
            a.attributeType = type
            a.isOptional = optional
            return a
        }

        entity.properties = [
            attr("id", .stringAttributeType, false),
            attr("code", .stringAttributeType, false),
            attr("type", .stringAttributeType, false),
            attr("title", .stringAttributeType, true),
            attr("brand", .stringAttributeType, true),
            attr("content", .stringAttributeType, true),
            attr("nutriScore", .stringAttributeType, true),
            attr("date", .dateAttributeType, false)
        ]

        model.entities = [entity]

        container = NSPersistentContainer(name: "BarcodeScanner", managedObjectModel: model)

        if inMemory {
            let desc = NSPersistentStoreDescription()
            desc.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [desc]
        }

        container.loadPersistentStores { (desc, error) in
            if let e = error {
                fatalError("Failed to load store: \(e)")
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}

