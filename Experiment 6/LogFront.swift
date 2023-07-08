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

func SaveFront(data: Data, benchmarkName : String) {
    let fileManager = FileManager()
    let pwd = fileManager.currentDirectoryPath
    print("$pwd: \(pwd)")
    let destinationPath = pwd.appending("/\(benchmarkName)/front.json")
    fileManager.createFile(atPath: destinationPath, contents: data)
}
