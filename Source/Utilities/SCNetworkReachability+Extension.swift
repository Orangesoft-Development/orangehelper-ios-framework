import SystemConfiguration

public extension SCNetworkReachability {
    
    static var isOnline: Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress,
                                                               { $0.withMemoryRebound(to: sockaddr.self, capacity: 1)
                                                               { SCNetworkReachabilityCreateWithAddress(nil, $0) }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        
        guard SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) else { return false }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return isReachable && !needsConnection
    }
}
