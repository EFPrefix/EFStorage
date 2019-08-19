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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(mobile.content ?? "NO PHONE NUMBER")
    }
}
