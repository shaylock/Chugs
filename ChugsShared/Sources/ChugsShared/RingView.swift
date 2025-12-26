//
//  RingView.swift
//  ChugsShared
//
//  Created by Shay Blum on 26/12/2025.
//

import SwiftUI

public struct RingView: View {
    public var progress: Double
    
    public init(progress: Double) {
        self.progress = progress
    }

    public var body: some View {
        Circle()
            .trim(from: 0, to: CGFloat(progress))
            .stroke(
                AngularGradient(
                    gradient: Gradient(colors: [
                        Color(#colorLiteral(red: 0.0, green: 0.7843137389, blue: 1.0, alpha: 1.0)),
                        Color(#colorLiteral(red: 0.0, green: 0.4470588267, blue: 0.9764705896, alpha: 1.0))
                    ]),
                    center: .center
                ),
                style: StrokeStyle(lineWidth: 8, lineCap: .round)
            )
            .rotationEffect(.degrees(-90))
    }
}
