//
//  Mutation.swift
//  Experiment 6
//
//  Created by Ananta Shahane on 05/06/2023.
//

import Foundation

extension GeneticAlgorithm {
    
    func MutatePopulation() {
        var newOffspringPopulation = [Routine]()
        for individual in parentPopulation {
            let randomNumber = SpinRouletteWheel(strictness: 2, onCandidates: Array(1...5))
            switch randomNumber {
            case 1: newOffspringPopulation.append(TSPMutation(individual: individual))
            case 2: newOffspringPopulation.append(LNS(individual: individual))
            case 3: newOffspringPopulation.append(CustomerExchangeMutation(individual: individual))
            case 4: newOffspringPopulation.append(TruckCrossover(individual: individual))
            default: newOffspringPopulation.append(CustomerTransferMutation(individual: individual))
            }
        }
        offspringPopulation = newOffspringPopulation
        //        print("\tUsage data: [2OptM, CTM, CEM, TX, LNS]: \(usageData).")
    }
    
    private func TSPMutation(individual : Routine) -> Routine {
        //Does the Alpha * current distance 2-opt search, an modification of 2-opt mutator, to optimise for searching for more fuel-distance pareto-front.
        var returnIndividual = individual
        if Double.random(in: 0...1) < 0.1 {
            if let mutationTruck = returnIndividual.trucks.enumerated().filter({!$0.element.sequence.isEmpty}).randomElement() {
                let count = mutationTruck.element.sequence.count
                let randomPoint = Int.random(in: 0..<count)
                let sequence = Array(mutationTruck.element.sequence[randomPoint..<count] + mutationTruck.element.sequence[0..<randomPoint])
                returnIndividual.trucks[mutationTruck.offset].sequence = sequence
                return returnIndividual
            }
        }
        if let mutationTruck = returnIndividual.trucks.enumerated().filter({$0.element.sequence.count > 2}).randomElement() {
            var sequence = mutationTruck.element.sequence
            let alpha = pow(2.71, Double.NormalRandom(mu: 0, sigma: 1)) * mutationTruck.element.GetAlpha()
            returnIndividual.trucks[mutationTruck.offset].SetAlpha(to: alpha)
            if let randomCustomer = sequence[0..<sequence.count - 1].randomElement() {
                let randomCustomerIndex = sequence.enumerated().filter({$0.element == randomCustomer}).first!.offset
                let distanceToBeat = distanceMatrix[randomCustomer][sequence[randomCustomerIndex + 1]] * alpha
                let candidateCustomers = sequence.enumerated().filter({distanceMatrix[randomCustomer][$0.element] < distanceToBeat}).sorted(by: {distanceMatrix[randomCustomer][$0.element] < distanceMatrix[randomCustomer][$1.element]})
                let strictness = CalculateStrictness(routine: individual)
                if let mutationPoint = SpinRouletteWheel(strictness: strictness, onCandidates: candidateCustomers) {
                    sequence = Array(sequence[0..<min(randomCustomerIndex, mutationPoint.offset) + 1] + sequence[min(randomCustomerIndex, mutationPoint.offset) + 1..<max(randomCustomerIndex, mutationPoint.offset) + 1].reversed() + sequence[max(randomCustomerIndex, mutationPoint.offset) + 1..<sequence.count])
                    returnIndividual.trucks[mutationTruck.offset].sequence = sequence
                } else {
                    let count = mutationTruck.element.sequence.count
                    let randomPoint = Int.random(in: 0..<count)
                    let sequence = Array(mutationTruck.element.sequence[randomPoint..<count] + mutationTruck.element.sequence[0..<randomPoint])
                    returnIndividual.trucks[mutationTruck.offset].sequence = sequence
                }
            }
        }
        return returnIndividual
    }
    
