//  Board.swift
//
//  Created by Ignacio Juarez on 07/18/2023.
//
//  Desc: object-oriented tic-tac-toe board (board with cells)
//
//  Func:
//  'checkGameStatus()' func that is called every cell click and updates GameStatus enum
//

import Foundation

enum GameStatus {
    case ongoing
    case playerXWin
    case playerOWin
    case draw
}

class Board {
    
    enum BoardCell { case X, O, empty }
    private var cells: [BoardCell] = Array(repeating: .empty, count: 9)

    func isCellEmpty(_ index: Int) -> Bool {
        return cells[index] == .empty
    }

    func setCell(_ index: Int, with player: BoardCell) {
        cells[index] = player
    }

    func checkGameStatus() -> GameStatus {
        let winPatterns = [
            [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
            [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
            [0, 4, 8], [2, 4, 6]             // Diagonals
        ]

        for pattern in winPatterns {
            if cells[pattern[0]] == .X, cells[pattern[1]] == .X, cells[pattern[2]] == .X {
                return .playerXWin
            } else if cells[pattern[0]] == .O, cells[pattern[1]] == .O, cells[pattern[2]] == .O {
                return .playerOWin
            }
        }
        if cells.allSatisfy({ $0 != .empty }) {
            return .draw
        } else {
            return .ongoing
        }
    }

    func reset() {
        cells = Array(repeating: .empty, count: 9)
    }
}
