//
//  ViewController.swift
//  Cocoapods
//
//  Created by ApolloZhu on 2019/8/19.
//  Copyright © 2019 EFPrefix. All rights reserved.
//

import UIKit
import EFStorage

class ViewController: UIViewController {
    
    let mobile = EFStorageUserDefaultsRef<String>.forKey("mobile")
    let nsString = EFStorageUserDefaultsRef<NSString>.forKey("hmm")
    let array = EFStorageUserDefaultsRef<[String]>.forKey("array")
    let cache = EFStorageYYCacheRef<NSArray>.forKey("just test")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(nsString.string ?? "NOTHING")
        nsString.content = nil
        print(nsString.string ?? "NOTHING")
        nsString.content = "WOW"
        print(nsString.string ?? "NOTHING")
        print(mobile.content ?? "NO PHONE NUMBER")
        print(cache.content ?? "NO CACHE")
    }
}
