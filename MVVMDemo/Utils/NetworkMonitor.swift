//
//  NetworkMonitor.swift
//  MVVMDemo
//
//  Created by Carlos Torres on 10/17/20.
//

import Foundation
import Network

final class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private let monitor: NWPathMonitor
    final public var networkUpdateHandler: ((Bool, ConnectionType, ConnectionStatus) -> Void)?
    
    public private(set) var isConnected: Bool = false
    public private(set) var connectionStatus: ConnectionStatus = .unknown
    
    public enum ConnectionStatus {
        case connected
        case connecting
        case disconnected
        case unknown
    }
    
    public enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }
    
    public private(set) var connectionType: ConnectionType = .unknown
    
    private init() {
        monitor = NWPathMonitor()
    }
    
    public func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let strongSelf = self else { return }
            strongSelf.isConnected = path.status != .unsatisfied
            strongSelf.connectionStatus = path.status == .requiresConnection ? .connecting : path.status == .satisfied ? .connected : .disconnected
            strongSelf.getConnectionType(path)
            strongSelf.networkUpdateHandler?(strongSelf.isConnected, strongSelf.connectionType, strongSelf.connectionStatus)
        }
        monitor.start(queue: queue)
    }
    
    public func stopMonitoring() {
        monitor.cancel()
    }
    
    private func getConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        }
        else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        }
        else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        }
        else {
            connectionType = .unknown
        }
    }
}
