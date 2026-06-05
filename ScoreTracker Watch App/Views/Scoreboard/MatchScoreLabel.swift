//
//  MatchScoreLabel.swift
//  ScoreTracker Watch App
//
//  Created by Turgut Egemen Özyürek on 30.08.2025.
//

import SwiftUI

struct MatchScoreLabel: View {
    let score: Int
    let columnWidth: CGFloat
    let fontSize: CGFloat
    let onGoal: () -> Void
    let onDecrement: () -> Void
    
    var body: some View {
        Text("\(score)")
            .font(.system(size: fontSize, weight: .bold))
            .monospacedDigit()
            .foregroundColor(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.65)
            .allowsTightening(true)
            .frame(width: columnWidth, alignment: .center)
            .contentShape(Rectangle())
            .onTapGesture(perform: onGoal)
            .gesture(scoreDecrementDrag(perform: onDecrement))
    }
}
func scoreDecrementDrag(perform onDecrement: @escaping () -> Void) -> some Gesture {
    DragGesture().onEnded { value in
        if abs(value.translation.height) > 20 {
            onDecrement()
        }
    }
}
