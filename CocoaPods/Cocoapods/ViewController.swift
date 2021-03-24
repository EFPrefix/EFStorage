//
//  ViewController.swift
//  Cocoapods
//
//  Created by ApolloZhu on 2019/8/19.
//  Copyright © 2019 EFPrefix. MIT License.
//

import UIKit
import EFStorage
import KeychainAccess
import YYCache

// MARK: - Replace default container

extension UserDefaults {
    private static let forAppGroup = UserDefaults(
        suiteName: kSecAttrAccessGroup as String
    )
    
    @_dynamicReplacement(for: makeDefault())
    class func makeDefaultForGroup() -> Self {
        _efStorageLog("SWAP: \(forAppGroup?.description ?? "FAILED")")
        return (forAppGroup as? Self) ?? makeDefault()
    }
}

// MARK: - Make custom types storable in some EFStorage

extension UIImage: YYCacheStorable { } // Auto synthesized implmentation for NSCoding

extension Double: KeychainAccessStorable {
    public func asKeychainAccessStorable() -> Result<AsIsKeychainAccessStorable, Error> {
        return "\(self)".asKeychainAccessStorable()
    }
    public static func fromKeychain(_ keychain: Keychain, forKey key: String) -> Double? {
        return String.fromKeychain(keychain, forKey: key).flatMap(Double.init)
    }
}

extension EFStorageKeychainAccessRef {
    @_dynamicReplacement(for: onConversionFailure(for:dueTo:))
    func doNothingOnConversionFailure(for content: Content, dueTo error: Error) {
        print("\(content) -> \(error.localizedDescription)")
    }
}

// MARK: Allow optional default value

extension Optional: AsIsUserDefaultsStorable where Wrapped: AsIsUserDefaultsStorable { }

extension Optional: UserDefaultsStorable where Wrapped: UserDefaultsStorable {
    public func asUserDefaultsStorable() -> Result<AsIsUserDefaultsStorable, Error> {
        return map { $0.asUserDefaultsStorable() }
            ?? .success(nil as Optional<Int>)
        //                              ^
        // It can be any type `Optional<T> where T: AsIsUserDefaultsStorable`
    }
    
    public static func fromUserDefaults(_ userDefaults: UserDefaults, forKey key: String) -> Optional<Wrapped>? {
        return Wrapped.fromUserDefaults(userDefaults, forKey: key)
    }
}

// MARK: - Property wrapper usage

class ViewController: UIViewController {
    @EFStorageYYCache(forKey: "image")
    var avatar: UIImage = UIImage(systemName: "hare") ?? UIImage() {
        didSet {
            avatarView.image = avatar
        }
    }
    
    @EFStorageUserDefaults(forKey: "username")
    var username: String? = nil
    
    @EFStorageKeychainAccess(forKey: "isNewUser")
    var isNewUser: Double = 0
    
    @EFStorageUserDefaults(forKey: "legacyNames")
    var usedNames: [String] = []
    
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
        print(usedNames)
        
        avatarView.image = avatar
        if isNewUser == .infinity {
            label.text = "Welcome back,"
        }
        textField.text = username
        Keychain.efStorage.isNewUser = Double.infinity
        
        textField.addTarget(self, action: #selector(updateUsername),
                            for: .allEditingEvents)
        
        if let ud = UserDefaults(suiteName: "2333") {
            UserDefaults.shared = ud
        }
    }
    
    @objc private func updateUsername() {
        username = textField.text
        
        guard let text = username else { return }
        usedNames.append(text)
        
        guard let image = UIImage(systemName: text) else { return }
        avatar = image
    }
    
    @IBAction func sync() {
        UserDefaults.makeDefault().synchronize()
    }
    
    @IBAction func cleanUp() {
        try? Keychain.makeDefault().removeAll()
        YYCache.makeDefault()?.removeAllObjects()
        let defaults = UserDefaults.makeDefault()
        defaults.dictionaryRepresentation().keys
            .forEach { defaults.removeObject(forKey: $0) }
    }
}
