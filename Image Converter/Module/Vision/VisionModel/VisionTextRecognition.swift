
//
//  VisionClassifyImage.swift
//  ModuleTest
//
//  Created by Azuby on 26/03/2024.
//

import UIKit
import Vision

enum RecognitionLanguage: String {
    case en_US = "en-US"
    case fr_FR = "fr-FR"
    case it_IT = "it-IT"
    case de_DE = "de-DE"
    case es_ES = "es-ES"
    case pt_BR = "pt-BR"
    case zh_Hans = "zh-Hans"
    case zh_Hant = "zh-Hant"
    case yue_Hans = "yue-Hans"
    case yue_Hant = "yue-Hant"
    case ko_KR = "ko-KR"
    case ja_JP = "ja-JP"
    case ru_RU = "ru-RU"
    case uk_UA = "uk-UA"
    case th_TH = "th-TH"
    case vi_VT = "vi-VT"
}

extension VisionModel {
    /**
     An image analysis request that finds and recognizes text in an image.
     
     By default, a text recognition request first locates all possible glyphs or characters in the input image, and then analyzes each string. To specify or limit the languages to find in the request, set the recognitionLanguages property to an array that contains the names of the languages of text you want to recognize. Vision returns the result of this request in a VNRecognizedTextObservation object.
     
     - Revision 1 or 2 or 3
     */
    @available(iOS 13, *)
    func recognizeText(image: VisionImage, orientation: CGImagePropertyOrientation? = nil, options: [VNImageOption: Any] = [:],
                       revision: Int = 3, minimumTextHeight: Float = 1 / 32.0, recognitionLevel: VNRequestTextRecognitionLevel,
                       automaticallyDetectsLanguage: Bool, recognitionLanguages: [RecognitionLanguage]? = nil,
                       usesLanguageCorrection: Bool = true, customWords: [String] = [],
                       for sequenceHandler: VNSequenceRequestHandler? = nil) -> VNRecognizeTextRequest {
        let request = VNRecognizeTextRequest()
        request.minimumTextHeight = minimumTextHeight
        
        if #available(iOS 16.0, *) {
            request.automaticallyDetectsLanguage = automaticallyDetectsLanguage
        }
        
        request.usesLanguageCorrection = usesLanguageCorrection
        request.recognitionLevel = recognitionLevel
        
        request.revision = revision
        
        if let recognitionLanguages = recognitionLanguages {
            request.recognitionLanguages = recognitionLanguages.map({ language in
                return language.rawValue
            })
        }
        
        request.customWords = customWords
        
        if let sequenceHandler = sequenceHandler {
            image.performRequests(requests: [request], for: sequenceHandler, orientation: orientation)
        } else {
            let handler = image.createImageHandler(orientation: orientation, options: options)
            try? handler.perform([request])
        }
        
        return request
    }
}
