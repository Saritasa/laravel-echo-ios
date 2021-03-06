//
//  SocketIOChannel.swift
//  laravel-echo-ios
//
//  Created by valentin vivies on 21/07/2017.
//

import Foundation
import SocketIO

/// This class represents a Socket.io channel.
class SocketIoChannel: Channel {
    /// The Socket.io client instance.
    var socket: SocketIOClient

    /// The name of the channel.
    var name: String

    /// Channel auth options.
    var auth: [String: Any]

    /// The event formatter.
    var eventFormatter: EventFormatter

    /// The event callbacks applied to the channel.
    var events: [String: [NormalCallback]]

    /// Create a new class instance.
    ///
    /// - Parameters:
    ///   - socket: the socket instance
    ///   - name: the channel name
    ///   - options: options for the channel
    init(socket: SocketIOClient, name: String, options: [String: Any]) {
        self.name = name
        self.socket = socket
        events = [:]

        var namespace = ""
        if let wrapperNamespace = options["namespace"] as? String {
            namespace = wrapperNamespace
        }

        auth = [:]
        if let wrapperAuth = options["auth"] as? [String: Any] {
            auth = wrapperAuth
        }

        eventFormatter = EventFormatter(namespace: namespace)

        super.init(options: options)

        subscribe()
        configureReconnector()
    }

    /// Subscribe to a Socket.io channel.
    override func subscribe() {
        let data = [["channel": name, "auth": auth]]
        socket.emit("subscribe", with: data)
    }

    /// Unsubscribe from channel and ubind event callbacks.
    override func unsubscribe() {
        unbind()
        let data = [["channel": name, "auth": auth]]
        socket.emit("unsubscribe", with: data)
    }

    /// Listen for an event on the channel instance.
    ///
    /// - Parameters:
    ///   - event: event name
    ///   - callback: callback
    /// - Returns: the channel itself
    override func listen(event: String, callback: @escaping NormalCallback) -> IChannel {
        on(event: eventFormatter.format(event: event), callback: callback)
        return self
    }

    /// Bind the channel's socket to an event and store the callback.
    ///
    /// - Parameters:
    ///   - event: event name
    ///   - callback: callback
    func on(event: String, callback: @escaping NormalCallback) {
        let listener: NormalCallback = { [weak self] data, ack in
            if let channel = data[0] as? String {
                if self?.name == channel {
                    callback(data, ack)
                }
            }
        }

        socket.on(event, callback: listener)
        bind(event: event, callback: listener)
    }

    /// Attach a 'reconnect' listener and bind the event.
    func configureReconnector() {
        let listener: NormalCallback = { [weak self] _, _ in
            self?.subscribe()
        }

        socket.on("reconnect", callback: listener)
        bind(event: "reconnect", callback: listener)
    }

    /// Bind the channel's socket to an event and store the callback.
    ///
    /// - Parameters:
    ///   - event: event name
    ///   - callback: callback
    func bind(event: String, callback: @escaping NormalCallback) {
        if events[event] == nil {
            events[event] = []
        }
        events[event]!.append(callback)
    }

    /// Unbind the channel's socket from all stored event callbacks.
    func unbind() {
        for (key, _) in events {
            events[key] = nil
        }
        socket.removeAllHandlers()
    }
}
