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
import SwiftyJSON

class TranslateViewController: UIViewController{
    private var player: AVPlayer?
    private let playerLayer = AVPlayerLayer()
    private var isPlaying: Bool = false
    let kVolume: Float = 0.0

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    private var recognitionTask: SFSpeechRecognitionTask?
    
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
        
        /*let inputParams = AVMutableAudioMixInputParameters(track: audioTrack)
        inputParams.setVolume(kVolume, at: kCMTimeZero)
        parameterArray.append(inputParams)
        audioMix.inputParameters = parameterArray
        playerItem.audioMix = audioMix
 */
        
       
        
        //try! setupSpeechRecognizer()
        //translateLabel.type = .leftRight
        //translateLabel.speed = .rate(1)
        //translateLabel.fadeLength = 80.0
        //translateLabel.labelWillBeginScroll()
        
        //tap audio asset track
        tapAudioAssetTrack(audioTrack: audioTrack!)
        //watson
        setupWatsonSpeechRecognizer()
    }
    
    func tapAudioAssetTrack(audioTrack: AVAssetTrack){
       // print("format  \(audioTrack.formatDescriptions)")
        getFormatDescription(audioTrack: audioTrack)
        tap = MYAudioTapProcessor(audioAssetTrack: audioTrack)
        tap.delegate = self
        player?.currentItem?.audioMix = tap.audioMix
    }
    
    func getFormatDescription(audioTrack: AVAssetTrack){
        let desc: CMAudioFormatDescription = audioTrack.formatDescriptions[0] as! CMAudioFormatDescription
        print("format description \(desc)")
       // var fmt =  AVAudioFormat(cmAudioFormatDescription: desc)
        self.dataConverter = AudioDataConverter(fmt: AVAudioFormat(cmAudioFormatDescription: desc))
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
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            /*
             The callback may not be called on the main thread. Add an
             operation to the main queue to update the record button's state.
             */
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    //self.recordButton.isEnabled = true
                      print("authorized")
                case .denied:
                    //
                    print("denined")
                case .restricted:
                    print("restricted")

                case .notDetermined:
                    print("not determine")

                }
            }
        }
    }
    
    private func setupSpeechRecognizer() throws {
       /*
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryPlayback)
        try audioSession.setMode(AVAudioSessionModeSpokenAudio)//AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
      */
      /*
        let inputNode = audioEngine.inputNode// else { fatalError("Audio engine has no input node") }
        //audioEngine.attach(self.audioMix)
        //playerItem?.audioMix = audioEngine.mainMixerNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)//inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {
            (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
             self.recognitionRequest?.append(buffer)
            //print("Input buffer tap buffer")
           // self.recognitionRequest.
            
        }
        */
        
       /* let mixer = audioEngine.mainMixerNode
        let format = mixer.outputFormat(forBus: 0)
        mixer.installTap(onBus: 0, bufferSize: 1024, format: format,
                         block: { (buffer: AVAudioPCMBuffer!, time: AVAudioTime!) -> Void in
                            
                            print(NSString(string: "writing"))
                            
        })
        audioEngine.prepare()
        try audioEngine.start()
      */
        
       startSpeechRecognizer()
    }
    
    func audioInput(assetTrack: AVAssetTrack){
//         var audioMixInputParameters = AVMutableAudioMixInputParameters(track: assetTrack)
//         var audioMix: AVMutableAudioMix = AVMutableAudioMix()
//         audioMix.inputParameters = [audioMixInputParameters]
         //playerItem?.add(<#T##output: AVPlayerItemOutput##AVPlayerItemOutput#>)
        // playerItem?.audioMix = audioEngine.mainMixerNode
        //audioMixInputParameters.
        //audioMix.
    }
    
    func startSpeechRecognizer(){
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        // Configure request so that results are returned before audio recording is finished
        recognitionRequest?.shouldReportPartialResults = true
        // A recognition task represents a speech recognition session.
        // We keep a reference to the task so that it can be cancelled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest!) { result, error in
         // let text  = result?.bestTranscription.formattedString;
             //self.translateLabel.text =  text
            //print(text)//NSString(string: text!))

            if (error != nil || (result?.isFinal)!){
                //self.audioEngine.stop()
               // inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.startSpeechRecognizer()
            }
        }
    }

    
    // MARK: Interface Builder actions
    
     func translateAudio() {
        if audioEngine.isRunning {
        //    audioEngine.stop()
            print("Engine stopped translating")
        } else {
            try! setupSpeechRecognizer()
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
//        do {
//            let avSession  = AVAudioSession.sharedInstance()
//            try avSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: [.mixWithOthers,  .defaultToSpeaker])
//            try avSession.setActive(true)
//             print("Available inputs")
//             print(avSession.availableInputs!)
//        }
//        catch{
//            print("Error setting up AVAudioSession category")
//        }
        //audioSession.play
        // use `SpeechToTextSession` for advanced configuration
        session = SpeechToTextSession(
            username: Credentials.SpeechToTextUsername,
            password: Credentials.SpeechToTextPassword
        )

        //session.websocketsURL = Credentials.SpeechWssUrl
        // define recognition session callbacks
        session.onConnect = { print("connected") }
        session.onDisconnect = { print("disconnected") }
        session.onError = { error in print(error) }
       // session.onPowerData = { decibels in print(decibels) }
        session.onResults = {
            results in
            self.accumulator.add(results: results)
            //self.textView.text = self.accumulator.bestTranscript
            print(self.accumulator.bestTranscript)
        }
        
        // define recognition settings
        //audio/l16;rate=16000;channels=2

        settings = RecognitionSettings(contentType: "audio/l16;rate=16000;channels=2")
        settings.interimResults = true
        settings.inactivityTimeout = -1
        
        //
//        speechToText = SpeechToText(
//            username: Credentials.SpeechToTextUsername,
//            password: Credentials.SpeechToTextPassword
//        )
        
        //speechToText.cr
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
            session.stopMicrophone()
            session.stopRequest()
            session.disconnect()
        }
    }
}


