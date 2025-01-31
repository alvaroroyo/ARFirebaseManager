import FirebaseStorage
import UIKit

struct StorageManager {
    enum ImageType: String {
        case jpg, png
    }
    
    struct StorageData {
        let path: String
        let name: String
        let type: String
        var fullPath: String { path + name + "." + type }
    }
    
    @discardableResult
    func upload(_ image: UIImage, _ path: String, name: String? = nil, _ fileType: ImageType, compressionQuality: CGFloat = 1, _ completion: (() -> Void)? = nil) -> StorageData? {
        var data: Data?
        switch fileType {
        case .jpg: data = image.jpegData(compressionQuality: compressionQuality)
        case .png: data = image.pngData()
        }
        guard let data = data else { return nil }
        return upload(data: data, path: path, name: name ?? UUID().uuidString, type: fileType.rawValue, completion)
    }
    
    private func upload(data: Data, path: String, name: String, type: String, _ completion: (() -> Void)? = nil) -> StorageData {
        let path = path.formatPath()
        let storageData = StorageData(path: path, name: name, type: type)
        let ref = Storage.storage().reference()
        let dataRef = ref.child(storageData.fullPath)
        dataRef.putData(data, metadata: nil) { _, _ in
            completion?()
        }
        return storageData
    }
}

private extension String {
    func formatPath() -> String {
        let strings = split(separator: "/")
        return strings.joined(separator: "/") + "/"
    }
}
