//
//  Customer.swift
//  Experiment 4
//
//  Created by Ananta Shahane on 19/04/2023.
//

import Foundation

enum CustomerType {
    case Depot
    case Customer
}

class Customer {
    let id : Int
    let customerType : CustomerType
    let x : Double
    let y : Double
    let demand : Int
    
    init(id: Int, x: Double, y: Double, demand: Int) {
        self.id = id
        customerType = demand == 0 ? .Depot : .Customer
        self.x = x
        self.y = y
        self.demand = demand
    }
    
    func PrintData() {
        if customerType == .Depot {
            print("Depot @(\(x), \(y))")
        } else {
            print("Customer \(id) @(\(x), \(y)), demand \(demand)")
        }
    }
}
