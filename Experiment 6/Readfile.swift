//
//  Readfile.swift
//  Experiment3
//
//  Created by Ananta Shahane on 28/03/2023.
//

import Foundation

func Readfile(filePath : String) -> (Int, [Customer], Int, Int?) {
    var customers = [Customer]()
    var numOfTrucks = 0
    var capacity = 0
    var optimal : Int? = nil
    if let fileData = FileManager().contents(atPath: filePath) {
        let decoder = JSONDecoder()
        if let content = try? decoder.decode(EncodedBenchmark.self, from: fileData) {
            print("Decoded \(content.benchmark)")
            customers = content.customers.map({Customer(id: $0.id, x: $0.x, y: $0.y, demand: $0.demand)}).sorted(by: {$0.id < $1.id})
            for customer in customers {
                if customer.customerType == .Depot {
                    print("\tDepot @ (\(customer.x), \(customer.y)")
                } else {
                    print("\tCustomer \(customer.id) @ (\(customer.x), \(customer.y)), demand \(customer.demand)")
                }
            }
            numOfTrucks = content.fleetSize
            capacity = content.vehicleCapcity
            optimal = content.optimal
            print("——————————————————————————————————————————————————————")
            print("Total Demand \(customers.map({$0.demand}).reduce(0, +)), Capacity \(capacity), Fleet Size \(numOfTrucks), Demand / Fleet = \(Double(customers.map({$0.demand}).reduce(0, +)) / Double(numOfTrucks))")
            return (numOfTrucks, customers, capacity, optimal)
        } else {
            print("File \(filePath) decode error.")
        }
    } else {
        print("File \(filePath) open error.")
    }
    return (numOfTrucks, customers, capacity, optimal)
}

