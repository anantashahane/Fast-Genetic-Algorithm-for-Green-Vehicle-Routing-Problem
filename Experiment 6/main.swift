//
//  main.swift
//  Experiment 6
//
//  Created by Ananta Shahane on 24/05/2023.
//

import Foundation

let files = ReadFiles(benchmarkNameContains: nil)
let clock = ContinuousClock()
for (index, file) in files.enumerated() {
    let benchmarkName = String(file.split(separator: "/").last!.split(separator: ".").first!)
    print("–––––––––––––––––––––––––(\(index + 1)/\(files.count)) \(benchmarkName)–––––––––––––––––––––––––")
    let ge = GeneticAlgorithm(fileName: file, populationSize: 100, enableArrogance: false)
    var archive = [Routine]()
    let result = clock.measure {
        archive = ge.RunAlgorithm(iterationCount: 500)
    }
    print("Took \(result).")
    
    if let data = EncodeParetoFront(benchmarkName: String(benchmarkName), frontRoutines: archive, Optimality: ge.optimal) {
        SaveDatatoFile(benchmarkName: benchmarkName, data: data, fileName: "front")
    }
    if let data = EncodeConvergence(benchmarkName: String(benchmarkName), distanceVector: ge.convergenceDistanceVector, fuelVector: ge.convergenceFuelVector, OptimalDistance: ge.optimal) {
        SaveDatatoFile(benchmarkName: benchmarkName, data: data, fileName: "convergence")
    }
    if let data = ExportBenchmarktoJson(benchmark: benchmarkName, Customers: ge.Customers.values + [ge.Depot]) {
        SaveDatatoFile(benchmarkName: benchmarkName, data: data, fileName: benchmarkName)
    }
}

