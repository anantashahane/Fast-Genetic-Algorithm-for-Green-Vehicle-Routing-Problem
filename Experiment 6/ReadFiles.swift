//
//  ReadFiles.swift
//  Experiment 5
//
//  Created by Ananta Shahane on 05/05/2023.
//

import Foundation

func ReadFiles(benchmarkNameContains : String? = nil, startingFrom : String? = nil) -> [String] {
    let localFileManager = FileManager()
    let docsDir = localFileManager.currentDirectoryPath.appending("/Benchmarks")
    var dataset = [String]()
    let dirEnum = localFileManager.enumerator(atPath: docsDir)
    while let file = dirEnum?.nextObject() as? String {
        if let benchmarkNameContains = benchmarkNameContains {
            if file.hasSuffix(".json") && file.contains(benchmarkNameContains){
                let location = docsDir.appending("/\(file)")
                dataset.append(location)
            }
        } else {
            if file.hasSuffix(".json") {
                let location = docsDir.appending("/\(file)")
                dataset.append(location)
            }
        }
    }
    dataset = dataset.sorted()
    if let startingFrom = startingFrom {
        if let startIndex = dataset.firstIndex(where: {$0.contains(startingFrom)}) {
            dataset = Array(dataset[startIndex..<dataset.count])
        }
    }
    if let benchmarkNameContains = benchmarkNameContains {
        return dataset.filter({$0.contains(benchmarkNameContains)}).sorted()
    }
    return dataset
}

