//
//  File.swift
//  
//
//  Created by ApolloZhu on 2019/8/16.
//

public protocol EFSingleInstanceStorageReferenceWrapper: EFStorage, CustomDebugStringConvertible {
    associatedtype Ref: EFSingleInstanceStorageReference where Content == Ref.Content
    var key: String { get }
    var _ref: Ref { get set }
    
    var persistDefaultContent: Bool { get }
    var makeDefaultContent: () -> Content { get }
    func removeContentFromUnderlyingStorage()
    
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
