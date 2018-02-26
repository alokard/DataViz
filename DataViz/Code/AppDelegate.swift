//
//  AppDelegate.swift
//  DataViz
//
//  Created by Eugene Tulusha on 2/19/18.
//  Copyright © 2018 Eugene Tulusha. All rights reserved.
//

import UIKit
import CoreData
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var applicationController: ApplicationController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        guard NSClassFromString("XCTest") == nil else { return false } // Prevents ApplicationController from runing
        guard let navigation = window?.rootViewController as? UINavigationController else { return false }
        applicationController = ApplicationController(navigation: navigation)
        applicationController?.setupWithLaunchOptions(launchOptions)

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        applicationController?.didBecomeActive()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        applicationController?.willResignActive()
    }
}

