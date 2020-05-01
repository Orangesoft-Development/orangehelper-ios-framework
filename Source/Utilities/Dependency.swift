import Foundation

public final class Dependency {
    
    public enum Lifetime {
        case singleton
        case weakSingleton
        case transient
    }
    
    private static var dependencies = [String: () -> AnyObject]()
    
    public static func register<T: AnyObject>(constructor: @escaping () -> T) {
        register(T.self, lifetime: .singleton, constructor: constructor)
    }
    
    public static func register<T: AnyObject>(lifetime: Lifetime, constructor: @escaping () -> T) {
        register(T.self, lifetime: lifetime, constructor: constructor)
    }
    
    public static func register<T: AnyObject>(_ type: T.Type, lifetime: Lifetime, constructor: @escaping () -> T) {
        var resolver: (() -> T)
        switch lifetime {
        case .singleton:
            var strongInstance: T?
            resolver = {
                if let instance = strongInstance {
                    return instance
                } else {
                    let instance = constructor()
                    strongInstance = instance
                    return instance
                }
            }
        case .weakSingleton:
            weak var weakInstance: T?
            resolver = {
                if let instance = weakInstance {
                    return instance
                } else {
                    let instance = constructor()
                    weakInstance = instance
                    return instance
                }
            }
        case .transient:
            resolver = constructor
        }
        dependencies[String(describing: type)] = resolver
    }
    
    public static func resolve<T: AnyObject>(_ type: T.Type = T.self) -> T {
        let key = String(describing: type)
        guard let resolver = dependencies[key] else {
            preconditionFailure("No registration for key \(key)")
        }
        guard let instance = resolver() as? T else {
            preconditionFailure("Expected Type \(key) by key \(key).")
        }
        return instance
    }
     
    public static func available<T: AnyObject>(_ type: T.Type = T.self) -> Bool {
        return dependencies.keys.contains(String(describing: type))
    }
    
    public static func remove<T: AnyObject>(_ type: T.Type = T.self) {
        dependencies.removeValue(forKey: String(describing: type))
    }
}
