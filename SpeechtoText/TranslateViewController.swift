//
//  TranslateViewController.swift
//  Speech to Text
//
//  Created by Ebrima Tunkara on 8/13/18.
//  Copyright © 2018 IBM Watson Developer Cloud. All rights reserved.
//

import AVFoundation
import UIKit
import Speech
import MediaToolbox
import MarqueeLabel
import SpeechToTextV1

class TranslateViewController: UIViewController{
    private var player: AVPlayer?
    private let playerLayer = AVPlayerLayer()
    private var isPlaying: Bool = false
    private let audioEngine = AVAudioEngine()
    
    var parameterArray: [AVAudioMixInputParameters] = []
    var audioMix = AVMutableAudioMix()

    @IBOutlet weak var translateView: TranslateTextView!
    
    @IBOutlet weak var playPauseButton: UIButton!
    
    @IBOutlet weak var translateLabel: MarqueeLabel!
    
    var  playerItem: AVPlayerItem?
    private var tap: MYAudioTapProcessor!

    var dataConverter: AudioDataConverter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = Bundle.main.url(forResource: "video", withExtension: "mp4")
        let urlAsset = AVURLAsset(url: url!)
        let audioTrack = urlAsset.tracks(withMediaType: AVMediaType.audio).first
        playerItem = AVPlayerItem(asset: urlAsset)
        player =  AVPlayer(playerItem: playerItem)
        playerLayer.player = player;
        playerLayer.frame = translateView.bounds;
        self.translateView.layer.addSublayer(playerLayer);
        print("Translate view controller view loaded!")
        
        //translateLabel.type = .leftRight
        translateLabel.speed = .rate(20.0)
        //translateLabel.fadeLength = 80.0
        translateLabel.labelWillBeginScroll()
        translateLabel.restartLabel()
        
        //tap audio asset track
        setupTapAudioAssetTrack(audioTrack: audioTrack!)
        setupWatsonSpeechRecognizer()
    }
    
    func setupTapAudioAssetTrack(audioTrack: AVAssetTrack){
        let desc: CMAudioFormatDescription = audioTrack.formatDescriptions[0] as! CMAudioFormatDescription
        print("format description \(desc)")
        self.dataConverter = AudioDataConverter(fmt: AVAudioFormat(cmAudioFormatDescription: desc))
        tap = MYAudioTapProcessor(audioAssetTrack: audioTrack)
        tap.delegate = self
        player?.currentItem?.audioMix = tap.audioMix
    }
    
    @IBAction func playAudioItem(_ sender: Any) {
        playPauseAudio();
    }
    
    func playPauseAudio(){
        isPlaying = !isPlaying;
        if isPlaying{
            player?.play()
            playPauseButton.setTitle("Pause", for: UIControlState.normal)
            self.translateLabel.backgroundColor = UIColor(ciColor: CIColor.black)
        }
        else{
            player?.pause()
            playPauseButton.setTitle("Play", for: UIControlState.normal)
        }
        //translateAudio();
        toggleWatsonSession();
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    // MARK: Interface Builder actions
     func translateAudio() {
        if audioEngine.isRunning {
        //    audioEngine.stop()
            print("Engine stopped translating")
        } else {
              print("Engine start recording")
        }
    }
    
    var speechToText: SpeechToText!
    var session: SpeechToTextSession!
    var settings: RecognitionSettings!
    var isSessionStarted = false
    var isStreaming = false
    var accumulator = SpeechRecognitionResultsAccumulator()
    
    private func setupWatsonSpeechRecognizer(){
        // use `SpeechToTextSession` for advanced configuration
        session = SpeechToTextSession(
            username: Credentials.SpeechToTextUsername,
            password: Credentials.SpeechToTextPassword
        )

        // define recognition session callbacks
        session.onConnect = { print("connected") }
        session.onDisconnect = { print("disconnected") }
        session.onError = { error in print(error) }
       // session.onPowerData = { decibels in print(decibels) }
        session.onResults = {
            results in
             self.accumulator.add(results: results)
             self.translateLabel.text = self.accumulator.bestTranscript
             print(self.accumulator.bestTranscript)
        }
        
        // define recognition settings
        settings = RecognitionSettings(contentType: "audio/l16;rate=16000;channels=2")
        settings.interimResults = true
        settings.inactivityTimeout = -1
    }
    
    func toggleWatsonSession(){
        if !isSessionStarted {
            isSessionStarted = true
            print("Start Session")
            session.connect()
            session.startRequest(settings: settings)
        } else {
            isSessionStarted = false
            isStreaming = false
            print("Stop Watson Sesson")
            session.stopRequest()
            session.disconnect()
        }
    }
}

extension TranslateViewController : MYAudioTabProcessorDelegate {
    // getting audio buffer back from the tap and feeding into speech recognizer
    func audioTabProcessor(_ audioTabProcessor: MYAudioTapProcessor!, didReceive buffer: AVAudioPCMBuffer!) {
        if buffer != nil{
             //print("buffer format desc: \(buffer.format.formatDescription)")
             let outBuffer = dataConverter.convertPCMBuffer(buffer: buffer)
            // print("buffer data out \(outBuffer.format.formatDescription)")
             let data = outBuffer.toData()
             session.recognize(audio: data)
        }
    }
}

extension TranslateViewController {
    func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: [.defaultToSpeaker, .mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup the AVAudioSession.")
        }
    }
}

fileprivate extension AVAudioPCMBuffer {
    func toData() -> Data {
        let channels = UnsafeBufferPointer(start: self.int16ChannelData, count: 1)
        let ch0Data = Data(bytes: UnsafeMutablePointer(channels[0]),
                           count: Int(frameCapacity * format.streamDescription.pointee.mBytesPerFrame))
        return ch0Data
     }
}
