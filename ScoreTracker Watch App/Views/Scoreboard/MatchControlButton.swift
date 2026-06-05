//
//  MatchControlButton.swift
//  ScoreTracker Watch App
//
//  Created by Turgut Egemen Özyürek on 30.08.2025.
//

import SwiftUI

struct MatchControlButton<Icon: View>: View {
    let backgroundColor: Color
    let accessibilityLabel: String
    let isEnabled: Bool
    let action: () -> Void
    @ViewBuilder let icon: () -> Icon
    
    private let size: CGFloat = 38
    
    var body: some View {
        Button(action: action) {
            icon()
                .frame(width: size, height: size)
                .background(backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.45)
        .accessibilityLabel(accessibilityLabel)
    }
}
