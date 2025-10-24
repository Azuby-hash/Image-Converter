//
//  Untitled.swift
//  Photo Stitch
//
//  Created by TapUniverse Dev9 on 3/7/25.
//

import UIKit

extension Array where Element: Equatable {
    func contains(_ element: Element) -> Bool {
        return contains(where: { $0 == element })
    }
    
    func transformArray(to newArray: [Element], add: ((Element, Int) -> Void)?, remove: ((Int) -> Void)?, move: ((Int, Int) -> Void)?) {
        let previous = self

        var result = previous
        var removedIndices: [Int] = []
        var addedElements: [(element: Element, index: Int)] = []

        // Identify removed elements (indices of `previous` not in `newArray`)
        for (index, element) in previous.enumerated() {
            if !newArray.contains(element) {
                removedIndices.append(index)
            }
        }

        // Identify added elements (indices and values in `newArray` not in `previous`)
        for (index, element) in newArray.enumerated() {
            if !previous.contains(element) {
                addedElements.append((element, index))
            }
        }

        // Step 1: Remove elements (in reverse order to maintain index correctness)
        for index in removedIndices.sorted(by: >) {
            result.remove(at: index)
            remove?(index)
        }

        // Step 2: Add elements (adjust insertion indices after removals)
        for (element, index) in addedElements {
            let adjustedIndex = Swift.min(index, result.count) // Ensure the index is within bounds
            result.insert(element, at: adjustedIndex)
            add?(element, adjustedIndex)
        }
        
        // Identify moved elements (indices and values in `newArray` not in `previous`)
        for (expectIndex, expectElement) in newArray.enumerated() {
            for (currentIndex, currentElement) in result.enumerated() {
                if currentElement == expectElement {
                    let element = result.remove(at: currentIndex)
                    result.insert(element, at: expectIndex)
                    move?(currentIndex, expectIndex)
                    break
                }
            }
        }
    }
}

