//
//  SceneDelegate.swift
//  VoalaAPPClip
//
//  Created by Amr Moussa on 25/10/2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        if let userActivity = connectionOptions.userActivities.first,
           userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let incomingURL = userActivity.webpageURL,
           let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true),let params = components.queryItems{
            print("AppClip invocation url is : \(incomingURL)")
            let ringID = params.first(where: { $0.name == "id" } )?.value
            NetworkManager.shared.setRingID(ringID: ringID)
        }else{
            NetworkManager.shared.setRingID(ringID: "72")
        }
        
        // log url
        
        guard let _ = (scene as? UIWindowScene) else { return }
        // Get URL components from the incoming user activity.
        
        
        
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let incomingURL = userActivity.webpageURL,
           let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true),let params = components.queryItems{
            print("AppClip invocation url is : \(incomingURL)")
            let ringID = params.first(where: { $0.name == "id" } )?.value
            NetworkManager.shared.setRingID(ringID: ringID)
        }else{
            NetworkManager.shared.setRingID(ringID: "72")
        }
        NotificationCenter.default.post(name: .ringUpdated, object: nil)
    }
    
    
}

