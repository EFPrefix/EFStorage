//
//  ViewController.swift
//  Cocoapods
//
//  Created by ApolloZhu on 2019/8/19.
//  Copyright © 2019 EFPrefix. All rights reserved.
//

import UIKit
import EFStorage

extension UIImage: YYCacheStorable { }

class ViewController: UIViewController {
    @EFStorageYYCache(forKey: "image", defaultsTo: UIImage(systemName: "hare") ?? UIImage())
    var image: UIImage
    
    let nsString = EFStorageUserDefaultsRef<NSString>.forKey("hmm")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        nsString.content = "WOW"
        assert(nsString.string == "WOW")
        nsString.content = nil
        assert(nsString.string == nil)
    }
}
