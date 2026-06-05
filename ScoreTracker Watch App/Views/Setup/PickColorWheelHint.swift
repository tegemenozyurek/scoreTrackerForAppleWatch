//
//  PickColorWheelHint.swift
//  ScoreTracker Watch App
//
//  Created by Turgut Egemen Özyürek on 30.08.2025.
//

import SwiftUI

struct PickColorWheelHint: View {
    var label: String = "Color"
    @State private var isArrowPulsing = false
    
    var body: some View {
        ZStack {
            Text(label)
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
                .fixedSize()
                .rotationEffect(.degrees(-90))
            
            Image(systemName: "chevron.right")
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(.white)
                .opacity(isArrowPulsing ? 0.95 : 0.2)
                .offset(x: 8)
        }
        .frame(width: 26, height: 62)
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
                isArrowPulsing = true
            }
        }
    }
}
