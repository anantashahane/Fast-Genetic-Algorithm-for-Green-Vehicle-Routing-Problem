//
//  Roulette.swift
//  Experiment 6
//
//  Created by Ananta Shahane on 02/06/2023.
//

import Foundation

extension GeneticAlgorithm {
    private func GenerateRouletteWheel(strictness: Double, length: Int) -> [Double] {
        // Support function for following functions.
            // Generates a roulettewheel of given size and strictness.
        if length < 1 {
            return []
        }
        var probabilityDistribution = [Double]()
        let selectionPressure = 1/Double(length)
        var px : Double = 0
        for x in 1...length {
            px += pow((1 - selectionPressure), strictness * Double(x - 1)) * selectionPressure
            probabilityDistribution.append(px)
        }
        probabilityDistribution = probabilityDistribution.map({$0/px})
        return probabilityDistribution
    }
    
    func SpinRouletteWheel<T>(strictness: Double, onCandidates: [T]) -> T? {
        //Accept an array of contents, and spins the roulette wheel on it, returns the values with decreasing probability with increase in index.
            //First elements are more likely to be returned.
        if onCandidates.count == 0 {
            return nil
        }
        let rouletteWheel = GenerateRouletteWheel(strictness: strictness, length: onCandidates.count)
        let randomNumber = Double.random(in: 0...1)
        var returnIndex = 0
        for (index, value) in rouletteWheel.enumerated() {
            if value > randomNumber {
                returnIndex = index
                break
            }
        }
        return onCandidates[returnIndex]
    }
}
