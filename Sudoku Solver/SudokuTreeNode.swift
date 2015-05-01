//
//  SudokuTreeNode.swift
//  Sudoku Solver
//
//  Created by Trent You on 4/25/15.
//  Copyright (c) 2015 Trent You. All rights reserved.
//

import Foundation


class SudokuTreeNode {
    
    var answer: Int = 0
    
    weak var parent: SudokuTreeNode?
    var firstChild: SudokuTreeNode?
    var nextSibling: SudokuTreeNode?
    var coordinates: CellCoordinates = CellCoordinates(row: 0, column: 0)
    
    var treeLevel: Int = 0
    
    init() {
        
    }
}