//
//  Readfile.swift
//  Experiment3
//
//  Created by Ananta Shahane on 28/03/2023.
//

import Foundation

func Readfile(filePath : String) -> (Int, [Customer], Int, Int?) {
    var contentFromFile: String = ""
       do {
           // Read file content
           contentFromFile  = try String(contentsOfFile: filePath)
   //        print(contentFromFile)
       }
       catch let error as NSError {
           print("An error took place: \(error)")
       }
    let lines = contentFromFile.split(separator: "\n")
    
    var optimal : Int? = nil
    var capacity = 0
    var currentSection = 0
    var ids = [Int]()
    var xs = [Double]()
    var ys = [Double]()
    var demands = [Int]()
    var numOfTrucks = -1
    for line in lines {
        if line.contains("trucks") {
            let words = line.split(separator: " ").enumerated()
            let count = words.filter({$0.element.contains("truck")}).first!
            var word = words.first(where: {$0.offset == count.offset + 1})!
            word.element = word.element.filter({Int(String($0)) != nil})
            numOfTrucks = Int(word.element)!
        }
        if line.contains("CAPACITY") {
            let words = line.split(separator: " ")
            capacity = Int(words[2]) ?? 0
        }
        if line.contains("Optimal value") || line.contains("Best Value") || line.contains("Best value") {
            let words = line.split(separator: " ")
            let word = String(String(words.last!).split(separator: ")").last!)
            optimal = Int(word)
        }
        else if line.contains("NODE_COORD") {
            currentSection = 1
            continue
        } else if line.contains("DEMAND_SEC"){
            currentSection = 2
            continue
        } else if line.contains("DEPOT_SEC") {
            currentSection = 3
            break
        }
        switch currentSection {
        case 1:
            let words = line.split(separator: " ")
            ids.append(Int(words[0])!)
            xs.append(Double(words[1])!)
            ys.append(Double(words[2])!)
        case 2:
            let words = line.split(separator: " ")
            demands.append(Int(words[1])!)
        default:
            continue
        }
    }
    print("Total demand \(demands.reduce(0, +))" )
    var customers = [Customer]()
    for i in 0..<ids.count {
        customers.append(Customer(id: ids[i], x: xs[i], y: ys[i], demand: demands[i]))
        customers.last!.PrintData()
    }
    print("Number of trucks \(numOfTrucks)")
    return (numOfTrucks, customers, capacity, optimal)
}
