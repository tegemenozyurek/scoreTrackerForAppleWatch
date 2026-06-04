//
//  ContentView.swift
//  ScoreTracker Watch App
//
//  Created by Turgut Egemen Özyürek on 30.08.2025.
//

import SwiftUI
import HealthKit

enum TeamColor: Int, CaseIterable {
    case red = 0
    case blue = 1
    case green = 2
    case pink = 3
    case purple = 4
    
    var color: Color {
        switch self {
        case .red: .red
        case .blue: .blue
        case .green: .green
        case .pink: .pink
        case .purple: .purple
        }
    }
}

private enum SetupScreenMetrics {
    static let buttonStackWidth: CGFloat = 120
    static let buttonTopPadding: CGFloat = 26
    static let contentVerticalOffset: CGFloat = 10
    /// Matches Team # title + icon block height on the color steps.
    static let headerBlockHeight: CGFloat = 80
}

struct SetupActionButtons: View {
    let primaryTitle: String
    let primaryAction: () -> Void
    let secondaryTitle: String
    let secondaryAction: () -> Void
    var primaryBackgroundColor: Color = .white
    var primaryForegroundColor: Color = .black
    var isPrimaryPulsing: Bool = false
    var isInteractionEnabled: Bool = true
    
    var body: some View {
        VStack(spacing: 6) {
            Button(action: primaryAction) {
                Text(primaryTitle)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(primaryForegroundColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 5)
                    .background(primaryBackgroundColor)
                    .cornerRadius(6)
                    .scaleEffect(isPrimaryPulsing ? 1.03 : 0.98)
                    .animation(
                        .easeInOut(duration: 1.4).repeatForever(autoreverses: true),
                        value: isPrimaryPulsing
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

struct TeamColorWheelSelectionView: View {
    let teamNumber: Int
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
                        Text("Team #\(teamNumber)")
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
    
    private func syncWheelFromColorIndex() {
        if let slot = availableColorIndices.firstIndex(of: colorIndex) {
            wheelSlot = slot
            crownSlot = Double(slot)
        } else if let first = availableColorIndices.first {
            wheelSlot = 0
            crownSlot = 0
            colorIndex = first
        }
    }
    
    private func applySlot(_ slot: Int) {
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
    
    private func stepColor(by delta: Int) {
        guard !isAdvancing else { return }
        let nextSlot = (wheelSlot + delta + availableColorIndices.count) % availableColorIndices.count
        applySlot(nextSlot)
    }
    
    private func advanceToNext() {
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

private struct DurationWheelColumn: View {
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
    private func wheelRow(offset: Int, fontSize: CGFloat, isCenter: Bool = false) -> some View {
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
    
    private enum FocusedDurationPicker {
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
    
    private func selectDurationPicker(_ picker: FocusedDurationPicker) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            highlightedPicker = picker
            focusedPicker = picker
        }
    }
}

private struct MatchSession: Identifiable {
    let id = UUID()
    let team1Color: Color
    let team2Color: Color
    let sportName: String
    let sportIcon: String
    let initialTimerSeconds: Int
    let countsUp: Bool
    
    var isBasketball: Bool { sportName == "Basketball" }
}

struct FootballSetupView: View {
    @Environment(\.dismiss) private var dismiss
    var onDismissToSportList: (() -> Void)? = nil
    @State private var team1ColorIndex = TeamColor.red.rawValue
    @State private var team2ColorIndex = TeamColor.blue.rawValue
    @State private var selectedTime: Int
    @State private var hasTimeLimit: Bool
    @State private var currentStep = 0 // 0: Team 1, 1: Team 2, 2: Time
    @State private var activeMatch: MatchSession?
    @State private var dismissToMain = false
    @State private var isStartPulsing = false
    let themeColor: Color
    let sportName: String
    let sportIcon: String
    
    init(
        onDismissToSportList: (() -> Void)? = nil,
        themeColor: Color,
        sportName: String,
        sportIcon: String,
        defaultHasTimeLimit: Bool = true
    ) {
        self.onDismissToSportList = onDismissToSportList
        self.themeColor = themeColor
        self.sportName = sportName
        self.sportIcon = sportIcon
        _hasTimeLimit = State(initialValue: defaultHasTimeLimit)
        _selectedTime = State(initialValue: defaultHasTimeLimit ? 60 : 0)
    }
    
    private var allColorIndices: [Int] {
        TeamColor.allCases.map(\.rawValue)
    }
    
    private var team2ColorIndices: [Int] {
        allColorIndices.filter { $0 != team1ColorIndex }
    }
    
    private var selectedTeam1Color: Color {
        TeamColor(rawValue: team1ColorIndex)?.color ?? .red
    }
    
    private var selectedTeam2Color: Color {
        TeamColor(rawValue: team2ColorIndex)?.color ?? .blue
    }
    
    private var screenBackgroundColor: Color {
        switch currentStep {
        case 0: selectedTeam1Color
        case 1: selectedTeam2Color
        default: .black
        }
    }
    
    var timeOptions: [Int] {
        [45, 60, 75, 90, 105, 120] // Common football match durations
    }
    
    private func exitToSportList() {
        if let onDismissToSportList {
            onDismissToSportList()
        } else {
            dismiss()
        }
    }
    
    private func startMatch() {
        let timerSeconds = hasTimeLimit ? max(selectedTime, 1) * 60 : 0
        activeMatch = MatchSession(
            team1Color: selectedTeam1Color,
            team2Color: selectedTeam2Color,
            sportName: sportName,
            sportIcon: sportIcon,
            initialTimerSeconds: timerSeconds,
            countsUp: !hasTimeLimit
        )
    }
    
    private func cancelFromCurrentStep() {
        switch currentStep {
        case 0:
            exitToSportList()
        case 1:
            currentStep = 0
        case 2:
            currentStep = 1
        default:
            exitToSportList()
        }
    }
    
    var body: some View {
        ZStack {
            screenBackgroundColor
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.2), value: team1ColorIndex)
                .animation(.easeInOut(duration: 0.2), value: team2ColorIndex)
                .animation(.easeInOut(duration: 0.2), value: currentStep)
            
            VStack(spacing: 0) {
                    Group {
                        switch currentStep {
                        case 0:
                            TeamColorWheelSelectionView(
                                teamNumber: 1,
                                sportIcon: sportIcon,
                                colorIndex: $team1ColorIndex,
                                availableColorIndices: allColorIndices,
                                onNext: { currentStep = 1 },
                                onCancel: cancelFromCurrentStep
                            )
                        case 1:
                            TeamColorWheelSelectionView(
                                teamNumber: 2,
                                sportIcon: sportIcon,
                                colorIndex: $team2ColorIndex,
                                availableColorIndices: team2ColorIndices,
                                onNext: { currentStep = 2 },
                                onCancel: cancelFromCurrentStep
                            )
                        default:
                            ZStack(alignment: .top) {
                                TimeDurationPicker(
                                    totalMinutes: $selectedTime,
                                    hasTimeLimit: $hasTimeLimit,
                                    accentColor: themeColor
                                )
                                .padding(.top, 24)
                                
                                SetupButtonStackPlacement(
                                    headerBlockHeight: SetupScreenMetrics.headerBlockHeight
                                ) {
                                    SetupActionButtons(
                                        primaryTitle: "Start",
                                        primaryAction: startMatch,
                                        secondaryTitle: "Cancel",
                                        secondaryAction: { currentStep = 1 },
                                        primaryBackgroundColor: themeColor,
                                        primaryForegroundColor: .white,
                                        isPrimaryPulsing: isStartPulsing
                                    )
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .scrollIndicators(.hidden)
                            .overlay {
                                GeometryReader { proxy in
                                    PickColorWheelHint(label: "Time")
                                        .frame(width: 26, height: 62)
                                        .allowsHitTesting(false)
                                        .position(
                                            x: proxy.size.width - 16,
                                            y: proxy.size.height * 0.26
                                        )
                                }
                            }
                        }
                    }
                .frame(maxHeight: .infinity, alignment: .center)
            }
        }
        .contentShape(Rectangle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 16)
                .onEnded { value in
                    guard currentStep == 2 else { return }
                    let horizontal = value.translation.width
                    let vertical = value.translation.height
                    if abs(horizontal) > abs(vertical), horizontal > 28 {
                        cancelFromCurrentStep()
                    }
                }
        )
        .onChange(of: team1ColorIndex) { _, _ in
            if team2ColorIndex == team1ColorIndex,
               let fallback = team2ColorIndices.first {
                team2ColorIndex = fallback
            }
        }
        .onChange(of: currentStep) { _, step in
            if step == 2 {
                withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                    isStartPulsing = true
                }
            } else {
                isStartPulsing = false
            }
        }
        .navigationBarHidden(true)
        .sheet(item: $activeMatch) { session in
            ScoreboardView(
                team1Color: session.team1Color,
                team2Color: session.team2Color,
                sportName: session.sportName,
                sportIcon: session.sportIcon,
                initialTimerSeconds: session.initialTimerSeconds,
                countsUp: session.countsUp,
                dismissToMain: $dismissToMain
            )
        }
        .onChange(of: dismissToMain) { _, newValue in
            if newValue {
                activeMatch = nil
                exitToSportList()
            }
        }
    }
}

private struct MatchControlButton<Icon: View>: View {
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

private struct ScoreSnapshot: Equatable {
    let team1: Int
    let team2: Int
}

private struct MatchScoreLabel: View {
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

private struct BasketballPointButton: View {
    let points: Int
    let color: Color
    let width: CGFloat
    let height: CGFloat
    let fontSize: CGFloat
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("+\(points)")
                .font(.system(size: fontSize, weight: .bold))
                .foregroundColor(.white)
                .frame(width: width, height: height)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.45)
    }
}

private struct BasketballScoreboardRow: View {
    let team1Color: Color
    let team2Color: Color
    let sportIcon: String
    let team1Score: Int
    let team2Score: Int
    let timeString: String
    let team1Spin: Double
    let team2Spin: Double
    let isScoringEnabled: Bool
    let onAddPointsTeam1: (Int) -> Void
    let onAddPointsTeam2: (Int) -> Void
    let onDecrementTeam1: () -> Void
    let onDecrementTeam2: () -> Void
    
    var body: some View {
        GeometryReader { geo in
            let screenWidth = geo.size.width
            let buttonGap: CGFloat = 5
            let topRowGaps = buttonGap * 3
            let quarterWidth = (screenWidth - topRowGaps) / 4
            let halfWidth = (screenWidth - buttonGap) / 2
            let buttonHeight = min(34, quarterWidth)
            let buttonFontSize: CGFloat = buttonHeight >= 30 ? 14 : 12
            let buttonRowSpacing: CGFloat = 6
            let teamGap: CGFloat = 6
            let dashWidth: CGFloat = 10
            let scoreColumnWidth: CGFloat = 30
            let ballSide = min(46, max(36, screenWidth * 0.18))
            let maxScore = max(team1Score, team2Score)
            let scoreFontSize = scoreFontSize(for: maxScore, columnWidth: scoreColumnWidth)
            let dashFontSize = max(16, scoreFontSize * 0.75)
            let timerHeight: CGFloat = 18
            let contentHeight = ballSide + timerHeight + 6 + buttonHeight * 2 + buttonRowSpacing
            
            VStack(spacing: 6) {
                HStack(alignment: .top, spacing: teamGap) {
                    TeamScoreBall(
                        color: team1Color,
                        sportIcon: sportIcon,
                        spinDegrees: team1Spin,
                        side: ballSide,
                        allowsTapIncrement: false,
                        onIncrement: {},
                        onDecrement: onDecrementTeam1
                    )
                    
                    VStack(spacing: 3) {
                        HStack(spacing: 2) {
                            MatchScoreLabel(
                                score: team1Score,
                                columnWidth: scoreColumnWidth,
                                fontSize: scoreFontSize,
                                onGoal: {},
                                onDecrement: onDecrementTeam1
                            )
                            
                            Text("-")
                                .font(.system(size: dashFontSize, weight: .medium))
                                .foregroundColor(.white.opacity(0.5))
                                .frame(width: dashWidth)
                                .lineLimit(1)
                            
                            MatchScoreLabel(
                                score: team2Score,
                                columnWidth: scoreColumnWidth,
                                fontSize: scoreFontSize,
                                onGoal: {},
                                onDecrement: onDecrementTeam2
                            )
                        }
                        .fixedSize(horizontal: true, vertical: false)
                        
                        Text(timeString)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white.opacity(0.85))
                            .monospacedDigit()
                    }
                    
                    TeamScoreBall(
                        color: team2Color,
                        sportIcon: sportIcon,
                        spinDegrees: team2Spin,
                        side: ballSide,
                        allowsTapIncrement: false,
                        onIncrement: {},
                        onDecrement: onDecrementTeam2
                    )
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                VStack(spacing: buttonRowSpacing) {
                    HStack(spacing: buttonGap) {
                        BasketballPointButton(
                            points: 1,
                            color: team1Color,
                            width: quarterWidth,
                            height: buttonHeight,
                            fontSize: buttonFontSize,
                            isEnabled: isScoringEnabled,
                            action: { onAddPointsTeam1(1) }
                        )
                        
                        BasketballPointButton(
                            points: 2,
                            color: team1Color,
                            width: quarterWidth,
                            height: buttonHeight,
                            fontSize: buttonFontSize,
                            isEnabled: isScoringEnabled,
                            action: { onAddPointsTeam1(2) }
                        )
                        
                        BasketballPointButton(
                            points: 1,
                            color: team2Color,
                            width: quarterWidth,
                            height: buttonHeight,
                            fontSize: buttonFontSize,
                            isEnabled: isScoringEnabled,
                            action: { onAddPointsTeam2(1) }
                        )
                        
                        BasketballPointButton(
                            points: 2,
                            color: team2Color,
                            width: quarterWidth,
                            height: buttonHeight,
                            fontSize: buttonFontSize,
                            isEnabled: isScoringEnabled,
                            action: { onAddPointsTeam2(2) }
                        )
                    }
                    
                    HStack(spacing: buttonGap) {
                        BasketballPointButton(
                            points: 3,
                            color: team1Color,
                            width: halfWidth,
                            height: buttonHeight,
                            fontSize: buttonFontSize,
                            isEnabled: isScoringEnabled,
                            action: { onAddPointsTeam1(3) }
                        )
                        
                        BasketballPointButton(
                            points: 3,
                            color: team2Color,
                            width: halfWidth,
                            height: buttonHeight,
                            fontSize: buttonFontSize,
                            isEnabled: isScoringEnabled,
                            action: { onAddPointsTeam2(3) }
                        )
                    }
                }
                .frame(width: screenWidth)
            }
            .frame(width: screenWidth, height: contentHeight, alignment: .top)
            .padding(.top, 2)
        }
        .frame(height: 138)
    }
    
    private func scoreFontSize(for score: Int, columnWidth: CGFloat) -> CGFloat {
        let digits = max(1, String(score).count)
        let base: CGFloat = switch digits {
        case 1: min(42, columnWidth * 1.4)
        case 2: min(36, columnWidth * 1.15)
        default: min(28, columnWidth * 0.95)
        }
        return max(20, base)
    }
}

private struct ScoreboardScoreRow: View {
    let team1Color: Color
    let team2Color: Color
    let sportIcon: String
    let team1Score: Int
    let team2Score: Int
    let team1Spin: Double
    let team2Spin: Double
    let onGoalTeam1: () -> Void
    let onGoalTeam2: () -> Void
    let onDecrementTeam1: () -> Void
    let onDecrementTeam2: () -> Void
    
    var body: some View {
        GeometryReader { geo in
            let horizontalSpacing: CGFloat = 4
            let dashWidth: CGFloat = 12
            let ballSide = min(46, max(34, geo.size.width * 0.21))
            let scoreAreaWidth = max(
                0,
                geo.size.width - (ballSide * 2) - dashWidth - (horizontalSpacing * 4)
            )
            let scoreColumnWidth = max(22, scoreAreaWidth / 2)
            let maxScore = max(team1Score, team2Score)
            let scoreFontSize = scoreFontSize(for: maxScore, columnWidth: scoreColumnWidth)
            let dashFontSize = max(18, scoreFontSize * 0.75)
            
            HStack(spacing: horizontalSpacing) {
                TeamScoreBall(
                    color: team1Color,
                    sportIcon: sportIcon,
                    spinDegrees: team1Spin,
                    side: ballSide,
                    onIncrement: onGoalTeam1,
                    onDecrement: onDecrementTeam1
                )
                
                HStack(spacing: 2) {
                    MatchScoreLabel(
                        score: team1Score,
                        columnWidth: scoreColumnWidth,
                        fontSize: scoreFontSize,
                        onGoal: onGoalTeam1,
                        onDecrement: onDecrementTeam1
                    )
                    
                    Text("-")
                        .font(.system(size: dashFontSize, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(width: dashWidth)
                        .lineLimit(1)
                    
                    MatchScoreLabel(
                        score: team2Score,
                        columnWidth: scoreColumnWidth,
                        fontSize: scoreFontSize,
                        onGoal: onGoalTeam2,
                        onDecrement: onDecrementTeam2
                    )
                }
                .fixedSize(horizontal: true, vertical: false)
                .layoutPriority(1)
                
                TeamScoreBall(
                    color: team2Color,
                    sportIcon: sportIcon,
                    spinDegrees: team2Spin,
                    side: ballSide,
                    onIncrement: onGoalTeam2,
                    onDecrement: onDecrementTeam2
                )
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
        }
        .frame(height: 50)
    }
    
    private func scoreFontSize(for score: Int, columnWidth: CGFloat) -> CGFloat {
        let digits = max(1, String(score).count)
        let base: CGFloat = switch digits {
        case 1: min(36, columnWidth * 1.35)
        case 2: min(30, columnWidth * 1.1)
        default: min(24, columnWidth * 0.95)
        }
        return max(18, base)
    }
}

private struct TeamScoreBall: View {
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

private func scoreDecrementDrag(perform onDecrement: @escaping () -> Void) -> some Gesture {
    DragGesture().onEnded { value in
        if abs(value.translation.height) > 20 {
            onDecrement()
        }
    }
}

private struct ConfettiParticle: Identifiable {
    let id = UUID()
    let xRatio: CGFloat
    let color: Color
    let width: CGFloat
    let height: CGFloat
    let startRotation: Double
    let endRotation: Double
    let horizontalDrift: CGFloat
    let fallDuration: Double
    let delay: Double
    
    static func make(count: Int) -> [ConfettiParticle] {
        let colors: [Color] = [.yellow, .orange, .pink, .blue, .green, .white, .purple, .mint]
        return (0..<count).map { _ in
            ConfettiParticle(
                xRatio: CGFloat.random(in: 0.08...0.92),
                color: colors.randomElement() ?? .yellow,
                width: CGFloat.random(in: 4...7),
                height: CGFloat.random(in: 6...11),
                startRotation: Double.random(in: 0...180),
                endRotation: Double.random(in: 180...540),
                horizontalDrift: CGFloat.random(in: -18...18),
                fallDuration: Double.random(in: 1.4...2.4),
                delay: Double.random(in: 0...0.35)
            )
        }
    }
}

private struct ConfettiPieceView: View {
    let particle: ConfettiParticle
    let containerSize: CGSize
    @State private var hasFallen = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 1.5, style: .continuous)
            .fill(particle.color)
            .frame(width: particle.width, height: particle.height)
            .rotationEffect(.degrees(hasFallen ? particle.endRotation : particle.startRotation))
            .position(
                x: particle.xRatio * containerSize.width + (hasFallen ? particle.horizontalDrift : 0),
                y: hasFallen ? containerSize.height + 24 : -16
            )
            .opacity(hasFallen ? 0 : 1)
            .onAppear {
                withAnimation(.easeIn(duration: particle.fallDuration).delay(particle.delay)) {
                    hasFallen = true
                }
            }
    }
}

private struct MatchEndConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    ConfettiPieceView(particle: particle, containerSize: geo.size)
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .onAppear {
            particles = ConfettiParticle.make(count: 30)
        }
    }
}

private struct MatchStatsPlaceholderView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "heart.fill")
                .font(.system(size: 22))
                .foregroundColor(.red)
            Text("Stats")
                .font(.system(size: 16, weight: .semibold))
            Text("Coming soon")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            Button("Close") { dismiss() }
                .font(.system(size: 13, weight: .semibold))
        }
        .padding()
    }
}

private struct MatchEndView: View {
    let backgroundColor: Color
    let resultMessage: String
    let team1Score: Int
    let team2Score: Int
    let onFinish: () -> Void
    let onStats: () -> Void
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            MatchEndConfettiView()
            
            VStack(spacing: 12) {
                Text(resultMessage)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
                
                Text("\(team1Score) - \(team2Score)")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(.white.opacity(0.85))
                    .monospacedDigit()
                
                Spacer(minLength: 8)
                
                VStack(spacing: 6) {
                    Button(action: onFinish) {
                        Text("Finish")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 7)
                            .background(Color.white)
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: onStats) {
                        HStack(spacing: 5) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 11, weight: .semibold))
                            Text("Stats")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 28)
                .offset(y: -18)
            }
            .padding(.top, 28)
            .padding(.bottom, 8)
            .offset(y: -22)
        }
    }
}

