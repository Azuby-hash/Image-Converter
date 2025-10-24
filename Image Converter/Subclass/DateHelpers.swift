//
//  UIVisualOpacity.swift
//  AIArtGenerator
//
//  Created by Tap Dev5 on 14/10/2022.
//

import UIKit

extension Date {
    func relative() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.formattingContext = .beginningOfSentence
        formatter.dateTimeStyle = .named
        
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
