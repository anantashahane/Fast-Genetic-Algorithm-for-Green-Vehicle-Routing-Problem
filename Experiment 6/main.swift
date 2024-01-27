//
//  main.swift
//  Experiment 6
//
//  Created by Ananta Shahane on 24/05/2023.
//

import Foundation

var files = [String]()
let commandLine = CommandLine.arguments
if commandLine.count != 3 {
    files = ReadFiles()
} else {
    switch commandLine[1] {
    case "contains": files = ReadFiles(benchmarkNameContains: commandLine[2])
    case "start": files = ReadFiles(startingFrom: commandLine[2])
    default: print("Expected arguements start <benchmark name> or contains <benchmark name substring.>")
    }
}
let clock = ContinuousClock()
for (index, file) in files.enumerated() {
    let benchmarkName = String(file.split(separator: "/").last!.split(separator: ".").first!)
    for run in 1...10 {
        print("–––––––––––––––––––––––––(\(index + 1)/\(files.count)) \(benchmarkName), run \(run)–––––––––––––––––––––––––")
        print("Run \(run)")
        let ge = GeneticAlgorithm(fileName: file, populationSize: 100, iterationCount: 500)
        var archive = [Routine]()
        let result = clock.measure {
            archive = ge.RunAlgorithm(runNumber: run)
        }
        print("Took \(result).")
        
        if let data = EncodeParetoFront(benchmarkName: String(benchmarkName), frontRoutines: archive, Optimality: ge.optimal) {
            SaveDatatoFile(benchmarkName: benchmarkName, data: data, fileName: "front (\(run))")
        }
        if let data = EncodeConvergence(benchmarkName: String(benchmarkName), distanceVector: ge.convergenceDistanceVector, fuelVector: ge.convergenceFuelVector, OptimalDistance: ge.optimal) {
            SaveDatatoFile(benchmarkName: benchmarkName, data: data, fileName: "convergence (\(run))")
        }
        if let data = ExportBenchmarktoJson(benchmark: benchmarkName, Customers: ge.Customers.values + [ge.Depot], VehicleCapacity: ge.vehicleCapacity, FleetSize: ge.numberOfTrucks, optimal: ge.optimal) {
            SaveDatatoFile(benchmarkName: benchmarkName, data: data, fileName: benchmarkName)
        }
    }
}

