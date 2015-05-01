//
//  Solver.swift
//  Sudoku Solver
//
//  Created by Trent You on 4/23/15.
//  Copyright (c) 2015 Trent You. All rights reserved.
//

import Foundation


class Solver : NSObject {
    
    var internalSudokuBoard: [[SudokuCell]] = [[]]
    var initialString = String()
    var listOfCellsToGuess: [CellCoordinates] = []
    
    var sudokuTree = SudokuTree()
    
    var direction: TreeSolverDirection?
    var anotherThreadFinished: Bool = false

    static let numberFormatter = NSNumberFormatter()
    
    
    // MARK: Public interface
    
    internal func solvePuzzleWithStartingNumbers(#startingNumbers: String, andDirection direction: TreeSolverDirection) -> HMDSwiftSolution? {
        
        self.direction = direction
        self.initialString = startingNumbers
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "cancelTreeTraversalOperations", name: "anotherThreadFinished", object: nil);
        
        self.setupInternalSudokuBoard(startingNumbers: startingNumbers)
        self.fillPossibleAnswers()
        
        if let solvedBoard = self.solveBoard() {
            return self.convertBoardToStringFormat(board: solvedBoard)
        } else {
            return nil
        }
        
    }
    
    
    // MARK: Initial board setup
    
    private func setupInternalSudokuBoard(var #startingNumbers: String) {
        
        for var row = 0; row < 9; row++ {
            var innerArray: [SudokuCell] = []
            
            for var column = 0; column < 9; column++ {
                var cell = SudokuCell()
                innerArray.insert(cell, atIndex: column)
            }
            
            self.internalSudokuBoard.insert(innerArray, atIndex: row)
        }
        
        for var row = 0; row < 9; row++ {
            for var column = 0; column < 9; column++ {
                var cell = self.internalSudokuBoard[row][column]
                
                let firstDigit = startingNumbers.substringToIndex(advance(startingNumbers.startIndex, 1))
                startingNumbers = dropFirst(startingNumbers)
                
                cell.answer = firstDigit.toInt()!
                
                if cell.answer != 0 {
                    cell.isPartOfInitialBoard = true
                }
                
                self.internalSudokuBoard[row][column] = cell
            }
        }
    }
    
    
    private func fillPossibleAnswers() {
        for var row = 0; row < 9; row++ {
            for var column = 0; column < 9; column++ {
                var cell = self.internalSudokuBoard[row][column]
                let answer = cell.answer
                
                if answer == 0 {
                    var possibleAnswers: [Int] = []
                    
                    for var number = 1; number <= 9; number++ {
                        
                        if self.checkValidPlacementOfAnswer(answer: number, inRow: row, andColumn: column) {
                            possibleAnswers.append(number)
                        }
                    }
                    
                    cell.possibleAnswers = possibleAnswers
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
    
    // MARK: Support methods for logic portion of algorithm
    
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
                            
                            let cell = self.internalSudokuBoard[row + quadrantRow][column + quadrantColumn]
                            
                            for possibleAnswer in cell.possibleAnswers {
                                if possibleAnswer == answer {
                                    occurenceCount++
                                    rowCoordinateOfOccurence = row + quadrantRow
                                    columnCoordinateOfOccurence = column + quadrantColumn
                                }
                            }
                        }
                    }
                    
                    if occurenceCount == 1 {
                        var cell = self.internalSudokuBoard[rowCoordinateOfOccurence][columnCoordinateOfOccurence]
                        
                        cell.answer = answer
                        cell.possibleAnswers = []
                        changed = true
                        
                        self.updateAllPossibleAnswers()
                    }
                }
                
            }
        }
        
        return changed
    }
    
    private func updateAllPossibleAnswers() {
        for var row = 0; row < 9; row++ {
            for var column = 0; column < 9; column++ {
                
                var cell = self.internalSudokuBoard[row][column]
                let answer = cell.answer
                
                if answer == 0 {
                    let possibleAnswers = cell.possibleAnswers
                    
                    for possibleAnswer in possibleAnswers {
                        if !self.checkValidPlacementOfAnswer(answer: possibleAnswer, inRow: row, andColumn: column) {
                            
                            for var i = 0; i < cell.possibleAnswers.count; i++ {
                                if (possibleAnswer == cell.possibleAnswers[i]) {
                                    cell.possibleAnswers.removeAtIndex(i)
                                    break
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Support methods for guessing portion of algorithm
    
    private func updatePossibleAnswersInRow(#inputRow: Int, andColumn inputColumn: Int, forAnswer answer: Int) {
        
        for var column = inputColumn + 1; column < 9; column++ {
            var cell = self.internalSudokuBoard[inputRow][column]
            
            if cell.answer == 0 {
                for var i = 0; i < cell.possibleAnswers.count; i++ {
                    if cell.possibleAnswers[i] == answer {
                        cell.possibleAnswers.removeAtIndex(i)
                        break
                    }
                }
            }
        }
        
        for var row = inputRow + 1; row < 9; row++ {
            var cell = self.internalSudokuBoard[row][inputColumn]
            
            if cell.answer == 0 {
                for var i = 0; i < cell.possibleAnswers.count; i++ {
                    if cell.possibleAnswers[i] == answer {
                        cell.possibleAnswers.removeAtIndex(i)
                        break
                    }
                }
            }
        }
        
        var coordinates = self.quadrantBoundariesForRow(row: inputRow, andColumn: inputColumn)
        
        for var row = inputRow + 1; row <= coordinates.rowMax; row++ {
            for var column = coordinates.columnMin; column <= coordinates.columnMax; column++ {
                var cell = self.internalSudokuBoard[row][column]
                
                if cell.answer == 0 {
                    for var i = 0; i < cell.possibleAnswers.count; i++ {
                        if cell.possibleAnswers[i] == answer {
                            cell.possibleAnswers.removeAtIndex(i)
                            break
                        }
                    }
                }
            }
        }
        
    }
    
    private func restorePossibleAnswer(#possibleAnswerToRestore: Int, forRow inputRow: Int, andColumn inputColumn: Int, andRemovePossibleAnswer possibleAnswerToRemove: Int) {
        
        for var column = inputColumn + 1; column < 9; column++ {
            var cell = self.internalSudokuBoard[inputRow][column]

            if cell.answer == 0 {
                
                for var i = 0; i < cell.possibleAnswers.count; i++ {
                    if cell.possibleAnswers[i] == possibleAnswerToRemove {
                        cell.possibleAnswers.removeAtIndex(i)
                        break
                    }
                }
 
                if self.checkValidPlacementOfAnswer(answer: possibleAnswerToRestore, inRow: inputRow, andColumn: column) {
                    
                    if cell.possibleAnswers.count == 0 {
                        cell.possibleAnswers.append(possibleAnswerToRestore)
                    } else {
                        for var i = 0; i < cell.possibleAnswers.count; i++ {
                            let answer = cell.possibleAnswers[i]
                            
                            if possibleAnswerToRestore < answer {
                                cell.possibleAnswers.insert(possibleAnswerToRestore, atIndex: i)
                                break
                            } else if i == cell.possibleAnswers.count - 1 {
                                cell.possibleAnswers .insert(possibleAnswerToRestore, atIndex: i + 1)
                                break
                            }
                        }
                    }
                }
            }
        }
        
        for var row = inputRow + 1; row < 9; row++ {
            var cell = self.internalSudokuBoard[row][inputColumn]
            
            if cell.answer == 0 {
                
                for var i = 0; i < cell.possibleAnswers.count; i++ {
                    if cell.possibleAnswers[i] == possibleAnswerToRemove {
                        cell.possibleAnswers.removeAtIndex(i)
                        break
                    }
                }
                
                if self.checkValidPlacementOfAnswer(answer: possibleAnswerToRestore, inRow: row, andColumn: inputColumn) {
                    
                    if cell.possibleAnswers.count == 0 {
                        cell.possibleAnswers.append(possibleAnswerToRestore)
                    } else {
                        for var i = 0; i < cell.possibleAnswers.count; i++ {
                            let answer = cell.possibleAnswers[i]
                            
                            if possibleAnswerToRestore < answer {
                                cell.possibleAnswers.insert(possibleAnswerToRestore, atIndex: i)
                                break
                            } else if i == cell.possibleAnswers.count - 1 {
                                cell.possibleAnswers.insert(possibleAnswerToRestore, atIndex: i + 1)
                                break
                            }
                        }
                    }
                }
            }
        }
        
        let coordinates = self.quadrantBoundariesForRow(row: inputRow, andColumn: inputColumn)
        
        for var row = inputRow + 1; row <= coordinates.rowMax; row++ {
            for var column = coordinates.columnMin; column <= coordinates.columnMax; column++ {
                
                var cell = self.internalSudokuBoard[row][column]
                
                if cell.answer == 0 && column != inputColumn {
                    
                    for var i = 0; i < cell.possibleAnswers.count; i++ {
                        if cell.possibleAnswers[i] == possibleAnswerToRemove {
                            cell.possibleAnswers.removeAtIndex(i)
                            break
                        }
                    }
                
                
                    if self.checkValidPlacementOfAnswer(answer: possibleAnswerToRestore, inRow: row, andColumn: column) {
                        
                        if cell.possibleAnswers.count == 0 {
                            cell.possibleAnswers.append(possibleAnswerToRestore)
                        } else {
                            for var i = 0; i < cell.possibleAnswers.count; i++ {
                                let answer = cell.possibleAnswers[i]
                                
                                if possibleAnswerToRestore < answer {
                                    cell.possibleAnswers.insert(possibleAnswerToRestore, atIndex: i)
                                    break
                                } else if i == cell.possibleAnswers.count - 1 {
                                    cell.possibleAnswers.insert(possibleAnswerToRestore, atIndex: i + 1)
                                    break
                                }
                            }
                        }
                    }
                }
                
            }
        }
        
        
        
    }
    
    private func restorePossibleAnswersForCellsToGuess() {
        for var treeLevel = 0; treeLevel < self.listOfCellsToGuess.count; treeLevel++ {
            
            let coordinates = self.listOfCellsToGuess[treeLevel]
            var cell = self.internalSudokuBoard[coordinates.row][coordinates.column]
            
            if cell.answer == 0 {
                var possibleAnswers: [Int] = []
                
                for var number = 1; number <= 9; number++ {
                    if self.checkValidPlacementOfAnswer(answer: number, inRow: coordinates.row, andColumn: coordinates.column) {
                        possibleAnswers.append(number)
                    }
                }
                
                cell.possibleAnswers = possibleAnswers
                
            }
        }
    }
    
    private func restorePossibleAnswersFromTreeLevel(#levelToStart: Int) {
        for var treeLevel = levelToStart; treeLevel < self.listOfCellsToGuess.count; treeLevel++ {
            let coordinates = self.listOfCellsToGuess[treeLevel]
            let cell = self.internalSudokuBoard[coordinates.row][coordinates.column]
            
            var restoredPossibleAnswers: [Int] = []
            
            for possibleAnswer in cell.initialPossibleAnswers {
                if self.checkValidPlacementOfAnswer(answer: possibleAnswer, inRow: coordinates.row, andColumn: coordinates.column) {
                    restoredPossibleAnswers.append(possibleAnswer)
                }
            }
            
            cell.possibleAnswers = restoredPossibleAnswers
            
        }
    }
    
    
    private func updatePossibleAnswersForCellsToGuess() {
        for coordinates in self.listOfCellsToGuess {
            var cell = self.internalSudokuBoard[coordinates.row][coordinates.column]
            
            if cell.answer == 0 {
                let possibleAnswers = cell.possibleAnswers
                
                for possibleAnswer in possibleAnswers {
                    if self.checkValidPlacementOfAnswer(answer: possibleAnswer, inRow: coordinates.row, andColumn: coordinates.column) {
                        
                        for var i = 0; i < cell.possibleAnswers.count; i++ {
                            if cell.possibleAnswers[i] == possibleAnswer {
                                cell.possibleAnswers.removeAtIndex(i)
                                break
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Checks for whether board is solved
    
    private func isSolved() -> Bool {
        
        for var row = 0; row < 9; row++ {
            for var column = 0; column < 9; column++ {
                let cell = self.internalSudokuBoard[row][column]
                
                if cell.answer == 0 {
                    return false
                }
                
                if !self.checkValidPlacementOfAnswer(answer: cell.answer, inRow: row, andColumn: column) {
                    return false
                }
            }
        }
        
        return true
        
    }
    
    // MARK: Solve methods
    
    private func solveBoard() -> [[SudokuCell]]? {
        var changed: Bool
        var logicLoopCount = 0
        
        do {
            changed = false
            
            for var row = 0; row < 9; row++ {
                for var column = 0; column < 9; column++ {
                    var cell = self.internalSudokuBoard[row][column]
                    let answer = cell.answer
                    
                    if answer == 0 && cell.possibleAnswers.count == 1 {
                        cell.answer = cell.possibleAnswers.first!
                        cell.possibleAnswers = []
                        
                        self.updateAllPossibleAnswers()
                        
                        changed = true
                    }
                }
            }
            
            if !changed {
                changed = self.subGroupExclusionCheck()
            }
        
            logicLoopCount++
        
        } while !self.anotherThreadFinished && changed
        
        println("Number of logic loops: \(logicLoopCount)")
        
        if self.anotherThreadFinished {
            println("Quitting from another thread finishing before tree traversal")
        }
        
        if self.anotherThreadFinished || self.isSolved() {
            return self.internalSudokuBoard
        } else {
            self.setupListOfCellsToGuess()
            self.setupTree()
            
            if self.direction == .Forward {
                return self.treeTraverseGuessForward()
            } else {
                return self.treeTraverseGuessBackward()
            }
        }
    }
    
    private func setupListOfCellsToGuess() {
        for var row = 0; row < 9; row++ {
            for var column = 0; column < 9; column++ {
                
                let cell = self.internalSudokuBoard[row][column]
                
                if cell.answer == 0 {
                    let coordinates = CellCoordinates(row: row, column: column)
                    self.listOfCellsToGuess.append(coordinates)
                    
                    cell.initialPossibleAnswers = cell.possibleAnswers
                }
            }
        }
    }
    
    private func setupTree() {

        var root = SudokuTreeNode()
        root.parent = nil
        root.treeLevel = -1
        
        self.sudokuTree.root = root
    }
    
    
    // MARK: Guessing portion of algorithm
    
    private func getNextParentNodeWithSibling(var #parent: SudokuTreeNode) -> SudokuTreeNode {
        while parent.nextSibling == nil {
            if let nextParent = parent.parent {
                parent = nextParent
            }
        }
        
        return parent
    }
    
    private func treeTraverseGuessForward() -> [[SudokuCell]]? {
        var parent: SudokuTreeNode = self.sudokuTree.root!
        var nextSibling: SudokuTreeNode?
        
        var iterationCount: Int = 0
        
        while (parent.treeLevel < self.listOfCellsToGuess.count - 1 && !self.anotherThreadFinished) {
            iterationCount++
            
            let childCoordinates: CellCoordinates = self.listOfCellsToGuess[parent.treeLevel + 1]
            let cell = self.internalSudokuBoard[childCoordinates.row][childCoordinates.column]
            
            var possibleAnswers = cell.possibleAnswers
            
            if possibleAnswers.count == 0 {
                var parentCoordinates = self.listOfCellsToGuess[parent.treeLevel]
                var parentCell = self.internalSudokuBoard[parentCoordinates.row][parentCoordinates.column]
                
                if parent.nextSibling != nil && (parentCoordinates.row == childCoordinates.row || parentCoordinates.column == childCoordinates.column) {
                    
                    var prevAnswer = parent.parent!.firstChild!.answer
                    
                    parent.parent!.firstChild = parent.nextSibling!
                    parent = parent.nextSibling!
                    parentCell.answer = parent.answer
                    
                    self.restorePossibleAnswer(possibleAnswerToRestore: prevAnswer, forRow: parentCoordinates.row, andColumn: parentCoordinates.column, andRemovePossibleAnswer: parentCell.answer)
                    
                    possibleAnswers = cell.possibleAnswers
                    
                } else {
                    
                    let previousTreeLevel = parent.treeLevel
                
                    parent = self.getNextParentNodeWithSibling(parent: parent.parent!)
                    
                    let newTreeLevel = parent.treeLevel
                    
                    parent.parent!.firstChild = parent.nextSibling!
                    parent = parent.nextSibling!
                    
                    for var level = previousTreeLevel; level > newTreeLevel; level-- {
                        let coordinatesForCellsToReset = self.listOfCellsToGuess[level]
                        var cellToReset = self.internalSudokuBoard[coordinatesForCellsToReset.row][coordinatesForCellsToReset.column]

                        cellToReset.answer = 0
                    }
                    
                    parentCoordinates = self.listOfCellsToGuess[newTreeLevel]
                    parentCell = self.internalSudokuBoard[parentCoordinates.row][parentCoordinates.column]
                    
                    parentCell.answer = parent.answer
                    
                    self.restorePossibleAnswersFromTreeLevel(levelToStart: newTreeLevel + 1)
                    
                    continue
                }
            }
            
            for var i = possibleAnswers.count - 1; i >= 0; i-- {
                let possibleAnswer = possibleAnswers[i]
                var child = SudokuTreeNode()
                
                child.answer = possibleAnswer
                child.parent = parent
                
                child.treeLevel = parent.treeLevel + 1
                
                let childCoordinates = self.listOfCellsToGuess[child.treeLevel]
                child.coordinates = childCoordinates
                
                if i == 0 {
                    parent.firstChild = child
                    child.nextSibling = nextSibling
                    nextSibling = nil
                    
                    cell.answer = possibleAnswer
                    cell.possibleAnswers = []
                    
                    parent = child
                    
                } else {
                    if nextSibling != nil {
                        child.nextSibling = nextSibling
                    } else {
                        child.nextSibling = nil
                    }
                    
                    nextSibling = child
                }
            }
            
            let parentCoordinates = self.listOfCellsToGuess[parent.treeLevel]
            let parentCell = self.internalSudokuBoard[parentCoordinates.row][parentCoordinates.column]
            
            self.updatePossibleAnswersInRow(inputRow: parentCoordinates.row, andColumn: parentCoordinates.column, forAnswer: parentCell.answer)
        }
        
        if self.isSolved() {
            println("Solved using forward")
            println("Iteration count: \(iterationCount)")
            
            self.sudokuTree.root = nil
            
            return self.internalSudokuBoard
        } else {
            return nil
        }
    }
    
    private func treeTraverseGuessBackward() -> [[SudokuCell]]? {
        var parent: SudokuTreeNode = self.sudokuTree.root!
        var nextSibling: SudokuTreeNode?
        
        var iterationCount: Int = 0
        
        while (parent.treeLevel < self.listOfCellsToGuess.count - 1 && !self.anotherThreadFinished) {
            iterationCount++
            
            let childCoordinates: CellCoordinates = self.listOfCellsToGuess[parent.treeLevel + 1]
            let cell = self.internalSudokuBoard[childCoordinates.row][childCoordinates.column]
            
            var possibleAnswers = cell.possibleAnswers
            
            if possibleAnswers.count == 0 {
                var parentCoordinates = self.listOfCellsToGuess[parent.treeLevel]
                var parentCell = self.internalSudokuBoard[parentCoordinates.row][parentCoordinates.column]
                
                if parent.nextSibling != nil && (parentCoordinates.row == childCoordinates.row || parentCoordinates.column == childCoordinates.column) {
                    
                    var prevAnswer = parent.parent!.firstChild!.answer
                    
                    parent.parent!.firstChild = parent.nextSibling!
                    parent = parent.nextSibling!
                    parentCell.answer = parent.answer
                    
                    self.restorePossibleAnswer(possibleAnswerToRestore: prevAnswer, forRow: parentCoordinates.row, andColumn: parentCoordinates.column, andRemovePossibleAnswer: parentCell.answer)
                    
                    possibleAnswers = cell.possibleAnswers
                    
                } else {
                    
                    let previousTreeLevel = parent.treeLevel
                    
                    parent = self.getNextParentNodeWithSibling(parent: parent.parent!)
                    
                    let newTreeLevel = parent.treeLevel
                    
                    parent.parent!.firstChild = parent.nextSibling!
                    parent = parent.nextSibling!
                    
                    for var level = previousTreeLevel; level > newTreeLevel; level-- {
                        let coordinatesForCellsToReset = self.listOfCellsToGuess[level]
                        var cellToReset = self.internalSudokuBoard[coordinatesForCellsToReset.row][coordinatesForCellsToReset.column]
                        
                        cellToReset.answer = 0
                    }
                    
                    parentCoordinates = self.listOfCellsToGuess[newTreeLevel]
                    parentCell = self.internalSudokuBoard[parentCoordinates.row][parentCoordinates.column]
                    
                    parentCell.answer = parent.answer
                    
                    self.restorePossibleAnswersFromTreeLevel(levelToStart: newTreeLevel + 1)
                    
                    continue
                }
            }
            
            for var i = 0; i < possibleAnswers.count; i++ {
                let possibleAnswer = possibleAnswers[i]
                var child = SudokuTreeNode()
                
                child.answer = possibleAnswer
                child.parent = parent
                
                child.treeLevel = parent.treeLevel + 1
                
                let childCoordinates = self.listOfCellsToGuess[child.treeLevel]
                child.coordinates = childCoordinates
                
                if i == possibleAnswers.count - 1 {
                    parent.firstChild = child
                    child.nextSibling = nextSibling
                    nextSibling = nil
                    
                    cell.answer = possibleAnswer
                    cell.possibleAnswers = []
                    
                    parent = child
                    
                } else {
                    if nextSibling != nil {
                        child.nextSibling = nextSibling
                    } else {
                        child.nextSibling = nil
                    }
                    
                    nextSibling = child
                }
            }
            
            let parentCoordinates = self.listOfCellsToGuess[parent.treeLevel]
            let parentCell = self.internalSudokuBoard[parentCoordinates.row][parentCoordinates.column]
            
            self.updatePossibleAnswersInRow(inputRow: parentCoordinates.row, andColumn: parentCoordinates.column, forAnswer: parentCell.answer)
        }
        
        if self.isSolved() {
            println("Solved using backward")
            println("Iteration count: \(iterationCount)")
            
            self.sudokuTree.root = nil
            
            return self.internalSudokuBoard
        } else {
            return nil
        }
    }
    
    
    // MARK: Packaging solved board to ObjC friendly format
    
    private func convertBoardToStringFormat(#board: [[SudokuCell]]) -> HMDSwiftSolution {
        
        var solutionString = ""
        
        for var row = 0; row < 9; row++ {
            for var column = 0; column < 9; column++ {
                
                let cell = board[row][column]
                
                solutionString += String(cell.answer)
            }
        }
        
        println("solutionString length: \(count(solutionString))")
        
        var solution = HMDSwiftSolution()
        
        solution.solution = solutionString
        solution.initialBoard = self.initialString
        
        return solution
    }
    
    
    // MARK: Multithreading
    
    @objc private func cancelTreeTraversalOperations() {
        self.anotherThreadFinished = true
    }

    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
}