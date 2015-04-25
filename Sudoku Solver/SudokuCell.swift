//
//  SudokuCell.swift
//  Sudoku Solver
//
//  Created by Trent You on 4/24/15.
//  Copyright (c) 2015 Trent You. All rights reserved.
//

import Foundation

class SudokuCell: NSObject {
    var answer: Int = 0
    var possibleAnswers: [Int] = []
    var isPartOfInitialBoard: Bool = false
    
}