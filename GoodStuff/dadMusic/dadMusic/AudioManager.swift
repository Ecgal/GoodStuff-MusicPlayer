//
//  AudioManager.swift
//  dadMusic
//
//  Created by Evan Gallagher on 12/9/24.
//


import AVFoundation
import SwiftUI
import MediaPlayer


class AudioManager:NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var currentSong: String = "No song playing"
    @Published var isPlaying: Bool = false
    @Published var songList: [String] = []
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var albumArt: UIImage?
    @Published var songTitle: String = ""
    @Published var artistName: String = ""
    @Published var songsGroupedByArtist: [String: [String]] = [:]
    @Published var startupMessage: String = ""
    @Published var isShuffleEnabled: Bool = false
    @Published var isPaused: Bool = false
    
    private var audioPlayer: AVAudioPlayer?
    private var currentSongIndex = 0
    private var timer: Timer?
    
    override init() {
        super.init()
        configureAudioSession()
        configureRemoteCommands()
        loadSongsFromFolder()
        groupSongsByArtist()
    }
    
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    
    func loadStartupMessage() {
        if let fileURL = Bundle.main.url(forResource: "GOODSTUFF-SAYINGS", withExtension: "txt") {
            do {
                let content = try String(contentsOf: fileURL)
                let lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty } // Remove empty lines
                startupMessage = lines.randomElement() ?? "Press play to start!"
            } catch {
                print("Error loading messages: \(error)")
                startupMessage = "Press play to start!"
            }
        } else {
            startupMessage = "Press play to start!"
        }
    }
    
    // Load song file names from the Music folder
    func loadSongsFromFolder() {
        if let musicFolderURL = Bundle.main.url(forResource: "Music", withExtension: nil) {
            do {
                let fileURLs = try FileManager.default.contentsOfDirectory(at: musicFolderURL, includingPropertiesForKeys: nil)
                songList = fileURLs
                    .filter { $0.pathExtension == "mp3" }
                    .map { $0.deletingPathExtension().lastPathComponent.replacingOccurrences(of: "_", with: " ") }
                print(songList)
            } catch {
                print("Error loading songs from folder: \(error)")
            }
        } else {
            print("Music folder not found in bundle.")
        }
    }
    
    // Group songs by artist
    private func groupSongsByArtist() {
        var groupedSongs = [String: [String]]()
        for song in songList {
            let components = song.split(separator: "-").map { $0.trimmingCharacters(in: .whitespaces) }
            if components.count == 2 {
                let songTitle = components[0]
                let artist = components[1]
                groupedSongs[artist, default: []].append(songTitle)
            }
        }
        songsGroupedByArtist = groupedSongs
    }
    
    func toggleShuffle() {
        isShuffleEnabled.toggle() // Toggle the shuffle state
        
        if isShuffleEnabled {
            print("Shuffle mode enabled. Will shuffle after the current song.")
        } else {
            print("Shuffle mode disabled.")
        }
    }
    
    func shuffleSongs() {
        songList.shuffle()
        currentSongIndex = 0
    }
    
    func loadSong(index: Int) {
        
        audioPlayer?.delegate = self
        
        guard !songList.isEmpty else {
            print("No songs available to play.")
            return
        }
        
        let songName = songList[index]
        if let musicFolderURL = Bundle.main.url(forResource: "Music", withExtension: nil) {
            let songURL = musicFolderURL.appendingPathComponent("\(songName).mp3")
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: songURL)
                audioPlayer?.delegate = self
                let components = songName.split(separator: " - ", maxSplits: 1).map{String($0)}
                songTitle = components.first ?? "Unknown Title"
                artistName = components.count > 1 ? components[1] : "Unknown Artist"
                
                
                currentSong = songName
                duration = audioPlayer?.duration ?? 0
                audioPlayer?.prepareToPlay()
                resetTimer()
                
                // Load album art
                if let albumArtImage = UIImage(named: songName) {
                    albumArt = albumArtImage
                } else if let placeholderImage = UIImage(named: "placeholder-artwork") {
                    albumArt = placeholderImage
                } else {
                    albumArt = nil
                }
                
                
            } catch {
                print("Error loading song: \(error)")
            }
        } else {
            print("Music folder not found in bundle.")
        }
    }
    
    func play(shuffle: Bool = false) {
        if !isPlaying {
            if !isPaused{
                if shuffle { // Only shuffle if explicitly told to do so
                    shuffleSongs()
                    nextSong()
                }
            }
        }
        guard let player = audioPlayer else { return }
        player.play()
        isPlaying = true
        startTimer()
        updateNowPlayingInfo()
    }
    
    func playSong(title: String, artist: String) {
        let fullName = "\(title) - \(artist)" // Combine title and artist
        guard let index = songList.firstIndex(of: fullName) else { return } // Find index
        loadSong(index: index) // Load the song by index
        play(shuffle: false)   // Start playback without shuffling
    }
    
    func pause() {
        guard let player = audioPlayer else { return }
        player.pause()
        isPlaying = false
        isPaused = true
        stopTimer()
        updateNowPlayingInfo()
    }
    
    func nextSong() {
        guard !songList.isEmpty else { return }
        currentSongIndex = (currentSongIndex + 1) % songList.count
        loadSong(index: currentSongIndex)
        if isPlaying { play() }
    }
    
    func previousSong() {
        guard !songList.isEmpty else { return }
        currentSongIndex = (currentSongIndex - 1 + songList.count) % songList.count
        loadSong(index: currentSongIndex)
        if isPlaying { play() }
    }
    
    
    func seek(to time: TimeInterval) {
        guard let player = audioPlayer else { return }
        player.currentTime = time
        currentTime = time
        updateNowPlayingInfo()
    }
    
    private func updateNowPlayingInfo() {
        
        // Get the currently playing song
        let isPlaying = self.isPlaying
        
        guard let player = audioPlayer else { return }
        
        // Create metadata dictionary
        var nowPlayingInfo: [String: Any] = [
            MPMediaItemPropertyTitle: songTitle,
            MPMediaItemPropertyArtist: artistName,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0, // Playing or paused
            MPNowPlayingInfoPropertyElapsedPlaybackTime:
                player.currentTime,
            MPMediaItemPropertyPlaybackDuration:player.duration
        ]
        
        
        if let artworkImage = albumArt {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: artworkImage.size) { _ in artworkImage }
        }
        
        // Set the now playing info
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        
        
        
    }
    private func configureRemoteCommands() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Play command
        commandCenter.playCommand.addTarget { [weak self] event in
            self?.play()
            return .success
        }
        
        // Pause command
        commandCenter.pauseCommand.addTarget { [weak self] event in
            self?.pause()
            return .success
        }
        
        // Next Track command
        commandCenter.nextTrackCommand.addTarget { [weak self] event in
            self?.nextSong()
            return .success
        }
        
        // Previous Track command
        commandCenter.previousTrackCommand.addTarget { [weak self] event in
            self?.previousSong()
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let positionEvent = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed }
            self?.seek(to: positionEvent.positionTime)
            return .success
        }
    }
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.audioPlayer else { return }
            self.currentTime = player.currentTime
        }
    }
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func resetTimer() {
        stopTimer()
        currentTime = 0
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            if isShuffleEnabled {
                shuffleSongs() // Shuffle the songs if enabled
                isShuffleEnabled = false // Reset shuffle mode after shuffling
            }
            nextSong()
        }
    }
}
