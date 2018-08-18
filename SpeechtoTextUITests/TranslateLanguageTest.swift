//
//  TranslateLanguageTest.swift
//  SpeechtoTextUITests
//
//  Created by Ebrima Tunkara on 8/17/18.
//  Copyright © 2018 Tunks dev. All rights reserved.
//

import XCTest
@testable import SpeechtoText

class TranslateLanguageTest: XCTestCase {
   // var languageTranslate: Translator!
    let sourceText = "Good morning, how are you?"
    let sourceLanguage = "en"
    let targetLanguage = "fr"
    override func setUp() {
        //super.setUp()
        
      //  languageTranslate = WatsonLanguageTranslator()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        //super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        /*languageTranslate.translate(text: sourceText,
                                    source: sourceLanguage,
                                    target: targetLanguage) */
    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
