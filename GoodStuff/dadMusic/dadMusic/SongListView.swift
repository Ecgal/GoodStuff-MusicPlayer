//
//  SongListView.swift
//  dadMusic
//
//  Created by Evan Gallagher on 12/20/24.
//

import SwiftUI

struct SongListView: View {
    @ObservedObject var audioManager: AudioManager
    @Binding var currentView: HomeScreen.CurrentView
    @Environment(\.presentationMode) var presentationMode // For dismissing the screen
    
    // Get the current hour
    private var currentHour: Int {
        Calendar.current.component(.hour, from: Date())
    }
    
    var body: some View {
        ZStack {
            // Background gradient (fixed)
            dynamicBackgroundGradient(for: currentHour)
                .ignoresSafeArea()
            
            Color.black.opacity(0.1)
                .ignoresSafeArea()
            
            
            VStack {
                // Title
                Text("GOOD STUFF ∞")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.top, 10) // Space from top edge
                    .padding(.bottom, 5) // Add padding below the title
                
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(audioManager.songsGroupedByArtist.sorted(by: { $0.key < $1.key }), id: \.key) { artist, songs in
                            Section(header:
                                        Text(artist + ":")
                                .font(.title)
                                .foregroundColor(.black)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                        
                            ) {
                                ForEach(songs, id: \.self) { song in
                                    Button(action: {
                                        // Find the artist and song name
                                        audioManager.playSong(title: song, artist: artist)
                                        currentView = .musicPlayer
                                    }) {
                                        Text(song)
                                            .font(.body)
                                            .foregroundColor(.black)
                                            .padding(.horizontal)
                                            .padding(.vertical, 5)
                                            .fontWeight(.bold)
                                            .background(Color.orange.opacity(0.5))
                                            .cornerRadius(4) // Rounded corners
                                            .padding(.horizontal)
                                    }
                                    
                                }
                            }
                        }
                    }
                    .padding(.bottom, 20) // Add padding at the bottom
                }
                .background(Color.clear) // Keep the scroll view background transparent
            }
        }
    }
}
