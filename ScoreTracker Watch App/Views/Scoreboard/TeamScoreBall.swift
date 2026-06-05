//
//  TeamScoreBall.swift
//  ScoreTracker Watch App
//
//  Created by Turgut Egemen Özyürek on 30.08.2025.
//

import SwiftUI

struct TeamScoreBall: View {
    let color: Color
    let sportIcon: String
    let spinDegrees: Double
    var side: CGFloat = 48
    var allowsTapIncrement: Bool = true
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    
    var body: some View {
        Image(systemName: sportIcon)
            .font(.system(size: side * 0.92, weight: .medium))
            .foregroundStyle(color)
            .symbolRenderingMode(.monochrome)
            .rotationEffect(.degrees(spinDegrees))
            .animation(.easeInOut(duration: TeamScoreBall.spinDuration), value: spinDegrees)
            .frame(width: side, height: side)
            .contentShape(Rectangle())
            .onTapGesture {
                if allowsTapIncrement { onIncrement() }
            }
            .gesture(
                DragGesture().onEnded { value in
                    if abs(value.translation.height) > 20 {
                        onDecrement()
                    }
                }
            )
    }
    
    static let spinDuration: TimeInterval = 0.7
}
