//
//  MusicPlayerView.swift
//  dadMusic
//
//  Created by Evan Gallagher on 12/9/24.
//


import SwiftUI

struct HomeScreen: View {
    @StateObject private var audioManager = AudioManager()
    @State private var showSplashScreen = true
    @State private var currentView: CurrentView = .musicPlayer
    @State private var greetingMessage = ""
    @State private var backgroundView: AnyView = AnyView(Color.white)
    @Environment(\.timeOverride) var currentHour: Int
    
    enum CurrentView {
        case musicPlayer
        case songList
    }
    
    var body: some View {
        Group {
            if showSplashScreen {
                SplashScreen(
                    greetingMessage: greetingMessage,
                    backgroundView: backgroundView)
                
            } else {
                VStack(spacing: 0) {
                    // Render the active view
                    if currentView == .musicPlayer {
                        MusicPlayerView(audioManager: audioManager, backgroundView: backgroundView)
                    } else if currentView == .songList {
                        SongListView(audioManager: audioManager,currentView: $currentView)
                    }
                    
                    // Navigation Buttons
                    HStack {
                        // Music Player Button
                        Button(action: {
                            currentView = .musicPlayer
                        }) {
                            VStack {
                                Image(systemName: "music.note")
                                    .font(.title2)
                                    .foregroundColor(currentView == .musicPlayer ? .orange : .gray)
                                Text("Player")
                                    .font(.footnote)
                                    .foregroundColor(currentView == .musicPlayer ? .orange : .gray)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Song List Button
                        Button(action: {
                            currentView = .songList
                        }) {
                            VStack {
                                Image(systemName: "list.bullet")
                                    .font(.title2)
                                    .foregroundColor(currentView == .songList ? .orange : .gray)
                                Text("Songs")
                                    .font(.footnote)
                                    .foregroundColor(currentView == .songList ? .orange : .gray)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(Color.black.opacity(1))
                }
            }
        }
        .environment(\.sizeCategory, .large)
        .onAppear {
            
            audioManager.loadStartupMessage()
            let hour = currentHour >= 0 ? currentHour : Calendar.current.component(.hour, from: Date())
            
            if hour < 12 {
                greetingMessage = "Good Morning Dad"
                backgroundView = AnyView(LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.sRGB, red: 1.0, green: 1.0, blue: 0.8, opacity: 1.0),
                        Color(.sRGB, red: 1.0, green: 1.0, blue: 0.0, opacity: 0.5)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom))
            } else if hour < 19 {
                greetingMessage = "Good Afternoon Dad"
                backgroundView = AnyView(LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.sRGB, red: 0.8, green: 0.9, blue: 1.0, opacity: 1.0),
                        Color(.sRGB, red: 0.0, green: 0.5, blue: 1.0, opacity: 0.5)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom))
            } else {
                greetingMessage = "Good Evening Dad"
                backgroundView = AnyView(LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.sRGB, red: 0.9, green: 0.8, blue: 1.0, opacity: 1.0),
                        Color(.sRGB, red: 0.5, green: 0.0, blue: 0.5, opacity: 0.5)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom))
            }
            
            // Simulate splash screen delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                showSplashScreen = false
            }
        }
    }
}

// Splash Screen
struct SplashScreen: View {
    let greetingMessage: String
    let backgroundView: AnyView
    var body: some View {
        
        ZStack{
            backgroundView
                .ignoresSafeArea()
            VStack {
                Text(greetingMessage)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                Text("Lets Listen To Some Music!")
                    .font(.headline)
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backgroundView)
            .ignoresSafeArea()
        }
    }
}

struct MusicPlayerView: View {
    @ObservedObject var audioManager: AudioManager
    let backgroundView: AnyView
    
