//
//  ContentView.swift
//  AudioRecorderApp
//
//  Created by Jon Peterson on 8/25/22.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var audioRecorder: AudioRecorder
    var body: some View {
        NavigationView{
            VStack {
                RecordingsList(audioRecorder: audioRecorder)
                    .onAppear(){audioRecorder.fetchRecordings()}
                Text("Power")
                Text("Average: \(Int(audioRecorder.averagePower+0.5))")
                Text("Peak: \(Int(audioRecorder.peakPower+0.5))")
                if audioRecorder.recording == false {
                    Button(action: {self.audioRecorder.startRecording()}) {
                        Image(systemName: "circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipped()
                            .foregroundColor(.red)
                            .padding(.bottom, 40)
                    }
                } else {
                    Button(action: {self.audioRecorder.stopRecording()}) {
                        Image(systemName: "stop.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipped()
                            .foregroundColor(.red)
                            .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarTitle("Voice recorder")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(audioRecorder: AudioRecorder())
    }
}
