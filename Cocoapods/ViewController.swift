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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(nsString.content ?? "NOTHING")
        nsString.content = nil
        print(nsString.content ?? "NOTHING")
        nsString.content = "WOW"
        print(nsString.content ?? "NOTHING")
        print(mobile.content ?? "NO PHONE NUMBER")
    }
}
