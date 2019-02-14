//
//  DataController.swift
//  Ressuscitou
//
//  Created by Tiago Maia Lopes on 13/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import CoreData

/// Object in charge of initializing and handling the core data stack.
class DataController: DataControllerProtocol {

    // MARK: Properties

    /// The container holding the core data stack.
    let dataContainer: NSPersistentContainer

    var viewContext: NSManagedObjectContext!

    // MARK: Initializers

    required init(modelName: String) {
        dataContainer = NSPersistentContainer(name: modelName)
    }

    // MARK: Imperatives

    func load(completionHandler handler: @escaping (NSPersistentStoreDescription?, Error?) -> Void) {
        dataContainer.loadPersistentStores { description, error in
            if error == nil {
                self.viewContext = self.dataContainer.viewContext
            }

            handler(description, error)
        }
    }

    func save() throws {
        if viewContext.hasChanges {
            try viewContext.save()
        }
    }
}
