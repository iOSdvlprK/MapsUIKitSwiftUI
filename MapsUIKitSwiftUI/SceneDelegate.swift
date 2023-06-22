//
//  SceneDelegate.swift
//  MapsUIKitSwiftUI
//
//  Created by joe on 2023/06/03.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
//        window.rootViewController = MainController()
//        window.rootViewController = DirectionsController()
//        window.rootViewController = UINavigationController(rootViewController: DirectionsController())
//        window.rootViewController = PlacesController()
        /*
        let mapSearchingView = MapSearchingView()
        window.rootViewController = UIHostingController(rootView: mapSearchingView)
        window.makeKeyAndVisible()
        */
        let directionsSearchView = DirectionsSearchView()
        window.rootViewController = UIHostingController(rootView: directionsSearchView)
        window.makeKeyAndVisible()
        self.window = window
    }

}

