//
//  AppDelegate.swift
//  MFileManager
//
//  Created by lynx on 2021/3/8.
//  Copyright © 2021 Lynx. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow()
        window?.makeKeyAndVisible()
        
        let vc = ViewController()
        let nav = UINavigationController(rootViewController: vc)
        window?.rootViewController = nav
        
        return true
    }
    
    //用于接收分享的文件，同时需在plist文件新增Document types参数
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        var path = url.absoluteString
        if path.contains("file:///private") {
            path = path.replacingOccurrences(of: "file:///private", with: "")
        }
        let dirArray = path.components(separatedBy: "/")
        guard dirArray.count > 0 else {
            return false
        }
        let fileName = dirArray.last!
        let filePath = NSHomeDirectory().appending("/Documents/").appending(fileName)
        try? FileManager.default.copyItem(atPath: path, toPath: filePath)
        if FileManager.default.fileExists(atPath: filePath) {
            print("The file has been shared successfully.")
        } else {
            print("The file has not been added to the directory.")
        }
        return true
    }
}

