//
//  LogFront.swift
//  Experiment 6
//
//  Created by Ananta Shahane on 07/07/2023.
//

import Foundation

struct SaveData : Encodable {
    let benchmark : String
    let Optimal : Int?
    let front : [EncodableRoutine]
}

struct EncodableRoutine : Encodable {
    let trucks : [[Int]]
    let distance : Double
    let fuel : Double
}

struct Convergence : Encodable {
    let benchmark : String
    let optimalDistance : Int?
    let distanceSequence : [Double]
    let fuelSequence : [Double]
}

func EncodeParetoFront(benchmarkName : String, frontRoutines : [Routine], Optimality: Int?) -> Data? {
    var routines = [EncodableRoutine]()
    for individual in frontRoutines {
        let routine = EncodableRoutine(trucks: individual.trucks.map({$0.sequence}), distance: individual.GetFitness(for: .Distance), fuel: individual.GetFitness(for: .Fuel))
        routines.append(routine)
    }
    let data = SaveData(benchmark: benchmarkName, Optimal: Optimality, front: routines)
    let jsonEncoder = JSONEncoder()
    if let jsonData = try? jsonEncoder.encode(data) {
        print(jsonData)
        return jsonData
    } else {
        print("Failed to encode \(benchmarkName).")
    }
    return nil
}

func EncodeConvergence(benchmarkName: String, distanceVector : [Double], fuelVector : [Double], OptimalDistance: Int?) -> Data? {
    let Convergence = Convergence(benchmark: benchmarkName, optimalDistance: OptimalDistance, distanceSequence: distanceVector, fuelSequence: fuelVector)
    let encode = JSONEncoder()
    if let data = try? encode.encode(Convergence.self) {
        print("Encoded Convergence")
        return data
    } else {
        print("Convergence Encoding failed.")
        return nil
    }
    
}

func SaveBenchmarkData(benchmarkName : String, data: Data) {
    let fileManager = FileManager()
    let pwd = fileManager.currentDirectoryPath
    print("$pwd: \(pwd)")
    let destinationPath = pwd.appending("/\(benchmarkName)")
    if fileManager.currentDirectoryPath.contains(benchmarkName) {
        print("Found \(benchmarkName)")
    } else {
        try? fileManager.createDirectory(atPath: destinationPath, withIntermediateDirectories: false)
        print("Generated directory \(destinationPath)")
    }
    let destinationFile = destinationPath.appending("/front.json")
    fileManager.createFile(atPath: destinationFile, contents: data)
}

func SaveConvergence(benchmarkName : String, CongerenceData : Data) {
    let fileManager = FileManager()
    let pwd = fileManager.currentDirectoryPath
    let convergenceDestinationPath = pwd.appending("/\(benchmarkName)")
    if fileManager.currentDirectoryPath.contains(benchmarkName) {
        print("Found \(benchmarkName)")
    } else {
        try? fileManager.createDirectory(atPath: convergenceDestinationPath, withIntermediateDirectories: false)
        print("Generated directory \(convergenceDestinationPath)")
    }
    let destinationFile = convergenceDestinationPath.appending("/convergence.json")
    fileManager.createFile(atPath: destinationFile, contents: CongerenceData)
}
