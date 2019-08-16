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

and assign through

```swift
UserDefaults.efStorage.someKey = "OwO"
```

Should you need to use a different instance, you can do that too

```swift
@EFStorageUserDefaults(forKey: "anotherKey", defaultsTo: true, 
                       in: UserDefaults.standard, persistDefaultContent: true)
var inAnotherStorage: Bool

UserDefaults.standard.efStorage.anotherKey // either reference or content

EFStorageUserDefaultsRef<Bool>.forKey("anotherKey", in: UserDefaults.standard)
```
