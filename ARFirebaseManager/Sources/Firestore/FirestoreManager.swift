import FirebaseFirestore

public struct FirestoreManager {
    public init() {}
    
    private var db: Firestore = {
        let settings = FirestoreSettings()
        settings.cacheSettings = PersistentCacheSettings(sizeBytes: FirestoreCacheSizeUnlimited as NSNumber)
        let db = Firestore.firestore()
        db.settings = settings
        return db
    }()
    
    public func getDocuments<T: Firestorable>(_ type: T.Type, source: FirestoreSource = .server) async -> [T]? {
        try? await db.collection(type.firestoreCollectionName)
            .getDocuments(source: source)
            .documents
            .compactMap { doc -> (T?) in
                var obj = try? doc.data(as: type)
                obj?.firestoreId = doc.documentID
                return obj
            }
    }
    
    public func getDocument<T: Firestorable>(_ type: T.Type, id: String, source: FirestoreSource = .server) async -> T? {
        try? await db.collection(type.firestoreCollectionName)
            .document(id)
            .getDocument(source: source)
            .data(as: type)
    }
    
    public func getPaginatedDocuments<T: Firestorable>(_ type: T.Type, start: Int, limit: Int) async -> [T]? {
        guard !type.orderBy.isEmpty else {
            return nil
        }
        return try? await db.collection(type.firestoreCollectionName)
            .order(by: type.orderBy)
            .start(at: [start])
            .limit(to: limit)
            .getDocuments()
            .documents
            .compactMap { doc -> (T?) in
                var obj = try? doc.data(as: type)
                obj?.firestoreId = doc.documentID
                return obj
            }
    }
    
    @discardableResult
    public func insert<T: Firestorable>(_ object: T) -> String? {
        var object = object
        let id = (object.firestoreId ?? "").isEmpty ? UUID().uuidString : object.firestoreId!
        object.firestoreId = id
        try? db.collection(type(of: object).firestoreCollectionName)
            .document(id)
            .setData(from: object)
        return id
    }
    
}
