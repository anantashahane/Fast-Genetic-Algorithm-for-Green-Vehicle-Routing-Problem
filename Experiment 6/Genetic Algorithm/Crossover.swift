//
//  Crossover.swift
//  Experiment 6
//
//  Created by Ananta Shahane on 03/07/2023.
//

import Foundation

extension GeneticAlgorithm {
    
    func CrossoverPopulation() {
        offspringPopulation = []
        parentPopulation = parentPopulation.shuffled()
        for i in 0..<parentPopulation.count {
            let offspring = Crossover(parent1: parentPopulation[i], parent2: parentPopulation[(i + 1) % parentPopulation.count])
            offspringPopulation.append(offspring)
        }
    }
    
    func Crossover(parent1 : Routine, parent2 : Routine) -> Routine {
        var remainingCustomers = Array(Customers.keys)
        var addedCustomers = [Int]()
        let xPoint = Int.random(in: 1...numberOfTrucks / 2)
        var offspringTrucks = [Truck]()
        var trucks = Array(parent1.trucks.enumerated())
        for _ in 1...xPoint {
            if let truck = trucks.randomElement() {
                offspringTrucks.append(truck.element)
                trucks = trucks.filter({$0.element.GetID() != truck.element.GetID()})
            }
        }
        addedCustomers = offspringTrucks.flatMap({$0.sequence})
        remainingCustomers = remainingCustomers.filter({!addedCustomers.contains($0)})
        trucks = Array(parent2.trucks.enumerated())
        var validity = [(Truck, Int)]()                                                 //Repeatations count for each truck.
        for truck in trucks {
            let repeatations = truck.element.sequence.map({addedCustomers.contains($0) ? 1 : 0}).reduce(0, +)   //Count number of repeating customers.
            validity.append((truck.element, repeatations))
        }
        validity = validity.sorted(by: {$0.1 < $1.1})
        for i in 1...(numberOfTrucks - xPoint) {
            var truck = validity[i].0
            let repeatingCustomers = truck.sequence.filter({addedCustomers.contains($0)})
            for customer in repeatingCustomers {
                _ = truck.RemoveCustomer(customer: Customers[customer]!, allCustomers: Customers.values)
            }
            offspringTrucks.append(truck)
        }
        addedCustomers = offspringTrucks.flatMap({$0.sequence})
        remainingCustomers = remainingCustomers.filter({!addedCustomers.contains($0)})
        for customer in remainingCustomers {
            let candidateTrucks = offspringTrucks.enumerated().sorted(by: {
                GetDotProduct(truck: $0.element, toCustomer: Customers[customer]!, fromCustomer: Depot, maxDistance: maxDistance) > GetDotProduct(truck: $1.element, toCustomer: Customers[customer]!, fromCustomer: Depot, maxDistance: maxDistance)
            }).filter({$0.element.CanAccept(customer: Customers[customer]!, capacity: vehicleCapacity)})
            if let toTruck = SpinRouletteWheel(strictness: 100, onCandidates: candidateTrucks) {
                offspringTrucks[toTruck.offset].AddCustomer(customer: Customers[customer]!, allCustomers: Customers.values)
            }
        }
        addedCustomers = offspringTrucks.flatMap({$0.sequence})
        remainingCustomers = remainingCustomers.filter({!addedCustomers.contains($0)})
        if remainingCustomers.isEmpty {
            return Routine(trucks: offspringTrucks)
        } else {
            return [parent1, parent2].randomElement()!
        }
    }
}
