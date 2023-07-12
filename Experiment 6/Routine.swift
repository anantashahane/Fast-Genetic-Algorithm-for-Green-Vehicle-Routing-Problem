//
//  Routine.swift
//  Experiment 5
//
//  Created by Ananta Shahane on 29/04/2023.
//

import Foundation

enum Optimiser : String {
    case PathOptimiser = "Path Optimiser"
    case TransferCustomer = "Transfer Customer"
    case CrossOver = "Crossover"
}


enum ObjectiveParameter : String {
    case Distance = "Distance"
    case Fuel = "Fuel"
}

enum ObjectiveDirection {
    case Minimisation
    case Maximisation
}

struct Truck {
    var sequence : [Int]
    private var alpha : Double
    private var alphaRange : (Double, Double)
    private var demand : Int
    private var scores : [ObjectiveParameter : Double]
    private var CentreOfMass : (Double, Double)
    init(sequenceOfCustomers : [Dictionary<Int, Customer>.Value]) {
        sequence = sequenceOfCustomers.map({$0.id})
        alpha = 1
        alphaRange = (1, 1)
        demand = sequenceOfCustomers.map({$0.demand}).reduce(0, +)
        scores = [:]
        CentreOfMass = (sequenceOfCustomers.map({$0.x}).reduce(0, +) / Double(sequenceOfCustomers.count), sequenceOfCustomers.map({$0.y}).reduce(0, +) / Double(sequenceOfCustomers.count))
        UpdateAlphaRange(customers: sequenceOfCustomers)
        
    }
    
    func GetID() -> String {
        return "\(sequence)"
    }
    
    func GetScore(objective : ObjectiveParameter) -> Double {
        if let score = scores[objective] {
            return score
        }
        return Double.infinity
    }
    
    func GetAlpha() -> Double {
        return alpha
    }
    
    mutating func SetAlpha(to : Double) {
        if to <= alphaRange.1 && to >= alphaRange.0 {
            self.alpha = to
        } else {
            self.alpha = 1
        }
    }
    
    func isValid(capacity : Int, customerList : Dictionary<Int, Customer>.Values) -> Bool {
        return capacity >= customerList.filter({sequence.contains($0.id)}).map({$0.demand}).reduce(0, +)
    }
    
    func GetCentreOfMass() -> (Double, Double) {
        return CentreOfMass
    }
    
    func GetDemand() -> Int {
        return demand
    }
    
    func CanAccept(customer : Dictionary<Int, Customer>.Value, capacity : Int) -> Bool {
        return capacity >= demand + customer.demand
    }
    
    func GetScores() -> [ObjectiveParameter : Double] {
        return scores
    }
    
    private mutating func UpdateAlphaRange(customers : [Dictionary<Int , Customer>.Value]) {
        var maxDistance = 0.0
        var minDistance = Double.infinity
        
        for customer1 in customers {
            for customer2 in customers {
                if customer1.id != customer2.id {
                    let distance = GetDistance(customer1: customer1, customer2: customer2)
                    if maxDistance < distance {
                        maxDistance = distance
                    }
                    if minDistance > distance {
                        minDistance = distance
                    }
                }
            }
        }
        alphaRange = (minDistance/maxDistance, maxDistance/minDistance)
    }
    
    private func GetDistace(customer : Customer) -> Double {
        return sqrt(
            pow(CentreOfMass.0 - customer.x, 2) + pow(CentreOfMass.1 - customer.y, 2)
        )
    }
    
    func GetRadius(with Customers : [Customer]) -> Double {
        let radius = Customers.map({GetDistace(customer: $0)}).reduce(0, +) / Double(Customers.count)
        return radius
    }
    
    mutating func AddCustomer(customer : Customer, atIndex : Int? = nil, allCustomers : Dictionary<Int, Customer>.Values) {
        if !sequence.contains(customer.id) {
            if let atIndex = atIndex {
                sequence.insert(customer.id, at: atIndex)
            } else {
                sequence.append(customer.id)
            }
            demand = allCustomers.filter({sequence.contains($0.id)}).map({$0.demand}).reduce(0, +)
            UpdateAlphaRange(customers: allCustomers.filter({sequence.contains($0.id)}))
            UpdateCentreofMass(customerList: allCustomers)
        }
        
    }
    
    mutating private func UpdateCentreofMass(customerList : Dictionary<Int, Customer>.Values) {
        self.CentreOfMass = (
            customerList.filter({sequence.contains($0.id)}).map({$0.x}).reduce(0, +) / Double(sequence.count),
            customerList.filter({sequence.contains($0.id)}).map({$0.y}).reduce(0, +) / Double(sequence.count)
        )
    }
    
