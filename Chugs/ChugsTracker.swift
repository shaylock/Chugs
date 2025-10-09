//
//  ChugsTracker.swift
//  Chugs
//
//  Created by Shay Blum on 04/09/2025.
//

import SwiftUI

class ChugTracker: ObservableObject {
    @AppStorage("dailyGoal") private var dailyGoal: Double = 3.0
    @AppStorage("dailyProgress") private var dailyProgress: Double = 0.0
    @AppStorage("gulpSize") private var gulpSize: Int = 10
    
    @AppStorage("dailyChugs") var dailyGulps = 0
    @AppStorage("goal") var goal = 8
    
    func addChug(amount: Int = 1) {
        dailyGulps += amount
    }
    
    func resetDaily() {
        dailyGulps = 0
    }
}
