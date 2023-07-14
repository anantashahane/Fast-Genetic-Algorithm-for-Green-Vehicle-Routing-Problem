//
//  GeneticAlgorithm.swift
//  Experiment 6
//
//  Created by Ananta Shahane on 24/05/2023.
//

import Foundation

class GeneticAlgorithm {
    //Constants.
    let Depot : Customer
    let maxDistance : Double
    let numberOfTrucks : Int
    let vehicleCapacity : Int
    let Customers : [Int : Customer]
    let distanceMatrix : [[Double]]
    let populationSize : Int
    let optimal : Int?
    let enableArrogance : Bool
    //Variables
    var convergenceDistanceVector = [Double]()
    var convergenceFuelVector = [Double]()
    var parentPopulation = [Routine]()
    var offspringPopulation = [Routine]()
    var paretoFronts = [[Routine]]()
    var archive = MultiObjectiveArchive(dimensions: [.Distance : .Minimisation, .Fuel : .Minimisation])
    var strictness : Double
    var maxFront = 1
    
    init(fileName: String, populationSize: Int, enableArrogance: Bool) {
        self.populationSize = populationSize
        
        let (numberofTrucks, customers, capacity, opt) = Readfile(filePath: fileName)
        optimal = opt
        numberOfTrucks = numberofTrucks
        Customers = Dictionary(uniqueKeysWithValues: customers.filter({$0.customerType == .Customer}).map({($0.id, $0)}))
        Depot = customers.filter({$0.customerType == .Depot}).first!
        vehicleCapacity = capacity
        
        strictness = parentPopulation.map({$0.strictness}).reduce(0, +) / Double(parentPopulation.count)
        
        (maxDistance, distanceMatrix) = GetDistanceMatrix(Customers: customers)
        self.enableArrogance = enableArrogance
    }
    
    func RunAlgorithm(iterationCount : Int) -> [Routine] {
        Initialise()
        Evaluate(parent: true)
        for gen in 1...iterationCount {
            convergenceDistanceVector.append(parentPopulation.map({$0.GetFitness(for: .Distance)}).min()!)
            convergenceFuelVector.append(parentPopulation.map({$0.GetFitness(for: .Fuel)}).min()!)
            CrossoverPopulation()
            ShareStrictness(generation: gen)
            MutatePopulation()
            Evaluate()
            Selection()
            _ = ArchiveSolution()
//            lastUpdate = success ? generation : lastUpdate
            let distance = archive.GetArchive().map({$0.GetFitness(for: .Distance)})
            let fuel = archive.GetArchive().map({$0.GetFitness(for: .Fuel)})
            if (gen % 1 == 0) {
                if let optimal = optimal {
                    let strictness = parentPopulation.map({$0.strictness})
                    print("Generation \(gen) Convergence: \(String(format: "%.2f", (distance.min()! - Double(optimal)) * 100 / Double(optimal)))% (\(optimal)): Distance [\(String(format: "%.2f", distance.min()!)), \(String(format: "%.2f", distance.max()!))], Fuel [\(String(format: "%.2f", fuel.min()!)), \(String(format: "%.2f", fuel.max()!))], fronts \(paretoFronts.count), strictness: \(String(format: "[%.2f, %.2f], %.2f", strictness.min()!, strictness.max()!, strictness.reduce(0, +) / Double(strictness.count))), archive size \(archive.GetArchive().count).")
                } else {
                    print("Generation \(gen) Archive Range: Distance [\(String(format: "%.2f", distance.min()!)), \(String(format: "%.2f", distance.max()!))], Fuel [\(String(format: "%.2f", fuel.min()!)), \(String(format: "%.2f", fuel.max()!))], fronts \(paretoFronts.count), strictness: \(strictness), archive size \(archive.GetArchive().count).")
                }
            }
        }
        convergenceDistanceVector.append(parentPopulation.map({$0.GetFitness(for: .Distance)}).min()!)
        convergenceFuelVector.append(parentPopulation.map({$0.GetFitness(for: .Fuel)}).min()!)
        return archive.GetArchive().sorted(by: {$0.GetFitness(for: .Distance) < $1.GetFitness(for: .Distance)})
    }
    
    func ShareStrictness(generation : Int) {
        strictness = parentPopulation.map({$0.strictness}).reduce(0, +) / Double(parentPopulation.count)
    }
    
    func GetCustomers() -> [Customer] {
        let customers = Customers.values + [Depot]
        return customers
    }
    
    func GetFronts() -> [[Routine]] {
        return paretoFronts
    }
}
