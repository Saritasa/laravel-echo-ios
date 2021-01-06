//
// Created by valentin vivies on 21/07/2017.
//

import Foundation
import SocketIO

/// This class creates a connnector to a Socket.io server.
class SocketIOConnector: IConnector {
    private var socketManager: SocketManagerSpec?

    /// Connector options.
    var options: [String: Any]

    /// All of the subscribed channels.
    var channels: [String: IChannel]

    /// Create a new class instance.
    ///
    /// - Parameter options: options
    init(options: [String: Any]) {
        self.options = options
        channels = [:]
        connect()
    }

    /// Create a fresh Socket.io connection.
    func connect() {
        if let url = URL(string: options["host"] as? String ?? "") {
            let log = options["log"] as? Bool ?? true
            let socketConfig: SocketIOClientConfiguration = [.log(log), .compress]
            socketManager = SocketManager(socketURL: url, config: socketConfig)
            socketManager?.defaultSocket.connect(timeoutAfter: 5, withHandler: {
                print("ERROR")
            })
        }
    }

    /// Add other handler type
    ///
    /// - Parameters:
    ///   - event: event name
    ///   - callback: callback
    func on(event: String, callback: @escaping NormalCallback) {
        socketManager?.defaultSocket.on(event, callback: callback)
    }

    /// Listen for an event on a channel instance.
    ///
    /// - Parameters:
    ///   - name: channel name
    ///   - event: event name
    ///   - callback: callback
    /// - Returns: the channel
    func listen(name: String, event: String, callback: @escaping NormalCallback) -> IChannel {
        return channel(name: name).listen(event: event, callback: callback)
    }

    /// Get a channel instance by name.
    ///
    /// - Parameter name: channel name
    /// - Returns: the channel
    func channel(name: String) -> IChannel {
        if channels[name] == nil {
            // TODO: Can Crash, needs refactor.
            channels[name] = SocketIoChannel(
                socket: socketManager!.defaultSocket, name: name, options: options
            )
        }
        return channels[name]!
    }

    /// Get a private channel instance by name.
    ///
    /// - Parameter name: channel name
    /// - Returns: the private channel
    func privateChannel(name: String) -> IPrivateChannel {
        if channels["private-" + name] == nil {
            // TODO: Can Crash, needs refactor.
            channels["private-" + name] = SocketIOPrivateChannel(
                socket: socketManager!.defaultSocket, name: "private-" + name, options: options
            )
        }
        return channels["private-" + name]! as! IPrivateChannel
    }

    /// Get a presence channel instance by name.
    ///
    /// - Parameter name: channel name
    /// - Returns: the presence channel
    func presenceChannel(name: String) -> IPresenceChannel {
        if channels["presence-" + name] == nil {
            // TODO: Can Crash, needs refactor.
            channels["presence-" + name] = SocketIOPresenceChannel(
                socket: socketManager!.defaultSocket, name: "presence-" + name, options: options
            )
        }
        return channels["presence-" + name]! as! IPresenceChannel
    }

    /// Leave the given channel.
    ///
    /// - Parameter name: channel name
    func leave(name: String) {
        let channels: [String] = [name, "private-" + name, "presence-" + name]
        for name in channels {
            if let c = self.channels[name] {
                c.unsubscribe()
                self.channels[name] = nil
            }
        }
    }

    /// Get the socket_id of the connection.
    ///
    /// - Returns: the socket id
    func socketId() -> String {
        return socketManager?.defaultSocket.sid ?? ""
    }

    /// Disconnect from the Echo server.
    func disconnect() {
        socketManager?.defaultSocket.disconnect()
    }
}
