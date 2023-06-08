//
//  Mutation.swift
//  Experiment 6
//
//  Created by Ananta Shahane on 05/06/2023.
//

import Foundation

extension GeneticAlgorithm {
    
    func MutatePopulation() {
        offspringPopulation = []
        for individual in parentPopulation {
            let randomNumber = Int.random(in: 1...3)
            switch randomNumber {
            case 1: offspringPopulation.append(TSPMutation(individual: individual))
            case 2: offspringPopulation.append(CustomerTransferMutation(individual: individual))
            default: offspringPopulation.append(CustomerExchangeMutation(individual: individual))
            }
        }
    }
    
    func TSPMutation(individual : Routine) -> Routine {
        //Does the Alpha * current distance 2-opt search, an modification of 2-opt mutator, to optimise for searching for more fuel-distance pareto-front.
        var returnIndividual = individual
        if let mutationTruck = returnIndividual.trucks.enumerated().filter({$0.element.sequence.count > 2}).randomElement() {
            if Double.random(in: 0...1) < 0.1 {
                let count = mutationTruck.element.sequence.count
                let randomPoint = Int.random(in: 0..<count)
                let sequence = Array(mutationTruck.element.sequence[randomPoint..<count] + mutationTruck.element.sequence[0..<randomPoint])
                returnIndividual.trucks[mutationTruck.offset].sequence = sequence
            }
            var sequence = mutationTruck.element.sequence
            let alpha = pow(2.71, Double(np.random.normal(0, 1))!) * mutationTruck.element.GetAlpha()
            returnIndividual.trucks[mutationTruck.offset].SetAlpha(to: alpha)
            if let randomCustomer = sequence[0..<sequence.count - 1].randomElement() {
                let randomCustomerIndex = sequence.enumerated().filter({$0.element == randomCustomer}).first!.offset
                let distanceToBeat = distanceMatrix[randomCustomer][sequence[randomCustomerIndex + 1]] * alpha
                let candidateCustomers = sequence.enumerated().filter({distanceMatrix[randomCustomer][$0.offset] < distanceToBeat})
                if let mutationPoint = candidateCustomers.randomElement() {
                    sequence = Array(sequence[0..<min(randomCustomerIndex, mutationPoint.offset)] + sequence[min(randomCustomerIndex, mutationPoint.offset)..<max(randomCustomerIndex, mutationPoint.offset)].reversed() + sequence[max(randomCustomerIndex, mutationPoint.offset)..<sequence.count])
                    returnIndividual.trucks[mutationTruck.offset].sequence = sequence
                }
            }
        }
        return returnIndividual
    }
    
    func CustomerTransferMutation(individual : Routine) -> Routine {
        // Transfers the customers from heaviest truck to the truck that can easily take care of that customer.
        var returnIndividual = individual
        var strictness = pow(2.71, Double(np.random.normal(0,1))!)
        let rouletteTruck = individual.trucks.enumerated().sorted(by: {$0.element.GetDemand() > $1.element.GetDemand()}).filter({!$0.element.sequence.isEmpty})
        if let emitterTruck = SpinRouletteWheel(strictness: strictness, onCandidates: rouletteTruck) {
            let transferCustomerCandidates = emitterTruck.element.GetDistanceSequence(customers: Customers.values)
            strictness = pow(2.71, Double(np.random.normal(1, 1))!)
            let transferCustomerID = SpinRouletteWheel(strictness: strictness, onCandidates: transferCustomerCandidates) ?? transferCustomerCandidates[0]
            let transferCustomer = Customers[transferCustomerID]!
            let truckCandidates = individual.trucks.enumerated().filter({$0.element.GetID() != emitterTruck.element.GetID() && $0.element.CanAccept(customer: transferCustomer, capacity: vehicleCapacity)}).sorted(by: {
                GetDotProduct(truck: $0.element, toCustomer: transferCustomer, fromCustomer: Depot, maxDistance: maxDistance) > GetDotProduct(truck: $1.element, toCustomer: transferCustomer, fromCustomer: Depot, maxDistance: maxDistance)
            })
            strictness = pow(2.71, Double(np.random.normal(0, 1))!)
            if let acceptingTruck = SpinRouletteWheel(strictness: strictness, onCandidates: truckCandidates) {
                _ = returnIndividual.trucks[emitterTruck.offset].RemoveCustomer(customer: transferCustomer, allCustomers: Customers.values)
                returnIndividual.trucks[acceptingTruck.offset].AddCustomer(customer: transferCustomer, allCustomers: Customers.values)
            }
        }
        return returnIndividual
    }
    
    func CustomerExchangeMutation(individual : Routine) -> Routine {
        //Selects two customers from different truck, with minimal exchange cost, and exchanges their assigned truck.
        var returnIndividual = individual
        let candidateTrucks = individual.trucks.enumerated().filter({$0.element.GetDemand() > 0})
        if let transferTruck1 = SpinRouletteWheel(strictness: 0, onCandidates: candidateTrucks) {
            var strictness = pow(2.71, Double(np.random.normal(0, 1))!)
            let t1OutCandidates = transferTruck1.element.GetDistanceSequence(customers: Customers.values)
            let customerfromTruck1ID = SpinRouletteWheel(strictness: strictness, onCandidates: t1OutCandidates) ?? t1OutCandidates[0]
            let customerfromTruck1 = Customers[customerfromTruck1ID]!
            var truckCustomerIDTuple = [(Int, Int)]()
            for truck in individual.trucks.enumerated() where truck.element.GetID() != transferTruck1.element.GetID() {
                for customerID in truck.element.sequence {
                    let customer = Customers[customerID]!
                    if truck.element.IsExchangable(inCustomer: customerfromTruck1, outCustomer: customer, capacity: vehicleCapacity) && transferTruck1.element.IsExchangable(inCustomer: customer, outCustomer: customerfromTruck1, capacity: vehicleCapacity) {
                        truckCustomerIDTuple.append((truck.offset, customerID))
                    }
                }
            }
            truckCustomerIDTuple = truckCustomerIDTuple.sorted(by: {
                GetDotProduct(shadow: Customers[$0.1]!, onCustomer: customerfromTruck1, fromCustomer: Depot, maxDistance: maxDistance) > GetDotProduct(shadow: Customers[$1.1]!, onCustomer: customerfromTruck1, fromCustomer: Depot, maxDistance: maxDistance)})
            strictness = pow(2.71, Double(np.random.normal(1, 1))!)
            if let luckyTruckCustomerID = SpinRouletteWheel(strictness: strictness, onCandidates: truckCustomerIDTuple) {
                let customerfromTruck2 = Customers[luckyTruckCustomerID.1]!
                let t1Index = returnIndividual.trucks[transferTruck1.offset].RemoveCustomer(customer: customerfromTruck1, allCustomers: Customers.values)
                let t2Index = returnIndividual.trucks[luckyTruckCustomerID.0].RemoveCustomer(customer: customerfromTruck2, allCustomers: Customers.values)
                returnIndividual.trucks[transferTruck1.offset].AddCustomer(customer: customerfromTruck2, atIndex: t1Index, allCustomers: Customers.values)
                returnIndividual.trucks[luckyTruckCustomerID.0].AddCustomer(customer: customerfromTruck1, atIndex: t2Index, allCustomers: Customers.values)
            }
        }
        return returnIndividual
    }
}
