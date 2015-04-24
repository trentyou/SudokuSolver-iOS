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
                        
                    }
                    
                }
            }
        }
    }
    
    // MARK: Utility methods for checking number placement
    
    
    private func checkValidPlacementOfAnswer(#answer: Int, inRow row: Int, andColumn column: Int) {
        
    }
    
    private func checkColumnForAnswer(#answer: Int, inRow inputRow: Int, andColumn inputColumn: Int) -> Bool {
        for var row = 0; row < 9; row++ {
            
        }
        
        return false
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