# EFStorage

## Usage

### As `@propertyWrapper`

```swift
@EFStorageUserDefaults(forKey: "someKey", defaultsTo: "Default Value")
var someValueToBeStoredInUserDefaults: String
```

### Through `@dynamicMemberLookup`

```swift
let someReference: EFStorageUserDefaultsRef<String> = UserDefaults.efStorage.someKey
```

this is equivalent to

```swift
let someReference = EFStorageUserDefaultsRef<String>.forKey("someKey")
```

and you can access the value stored in `UserDefaults.standard` by

```swift
someReference.content
```

which can be simplified as 

```swift
UserDefaults.efStorage.someKey as String?
```

and assign the content through

```swift
UserDefaults.efStorage.someKey = "OwO"
```

### Non-default Container

Should you need to use a different instance, you can do that too

```swift
@EFStorageUserDefaults(forKey: "anotherKey", defaultsTo: true, 
                       in: UserDefaults.standard, 
                       persistDefaultContent: true)
var inAnotherStorage: Bool

UserDefaults.standard.efStorage.anotherKey // either content or the reference to it

EFStorageUserDefaultsRef<Bool>.forKey("anotherKey", in: UserDefaults.standard)
```

### Supported Containers

As of now, we offer support for `UserDefaults` and `Keychain` (provided by `KeychainAccess`). 
You can combine them to form a new type of container, or to support previous keys.

```swift
@EFStorageComposition(
    EFStorageUserDefaults(forKey: "isNewUser", defaultsTo: false),
    EFStorageKeychainAccess(forKey: "isNewUser", defaultsTo: false))
var isNewUser: Bool

@AnyEFStorage(
    EFStorageKeychainAccess(forKey: "paidBefore", defaultsTo: false)
    + EFStorageUserDefaults(forKey: "paidBefore", defaultsTo: false)
    + EFStorageUserDefaults(forKey: "oldHasPaidBeforeKey", 
                            defaultsTo: true,
                            persistDefaultContent: true))
var hasPaidBefore: Bool
```

To migrate from another data type, you can use a migrator

```swift
@EFStorageComposition(
    EFStorageUserDefaults<String>(forKey: "sameKey", 
                                  defaultsTo: "Nah"),
    EFStorageMigrate(
        from: EFStorageUserDefaults<Int>(
            forKey: "sameKey", 
            defaultsTo: 1551, 
            persistDefaultContent: true),
        by: { number in String(number) }
    )
)
var mixedType: String
```
