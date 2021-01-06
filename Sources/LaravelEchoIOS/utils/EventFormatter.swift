//
//  EventFormatter.swift
//  laravel-echo-ios
//
//  Created by valentin vivies on 21/07/2017.
//

import Foundation

/// Event name formatter
class EventFormatter {
    /// Event namespace.
    var namespace = ""

    /// Create a new class instance.
    ///
    /// - Parameter namespace: namespce
    init(namespace: String? = "") {
        setNamespace(value: namespace!)
    }

    /// Format the given event name.
    ///
    /// - Parameter event: event name
    /// - Returns: formated event name
    func format(event: String) -> String {
        var e: String = ""
        if !(event.hasPrefix("\\") || event.hasPrefix(".")) {
            e = namespace + "." + event
        } else {
            let index = event.index(event.startIndex, offsetBy: 1)
            return String(event[index...])
        }
        return e.replacingOccurrences(of: ".", with: "\\")
    }

    /// Set the event namespace.
    ///
    /// - Parameter value: namespace
    func setNamespace(value: String? = "") {
        if let wrap = value {
            namespace = wrap
        }
    }
}
