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
    let iterationCount : Int
    //Variables
    var rouletteCache = [String : [Double]]()
    var parentPopulation = [Routine]()
    var offspringPopulation = [Routine]()
    var paretoFronts = [[Routine]]()
    var archive = MultiObjectiveArchive(dimensions: [.Distance : .Minimisation, .Fuel : .Minimisation])
    var convergenceDistanceVector = [Double]()
    var convergenceFuelVector = [Double]()
    var remainingIterations : Int
    init(fileName: String, populationSize: Int, iterationCount : Int) {
        self.populationSize = populationSize
        
        let (numberofTrucks, customers, capacity, opt) = Readfile(filePath: fileName)
        optimal = opt
        numberOfTrucks = numberofTrucks
        self.iterationCount = iterationCount
        remainingIterations = iterationCount
        Customers = Dictionary(uniqueKeysWithValues: customers.filter({$0.customerType == .Customer}).map({($0.id, $0)}))
        Depot = customers.filter({$0.customerType == .Depot}).first!
        vehicleCapacity = capacity
        (maxDistance, distanceMatrix) = GetDistanceMatrix(Customers: customers)
    }
    
    func RunAlgorithm(runNumber : Int) -> [Routine] {
        Initialise()
        Evaluate(parent: true)
        for gen in 1...iterationCount {
            CrossoverPopulation()
            MutatePopulation()
            Evaluate()
            Selection()
            _ = ArchiveSolution()
//            lastUpdate = success ? generation : lastUpdate
            let distance = archive.GetArchive().map({$0.GetFitness(for: .Distance)})
            let fuel = archive.GetArchive().map({$0.GetFitness(for: .Fuel)})
            convergenceDistanceVector.append(parentPopulation.map({$0.GetFitness(for: .Distance)}).min()!)
            convergenceFuelVector.append(parentPopulation.map({$0.GetFitness(for: .Fuel)}).min()!)
            if (gen % 1 == 0) {
                if let optimal = optimal {
                    print("\t Gen \(runNumber)- \(gen) Convergence: \(String(format: "%.2f", (distance.min()! - Double(optimal)) * 100 / Double(optimal)))% (\(optimal)): Distance [\(String(format: "%.2f", distance.min()!)), \(String(format: "%.2f", distance.max()!))], Fuel [\(String(format: "%.2f", fuel.min()!)), \(String(format: "%.2f", fuel.max()!))], fronts \(paretoFronts.count), gamama : \(String(format: "%.3f", Double(remainingIterations) / Double(iterationCount))), archive size \(archive.GetArchive().count).")
                } else {
                    print("\t Gen \(runNumber)- \(gen) Archive Range: Distance [\(String(format: "%.2f", distance.min()!)), \(String(format: "%.2f", distance.max()!))], Fuel [\(String(format: "%.2f", fuel.min()!)), \(String(format: "%.2f", fuel.max()!))], fronts \(paretoFronts.count), archive size \(archive.GetArchive().count).")
                }
            }
            remainingIterations -= 1
        }
        convergenceDistanceVector.append(parentPopulation.map({$0.GetFitness(for: .Distance)}).min()!)
        convergenceFuelVector.append(parentPopulation.map({$0.GetFitness(for: .Fuel)}).min()!)
        return archive.GetArchive().sorted(by: {$0.GetFitness(for: .Distance) < $1.GetFitness(for: .Distance)})
    }
    
    func GetCustomers() -> [Customer] {
        let customers = Customers.values + [Depot]
        return customers
    }
    
    func GetFronts() -> [[Routine]] {
        return paretoFronts
    }
}
