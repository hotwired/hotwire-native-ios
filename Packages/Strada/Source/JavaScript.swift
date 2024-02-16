import Foundation

enum JavaScriptError: Error, Equatable {
    case invalidArgumentType
}

/// Represents a single JavaScript function call
/// Handling the conversion of the arguments into a suitable format
struct JavaScript {
    /// The object to call the function on, nil by default
    var object: String? = nil
    
    /// The function name without parens
    let functionName: String
    
    /// An array representing arguments. Arguments will passed to function like so:
    /// functionName(args[0], args[1], ...)
    var arguments: [Any] = []

    /// Final string that can be passed to `webView.evaluateJavaScript()` method
    func toString() throws -> String {
        let encodedArguments = try encode(arguments: arguments)
        let function = sanitizedFunctionName(functionName)
        return "\(function)(\(encodedArguments))"
    }
    
    private func encode(arguments: [Any]) throws -> String {
        guard JSONSerialization.isValidJSONObject(arguments) else {
            throw JavaScriptError.invalidArgumentType
        }
        
        let data = try JSONSerialization.data(withJSONObject: arguments, options: [])
        let string = String(data: data, encoding: .utf8)!
        return String(string.dropFirst().dropLast())
    }

    private func sanitizedFunctionName(_ name: String) -> String {
        // Strip parens if included
        let name = name.hasSuffix("()") ? String(name.dropLast(2)) : name
        
        if let object = object {
            return "\(object).\(name)"
        } else {
            return name
        }
    }
}
