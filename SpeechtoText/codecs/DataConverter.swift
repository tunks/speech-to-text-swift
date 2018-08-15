//
//  DataConverter.swift
//  SpeechtoText
//
//  Created by Ebrima Tunkara on 8/15/18.
//  Copyright © 2018 Tunks dev. All rights reserved.
//

import AVFoundation

class AudioDataConverter{
    var audioConverter: AVAudioConverter!
    var formatOut: AVAudioFormat!
    init(fmt formatIn: AVAudioFormat){
         formatOut = AVAudioFormat(commonFormat: .pcmFormatInt16,
                                   sampleRate: 16000, channels: 2,
                                   interleaved:  true)
    }
    
    func convertPCMBuffer(buffer: AVAudioPCMBuffer) -> AVAudioPCMBuffer{
         let inputFormat = AVAudioFormat( cmAudioFormatDescription: buffer.format.formatDescription)
         audioConverter  = AVAudioConverter(from:inputFormat, to: formatOut!)
        //Here is where I adjusted for the sample rate. It's hard coded here, but you would want to adjust so that you're dividing the input sample rate by your chosen sample rate.
        let sampleRateConversionRatio: Float = Float(buffer.format.sampleRate/16000.0)
        let capacity = UInt32(Float(buffer.frameCapacity)/sampleRateConversionRatio)
        let convertedBuffer = AVAudioPCMBuffer(pcmFormat: formatOut, frameCapacity: capacity)
        let inputBlock: AVAudioConverterInputBlock = { inNumPackets, outStatus in
            outStatus.pointee = AVAudioConverterInputStatus.haveData
            return buffer
        }
        var error: NSError? = nil
        _ = audioConverter.convert(to: convertedBuffer!, error: &error, withInputFrom: inputBlock)
        
        //print("Convert buffer status error \(error!)")
        //assert(error != NSError.init())
        return convertedBuffer!
    }
}
