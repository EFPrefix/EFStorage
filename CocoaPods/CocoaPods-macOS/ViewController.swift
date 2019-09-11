//
//  ViewController.swift
//  CocoaPods-macOS
//
//  Created by ApolloZhu on 2019/8/23.
//  Copyright © 2019 EFPrefix. MIT License.
//

import Cocoa
import EFStorage
import KeychainAccess

extension Bool: KeychainAccessStorable {
    public func asKeychainStorable() -> KeychainAccessStorable! {
        return "\(self)"
    }
    public static func fromKeychain(_ keychain: Keychain, forKey key: String) -> Bool? {
        return String.fromKeychain(keychain, forKey: key).map {
            $0 == "true"
        }
    }
}

class ViewController: NSViewController {
    
    @EFStorageKeychainAccess(forKey: "newUser", defaultsTo: true)
    var isNewUser: Bool
    
    @EFStorageUserDefaults(forKey: "username", defaultsTo: "EFS")
    var username: String
    
    @EFStorageUserDefaults(forKey: "a", defaultsTo: [])
    var array: [String]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("\(username) is \(isNewUser ? "new" : "old") user")
        isNewUser = false
    }
}

