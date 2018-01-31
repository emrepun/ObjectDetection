//
//  Extensions.swift
//  ObjectDetectionML
//
//  Created by Emre HAVAN on 31.01.2018.
//  Copyright © 2018 Emre HAVAN. All rights reserved.
//

import Foundation


extension Double {
    
    // Extension to round doubles.
    func roundNumber(digitsToShow digit: Int) -> Double {
        let multiplier = pow(10.0, Double(digit))
        return (self*multiplier).rounded()/multiplier
    }
}
