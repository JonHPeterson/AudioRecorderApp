//
//  AudioRecorderAppApp.swift
//  AudioRecorderApp
//
//  Created by Jon Peterson on 8/25/22.
//

import SwiftUI

@main
struct AudioRecorderAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(audioRecorder: AudioRecorder())
        }
    }
}
