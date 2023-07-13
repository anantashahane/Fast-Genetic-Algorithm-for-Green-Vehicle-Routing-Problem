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
    let benchmarkName = file.split(separator: "/").last!.split(separator: ".").first!
    print("–––––––––––––––––––––––––(\(index + 1)/\(files.count)) \(benchmarkName)–––––––––––––––––––––––––")
    let ge = GeneticAlgorithm(fileName: file, populationSize: 100)
    var archive = [Routine]()
    let result = clock.measure {
        archive = ge.RunAlgorithm(iterationCount: 500)
    }
    print("Took \(result).")
    
    
//    for (index, individual) in archive.enumerated() {
//        PlotPath(for: individual, of: ge.GetCustomers(), runNumber: 1, id: index + 1, benchmark: String(benchmarkName))
//    }
    if let data = EncodeParetoFront(benchmarkName: String(benchmarkName), frontRoutines: archive, Optimality: ge.optimal) {
        SaveBenchmarkData(benchmarkName: String(benchmarkName), data: data)
    }
    if let data = EncodeConvergence(benchmarkName: String(benchmarkName), distanceVector: ge.convergenceDistanceVector, fuelVector: ge.convergenceFuelVector, OptimalDistance: ge.optimal) {
        SaveConvergence(benchmarkName: String(benchmarkName), CongerenceData: data)
    }
//    PlotParetoFronts(for: ge.GetFronts(), run: -1, benchmark: String(benchmarkName))
//    PlotParetoFronts(for: [archive], run: 1, benchmark: String(benchmarkName))
}