struct ScoreboardView: View {
    @Environment(\.dismiss) private var dismiss
    let team1Color: Color
    let team2Color: Color
    let sportName: String
    let sportIcon: String
    let initialTimerSeconds: Int
    let countsUp: Bool
    @Binding var dismissToMain: Bool
    
    private var isBasketball: Bool { sportName == "Basketball" }
    private var showsMatchEndScreen: Bool {
        sportName == "Basketball" || sportName == "Football"
    }
    
    @State private var team1Score = 0
    @State private var team2Score = 0
    @State private var timerSeconds: Int = 0
    @State private var isGameActive = true
    @State private var showingFinishAlert = false
    @State private var showingMatchEnd = false
    @State private var showingStats = false
    @State private var scoreHistory: [ScoreSnapshot] = []
    @State private var isScoreIncreaseLocked = false
    @State private var team1Spin: Double = 0
    @State private var team2Spin: Double = 0
    
    init(
        team1Color: Color,
        team2Color: Color,
        sportName: String,
        sportIcon: String,
        initialTimerSeconds: Int,
        countsUp: Bool,
        dismissToMain: Binding<Bool>
    ) {
        self.team1Color = team1Color
        self.team2Color = team2Color
        self.sportName = sportName
        self.sportIcon = sportIcon
        self.initialTimerSeconds = initialTimerSeconds
        self.countsUp = countsUp
        self._dismissToMain = dismissToMain
        self._timerSeconds = State(initialValue: countsUp ? 0 : initialTimerSeconds)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                ZStack(alignment: .bottom) {
                    VStack(spacing: 0) {
                        VStack(spacing: 4) {
                            HStack(spacing: 6) {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                                    .font(.system(size: 16))
                                
                                Text("--")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("BPM")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Capsule())
                        }
                        .padding(.top, -60)
                        
                        Group {
                            if isBasketball {
                                BasketballScoreboardRow(
                                    team1Color: team1Color,
                                    team2Color: team2Color,
                                    sportIcon: sportIcon,
                                    team1Score: team1Score,
                                    team2Score: team2Score,
                                    timeString: timeString,
                                    team1Spin: team1Spin,
                                    team2Spin: team2Spin,
                                    isScoringEnabled: !isScoreIncreaseLocked,
                                    onAddPointsTeam1: { scorePoints(for: 1, points: $0) },
                                    onAddPointsTeam2: { scorePoints(for: 2, points: $0) },
                                    onDecrementTeam1: { adjustTeam1Score(by: -1) },
                                    onDecrementTeam2: { adjustTeam2Score(by: -1) }
                                )
                            } else {
                                ScoreboardScoreRow(
                                    team1Color: team1Color,
                                    team2Color: team2Color,
                                    sportIcon: sportIcon,
                                    team1Score: team1Score,
                                    team2Score: team2Score,
                                    team1Spin: team1Spin,
                                    team2Spin: team2Spin,
                                    onGoalTeam1: { scorePoints(for: 1, points: 1) },
                                    onGoalTeam2: { scorePoints(for: 2, points: 1) },
                                    onDecrementTeam1: { adjustTeam1Score(by: -1) },
                                    onDecrementTeam2: { adjustTeam2Score(by: -1) }
                                )
                            }
                        }
                        .padding(.horizontal, 2)
                        .padding(.top, isBasketball ? 0 : 10)
                        .offset(y: isBasketball ? -12 : 2)
                        .overlay(alignment: .bottom) {
                            if !isBasketball {
                                Text(timeString)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white.opacity(0.85))
                                    .offset(y: 26)
                            }
                        }
                        
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    
                    HStack(spacing: 8) {
                        MatchControlButton(
                            backgroundColor: .yellow,
                            accessibilityLabel: "Revert last score",
                            isEnabled: !scoreHistory.isEmpty,
                            action: revertLastScoreChange
                        ) {
                            Image(systemName: "arrow.uturn.backward")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        MatchControlButton(
                            backgroundColor: .orange,
                            accessibilityLabel: isGameActive ? "Pause match" : "Resume match",
                            isEnabled: true,
                            action: { isGameActive.toggle() }
                        ) {
                            Image(systemName: isGameActive ? "pause.fill" : "play.fill")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        MatchControlButton(
                            backgroundColor: .red,
                            accessibilityLabel: "Finish match",
                            isEnabled: !showingMatchEnd,
                            action: requestFinishFromWhistle
                        ) {
                            Image("Whistle")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18, height: 18)
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 0)
                    .offset(y: 28)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                if showingMatchEnd {
                    MatchEndView(
                        backgroundColor: matchEndBackgroundColor,
                        resultMessage: matchResultMessage,
                        team1Score: team1Score,
                        team2Score: team2Score,
                        onFinish: exitToSportList,
                        onStats: { showingStats = true }
                    )
                    .transition(.opacity)
                }
            }
        }
        .onReceive(timer) { _ in
            guard isGameActive, !showingMatchEnd else { return }
            if countsUp {
                timerSeconds += 1
            } else if timerSeconds > 0 {
                timerSeconds -= 1
                if timerSeconds == 0 {
                    presentMatchEnd()
                }
            }
        }
        .alert("End Match?", isPresented: $showingFinishAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Finish", role: .destructive) {
                presentMatchEnd()
            }
        } message: {
            Text("Are you sure you want to end the match?")
        }
        .sheet(isPresented: $showingStats) {
            MatchStatsPlaceholderView()
        }
        .navigationBarHidden(true)
    }
    
