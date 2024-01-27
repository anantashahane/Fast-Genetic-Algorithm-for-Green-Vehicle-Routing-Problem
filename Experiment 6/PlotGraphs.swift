//
//  PlotGraphs.swift
//  Experiment3
//
//  Created by Ananta Shahane on 29/03/2023.
//

import Foundation
import PythonKit

let plt = Python.import("matplotlib.pyplot")
let mpl = Python.import("matplotlib")
let os = Python.import("os")

func CreateFolder(named: String) {
    let parentFolder = "."
    let path = os.path.join(parentFolder, named)
    let directoryContents = "\(os.listdir(path: parentFolder))"
    if !directoryContents.contains(named) {
        os.mkdir(path)
    }
}

func PlotPath(for routine: Routine, of customers: [Customer], runNumber: Int, id: Int, benchmark: String) {
    CreateFolder(named: benchmark)
    let Customers = Dictionary(uniqueKeysWithValues: customers.map({($0.id, $0)}))
    
    let depotX = customers.filter({$0.customerType == .Depot}).map({$0.x})
    let depotY = customers.filter({$0.customerType == .Depot}).map({$0.y})
    plt.figure(figsize: [16, 16])
    let colorMap = mpl.cm.get_cmap("plasma", routine.trucks.count).colors
    plt.scatter(x: customers.map({$0.x}), y: customers.map({$0.y}), c: "black")
    for (index, truck) in routine.trucks.enumerated() {
        var servX = depotX
        var servY = depotY
        for customer in truck.sequence {
            servX.append(Customers[customer]!.x)
            servY.append(Customers[customer]!.y)
        }
        servX += depotX
        servY += depotY
        var posX = depotX
        posX += customers.filter({truck.sequence.contains($0.id)}).map({$0.x})
        posX += depotX
        var posY = depotY
        posY += customers.filter({truck.sequence.contains($0.id)}).map({$0.y})
        posY += depotY
        
        
        
        plt.plot(servX, servY, linewidth: 1.2, c: colorMap[index], label: "Truck \(index + 1), demand \(routine.trucks[index].GetDemand())")
    }
    plt.scatter(x: depotX, y: depotY, label: "Depots")
    plt.title("Paths (\(runNumber), \(id)); Fitness: \(routine.GetFitness(for: .Distance)) km, \(routine.GetFitness(for: .Fuel)) l, demand \(routine.trucks.map({$0.GetDemand()}).reduce(0, +))")
    for customer in customers {
        plt.text(x: customer.x, y: customer.y, s: "\(customer.id)")
    }
    plt.legend()
    plt.axis("equal")
    plt.savefig("\(benchmark)/Path (\(runNumber) \(id))")
    plt.clf()
    plt.close("all")
}

func plotGenerationProgression(lowestDistance: [Double], highestDistance: [Double], averageDistance: [Double], lowestFuel : [Double], highestFuel : [Double], averageFuel : [Double], runNumber: Int) {
    plt.figure(figsize: [16, 16])
    plt.fill_between(x: Array(1...highestDistance.count), y1: lowestDistance, y2: highestDistance, alpha: 0.5, label: "Distance Population")
    plt.plot(Array(1...averageDistance.count), averageDistance, linewidth: 1.2, label: "Distance Average")
    
    plt.fill_between(x: Array(1...highestFuel.count), y1: lowestFuel, y2: highestFuel, alpha: 0.5, label: "Fuel Population")
    plt.plot(Array(1...averageFuel.count), averageFuel, linewidth: 1.2, label: "Fuel Average")
    plt.legend()
    plt.savefig("Temp/Generation Analysis \(runNumber)")
    plt.clf()
    plt.close("all")
}

func PlotBestSolutions(for solutions: [Routine]) {
    plt.figure(figsize: [16, 16])
    let average = solutions.map({$0.GetFitness(for: .Distance)}).reduce(0, +) / Double(solutions.count)
    plt.plot(Array(1...solutions.count), solutions.map({$0.GetFitness(for: .Distance)}), linewidth: 1.2, label: "Best Solutions")
    plt.plot(Array(1...solutions.count), Array(repeating: average, count: solutions.count), linewidth: 1.2, label: "Average")
    plt.legend()
    plt.grid()
    plt.savefig("Temp/Best Solutions")
    plt.clf()
    plt.close("all")
}

func PlotParetoFronts(for fronts : [[Routine]], run: Int, benchmark: String) {
    CreateFolder(named: benchmark)
    plt.figure(figsize: [16, 16])
    for (index, front) in fronts.enumerated() {
        let individuals = front.sorted(by: {$0.GetFitness(for: .Distance) < $1.GetFitness(for: .Distance)})
        plt.scatter(x: individuals.map({$0.GetFitness(for: .Distance)}), y: individuals.map({$0.GetFitness(for: .Fuel)}), label: "Front \(index)")
        plt.plot(individuals.map({$0.GetFitness(for: .Distance)}), individuals.map({$0.GetFitness(for: .Fuel)}), linewidth: 1.2)
    }
    plt.xlabel(ObjectiveParameter.Distance.rawValue)
    plt.ylabel(ObjectiveParameter.Fuel.rawValue)
    plt.grid()
    plt.legend()
    plt.title("Pareto Front Run \(run), Count \(fronts[0].count)")
    plt.savefig("\(benchmark)/Pareto Front \(run) (\(fronts[0].count))")
    plt.clf()
    plt.close("all")
}
