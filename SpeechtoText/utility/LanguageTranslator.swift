//
//  Language.swift
//  SpeechtoText
//
//  Created by Ebrima Tunkara on 8/16/18.
//  Copyright © 2018 Tunks dev. All rights reserved.
//

import Foundation
import LanguageTranslatorV3


class Language{
    static func detectedLangauge<T: StringProtocol>(_ forString: T) -> String? {
        guard let languageCode = NSLinguisticTagger.dominantLanguage(for: String(forString)) else {
            return nil
        }
        
       // let detectedLangauge = Locale.current.localizedString(forIdentifier: languageCode)
        return languageCode
    }
}

protocol TranslateHandler {
    func handle<T>(object: T)
}


protocol Translator{
    func translate(text: String, source: String, target: String, handle: TranslateHandler? )
}

extension Translator{
    func translate(text: String, source: String, target: String){
         translate(text: text, source: source, target: target, handle: nil)
    }
}

class WatsonLanguageTranslator : Translator {
    var translator : LanguageTranslator!
  
    private let failure = { (error: Error) in print(error) }
    private let success = { (translation: TranslationResult) -> Void in print(translation) }
    private var modelId = { (source: String, target: String ) -> String in return source+"-"+target}
    /*
     success: { (translation) -> Void in
     print("translation success \(translation)")
     }
     */

    init(){
        translator = LanguageTranslator (version: Credentials.TranslateVersion,
                                         apiKey:  Credentials.TranslateApikey);
        translator.serviceURL = Credentials.TranslateUrl
    }
    
    func translate(text: String, source: String, target: String, handle: TranslateHandler? = nil){
        let  request = TranslateRequest(text: [text], modelID: modelId(source, target),
                                        source: source, target: target )
        self.translator.translate(request: request, failure: failure, success: success)
    }
    
}


 class WastonTranslateHandler: TranslateHandler{
    func handle<TranslationResult>(object: TranslationResult) {
        
    }
}   
