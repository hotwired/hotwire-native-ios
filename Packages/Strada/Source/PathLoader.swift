import Foundation

class PathLoader {
    func pathFor(name: String, fileType: String, directory: String? = nil) -> String? {
        #if SWIFT_PACKAGE
        return Bundle.module.path(forResource: name, ofType: fileType, inDirectory: directory)
        #else
        let bundle = Bundle(for: type(of: self))
        return bundle.path(forResource: name, ofType: fileType)
        #endif
    }
}
