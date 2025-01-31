import Foundation

public protocol Firestorable: Codable, Hashable {
    static var firestoreCollectionName: String { get }
    static var orderBy: String { get }
    var firestoreId: String! { get set }
}

public extension Firestorable {
    static var orderBy: String { "" }

    func saveLocally(_ id: String? = nil) {
        guard let data = try? JSONEncoder().encode(self), let id = id ?? firestoreId else { return }
        UserDefaults.standard.set(data, forKey: id)
    }

    func saveOnCloud() {
        FirestoreManager().insert(self)
    }

    static func getLocally(_ id: String) -> Self? {
        guard
            let data = UserDefaults.standard.data(forKey: id),
            let object = try? JSONDecoder().decode(Self.self, from: data)
        else {
            return nil
        }
        return object
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        guard let id1 = lhs.firestoreId,
              let id2 = rhs.firestoreId
        else { return false }
        return id1 == id2
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(firestoreId)
    }
}

extension Array: Firestorable where Element: Firestorable {
    public static var firestoreCollectionName: String { Element.firestoreCollectionName }

    public var firestoreId: String! {
        get { "" }
        set {}
    }
}
