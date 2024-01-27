//
//  MultiObjectiveArchive.swift
//  Experiment3
//
//  Created by Ananta Shahane on 10/04/2023.
//

import Foundation

class MultiObjectiveArchive {
    private var archive = [Routine]()
    private var dimension : [ObjectiveParameter : ObjectiveDirection]
    init(dimensions : [ObjectiveParameter : ObjectiveDirection]) {
        self.dimension = dimensions
    }
    
    func AddSolution(solution: Routine) -> Bool {
        if isDominated(solution: solution) {
            return false
        } else {
            archive = archive.filter { !dominates(s1: solution, s2: $0) }
            archive.append(solution)
            return true
        }
    }

    func isDominated(solution: Routine) -> Bool {
        for s in archive {
            if dominates(s1: s, s2: solution) {
                return true
            }
        }
        return false
    }

    func dominates(s1: Routine, s2: Routine) -> Bool {
        let fitness1 = s1.GetAllFitness()
        let fitness2 = s2.GetAllFitness()
        for key in fitness1.keys {
            if dimension[key] == .Minimisation {
                if fitness1[key]! > fitness2[key]! {
                    return false
                }
            } else {
                if fitness1[key]! < fitness2[key]! {
                    return false
                }
            }
            
        }
        return true
    }
    
    func ClearArchive() {
        archive = []
    }
    
    func GetArchive() -> [Routine] {
        return archive
    }
}