    var body: some View {
        ZStack {
            // Background gradient
            backgroundView
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Album Art
                if let albumArtImage = audioManager.albumArt {
                    Image(uiImage: albumArtImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.8)
                        .padding()
                } else {
                    VStack {
                        Text(audioManager.startupMessage)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)
                            .padding()
                        
                        Text("Press the play button to begin")
                            .font(.subheadline)
                            .foregroundColor(.black)
                            .padding(.top, 5)
                        
                        Image(systemName: "arrow.down")
                            .font(.largeTitle)
                            .fontWeight(.black)
                            .foregroundColor(.black)
                            .padding(.top, 10)
                    }
                }
                
                ZStack {
                    // Extended Gradient at the bottom
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(1.0),
                            Color.black.opacity(0.7),
                            Color.black.opacity(0.4),
                            Color.clear
                        ]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        // Song Title
                        Text(audioManager.songTitle)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                        
                        // Artist Name
                        Text(audioManager.artistName)
                            .font(.subheadline)
                            .foregroundColor(Color(.sRGB, red: 0.75, green: 0.75, blue: 0.75, opacity: 1))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                        
                        // Progress Bar and Time
                        VStack {
                            ZStack(alignment: .leading) {
                                // Background Track (Full Width)
                                Rectangle()
                                    .foregroundColor(.white)
                                    .frame(height: 4)
                                    .cornerRadius(2)

                                // Played Track (Width Clamped to Screen Size)
                                Rectangle()
                                    .foregroundColor(.orange)
                                    .frame(
                                        width: max(0, min(UIScreen.main.bounds.width - 40, // Clamp to prevent overflow
                                            CGFloat(audioManager.currentTime / max(1, audioManager.duration)) * (UIScreen.main.bounds.width - 40)
                                        )),
                                        height: 4
                                    )
                                    .cornerRadius(2)

                                // Scrubbing Circle (Clamped to Max Width)
                                Circle()
                                    .foregroundColor(.orange)
                                    .frame(width: 12, height: 12)
                                    .offset(
                                        x: max(0, min(UIScreen.main.bounds.width - 40, // Clamp to prevent overflow
                                            CGFloat(audioManager.currentTime / max(1, audioManager.duration)) * (UIScreen.main.bounds.width - 40)
                                        )) - 6 // Center the circle
                                    )
                                    .gesture(
                                        DragGesture()
                                            .onChanged { value in
                                                // Calculate percentage and new time
                                                let percentage = min(1.0, max(0.0, value.location.x / (UIScreen.main.bounds.width - 40)))
                                                let newTime = percentage * audioManager.duration
                                                audioManager.seek(to: newTime) // Seek to new time
                                            }
                                    )
                            }

                            // Playback Time Display
                            HStack {
                                Text(formatTime(audioManager.currentTime))
                                    .font(.caption)
                                    .foregroundColor(.white)
                                Spacer()
                                Text(formatTime(audioManager.duration))
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Music Player Controls
                        HStack {
                            Button(action: {
                                   audioManager.toggleShuffle()
                               }) {
                                   Image(systemName: "shuffle")
                                       .font(.title2)
                                       .foregroundColor(audioManager.isShuffleEnabled ? .orange : .white) // Highlight when enabled
                               }
                    
                            Spacer()
                            
                            Button(action: audioManager.previousSong) {
                                Image(systemName: "backward.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            
                            Button(action: {
                                if audioManager.isPlaying {
                                    audioManager.pause()
                                } else {
                                    audioManager.play(shuffle:true)
                                }
                            }) {
                                Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            
                            Button(action: audioManager.nextSong) {
                                Image(systemName: "forward.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            
                            Button(action: {
                                // Placeholder for additional functionality
                            }) {
                                Image(systemName: "plus.circle")
                                    .font(.title)
                                    .foregroundColor(.clear)
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.top, 10)
                    }
                    .padding(.bottom, 20)
                }
                .frame(height: UIScreen.main.bounds.height * 0.4)
            }
        }
    }
}


// Helper function to format playback time
func formatTime(_ time: TimeInterval) -> String {
    let minutes = Int(time) / 60
    let seconds = Int(time) % 60
    return String(format: "%02d:%02d", minutes, seconds)
}




