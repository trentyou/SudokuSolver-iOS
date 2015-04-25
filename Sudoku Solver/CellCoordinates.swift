//
//  CellCoordinates.swift
//  Sudoku Solver
//
//  Created by Trent You on 4/24/15.
//  Copyright (c) 2015 Trent You. All rights reserved.
//

import Foundation


struct CellCoordinates {
    let row: Int
    let column: Int
    
    init(row: Int, column: Int) {
        self.row = row
        self.column = column
    }
}