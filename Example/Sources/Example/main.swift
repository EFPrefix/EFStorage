import EFStorageUserDefaults

struct UD {
    @EFStorageUserDefaults(forKey: "catSound", defaultsTo: "nyan")
    static var meow: String
}

print(UD.meow)
