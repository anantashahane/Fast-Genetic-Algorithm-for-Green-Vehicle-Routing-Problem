//
//  Initialise.swift
//  Experiment 6
//
//  Created by Ananta Shahane on 24/05/2023.
//

import Foundation

extension GeneticAlgorithm {
    
    func Initialise() {
        archive.ClearArchive()
        for _ in 1...populationSize {
//            if i % 10 == 0 {print("Generating individual \(i)")}
            var flag = false
            var individual = Routine(trucks: [], averageStrictness: Double(Customers.count / 2))
            while !flag {
                (flag, individual) = GetSeed(balanced: Bool.random())
            }
            individual.strictness = Double(Customers.count/2)
            parentPopulation.append(individual)
        }
    }
    
    private func GetSeed(balanced : Bool) -> (Bool, Routine) {
        var trucks = [Truck]()
        var remainingCustomers = Array(Customers.values)
        let totalDemand = remainingCustomers.map({$0.demand}).reduce(0, +)
        for _ in 0..<numberOfTrucks {
            var truck = Truck(sequenceOfCustomers: [])
            var flag = true
            while flag {
                if remainingCustomers.isEmpty {
                    flag = false
                }
                if truck.sequence.isEmpty {
                    if let candidateCustomer = remainingCustomers.filter({truck.CanAccept(customer: $0, capacity: vehicleCapacity)}).randomElement() {
                        truck.AddCustomer(customer: candidateCustomer, allCustomers: Customers.values)
                        remainingCustomers = remainingCustomers.filter({$0.id != candidateCustomer.id})
                    }
                } else {
                    let lastCustomer = Customers[truck.sequence.last!]!
                    if let candidateCustomer = remainingCustomers.filter({truck.CanAccept(customer: $0, capacity: vehicleCapacity)}).sorted(by: {
                        GetDotProduct(shadow: $0, onCustomer: lastCustomer, fromCustomer: Depot, maxDistance: maxDistance) > GetDotProduct(shadow: $1, onCustomer: lastCustomer, fromCustomer: Depot, maxDistance: maxDistance)}).first {
                        truck.AddCustomer(customer: candidateCustomer, allCustomers: Customers.values)
                        remainingCustomers = remainingCustomers.filter({$0.id != candidateCustomer.id})
                    } else {
                        flag = false
                    }
                    if truck.GetDemand() > totalDemand / numberOfTrucks || balanced {
                        flag = false
                    }
                }
            }
            trucks.append(truck)
        }
        return (remainingCustomers.isEmpty, Routine(trucks: trucks, averageStrictness: Double(Customers.count / 2)))
    }
}
