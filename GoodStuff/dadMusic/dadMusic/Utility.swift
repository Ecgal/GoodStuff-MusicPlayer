//
//  Utility.swift
//  dadMusic
//
//  Created by Evan Gallagher on 12/22/24.
//

import Foundation
import SwiftUI

func dynamicBackgroundGradient(for hour: Int) -> LinearGradient {
    if hour < 12 {
        // Morning Gradient
        return LinearGradient(
            gradient: Gradient(colors: [
                Color(.sRGB, red: 1.0, green: 1.0, blue: 0.8, opacity: 1.0),
                Color(.sRGB, red: 1.0, green: 1.0, blue: 0.0, opacity: 0.5)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    } else if hour < 19 {
        // Afternoon Gradient
        return LinearGradient(
            gradient: Gradient(colors: [
                Color(.sRGB, red: 0.8, green: 0.9, blue: 1.0, opacity: 1.0),
                Color(.sRGB, red: 0.0, green: 0.5, blue: 1.0, opacity: 0.5)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    } else {
        // Evening Gradient
        return LinearGradient(
            gradient: Gradient(colors: [
                Color(.sRGB, red: 0.9, green: 0.8, blue: 1.0, opacity: 1.0),
                Color(.sRGB, red: 0.5, green: 0.0, blue: 0.5, opacity: 0.5)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
