//
//  VisionProvider.swift
//  ModuleTest
//
//  Created by Azuby on 24/04/2024.
//

import UIKit
import CoreML

class VisionProvider:  MLFeatureProvider {
    var featureNames: Set<String>
    private var featureValues: [String: MLFeatureValue?]
    
    init(values: [String: MLFeatureValue?]) {
        featureNames = Set<String>.init(values.keys)
        featureValues = values
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        return featureValues[featureName] ?? nil
    }
}
