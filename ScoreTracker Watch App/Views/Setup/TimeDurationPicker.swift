//
//  TimeDurationPicker.swift
//  ScoreTracker Watch App
//
//  Created by Turgut Egemen Özyürek on 30.08.2025.
//

import SwiftUI

struct DurationWheelColumn: View {
    @Binding var value: Int
    let options: [Int]
    let format: (Int) -> String
    let pickerFontSize: CGFloat
    let width: CGFloat
    let height: CGFloat
    let accentColor: Color
    let isActive: Bool
    
    @State private var crownIndex: Double = 0
    
    private var selectedIndex: Int {
        options.firstIndex(of: value) ?? 0
    }
    
    private var rowHeight: CGFloat {
        height / 3
    }
    
    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 8, style: .continuous)
        let borderColor = isActive ? accentColor : Color.white.opacity(0.28)
        let borderWidth: CGFloat = isActive ? 2.5 : 1
        let secondaryFontSize = max(12, pickerFontSize - 3)
        
        ZStack {
            shape.fill(Color.black)
            
            VStack(spacing: 0) {
                wheelRow(offset: -1, fontSize: secondaryFontSize)
                    .frame(height: rowHeight)
                wheelRow(offset: 0, fontSize: pickerFontSize, isCenter: true)
                    .frame(height: rowHeight)
                wheelRow(offset: 1, fontSize: secondaryFontSize)
                    .frame(height: rowHeight)
            }
            .frame(width: width, height: height)
            
            shape.stroke(
                borderColor,
                style: StrokeStyle(lineWidth: borderWidth, lineCap: .round, lineJoin: .round)
            )
        }
        .frame(width: width, height: height)
        .contentShape(shape)
        .animation(nil, value: value)
        .animation(nil, value: isActive)
        .focusable()
        .digitalCrownRotation(
            $crownIndex,
            from: 0,
            through: Double(max(0, options.count - 1)),
            by: 1,
            sensitivity: .medium,
            isContinuous: true,
            isHapticFeedbackEnabled: true
        )
        .onAppear {
            crownIndex = Double(selectedIndex)
        }
        .onChange(of: value) { _, _ in
            crownIndex = Double(selectedIndex)
        }
        .onChange(of: crownIndex) { _, newIndex in
            let idx = min(options.count - 1, max(0, Int(newIndex.rounded())))
            guard options.indices.contains(idx) else { return }
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                value = options[idx]
            }
        }
    }
    
    @ViewBuilder
    func wheelRow(offset: Int, fontSize: CGFloat, isCenter: Bool = false) -> some View {
        let idx = selectedIndex + offset
        if options.indices.contains(idx) {
            Text(format(options[idx]))
                .font(.system(size: fontSize, weight: isCenter ? .semibold : .regular))
                .monospacedDigit()
                .foregroundColor(isCenter ? .white : .white.opacity(0.35))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .lineLimit(1)
                .contentTransition(.identity)
        } else {
            Text("00")
                .font(.system(size: fontSize))
                .monospacedDigit()
                .opacity(0)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct TimeDurationPicker: View {
    @Binding var totalMinutes: Int
    @Binding var hasTimeLimit: Bool
    let accentColor: Color
    
    @State private var highlightedPicker: FocusedDurationPicker = .hours
    @FocusState private var focusedPicker: FocusedDurationPicker?
    
    enum FocusedDurationPicker {
        case hours
        case minutes
    }
    
    private let hourRange: [Int] = Array(0...3)
    private let minuteStepRange: [Int] = Array(stride(from: 0, through: 55, by: 5)) // 0,5,10,...55
    
    private var hoursBinding: Binding<Int> {
        Binding(
            get: { min(hourRange.last ?? 0, max(0, totalMinutes / 60)) },
            set: { newHours in
                guard hasTimeLimit else { return }
                totalMinutes = newHours * 60 + snappedMinutes
            }
        )
    }
    
    private var minutesBinding: Binding<Int> {
        Binding(
            get: { snappedMinutes },
            set: { newMinutes in
                guard hasTimeLimit else { return }
                totalMinutes = min(hourRange.last ?? 0, max(0, totalMinutes / 60)) * 60 + newMinutes
            }
        )
    }
    
    private var snappedMinutes: Int {
        let remainder = totalMinutes % 60
        return minuteStepRange.min(by: { abs($0 - remainder) < abs($1 - remainder) }) ?? 0
    }
    
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let isLarge = width > 175
            let pickerFontSize: CGFloat = isLarge ? 18 : 16
            let pickerHeight: CGFloat = isLarge ? 48 : 42
            let pickerWidth: CGFloat = min(72, width * 0.34)
            
            VStack(spacing: 4) {
                HStack(alignment: .top, spacing: 6) {
                    VStack(spacing: 3) {
                        DurationWheelColumn(
                            value: hoursBinding,
                            options: hourRange,
                            format: { "\($0)" },
                            pickerFontSize: pickerFontSize,
                            width: pickerWidth,
                            height: pickerHeight,
                            accentColor: accentColor,
                            isActive: highlightedPicker == .hours
                        )
                        .onTapGesture { selectDurationPicker(.hours) }
                        .focused($focusedPicker, equals: .hours)
                        
                        Text("hour(s)")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.white.opacity(0.55))
                            .frame(width: pickerWidth)
                    }
                    
                    VStack(spacing: 3) {
                        DurationWheelColumn(
                            value: minutesBinding,
                            options: minuteStepRange,
                            format: { String(format: "%02d", $0) },
                            pickerFontSize: pickerFontSize,
                            width: pickerWidth,
                            height: pickerHeight,
                            accentColor: accentColor,
                            isActive: highlightedPicker == .minutes
                        )
                        .onTapGesture { selectDurationPicker(.minutes) }
                        .focused($focusedPicker, equals: .minutes)
                        
                        Text("minute(s)")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.white.opacity(0.55))
                            .frame(width: pickerWidth)
                    }
                }
                .disabled(!hasTimeLimit)
                
                Button {
                    hasTimeLimit.toggle()
                    if hasTimeLimit {
                        if totalMinutes <= 0 { totalMinutes = 60 }
                    } else {
                        totalMinutes = 0
                    }
                } label: {
                    HStack(spacing: 5) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(hasTimeLimit ? Color.clear : Color.white)
                                .frame(width: 13, height: 13)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 3)
                                        .stroke(Color.white.opacity(0.75), lineWidth: 1)
                                )
                            if !hasTimeLimit {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(.black)
                            }
                        }
                        Text("No time limit")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 10)
            }
            .padding(.top, 32)
            .onAppear {
                if hasTimeLimit {
                    if totalMinutes <= 0 { totalMinutes = 60 }
                    else { totalMinutes = min(hourRange.last ?? 0, totalMinutes / 60) * 60 + snappedMinutes }
                    highlightedPicker = .hours
                    focusedPicker = .hours
                } else {
                    totalMinutes = 0
                }
            }
            .onChange(of: focusedPicker) { _, newFocus in
                guard let newFocus, hasTimeLimit else { return }
                highlightedPicker = newFocus
            }
            .onChange(of: hasTimeLimit) { _, limited in
                if limited {
                    if totalMinutes <= 0 { totalMinutes = 60 }
                    highlightedPicker = .hours
                    focusedPicker = .hours
                } else {
                    totalMinutes = 0
                    focusedPicker = nil
                }
            }
            .scrollIndicators(.hidden)
        }
    }
    
    func selectDurationPicker(_ picker: FocusedDurationPicker) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            highlightedPicker = picker
            focusedPicker = picker
        }
    }
}
