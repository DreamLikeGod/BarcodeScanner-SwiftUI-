//
//  CoreDataManager.swift
//  BarcodeScanner
//
//  Created by Егор Ершов on 31.10.2025.
//

import Foundation
import CoreData

@objc(ScannedCode)
final class ScannedCode: NSManagedObject {
    @NSManaged var id: String
    @NSManaged var code: String
    @NSManaged var type: String
    @NSManaged var title: String?
    @NSManaged var brand: String?
    @NSManaged var content: String?
    @NSManaged var nutriScore: String?
    @NSManaged var date: Date
}

final class CoreDataManager {
    static let shared = CoreDataManager(context: PersistenceController.shared.container.viewContext)
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchAll() throws -> [ScannedCode] {
        let req = NSFetchRequest<ScannedCode>(entityName: "ScannedCode")
        req.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        return try context.fetch(req)
    }

    func exists(code: String) throws -> ScannedCode? {
        let req = NSFetchRequest<ScannedCode>(entityName: "ScannedCode")
        req.predicate = NSPredicate(format: "code == %@", code)
        req.fetchLimit = 1
        return try context.fetch(req).first
    }

    func saveScanned(code: String, type: String, title: String? = nil, brand: String? = nil, content: String? = nil, nutriScore: String? = nil) throws {
        if let existing = try exists(code: code) {
            existing.date = Date()
            try context.save()
            return
        }

        let entity = NSEntityDescription.entity(forEntityName: "ScannedCode", in: context)!
        let obj = ScannedCode(entity: entity, insertInto: context)
        obj.id = UUID().uuidString
        obj.code = code
        obj.type = type
        obj.title = title
        obj.brand = brand
        obj.content = content
        obj.nutriScore = nutriScore
        obj.date = Date()
        try context.save()
    }

    func update(_ object: ScannedCode) throws {
        try context.save()
    }

    func updateTitle(_ object: ScannedCode, title: String) throws {
        object.title = title.isEmpty ? nil : title
        try context.save()
    }

    func delete(_ object: ScannedCode) throws {
        context.delete(object)
        try context.save()
    }
}
