//
//  AppDelegate.swift
//  NotesClone
//
//  Created by Selin Kayar on 7.07.24.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        CoreDataManager.shared.load()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        saveAllChanges()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        saveAllChanges()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        saveAllChanges()
    }
    
    private func saveAllChanges() {
        NotificationCenter.default.post(name: .appWillSaveData, object: nil)
    }
}

extension Notification.Name {
    static let appWillSaveData = Notification.Name("appWillSaveData")
}
