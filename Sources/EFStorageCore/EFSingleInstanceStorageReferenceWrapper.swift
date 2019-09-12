//
//  EFSingleInstanceStorageReferenceWrapper.swift
//  EFStorage
//
//  Created by ApolloZhu on 2019/8/16.
//

/// Protocol for some EFStorage `@propertyWrapper`.
public protocol EFSingleInstanceStorageReferenceWrapper: EFStorage, CustomDebugStringConvertible {
    associatedtype Ref: EFSingleInstanceStorageReference where Content == Ref.Content
    var key: String { get }
    var _ref: Ref { get set }
    
    var persistDefaultContent: Bool { get }
    var makeDefaultContent: () -> Content { get }
    func removeContentFromUnderlyingStorage()
    
    /// Invoke this constructor with caution. You can do it, but is not recommended.
    init(__ref: Ref, makeDefaultContent: @escaping () -> Content, persistDefaultContent: Bool)
}

public extension EFSingleInstanceStorageReferenceWrapper {
    var key: String {
        return _ref.key
    }
    
    var content: Content? {
        get { return _ref.content }
        set { _ref.content = newValue }
    }
    
    var debugDescription: String {
        let storageName = String(describing: Ref.Storage.self)
        return "\(storageName)[\(key)] : \(content ?? makeDefaultContent())"
    }
    
    /// The constructor to use for `@propertyWrapper`s.
    /// - Parameter key: identifier for the stored content.
    /// - Parameter storage: where content should be stored to.
    /// - Parameter makeDefaultContent: default value to use when no content is found in `storage`.
    /// - Parameter persistDefaultContent: wether default value should actually be stored into `storage` or not.
    init(
        forKey key: String, in storage: Ref.Storage = Ref.Storage.makeDefault(),
        defaultsTo makeDefaultContent: @escaping @autoclosure () -> Content,
        persistDefaultContent: Bool = false
    ) {
        self.init(
            __ref: Ref.forKey(key, in: storage),
            makeDefaultContent: makeDefaultContent,
            persistDefaultContent: persistDefaultContent
        )
        if _ref.content == nil, persistDefaultContent {
            _ref.content = makeDefaultContent()
        }
    }
}
