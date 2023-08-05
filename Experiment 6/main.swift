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
    files = ReadFiles(benchmarkNameContains: "A-n32-k5")
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
    print("–––––––––––––––––––––––––(\(index + 1)/\(files.count)) \(benchmarkName)–––––––––––––––––––––––––")
    for run in 1...10 {
        print("Run \(run)")
        let ge = GeneticAlgorithm(fileName: file, populationSize: 100)
        var archive = [Routine]()
        let result = clock.measure {
            archive = ge.RunAlgorithm(iterationCount: 500)
        }
        print("Took \(result).")
        
        if let data = EncodeParetoFront(benchmarkName: String(benchmarkName), frontRoutines: archive, Optimality: ge.optimal) {
            SaveDatatoFile(benchmarkName: benchmarkName, data: data, fileName: "front (\(run))")
        }
        if let data = EncodeConvergence(benchmarkName: String(benchmarkName), distanceVector: ge.convergenceDistanceVector, fuelVector: ge.convergenceFuelVector, OptimalDistance: ge.optimal) {
            SaveDatatoFile(benchmarkName: benchmarkName, data: data, fileName: "convergence (\(run))")
        }
        if let data = ExportBenchmarktoJson(benchmark: benchmarkName, Customers: ge.Customers.values + [ge.Depot]) {
            SaveDatatoFile(benchmarkName: benchmarkName, data: data, fileName: benchmarkName)
        }
    }
}

