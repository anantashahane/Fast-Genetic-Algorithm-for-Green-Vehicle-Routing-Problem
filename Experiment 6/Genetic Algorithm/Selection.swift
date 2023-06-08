//
//  Selection.swift
//  Experiment 6
//
//  Created by Ananta Shahane on 07/06/2023.
//

import Foundation

extension GeneticAlgorithm {
    
    func FastNonDominatedSort() {
        var fronts = [[Routine]]()
        var front1 = [Routine]()
        
        var population = offspringPopulation + parentPopulation
        
        for pid in 0..<population.count {
            population[pid].dominatedByNumber = 0
            population[pid].dominatesSetIndex = []
            for qid in 0..<population.count {
                if population[pid].Dominates(other: population[qid]) {
                    population[pid].dominatesSetIndex.append(qid)
                } else if population[qid].Dominates(other: population[pid]) {
                    population[pid].dominatedByNumber += 1
                }
            }
            if population[pid].dominatedByNumber == 0 {
                population[pid].rank = 1
                front1.append(population[pid])
            }
        }
        var i = 0
        fronts.append(front1)
        while !fronts[i].isEmpty {
            var nextFront = [Routine]()

            for (pid, _) in fronts[i].enumerated() {
                for qid in fronts[i][pid].dominatesSetIndex {
                    population[qid].dominatedByNumber -= 1
                    if population[qid].dominatedByNumber == 0 {
                        population[qid].rank = i + 2
                        nextFront.append(population[qid])
                    }
                }
            }
            i += 1
            fronts.append(nextFront)
        }
        paretoFronts = fronts
    }
    
    func CrowdingDistance(front : [Routine]) -> [Routine] {
        if front.count == 0 {
            return []
        }
        var pop = [(Routine, Double)]()
        let length = front.count
        for i in 0..<length {
            pop.append((front[i], 0))
        }
        for key in front[0].GetAllFitness().keys {
            let max = front.map({$0.GetFitness(for: key)}).max()!
            let min = front.map({$0.GetFitness(for: key)}).min()!
            pop = pop.sorted(by: {$0.0.GetFitness(for: key) < $1.0.GetFitness(for: key)})
            pop[0].1 = Double.infinity
            pop[length - 1].1 = Double.infinity
            
            for i in 1..<length - 1 {
                pop[i].1 = pop[i].1 + (pop[i+1].0.GetFitness(for: key) - pop[i+1].0.GetFitness(for: key)) / (max - min)
            }
        }
        return pop.sorted(by: {$0.1 > $1.1}).map({$0.0})
    }

    func Selection() {
        FastNonDominatedSort()
        var remainingPopulationSize = populationSize
        parentPopulation = []
        var finalFront = [Routine]()
        for front in paretoFronts {
            if remainingPopulationSize - front.count > 0 {
                remainingPopulationSize -= front.count
                parentPopulation += front
            } else {
                finalFront = front
                break
            }
        }
        let population = CrowdingDistance(front: finalFront)
        parentPopulation += population[0..<remainingPopulationSize]
    }
    
    func ArchiveSolution() {
        _ = offspringPopulation.map({archive.AddSolution(solution: $0)})
    }
    
}
