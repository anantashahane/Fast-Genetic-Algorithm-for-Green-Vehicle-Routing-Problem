//
//  main.swift
//  Experiment 6
//
//  Created by Ananta Shahane on 24/05/2023.
//

import Foundation

let files = ReadFiles(benchmarkNameContains: "A")
let clock = ContinuousClock()
for file in files {
    let benchmarkName = file.split(separator: "/").last!.split(separator: ".").first!
    print("–––––––––––––––––––––––––\(benchmarkName)–––––––––––––––––––––––––")
    
    let ge = GeneticAlgorithm(fileName: file, populationSize: 100)
    let result = clock.measure {
        ge.Initialise()
        ge.Evaluate(parent: true)
        for i in 1...500 {
            let distance = ge.parentPopulation.map({$0.GetFitness(for: .Distance)})
            let fuel = ge.parentPopulation.map({$0.GetFitness(for: .Fuel)})
            print("Generation \(i) Distance [\(String(format: "%.2f", distance.min()!)), \(String(format: "%.2f", distance.max()!))], Fuel [\(String(format: "%.2f", fuel.min()!)), \(String(format: "%.2f", fuel.max()!))], archive size \(ge.archive.GetArchive().count).")
            ge.MutatePopulation()
            ge.Evaluate()
            ge.Selection()
            ge.ArchiveSolution()
        }
    }
    print("Took \(result).")
    for (index, individual) in ge.archive.GetArchive().enumerated() {
        PlotPath(for: individual, of: ge.Customers.values + [ge.Depot], runNumber: 1, id: index + 1, benchmark: String(benchmarkName))
    }
    PlotParetoFronts(for: ge.paretoFronts, run: -1, benchmark: String(benchmarkName))
    PlotParetoFronts(for: [ge.archive.GetArchive()], run: 1, benchmark: String(benchmarkName))
}

