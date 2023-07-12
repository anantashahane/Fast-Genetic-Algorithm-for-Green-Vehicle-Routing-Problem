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
//            CrossoverPopulation()
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
                    print("Generation \(gen) currBest/optimal: \(String(format: "%.2f", distance.min()! * 100 / Double(optimal)))% (\(optimal)): Distance [\(String(format: "%.2f", distance.min()!)), \(String(format: "%.2f", distance.max()!))], Fuel [\(String(format: "%.2f", fuel.min()!)), \(String(format: "%.2f", fuel.max()!))], fronts \(paretoFronts.count), strictness: \(String(format: "%.2f", strictness)), archive size \(archive.GetArchive().count).")
                } else {
                    print("Generation \(gen) Archive Range: Distance [\(String(format: "%.2f", distance.min()!)), \(String(format: "%.2f", distance.max()!))], Fuel [\(String(format: "%.2f", fuel.min()!)), \(String(format: "%.2f", fuel.max()!))], fronts \(paretoFronts.count), strictness: \(strictness), archive size \(archive.GetArchive().count).")
                }
            }
        }
        return archive.GetArchive().sorted(by: {$0.GetFitness(for: .Distance) < $1.GetFitness(for: .Distance)})
    }
    
    func ShareStrictness(generation : Int) {
        if let max = parentPopulation.map({$0.frontNumber}).max() {
            maxFront = max + 1
        }
        strictness = parentPopulation.map({$0.strictness}).reduce(0, +) / Double(parentPopulation.count)
        if generation % 50 == 0 {
            strictness = 1
        }
    }
    
    func GetCustomers() -> [Customer] {
        let customers = Customers.values + [Depot]
        return customers
    }
    
    func GetFronts() -> [[Routine]] {
        return paretoFronts
    }
}
