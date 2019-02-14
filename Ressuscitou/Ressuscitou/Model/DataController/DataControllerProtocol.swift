//
//  DataControllerProtocol.swift
//  Ressuscitou
//
//  Created by Tiago Maia Lopes on 13/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import Foundation
import CoreData

/// Object in charge of initializing and handling the core data stack.
protocol DataControllerProtocol {

    // MARK: Properties

    /// The view context associated to the core data stack.
    var viewContext: NSManagedObjectContext! { get }

    // MARK: Initializers

    init(modelName: String)

    // MARK: Imperatives

    /// Loads the core data stack.
    /// - Parameter completionHandler: the handler called after the load finishes.
    func load(completionHandler handler: @escaping (NSPersistentStoreDescription?, Error?) -> Void)

    /// Saves the view context, if it has any changes.
    func save() throws
}
