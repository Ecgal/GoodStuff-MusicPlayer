//
//  HomeScreen_Previews.swift
//  dadMusic
//
//  Created by Evan Gallagher on 12/11/24.
//

import SwiftUI

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Morning Preview
            HomeScreen()
                .environment(\.timeOverride, 8) //  8 AM
                .previewDisplayName("Morning")

            // Afternoon Preview
            HomeScreen()
                .environment(\.timeOverride, 14) // 2 PM
                .previewDisplayName("Afternoon")

            // Evening Preview
            HomeScreen()
                .environment(\.timeOverride, 20) //  8 PM
                .previewDisplayName("Evening")
        }
    }
}