    private func CustomerTransferMutation(individual : Routine) -> Routine {
        // Transfers the customers from heaviest truck to the truck that can easily take care of that customer.
        var returnIndividual = individual
        var strictness = 0.0
        let rouletteTruck = individual.trucks.enumerated().filter({!$0.element.sequence.isEmpty})
        if let emitterTruck = SpinRouletteWheel(strictness: strictness, onCandidates: rouletteTruck) {
            let transferCustomerCandidates = emitterTruck.element.GetDistanceSequence(customers: Customers.values)
            strictness = CalculateStrictness(routine: individual)
            let transferCustomerID = SpinRouletteWheel(strictness: strictness, onCandidates: transferCustomerCandidates) ?? transferCustomerCandidates[0]
            let transferCustomer = Customers[transferCustomerID]!
            let truckCandidates = individual.trucks.enumerated().filter({$0.element.GetID() != emitterTruck.element.GetID() && $0.element.CanAccept(customer: transferCustomer, capacity: vehicleCapacity)}).sorted(by: {
                GetDotProduct(truck: $0.element, toCustomer: transferCustomer, fromCustomer: Depot, maxDistance: maxDistance) > GetDotProduct(truck: $1.element, toCustomer: transferCustomer, fromCustomer: Depot, maxDistance: maxDistance)
            })
            if let acceptingTruck = SpinRouletteWheel(strictness: strictness, onCandidates: truckCandidates) {
                _ = returnIndividual.trucks[emitterTruck.offset].RemoveCustomer(customer: transferCustomer, allCustomers: Customers.values)
                let customers = acceptingTruck.element.sequence.enumerated().sorted(by: {
                    GetDotProduct(shadow: Customers[$0.element]!, onCustomer: transferCustomer, fromCustomer: Depot, maxDistance: maxDistance) > GetDotProduct(shadow: Customers[$1.element]!, onCustomer: transferCustomer, fromCustomer: Depot, maxDistance: maxDistance)
                })
                if customers.isEmpty {
                    returnIndividual.trucks[acceptingTruck.offset].AddCustomer(customer: transferCustomer, allCustomers: Customers.values)
                } else {
                    returnIndividual.trucks[acceptingTruck.offset].AddCustomer(customer: transferCustomer, atIndex: customers[0].offset, allCustomers: Customers.values)
                }
            }
        }
        return returnIndividual
    }
    