extension TranslateViewController :  SFSpeechRecognizerDelegate, MYAudioTabProcessorDelegate {
    // MARK: SFSpeechRecognizerDelegate
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            //  recordButton.isEnabled = true
            //recordButton.setTitle("Start Recording", for: [])
        } else {
            //recordButton.isEnabled = false
            //recordButton.setTitle("Recognition not available", for: .disabled)
        }
    }
    // getting audio buffer back from the tap and feeding into speech recognizer
    func audioTabProcessor(_ audioTabProcessor: MYAudioTapProcessor!, didReceive buffer: AVAudioPCMBuffer!) {
        // recognitionRequest?.append(buffer)
        //use watson
        //session.r
        if buffer != nil{
             //print("buffer format desc: \(buffer.format.formatDescription)")
            
             let outBuffer = dataConverter.convertPCMBuffer(buffer: buffer)
            // print("buffer data out \(outBuffer.format.formatDescription)")
             let data = outBuffer.toData()
             session.recognize(audio: data)
        }
    }
    
    
    
    
    
//    private func toData(buffer: AVAudioPCMBuffer) -> Data {
//        let channelCount = 1  // given PCMBuffer channel count is 1
//        let channels = UnsafeBufferPointer(start: buffer.floatChannelData, count: channelCount)
//        let ch0Data = Data(bytes: channels[0],
//                           count: Int( buffer.frameCapacity *
//                                       buffer.format.streamDescription.pointee.mBytesPerFrame))
//        return ch0Data
//    }
}


extension TranslateViewController {
    /// Depending on your application's requirements, you might need to configure the default
    /// audio session to play nicely with other audio sources. For example, this function
    /// configures the session to default to the speaker (instead of headphones) and mix
    /// with audio from other apps rather than stopping playback when recording starts.
    func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, with: [.defaultToSpeaker, .mixWithOthers])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup the AVAudioSession.")
        }
    }
    
    /*
     func toPCMBuffer(data: Data) -> AVAudioPCMBuffer {
         let audioFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 8000, channels: 1, interleaved: false)
         let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat!, frameCapacity: UInt32(data.count)/2)
         audioBuffer?.frameLength = (audioBuffer?.frameCapacity)!
         for i in 0..<data.count/2 {
         // transform two bytes into a float (-1.0 - 1.0), required by the audio buffer
         audioBuffer?.floatChannelData?.pointee[i] = Float(Int16(data[i*2+1]) << 8 | Int16(data[i*2]))/Float(INT16_MAX)
         }
         return audioBuffer!
     }
     */
}


fileprivate extension AVAudioPCMBuffer {
    func toData() -> Data {
        //print(self.int16ChannelData)
        let channels = UnsafeBufferPointer(start: self.int16ChannelData, count: 1)
        let ch0Data = Data(bytes: UnsafeMutablePointer(channels[0]),
                           count: Int(frameCapacity * format.streamDescription.pointee.mBytesPerFrame))
        return ch0Data
     }
}
