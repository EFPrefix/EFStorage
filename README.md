# EFStorage

An easy way to store anything anywhere -- UserDefaults, KeychainAccess, YYCache, you name it!

```swift
@EFStorageUserDefaults(forKey: "username", defaultsTo: User.Name.random())
var username: String

// Or, if you don't like constraints,
UserDefaults.efStorage.username = "OwO"
```

## Usage

* [WARNING](https://github.com/EFPrefix/EFStorage/wiki), and Table of Contents | **注意事项**
* [Adding `EFStorage` to your project](https://github.com/EFPrefix/EFStorage/wiki/Integration) | [集成 `EFStorage`](https://github.com/EFPrefix/EFStorage/wiki/集成)
  * [Swift Package Manager](https://github.com/EFPrefix/EFStorage/wiki/Integration#swift-package-manager) | [中文](https://github.com/EFPrefix/EFStorage/wiki/集成#swift-package-manager)
  * [Cocoapods](https://github.com/EFPrefix/EFStorage/wiki/Integration#cocoapods) | [中文](https://github.com/EFPrefix/EFStorage/wiki/集成#cocoapods)
* [Using `EFStorage`](https://github.com/EFPrefix/EFStorage/wiki/Usage) | [使用 `EFStorage`](https://github.com/EFPrefix/EFStorage/wiki/用法)
  * [@propertyWrapper](https://github.com/EFPrefix/EFStorage/wiki/Usage#as-propertywrapper) | [属性包装器](https://github.com/EFPrefix/EFStorage/wiki/用法#propertywrapper-属性包装器)
  * [@dynamicMemberLookup](https://github.com/EFPrefix/EFStorage/wiki/Usage#through-dynamicmemberlookup) | [动态成员查找](https://github.com/EFPrefix/EFStorage/wiki/用法#dynamicmemberlookup-动态成员查找)
  * [non-standard/default/shared storage](https://github.com/EFPrefix/EFStorage/wiki/Usage#non-default-container) | [非默认容器](https://github.com/EFPrefix/EFStorage/wiki/用法#放在其他什么地方吧)
  * [container/content type mix & match](https://github.com/EFPrefix/EFStorage/wiki/Usage#supported-containers) | [类型结合与转换](https://github.com/EFPrefix/EFStorage/wiki/用法#但是)
* [Expand `EFStorage` to Support Your Data Store](https://github.com/EFPrefix/EFStorage/wiki/Extend) | [让 `EFStorage` 支持新的存储方案](https://github.com/EFPrefix/EFStorage/wiki/扩展)

## License

MIT License.

Icons of the demo projects in `CocoaPods/` folder are from [萌娘百科 - 四次元ポケット](https://zh.moegirl.org/zh-hans/四次元口袋). We are using it because in the hope that EFStorage can be like Doraemon's 4D Pocket to you.
