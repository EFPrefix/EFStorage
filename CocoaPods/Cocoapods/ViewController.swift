//
//  ViewController.swift
//  Cocoapods
//
//  Created by ApolloZhu on 2019/8/19.
//  Copyright © 2019 EFPrefix. All rights reserved.
//

import UIKit
import EFStorage
import KeychainAccess

extension UIImage: YYCacheStorable { }

extension Bool: KeychainAccessStorable {
    public func asKeychainStorable() -> KeychainAccessStorable! {
        return "\(self)".asKeychainStorable()
    }
    public static func fromKeychain(_ keychain: Keychain, forKey key: String) -> Bool? {
        return String.fromKeychain(keychain, forKey: key).map {
            $0 == "true"
        }
    }
}

extension Optional: UserDefaultsStorable where Wrapped: UserDefaultsStorable {
    public static func fromUserDefaults(_ userDefaults: UserDefaults, forKey key: String) -> Optional<Wrapped>? {
        return Wrapped.fromUserDefaults(userDefaults, forKey: key)
    }
    
    public func asUserDefaultsStorable() -> UserDefaultsStorable! {
        return self.flatMap { $0.asUserDefaultsStorable() }
    }
}

class ViewController: UIViewController {
    @EFStorageYYCache(forKey: "image", defaultsTo: UIImage(systemName: "hare") ?? UIImage())
    var avatar: UIImage {
        didSet {
            avatarView.image = avatar
        }
    }
    
    @EFStorageUserDefaults(forKey: "username", defaultsTo: nil)
    var username: String?
    
    @EFStorageKeychainAccess(forKey: "isNewUser", defaultsTo: true)
    var isNewUser: Bool
    
    @EFStorageUserDefaults(forKey: "legacyNames", defaultsTo: [])
    var usedNames: [String]
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    let nsString = EFStorageUserDefaultsRef<NSString>.forKey("hmm")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        nsString.content = "WOW"
        assert(nsString.string == "WOW")
        nsString.content = nil
        assert(nsString.string == nil)
        
        avatarView.image = avatar
        if !isNewUser {
            label.text = "Welcome back,"
        }
        textField.text = username
        isNewUser = false
        
        textField.addTarget(self, action: #selector(updateUsername),
                            for: .allEditingEvents)
    }
    
    @objc private func updateUsername() {
        username = textField.text
        
        guard let text = username else { return }
        usedNames.append(text)
        
        guard let image = UIImage(systemName: text) else { return }
        avatar = image
    }
}