    mutating func RemoveCustomer(customer : Customer, allCustomers : Dictionary<Int, Customer>.Values) -> Int? {
        let removedElement = sequence.enumerated().filter({$0.element == customer.id})
        if sequence.contains(customer.id) {
            sequence = sequence.filter({ $0 != customer.id })
            demand = allCustomers.filter({sequence.contains($0.id)}).map({$0.demand}).reduce(0, +)
            UpdateAlphaRange(customers: allCustomers.filter({sequence.contains($0.id)}))
            UpdateCentreofMass(customerList: allCustomers)
        }
        return removedElement.first?.offset
    }
    
    func GetDistanceSequence(customers : Dictionary<Int, Customer>.Values) -> [Int] {
        let customs = customers.filter({sequence.contains($0.id)})
        let returnSequence = customs.sorted(by: {
            GetDistace(customer: $0) > GetDistace(customer: $1)
        }).map({$0.id})
        return returnSequence
    }
    
    func IsExchangable(inCustomer : Dictionary<Int, Customer>.Value, outCustomer: Dictionary<Int, Customer>.Value, capacity : Int) -> Bool {
        return capacity >= demand - outCustomer.demand + inCustomer.demand
    }
    
    func IsExchangable(inCustomers : [Dictionary<Int, Customer>.Value], outCustomers: [Dictionary<Int, Customer>.Value], capacity : Int) -> Bool {
        let inDemand = inCustomers.map({$0.demand}).reduce(0, +)
        let outDemand = outCustomers.map({$0.demand}).reduce(0, +)
        return capacity >= demand - outDemand + inDemand
    }
    
    mutating func SetScore(token : ObjectiveParameter, score : Double) {
        self.scores[token] = score
    }
    
    
    func PrintData() {
        print("Sequence : \(sequence) of demand \(demand)")
        print("\tScore [Distance : \(GetScore(objective: .Distance)), Fuel : \(GetScore(objective: .Fuel))]")
        print("\tAlpha \(alpha)")
        print("\tCentre of mass (\(CentreOfMass.0), \(CentreOfMass.1)).")
        print("–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––")
    }
    
    func PrintRoutineData() {
        print("\tTruck \(sequence), with fitness \(self.scores.map({($0.key.rawValue, $0.value)})), demand \(demand).")
    }
}

//MARK: - Truck
struct Routine {
    var trucks : [Truck]
    var strictness : Double
    var dominatesSetIndex = [Int]()                 //Set of individuals that this individual dominate.
    var dominatedByNumber = 0                       //Count of individual that dominates this individual.
    var rank = 0
    var frontNumber = 0
    
    init(trucks: [Truck]) {
        self.trucks = trucks
        strictness = 1
    }
    
    func GetID() -> String {
        return trucks.map({$0.GetID()}).reduce("", +)
    }
    
    func PrintData() {
        print("Routine with demand \(trucks.map({$0.GetDemand()}).reduce(0, +)).")
        for truck in trucks {
            truck.PrintRoutineData()
        }
        print("Fitness (\(trucks.map({$0.GetScore(objective: .Distance)}).reduce(0, +)) km, \(trucks.map({$0.GetScore(objective: .Fuel)}).reduce(0, +)) l.)")
    }
    
    func GetFitness(for token : ObjectiveParameter) -> Double {
        return trucks.map({$0.GetScore(objective: token)}).reduce(0, +)
    }
    
    func GetAllFitness() -> [ObjectiveParameter : Double] {
        var fitness = [ObjectiveParameter : Double]()
        fitness[.Distance] = trucks.map({$0.GetScore(objective: .Distance)}).reduce(0, +)
        fitness[.Fuel] = trucks.map({$0.GetScore(objective: .Fuel)}).reduce(0, +)
        return fitness
    }
    
    func Dominates(other: Routine) -> Bool {
        let myFitness = GetAllFitness()
        let othersFitness = other.GetAllFitness()
        for key in myFitness.keys {
            if myFitness[key]! > othersFitness[key]! {
                return false
            }
        }
        return true
    }
    
    func GetRadiusSequence(with Customers : [Customer]) -> [Truck] {
        var CustomerSet = [[Customer]]()
        for truck in trucks {
            CustomerSet.append(Customers.filter({truck.sequence.contains($0.id)}))
        }
        let returnTrucks = trucks.enumerated().sorted(by: {
            $0.element.GetRadius(with: CustomerSet[$0.offset]) > $1.element.GetRadius(with: CustomerSet[$1.offset])
        }).map({$0.element})
        return returnTrucks
    }
    
    mutating func UpdateStrictness(globalStrictness: Double, usingArrogance : Bool, frontCount : Int) {
        if !usingArrogance {
            let strictness = globalStrictness * pow(2.71, Double.NormalRandom(mu: 0, sigma: 1))
            self.strictness = strictness
        } else {
            let strictness = globalStrictness * pow(2.71, Double.NormalRandom(mu: 0, sigma: 2))
            let arrogance = 1.0 / (1.0 + pow(2.71, Double(frontNumber - frontCount)))
            self.strictness = (self.strictness * arrogance) + (strictness * (1 - arrogance))
        }
    }
}
