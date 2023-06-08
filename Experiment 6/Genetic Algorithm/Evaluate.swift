//
//  Evaluate.swift
//  Experiment 6
//
//  Created by Ananta Shahane on 31/05/2023.
//

import Foundation

extension GeneticAlgorithm {
    private func EvaluateDistance(individual : Routine) -> Routine {
        var returnIndividual = individual
        for (index, truck) in returnIndividual.trucks.enumerated() {
            var fitness = 0.0
            var prev = Depot.id
            let sequence = truck.sequence
            for customer in sequence {
                fitness += distanceMatrix[prev][customer]
                prev = customer
            }
            fitness += distanceMatrix[prev][Depot.id]
            returnIndividual.trucks[index].SetScore(token: .Distance, score: fitness)
        }
        return returnIndividual
    }
    
    private func EvaluateFuel(individual : Routine) -> Routine {
        var returnIndividual = individual
        for (index, truck) in returnIndividual.trucks.enumerated() {
            var fitness = 0.0
            var revfitness = 0.0
            
            var prev = Depot.id
            var revPrev = Depot.id
            
            let sequence = truck.sequence
            let reverseSequence = Array(truck.sequence.reversed())
            
            var remainingDemand = Double(truck.GetDemand())
            var revRemainingDemand = Double(truck.GetDemand())
            
            let vehicleCap = Double(vehicleCapacity)
            var consumptionRate = 1.0 + (remainingDemand / vehicleCap)
            var revConsumptionRate = 1.0 + (revRemainingDemand / vehicleCap)
            for index2 in 0..<sequence.count {
                fitness += (consumptionRate * distanceMatrix[prev][sequence[index2]])
                remainingDemand -= Double(Customers[sequence[index2]]!.demand)
                consumptionRate = 1.0 + (remainingDemand / vehicleCap)
                prev = sequence[index2]
                
                revfitness += (revConsumptionRate * distanceMatrix[revPrev][reverseSequence[index2]])
                revRemainingDemand -= Double(Customers[reverseSequence[index2]]!.demand)
                revConsumptionRate = 1.0 + (revRemainingDemand / vehicleCap)
                revPrev = sequence[index2]
                
            }
            fitness += distanceMatrix[prev][Depot.id]
            revfitness += distanceMatrix[revPrev][Depot.id]
            if revfitness < fitness {
                returnIndividual.trucks[index].sequence = reverseSequence
                returnIndividual.trucks[index].SetScore(token: .Fuel, score: revfitness)
            } else {
                returnIndividual.trucks[index].SetScore(token: .Fuel, score: fitness)
            }
        }
        return returnIndividual
    }
    
    func Evaluate(parent : Bool = false) {
        if parent {
            parentPopulation = parentPopulation.map({EvaluateDistance(individual: $0)})
            parentPopulation = parentPopulation.map({EvaluateFuel(individual: $0)})
        }
        offspringPopulation = offspringPopulation.map({EvaluateDistance(individual: $0)})
        offspringPopulation = offspringPopulation.map({EvaluateFuel(individual: $0)})
    }
    
}
