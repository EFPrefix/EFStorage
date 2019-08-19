# EFStorage

An easy way to store anything anywhere -- UserDefaults, KeychainAccess, YYCache, you name it!

```swift
@EFStorageUserDefaults(forKey: "username", defaultsTo: User.Name.random())
var username: String

// Or, if you don't like constraints,
UserDefaults.efStorage.username = "OwO"
```

See [Wiki](https://github.com/EFPrefix/EFStorage/wiki) for details on how to use `EFStorage`.
