//
//  LevelDataDecoder.swift
//  DamIt
//
//  Created by Saigaurav Purushothaman on 10/21/20.
//

import Foundation

typealias LevelDataFormat = (id: String, width: Int, height: Int, logs: [(x: Int,y: Int)], rocks: [(x: Int,y: Int)], beavers: [(x: Int,y: Int)])

class LevelDataDecoder {
    
    var encoding: String!
    
    init(for encoding: String) {
        self.encoding = encoding
    }
    
    private func fixPoint(point: (x: Int, y: Int), height: Int) -> (x: Int, y: Int) {
        let temp = point.x
        let newX = height - (point.y + 1)
        let newY = temp
        return (newX, newY)
    }

    private func fixLevelData( levelData: inout LevelDataFormat) {
        levelData.logs = levelData.logs.map { fixPoint(point: $0, height: levelData.height) }
        levelData.rocks = levelData.rocks.map { fixPoint(point: $0, height: levelData.height) }
        levelData.beavers = levelData.beavers.map { fixPoint(point: $0, height: levelData.height) }
//        levelData.beaver = fixPoint(point: levelData.beaver, height: levelData.height)
    }

    func getLevelDataFromEncoding() -> LevelDataFormat {
        let pad = 8
        let levelFormat: String = String(encoding.substring(from: pad))
        let levelPackNum = Int(encoding.substring(with: 0..<2))
        let levelNum = Int(encoding.substring(with: 2..<4))
        let id = "Pack\(levelPackNum!)_Level\(levelNum!)"
        let width = Int(encoding.substring(with: 4..<6))!
        let height = Int(encoding.substring(with: 6..<8))!
        var logList: [(x: Int,y: Int)] = []
        var rockList: [(x: Int,y: Int)] = []
        var beaverList: [(x: Int,y: Int)] = []
        var row = 0
        var col = 0
        for i in 0 ..< levelFormat.count {
            let block = levelFormat[i]
            switch block {
            case "L":
                logList.append((col, row))
            case "R":
                rockList.append((col, row))
            case "B":
                beaverList.append((col, row))
            default:
                print("Unknown Character In Level Encoding")
            }
            row = (row + 1) % height
            if row == 0 {
                col += 1
            }
        }
        var levelData: LevelDataFormat = (id, width, height, logList, rockList, beaverList)
        fixLevelData(levelData: &levelData)
        return levelData
    }
}

// MARK: - Decoder Breakdown - Example Level Data:

//        1)
//        Encoding "01011004RLLLLLAAAAAALLAALAAARRBAAAAALLAALLLARRLL"
//        - 01 level pack, 01 level, 10 width, 04 height, String Blocks in order of bottom to top from left to right

//        2)
//        logList: [(x: Int,y: Int)] = [(0,1),(0,2),(0,3),(1,0),(1,1),(3,0),(3,1),(4,0),(7,0),(7,1),(8,0),(8,1),(8,2),(9,2),(9,3)]
//        rockList: [(x: Int,y: Int)] = [(0,0),(5,1),(5,0),(9,0),(9,1)]
//        beaverPos: (x: Int,y: Int) = (5,2)
//        - Encoding converted to lists of traditional coordinates

//        3)
//        logList: [(x: Int,y: Int)] = [(0,0),(1,0),(2,0),(2,1),(3,1),(2,3),(3,3),(3,4),(2,7),(3,7),(1,8),(2,8),(3,8),(0,9),(1,9)]
//        rockList: [(x: Int,y: Int)] = [(3,0),(2,5),(3,5),(2,9),(3,9)]
//        beaverPos: (x: Int,y: Int) = (1,5)
//        - Lists refactored into coordinate system understood by game files internally such as Level class
