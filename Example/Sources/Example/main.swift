import EFStorageUserDefaults
import Foundation

print(UserDefaults.standard)

UserDefaults.standard.removeObject(forKey: "catSound")

struct UD {
    @EFStorageUserDefaults(forKey: "catSound", defaultsTo: "nyan", persistDefaultContent: true)
    static var meow: String
}

print(UD.meow)

let catSound: EFStorageUserDefaultsRef<String> = UserDefaults.efStorage.catSound

print(catSound.content!)

catSound.content = "meow"

let explicitReference = EFStorageUserDefaultsRef<String>.forKey("catSound")

print(explicitReference.content!)
print(UserDefaults.standard.string(forKey: "catSound")!)
UserDefaults.efStorage.catSound = "喵"
print(UserDefaults.standard.efStorage.catSound! as String)