    private var matchResultMessage: String {
        if team1Score > team2Score { return "Team 1 wins" }
        if team2Score > team1Score { return "Team 2 wins" }
        return "Draw"
    }
    
    private var matchEndBackgroundColor: Color {
        if team1Score > team2Score { return team1Color }
        if team2Score > team1Score { return team2Color }
        return .gray
    }
    
    private func requestFinishFromWhistle() {
        guard !showingMatchEnd else { return }
        showingFinishAlert = true
    }
    
    private func presentMatchEnd() {
        guard !showingMatchEnd else { return }
        isGameActive = false
        guard showsMatchEndScreen else {
            exitToSportList()
            return
        }
        withAnimation(.easeInOut(duration: 0.25)) {
            showingMatchEnd = true
        }
    }
    
    private func exitToSportList() {
        dismissToMain = true
        dismiss()
    }
    
    private func pushScoreHistory() {
        scoreHistory.append(ScoreSnapshot(team1: team1Score, team2: team2Score))
    }
    
    private func scorePoints(for team: Int, points: Int) {
        guard !isScoreIncreaseLocked else { return }
        guard points > 0 else { return }
        isScoreIncreaseLocked = true
        
        pushScoreHistory()
        switch team {
        case 1:
            team1Score += points
            withAnimation(.easeInOut(duration: TeamScoreBall.spinDuration)) {
                team1Spin += 360
            }
        case 2:
            team2Score += points
            withAnimation(.easeInOut(duration: TeamScoreBall.spinDuration)) {
                team2Spin += 360
            }
        default:
            isScoreIncreaseLocked = false
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + TeamScoreBall.spinDuration) {
            isScoreIncreaseLocked = false
        }
    }
    
