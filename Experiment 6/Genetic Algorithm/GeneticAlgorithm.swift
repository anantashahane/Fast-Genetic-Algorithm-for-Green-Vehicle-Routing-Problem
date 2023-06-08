//
//  GeneticAlgorithm.swift
//  Experiment 6
//
//  Created by Ananta Shahane on 24/05/2023.
//

import Foundation
import PythonKit

class GeneticAlgorithm {
    //Dependancies
    let np = Python.import("numpy")
    
    //Constants.
    let Depot : Customer
    let maxDistance : Double
    let numberOfTrucks : Int
    let vehicleCapacity : Int
    let Customers : [Int : Customer]
    let distanceMatrix : [[Double]]
    let populationSize : Int
    
    //Variables
    var parentPopulation = [Routine]()
    var offspringPopulation = [Routine]()
    var paretoFronts = [[Routine]]()
    var archive = MultiObjectiveArchive(dimensions: [.Distance : .Minimisation, .Fuel : .Minimisation])
    
    init(fileName: String, populationSize: Int) {
        self.populationSize = populationSize
        
        let (numberofTrucks, customers, capacity) = Readfile(filePath: fileName)
        numberOfTrucks = numberofTrucks
        Customers = Dictionary(uniqueKeysWithValues: customers.filter({$0.customerType == .Customer}).map({($0.id, $0)}))
        Depot = customers.filter({$0.customerType == .Depot}).first!
        vehicleCapacity = capacity
        
        (maxDistance, distanceMatrix) = GetDistanceMatrix(Customers: customers)
    }
}
