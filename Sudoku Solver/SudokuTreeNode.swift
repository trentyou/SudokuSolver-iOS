//
//  SudokuTreeNode.swift
//  Sudoku Solver
//
//  Created by Trent You on 4/25/15.
//  Copyright (c) 2015 Trent You. All rights reserved.
//

import Foundation


class SudokuTreeNode {
    
    var answer: Int?
    
    weak var parent: SudokuTreeNode?
    var firstChild: SudokuTreeNode?
    var nextSibling: SudokuTreeNode?
    var coordinates: CellCoordinates?
    
    var treeLevel: Int?
}