    private func CustomerExchangeMutation(individual : Routine) -> Routine {
        //Selects two customers from different truck, with minimal exchange cost, and exchanges their assigned truck.
        var returnIndividual = individual
        let candidateTrucks = individual.trucks.enumerated().filter({$0.element.GetDemand() > 0})
        if let transferTruck1 = SpinRouletteWheel(strictness: 0, onCandidates: candidateTrucks) {
            let strictness = CalculateStrictness(routine: individual)
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
    
    private func TruckCrossover(individual : Routine) -> Routine {
        var returnIndividual = individual
        var remainingTrucks = Array(returnIndividual.trucks.enumerated())
        var truck1 = SpinRouletteWheel(strictness: 0, onCandidates: remainingTrucks)!
        remainingTrucks = remainingTrucks.filter({$0.offset != truck1.offset}).filter({$0.element.sequence.count > 1})
        remainingTrucks = remainingTrucks.sorted(by: {
            GetDotProduct(projector: $0.element, projectee: truck1.element, fromCustomer: Depot, maxDistance: maxDistance) > GetDotProduct(projector: $1.element, projectee: truck1.element, fromCustomer: Depot, maxDistance: maxDistance)
        })
        let strictness = CalculateStrictness(routine: individual)
        var truck2 = SpinRouletteWheel(strictness: strictness, onCandidates: remainingTrucks)!
        
        if truck1.element.sequence.isEmpty {
            let splitPoint = Int.random(in: 1..<truck2.element.sequence.count)
            let seq = truck2.element.sequence[splitPoint..<truck2.element.sequence.count]
            for individualID in seq {
                truck1.element.AddCustomer(customer: Customers[individualID]!, allCustomers: Customers.values)
                _ = truck2.element.RemoveCustomer(customer: Customers[individualID]!, allCustomers: Customers.values)
            }
            returnIndividual.trucks[truck1.offset] = truck1.element
            returnIndividual.trucks[truck2.offset] = truck2.element
        } else {
            if truck1.element.sequence.count > 1 {
                let splitPoint1 = Int.random(in: 1..<truck1.element.sequence.count)
                let seq1Pt2 = truck1.element.sequence[splitPoint1..<truck1.element.sequence.count]
                let Truck2inCustomers = seq1Pt2.map({Customers[$0]!})
                var truck2OutCustomers = truck2.element.sequence[truck2.element.sequence.count - 1..<truck2.element.sequence.count].map({Customers[$0]!})
                for i in 1..<truck2.element.sequence.count {
                    truck2OutCustomers = truck2.element.sequence[truck2.element.sequence.count - i..<truck2.element.sequence.count].map({Customers[$0]!})
                    if truck2.element.IsExchangable(inCustomers: Truck2inCustomers, outCustomers: truck2OutCustomers, capacity: vehicleCapacity) {
                        break
                    }
                }
                if truck1.element.IsExchangable(inCustomers: truck2OutCustomers, outCustomers: Truck2inCustomers, capacity: vehicleCapacity) {
                    for customer in Truck2inCustomers {
                        _ = truck1.element.RemoveCustomer(customer: customer, allCustomers: Customers.values)
                    }
                    for customer in truck2OutCustomers {
                        _ = truck2.element.RemoveCustomer(customer: customer, allCustomers: Customers.values)
                        truck1.element.AddCustomer(customer: customer, allCustomers: Customers.values)
                    }
                    for customer in Truck2inCustomers {
                        truck2.element.AddCustomer(customer: customer, allCustomers: Customers.values)
                    }
                    if truck1.element.GetDemand() <= vehicleCapacity && truck2.element.GetDemand() <= vehicleCapacity {
                        returnIndividual.trucks[truck1.offset] = truck1.element
                        returnIndividual.trucks[truck2.offset] = truck2.element
                    }
                }
            }
        }
        return returnIndividual
    }
    
    private func LNS(individual : Routine) -> Routine {
        var freeCustomerIDs = [Int]()
        var returnIndividual = individual
        let strictness1 = CalculateStrictness(routine: individual)
        let strictness0 = sqrt(strictness1)
        for (id, truck) in returnIndividual.trucks.enumerated() {
            let emitterCount = Int.random(in: 0...(5 * truck.sequence.count / 6))
            if emitterCount != 0 {
                var customers = truck.GetDistanceSequence(customers: Customers.values)
                for _ in 1...emitterCount {
                    if let emittedCustomer = SpinRouletteWheel(strictness: strictness0, onCandidates: customers) {
                        freeCustomerIDs.append(emittedCustomer)
                        customers = customers.filter({$0 != emittedCustomer})
                        _ = returnIndividual.trucks[id].RemoveCustomer(customer: Customers[emittedCustomer]!, allCustomers: Customers.values)
                    }
                }
            }
        }
        let freeCustomers = freeCustomerIDs.map({Customers[$0]!})
        for customer in freeCustomers {
            let candidateTrucks = returnIndividual.trucks.enumerated().filter({$0.element.CanAccept(customer: customer, capacity: vehicleCapacity)}).sorted(by:{
                GetDotProduct(truck: $0.element, toCustomer: customer, fromCustomer: Depot, maxDistance: maxDistance) > GetDotProduct(truck: $1.element, toCustomer: customer, fromCustomer: Depot, maxDistance: maxDistance)
            })
            if let truck = SpinRouletteWheel(strictness: strictness1, onCandidates: candidateTrucks) {
                let targetCustomerIDs = truck.element.sequence.enumerated()
                let customers = targetCustomerIDs.map({($0.offset, Customers[$0.element]!)}).sorted(by: {
                    GetDotProduct(shadow: $0.1, onCustomer: customer, fromCustomer: Depot, maxDistance: maxDistance) > GetDotProduct(shadow: $1.1, onCustomer: customer, fromCustomer: Depot, maxDistance: maxDistance)
                })
                if customers.isEmpty {
                    returnIndividual.trucks[truck.offset].AddCustomer(customer: customer, allCustomers: Customers.values)
                } else {
                    returnIndividual.trucks[truck.offset].AddCustomer(customer: customer, atIndex: customers[0].0, allCustomers: Customers.values)
                }
                freeCustomerIDs = freeCustomerIDs.filter({$0 != customer.id})
            }
        }
        if !freeCustomerIDs.isEmpty {
            return individual
        }
        return returnIndividual
    }

    private func CalculateStrictness(routine : Routine) -> Double {
        let strictness = Double(routine.frontNumber) / Double(paretoFronts.count) * pow(2.71, log(Double(Customers.count)))   
        return strictness
    }
}

