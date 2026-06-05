//
//  TeamColorWheelSelectionView.swift
//  ScoreTracker Watch App
//
//  Created by Turgut Egemen Özyürek on 30.08.2025.
//

import SwiftUI

struct TeamColorWheelSelectionView: View {
    let teamNumber: Int
    var usesPlayerLabel: Bool = false
    let sportIcon: String
    @Binding var colorIndex: Int
    let availableColorIndices: [Int]
    let onNext: () -> Void
    let onCancel: () -> Void
    
    @State private var wheelSlot = 0
    @State private var crownSlot: Double = 0
    @State private var isNextPulsing = false
    @State private var iconSpin: Double = 0
    @State private var isAdvancing = false
    @FocusState private var isCrownFocused: Bool
    
    private static let spinDuration: TimeInterval = 0.7
    
    private var maxWheelSlot: Int {
        max(availableColorIndices.count - 1, 0)
    }
    
    private var crownWheelControl: some View {
        PickColorWheelHint()
            .frame(width: 26, height: 62)
            .contentShape(Rectangle())
            .focusable(true)
            .focused($isCrownFocused)
            .digitalCrownRotation(
                $crownSlot,
                from: 0,
                through: Double(max(maxWheelSlot, 0)),
                by: 1,
                sensitivity: .medium,
                isContinuous: true,
                isHapticFeedbackEnabled: true
            )
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                
                VStack(spacing: 0) {
                    VStack(spacing: 8) {
                        Text("\(usesPlayerLabel ? "Player" : "Team") #\(teamNumber)")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Image(systemName: sportIcon)
                            .font(.system(size: 46, weight: .medium))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(iconSpin))
                            .animation(.easeInOut(duration: Self.spinDuration), value: iconSpin)
                    }
                    .offset(y: 2)
                    
                    SetupActionButtons(
                        primaryTitle: "Next",
                        primaryAction: advanceToNext,
                        secondaryTitle: "Cancel",
                        secondaryAction: onCancel,
                        isPrimaryPulsing: isNextPulsing,
                        isInteractionEnabled: !isAdvancing
                    )
                    .padding(.top, SetupScreenMetrics.buttonTopPadding)
                }
                .offset(y: SetupScreenMetrics.contentVerticalOffset)
                
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                    isNextPulsing = true
                }
            }
            .allowsHitTesting(!isAdvancing)
        }
        .overlay {
            GeometryReader { proxy in
                crownWheelControl
                    .allowsHitTesting(!isAdvancing)
                    .position(
                        x: proxy.size.width - 16,
                        y: proxy.size.height * 0.26
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .scrollIndicators(.hidden)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 12)
                .onEnded { value in
                    guard !isAdvancing else { return }
                    
                    let horizontal = value.translation.width
                    let vertical = value.translation.height
                    
                    if abs(horizontal) > abs(vertical), horizontal > 28 {
                        onCancel()
                        return
                    }
                    
                    let threshold: CGFloat = 20
                    if vertical < -threshold {
                        stepColor(by: 1)
                    } else if vertical > threshold {
                        stepColor(by: -1)
                    }
                }
        )
        .onAppear {
            iconSpin = 0
            isAdvancing = false
            syncWheelFromColorIndex()
            isCrownFocused = true
        }
        .onChange(of: crownSlot) { _, newValue in
            let slot = min(max(Int(newValue.rounded()), 0), maxWheelSlot)
            applySlot(slot)
        }
        .onChange(of: colorIndex) { _, _ in
            syncWheelFromColorIndex()
        }
        .onChange(of: availableColorIndices) { _, _ in
            syncWheelFromColorIndex()
        }
    }
    
    func syncWheelFromColorIndex() {
        if let slot = availableColorIndices.firstIndex(of: colorIndex) {
            wheelSlot = slot
            crownSlot = Double(slot)
        } else if let first = availableColorIndices.first {
            wheelSlot = 0
            crownSlot = 0
            colorIndex = first
        }
    }
    
    func applySlot(_ slot: Int) {
        guard availableColorIndices.indices.contains(slot) else { return }
        wheelSlot = slot
        let newColorIndex = availableColorIndices[slot]
        if colorIndex != newColorIndex {
            colorIndex = newColorIndex
        }
        if crownSlot != Double(slot) {
            crownSlot = Double(slot)
        }
    }
    
    func stepColor(by delta: Int) {
        guard !isAdvancing else { return }
        let nextSlot = (wheelSlot + delta + availableColorIndices.count) % availableColorIndices.count
        applySlot(nextSlot)
    }
    
    func advanceToNext() {
        guard !isAdvancing else { return }
        isAdvancing = true
        isCrownFocused = false
        iconSpin = 0
        
        withAnimation(.easeInOut(duration: Self.spinDuration)) {
            iconSpin = 360
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.spinDuration) {
            isAdvancing = false
            iconSpin = 0
            onNext()
        }
    }
}
