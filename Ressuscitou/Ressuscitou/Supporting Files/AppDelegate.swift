//
//  AppDelegate.swift
//  Ressuscitou
//
//  Created by Tiago Maia Lopes on 13/02/19.
//  Copyright © 2019 Tiago Maia Lopes. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: Properties

    var window: UIWindow?

    /// The data controller holding the core data stack.
    var dataController: DataController!

    // MARK: Life cycle

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
        ) -> Bool {
        dataController = DataController(modelName: "Ressuscitou")

        guard let splashController = window?.rootViewController as? SplashViewController else {
            preconditionFailure("The first controller should be the splash screen.")
        }
        splashController.dataController = dataController
        splashController.songsService = SongsService(dataController: dataController, songsStore: SongsMOStore())

        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        try? dataController.save()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        try? dataController.save()
    }
}
