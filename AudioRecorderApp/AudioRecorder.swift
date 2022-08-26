//
//  AudioRecorder.swift
//  AudioRecorderApp
//
//  Created by Jon Peterson on 8/25/22.
//

import Foundation
import SwiftUI
import Combine
import AVFoundation
class AudioRecorder: ObservableObject {
    let objectWillChange = PassthroughSubject<AudioRecorder, Never>()
    var audioRecorder: AVAudioRecorder?
    var recordings = [Recording]()
    var meterUpdates = true
    var recording = false {
            didSet {
                objectWillChange.send(self)
            }
        }
    var averagePower:Float = 0.0 {
        didSet{
            objectWillChange.send(self)
        }
    }
    var peakPower:Float = 0.0 {
        didSet{
            objectWillChange.send(self)
        }
    }
    init(){
        DispatchQueue.global(qos: .background).async {
            self.updatePowerThreadFunc()
        }
    }
    func startRecording() {
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Failed to set up recording session")
        }
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioFilename = documentPath.appendingPathComponent("\(Date().toString(dateFormat: "dd-MM-YY_'at'_HH:mm:ss")).m4a")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 8000,  // cannot go below 8000
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            
        ]
        do {
            
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            if let localAR = audioRecorder {
                localAR.isMeteringEnabled = true
                localAR.record()
                recording = true
            }
        } catch {
            print("Could not start recording")
        }
    }
    
    func updatePowerThreadFunc(){
        let waitSemaphore = DispatchSemaphore(value: 0)
        let waitTime = 1.0/22.0
        var counter = 0
        var avgPower:Float = 0.0
        var pkPower:Float = 0.0
        while meterUpdates {
            _ = waitSemaphore.wait(timeout: .now() + waitTime)
            if recording {
                if let localAR = audioRecorder {
                    localAR.updateMeters()
                    counter += 1
                    avgPower += localAR.averagePower(forChannel: 0)
                    pkPower += localAR.peakPower(forChannel: 0)
                    if counter >= 10 {
                        DispatchQueue.main.async {
                            self.averagePower = avgPower / 10.0
                            self.peakPower = pkPower / 10.0
                            avgPower = 0.0
                            pkPower = 0.0
                            counter = 0
                        }
                    }
                }
            }
        }
    }
    
    func stopRecording() {
        if let localAR = audioRecorder {
            localAR.stop()
        }
        recording = false
        averagePower = 0.0
        peakPower = 0.0
        fetchRecordings()
    }
    
    func fetchRecordings() {
        recordings.removeAll()
        
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryContents = try! fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
        for audio in directoryContents {
            let recording = Recording(fileURL: audio, createdAt: getCreationDate(for: audio))
            recordings.append(recording)
            recordings.sort(by: { $0.createdAt.compare($1.createdAt) == .orderedAscending})
            objectWillChange.send(self)
        }
    }
    func deleteRecording(urlsToDelete: [URL]) {
        for url in urlsToDelete {
            print(url)
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                print("File could not be deleted!")
            }
        }
        fetchRecordings()
    }
}