    private func adjustTeam1Score(by delta: Int) {
        guard delta < 0 else { return }
        let newScore = team1Score + delta
        guard newScore >= 0 else { return }
        pushScoreHistory()
        team1Score = newScore
    }
    
    private func adjustTeam2Score(by delta: Int) {
        guard delta < 0 else { return }
        let newScore = team2Score + delta
        guard newScore >= 0 else { return }
        pushScoreHistory()
        team2Score = newScore
    }
    
    private func revertLastScoreChange() {
        guard let previous = scoreHistory.popLast() else { return }
        team1Score = previous.team1
        team2Score = previous.team2
    }
    
    private var timeString: String {
        let minutes = timerSeconds / 60
        let seconds = timerSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
}

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
    
    private func resetRockAnimation() {
        isSelecting = false
        selectionSpin = 0
        isRocking = false
        DispatchQueue.main.async {
            isRocking = true
        }
    }
    
    private func selectSport() {
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

struct Sport {
    let name: String
    let icon: String
    let color: Color
}

struct ContentView: View {
    let sports = [
        Sport(name: "Football", icon: "soccerball", color: Color(hex: "#228B22")),
        Sport(name: "Basketball", icon: "basketball", color: Color(hex: "#FF8C00")),
        Sport(name: "Tennis", icon: "tennisball", color: Color(hex: "#FFD700")),
        Sport(name: "Volleyball", icon: "volleyball", color: Color(hex: "#1E90FF"))
    ]
    
    @State private var currentIndex = 0
    @State private var isTransitioning = false
    @State private var showingSetup = false
    @State private var setupCoverOpacity: Double = 1
    @State private var isSelectingSport = false
    @State private var setupThemeColor: Color = Color(hex: "#228B22")
    @State private var setupSportIcon: String = "soccerball"
    @State private var setupSportName: String = "Football"
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(sports.enumerated()), id: \.offset) { index, sport in
                            SportCard(
                                sport: sport,
                                isSelectionEnabled: !showingSetup && !isSelectingSport,
                                onSelectionBegin: { isSelectingSport = true }
                            ) {
                                beginSetup(for: sport)
                            }
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .scaleEffect(isTransitioning ? 0.85 : 1.0)
                            .opacity(isTransitioning ? 0.6 : 1.0)
                            .animation(
                                Animation.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.4),
                                value: isTransitioning
                            )
                        }
                    }
                }
                .scrollTargetBehavior(.paging)
                .scrollDisabled(isSelectingSport || showingSetup)
                .onChange(of: currentIndex) { _, _ in
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isTransitioning = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isTransitioning = false
                        }
                    }
                }
            }
            .allowsHitTesting(!showingSetup && !isSelectingSport)
            
            if showingSetup {
                FootballSetupView(
                    onDismissToSportList: exitSetup,
                    themeColor: setupThemeColor,
                    sportName: setupSportName,
                    sportIcon: setupSportIcon,
                    defaultHasTimeLimit: setupSportName != "Basketball"
                )
                .opacity(setupCoverOpacity)
            }
        }
        .ignoresSafeArea()
    }
    
    private func beginSetup(for sport: Sport) {
        setupThemeColor = sport.color
        setupSportIcon = sport.icon
        setupSportName = sport.name
        isSelectingSport = false
        setupCoverOpacity = 1
        showingSetup = true
    }
    
    private func exitSetup() {
        isSelectingSport = false
        withAnimation(.easeInOut(duration: 0.25)) {
            setupCoverOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            showingSetup = false
            setupCoverOpacity = 1
        }
    }
}

// Color extension to support hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ContentView()
}
