//
//  Solver.swift
//  Sudoku Solver
//
//  Created by Trent You on 4/23/15.
//  Copyright (c) 2015 Trent You. All rights reserved.
//

import Foundation


class Solver : NSObject {
    
    var internalSudokuBoard: [[HMDSudokuCell]] = [[]]
    var originalBoard: [[HMDSudokuCell]] = [[]]
    var listOfCellsToGuess: [HMDCellCoordinates] = []
    
    var direction: TreeSolverDirection?
    var anotherThreadFinished: Bool

    static let numberFormatter = NSNumberFormatter()
    
    
    // MARK: Init
    
    override init() {
        self.anotherThreadFinished = false
        super.init()
    }
    
    internal func solvePuzzleWithStartingNumbers(#startingNumbers: [[HMDSudokuCell]], andDirection direction: TreeSolverDirection) -> [[HMDSudokuCell]]?{
        
        self.direction = direction
        self.internalSudokuBoard = startingNumbers
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "cancelTreeTraversalOperations", name: "anotherThreadFinished", object: nil);
        
        self.fillPossibleAnswers()
        
        return nil;
    }
    
    
    // MARK: Initial board setup
    
    private func fillPossibleAnswers() {
        for var row = 0; row < 9; row++ {
            for var column = 0; column < 9; column++ {
                let cell = self.internalSudokuBoard[row][column]
                let answer = cell.answer
                
                if answer == 0 {
                    var possibleAnswers: [HMDPossibleAnswer] = []
                    
                    for var number = 1; number <= 9; number++ {
                        
                        if self.checkValidPlacementOfAnswer(answer: number, inRow: row, andColumn: column) {
                            var possibleAnswer = HMDPossibleAnswer()
                            
                            possibleAnswer.answer = number
                            possibleAnswers.append(possibleAnswer)
                        }
                    }
                    

                }
            }
        }
    }
    
    // MARK: Utility methods for checking number placement
    
    
    private func checkValidPlacementOfAnswer(#answer: Int, inRow row: Int, andColumn column: Int) -> Bool {
        
        if !self.checkColumnForAnswer(answer: answer, inRow: row, andColumn: column) && !self.checkRowForAnswer(answer: answer, inRow: row, andColumn: column) && !self.checkQuadrantForAnswer(answer: answer, inRow: row, andColumn: column) {
            return true
        } else {
            return false
        }
    }
    
    private func checkColumnForAnswer(#answer: Int, inRow inputRow: Int, andColumn inputColumn: Int) -> Bool {
        for var row = 0; row < 9; row++ {
            if row != inputRow {
                let cell = self.internalSudokuBoard[row][inputColumn]
                let cellAnswer = cell.answer
                
                if cellAnswer == answer {
                    return true;
                }
            }
        }
        
        return false
    }
    
    
    private func checkRowForAnswer(#answer: Int, inRow inputRow: Int, andColumn inputColumn: Int) -> Bool {
        
        for var column = 0; column < 9; column++ {
            if column != inputColumn {
                let cell = self.internalSudokuBoard[inputRow][column]
                let cellAnswer = cell.answer
                
                if cellAnswer == answer {
                    return true
                }
            }
        }
        
        return false
    }
    
    
    private func getQuadrantFromRow(#row: Int, andColumn column: Int) -> Int {
        if row <= 2 {
            return (column / 3) + 1
        } else if row > 2 && row < 6 {
            return (column / 3) + 4
        } else {
            return (column / 3) + 7
        }
    }
    
    private func quadrantBoundariesForRow(#row: Int, andColumn column: Int) -> (rowMin: Int, rowMax: Int, columnMin: Int, columnMax: Int) {
        
        var rowMin: Int
        var rowMax: Int
        
        var columnMin: Int
        var columnMax: Int
        
        switch self.getQuadrantFromRow(row: row, andColumn: column) {
        case 1:
            rowMin = 0
            rowMax = 2
            
            columnMin = 0
            columnMax = 2
            
        case 2:
            rowMin = 0
            rowMax = 2
            
            columnMin = 3
            columnMax = 5
            
        case 3:
            rowMin = 0
            rowMax = 2
            
            columnMin = 6
            columnMax = 8
            
        case 4:
            rowMin = 3
            rowMax = 5
            
            columnMin = 0
            columnMax = 2
            
        case 5:
            rowMin = 3
            rowMax = 5
            
            columnMin = 3
            columnMax = 5
            
        case 6:
            rowMin = 3
            rowMax = 5
            
            columnMin = 6
            columnMax = 8
            
        case 7:
            rowMin = 6
            rowMax = 8
            
            columnMin = 0
            columnMax = 2
            
        case 8:
            rowMin = 6
            rowMax = 8
            
            columnMin = 3
            columnMax = 5
            
        case 9:
            rowMin = 6
            rowMax = 8
            
            columnMin = 6
            columnMax = 8
            
        default:
            rowMin = 0
            rowMax = 2
            
            columnMin = 0
            columnMax = 2
            
        }
        
        return (rowMin, rowMax, columnMin, columnMax)
    }
    
    
    private func checkQuadrantForAnswer(#answer: Int, inRow inputRow: Int, andColumn inputColumn: Int) -> Bool {
        
        var coordinates = self.quadrantBoundariesForRow(row: inputRow, andColumn: inputColumn)
        
        for var row = coordinates.rowMin; row <= coordinates.rowMax; row++ {
            for var column = coordinates.columnMin; column <= coordinates.columnMax; column++ {
                if row != inputRow && column != inputColumn {
                    
                    let cell = self.internalSudokuBoard[row][column]
                    let cellAnswer = cell.answer
                    
                    if cellAnswer == answer {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    // MARK: Logic algorithm support methods
    
    private func subGroupExclusionCheck() -> Bool {
        var changed = false
        
        for var row = 0; row < 7; row += 3 {
            for var column = 0; column < 7; column += 3 {
                
                for var answer = 1; answer <= 9; answer++ {
                    
                    var occurenceCount = 0
                    var rowCoordinateOfOccurence = 0
                    var columnCoordinateOfOccurence = 0
                    
                    for var quadrantRow = 0; quadrantRow <= 2; quadrantRow++ {
                        for var quadrantColumn = 0; quadrantColumn <= 2; quadrantColumn++ {
                            
                            let cell = self.internalSudokuBoard[row + quadrantRow]
                            //var possibleAnswers = cell.possibleAnswers
                        }
                    }
                }
                
            }
        }
        
        return changed
    }
    
    private func updatePossibleAnswers() {
        for var row = 0; row < 9; row++ {
            for var column = 0; column < 9; column++ {
                
                let cell = self.internalSudokuBoard[row][column]
                let answer = cell.answer
                
                if answer == 0 {
                    
                }
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}