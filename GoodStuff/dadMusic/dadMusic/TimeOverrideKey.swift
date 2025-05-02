//
//  TimeOverrideKey.swift
//  dadMusic
//
//  Created by Evan Gallagher on 12/11/24.
//
//used for testing time specific screens
import SwiftUI

private struct TimeOverrideKey: EnvironmentKey {
    static let defaultValue: Int = -1 // Default is -1, meaning no override
}

extension EnvironmentValues {
    var timeOverride: Int {
        get { self[TimeOverrideKey.self] }
        set { self[TimeOverrideKey.self] = newValue }
    }
}
