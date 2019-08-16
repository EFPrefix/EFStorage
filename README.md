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
