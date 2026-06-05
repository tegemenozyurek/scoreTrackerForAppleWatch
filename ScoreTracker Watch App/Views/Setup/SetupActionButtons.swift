//
//  SetupActionButtons.swift
//  ScoreTracker Watch App
//
//  Created by Turgut Egemen Özyürek on 30.08.2025.
//

import SwiftUI

struct SetupActionButtons: View {
    let primaryTitle: String
    let primaryAction: () -> Void
    let secondaryTitle: String
    let secondaryAction: () -> Void
    var primaryBackgroundColor: Color = .white
    var primaryForegroundColor: Color = .black
    var isPrimaryPulsing: Bool = false
    var primaryMatchesSecondaryStyle: Bool = false
    var isInteractionEnabled: Bool = true
    
    private var resolvedPrimaryBackground: Color {
        primaryMatchesSecondaryStyle ? Color.white.opacity(0.15) : primaryBackgroundColor
    }
    
    private var resolvedPrimaryForeground: Color {
        primaryMatchesSecondaryStyle ? .white : primaryForegroundColor
    }
    
    private var resolvedPrimaryPulsing: Bool {
        primaryMatchesSecondaryStyle ? false : isPrimaryPulsing
    }
    
    var body: some View {
        VStack(spacing: 6) {
            Button(action: primaryAction) {
                Text(primaryTitle)
                    .font(.system(size: 12, weight: primaryMatchesSecondaryStyle ? .medium : .semibold))
                    .foregroundColor(resolvedPrimaryForeground)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 5)
                    .background(resolvedPrimaryBackground)
                    .cornerRadius(6)
                    .scaleEffect(resolvedPrimaryPulsing ? 1.03 : 0.98)
                    .animation(
                        .easeInOut(duration: 1.4).repeatForever(autoreverses: true),
                        value: resolvedPrimaryPulsing
                    )
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: secondaryAction) {
                Text(secondaryTitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(6)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .frame(maxWidth: SetupScreenMetrics.buttonStackWidth)
        .allowsHitTesting(isInteractionEnabled)
    }
}

struct SetupButtonStackPlacement<Buttons: View>: View {
    let headerBlockHeight: CGFloat
    @ViewBuilder let buttons: () -> Buttons
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)
            
            VStack(spacing: 0) {
                Color.clear
                    .frame(height: headerBlockHeight)
                
                buttons()
                    .padding(.top, SetupScreenMetrics.buttonTopPadding)
            }
            .offset(y: SetupScreenMetrics.contentVerticalOffset)
            
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
