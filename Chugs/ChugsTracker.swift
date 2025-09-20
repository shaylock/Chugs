//
//  ChugsTracker.swift
//  Chugs
//
//  Created by Shay Blum on 04/09/2025.
//

import SwiftUI

class ChugTracker: ObservableObject {
    @AppStorage("dailyChugs") var dailyGulps = 0
    @AppStorage("goal") var goal = 8
    
    func addChug(amount: Int = 1) {
        dailyGulps += amount
    }
    
    func resetDaily() {
        dailyGulps = 0
    }
}
