//
//  SportCard.swift
//  ScoreTracker Watch App
//
//  Created by Turgut Egemen Özyürek on 30.08.2025.
//

import SwiftUI

struct SportCard: View {
    let sport: Sport
    let isSelectionEnabled: Bool
    let onSelectionBegin: () -> Void
    let action: () -> Void
    
    @State private var isRocking = false
    @State private var selectionSpin: Double = 0
    @State private var isSelecting = false
    
    private static let spinDuration: TimeInterval = 0.7
    
    private var iconScale: CGFloat {
        isSelecting ? 1.0 : (isRocking ? 1.15 : 0.95)
    }
    
    private var iconRotation: Double {
        isSelecting ? selectionSpin : (isRocking ? 8 : -8)
    }
    
    var body: some View {
        ZStack {
            sport.color
                .ignoresSafeArea()
            
            Button(action: selectSport) {
                Image(systemName: sport.icon)
                    .font(.system(size: 80, weight: .medium))
                    .foregroundColor(.white)
                    .scaleEffect(iconScale)
                    .rotationEffect(.degrees(iconRotation))
                    .animation(
                        .easeInOut(duration: Self.spinDuration),
                        value: selectionSpin
                    )
                    .animation(
                        .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                        value: isRocking
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .allowsHitTesting(isSelectionEnabled && !isSelecting)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            resetRockAnimation()
        }
        .onDisappear {
            isRocking = false
            isSelecting = false
            selectionSpin = 0
        }
        .onChange(of: isSelectionEnabled) { _, enabled in
            if enabled {
                resetRockAnimation()
            }
        }
    }
    
    func resetRockAnimation() {
        isSelecting = false
        selectionSpin = 0
        isRocking = false
        DispatchQueue.main.async {
            isRocking = true
        }
    }
    
    func selectSport() {
        guard isSelectionEnabled, !isSelecting else { return }
        isSelecting = true
        onSelectionBegin()
        isRocking = false
        selectionSpin = 0
        
        withAnimation(.easeInOut(duration: Self.spinDuration)) {
            selectionSpin = 360
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.spinDuration) {
            isSelecting = false
            action()
        }
    }
}
