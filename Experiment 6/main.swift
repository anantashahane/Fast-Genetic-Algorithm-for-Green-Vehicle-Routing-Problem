//
//  main.swift
//  Experiment 6
//
//  Created by Ananta Shahane on 24/05/2023.
//

import Foundation

let learningRate : Double = 2.0
print("Self Adaptation Model with learning rate \(learningRate)")

let commandLineArguements = CommandLine.arguments
var files = [String]()
if commandLineArguements.count < 2 {
    files = ReadFiles(afterName: "A-n32-k5")
} else {
    switch commandLineArguements[1] {
    case "start":
        files = ReadFiles(afterName: commandLineArguements[2])
    case "contains":
        files = ReadFiles(benchmarkNameContains: commandLineArguements[2])
    default:
        print("Expected : start <benchmark name> or contains <benchmark name sub-string>, got \(commandLineArguements[0])")
        files = []
    }
}

let clock = ContinuousClock()
for (index, file) in files.enumerated() {
    let benchmarkName = String(file.split(separator: "/").last!.split(separator: ".").first!)
    for run in 1...10 {
        print("–––––––––––––––––––––––––(\(index + 1)/\(files.count)) \(benchmarkName), run \(run)–––––––––––––––––––––––––")
        let ge = GeneticAlgorithm(fileName: file, populationSize: 100, learningRate: learningRate)
        var archive = [Routine]()
        let result = clock.measure {
            archive = ge.RunAlgorithm(iterationCount: 500)
        }
        print("Took \(result).")
        
        if let data = EncodeParetoFront(benchmarkName: String(benchmarkName), frontRoutines: archive, Optimality: ge.optimal) {
            SaveDatatoFile(benchmarkName: benchmarkName, data: data, fileName: "front \(run)")
        }
        if let data = EncodeConvergence(benchmarkName: String(benchmarkName), distanceVector: ge.convergenceDistanceVector, fuelVector: ge.convergenceFuelVector, OptimalDistance: ge.optimal) {
            SaveDatatoFile(benchmarkName: benchmarkName, data: data, fileName: "convergence \(run)")
        }
        if let data = ExportBenchmarktoJson(benchmark: benchmarkName, Customers: ge.Customers.values + [ge.Depot]) {
            SaveDatatoFile(benchmarkName: benchmarkName, data: data, fileName: benchmarkName)
        }
        if let data = EncodeStrictness(benchmark: benchmarkName, strictnessProgression: ge.strictnessProgression) {
            SaveDatatoFile(benchmarkName: benchmarkName, data: data, fileName: "strictnessProgression \(run)")
        }
    }
}

