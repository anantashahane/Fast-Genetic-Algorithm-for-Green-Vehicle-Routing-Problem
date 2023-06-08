//
//  ReadFiles.swift
//  Experiment 5
//
//  Created by Ananta Shahane on 05/05/2023.
//

import Foundation

func ReadFiles(benchmarkNameContains : String? = nil) -> [String] {
    let docsDir = NSHomeDirectory().appending("/Documents/Masters/Research Project/Experiment 6/Experiment 6/Benchmarks")
    let localFileManager = FileManager()
    var dataset = [String]()
    let dirEnum = localFileManager.enumerator(atPath: docsDir)
    while let file = dirEnum?.nextObject() as? String {
        if let benchmarkNameContains = benchmarkNameContains {
            if file.hasSuffix(".vrp") && file.contains(benchmarkNameContains){
                let location = docsDir.appending("/\(file)")
                dataset.append(location)
            }
        } else {
            if file.hasSuffix(".vrp") {
                let location = docsDir.appending("/\(file)")
                dataset.append(location)
            }
        }
    }
    if let benchmarkNameContains = benchmarkNameContains {
        return dataset.filter({$0.contains(benchmarkNameContains)})
    }
    return dataset
}
