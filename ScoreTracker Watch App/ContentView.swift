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

struct PickColorWheelHint: View {
    @State private var isArrowPulsing = false
    
    var body: some View {
        ZStack {
            Text("Color")
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
                    
                    VStack(spacing: 6) {
                        Button(action: advanceToNext) {
                            Text("Next")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 5)
                                .background(Color.white)
                                .cornerRadius(6)
                                .scaleEffect(isNextPulsing ? 1.03 : 0.98)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .allowsHitTesting(!isAdvancing)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                                isNextPulsing = true
                            }
                        }
                        
                        Button(action: onCancel) {
                            Text("Cancel")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 5)
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(6)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .allowsHitTesting(!isAdvancing)
                    }
                    .frame(maxWidth: 120)
                    .padding(.top, 26)
                }
                .offset(y: 10)
                
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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

struct TimeDurationPicker: View {
    @Binding var totalMinutes: Int
    
    @State private var hours: Int = 1
    @State private var minutes: Int = 30
    @State private var isUnlimited: Bool = false
    
    private let hourRange: [Int] = Array(0...2) // 0h to 2h (0-120 min)
    private let minuteStepRange: [Int] = Array(stride(from: 0, through: 55, by: 5)) // 0,5,10,...55
    
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let isLarge = width > 175
            let titleSize: CGFloat = isLarge ? 18 : 16
            let pickerFontSize: CGFloat = isLarge ? 18 : 16
            
            VStack(spacing: 4) {
                HStack(spacing: 8) {
                    VStack(spacing: 2) {
                        Picker("Hours", selection: $hours) {
                            ForEach(hourRange, id: \.self) { h in
                                Text("\(h)")
                                    .font(.system(size: pickerFontSize, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .pickerStyle(.wheel)
                        .background(Color(hex: "#228B22"))
                        .overlay(Color.clear)
                        .disabled(isUnlimited)
                        .frame(height: isLarge ? 96 : 86)
                        .clipped()
                    }
                    .background(Color(hex: "#228B22"))
                    
                    VStack(spacing: 2) {
                        Picker("Minutes", selection: $minutes) {
                            ForEach(minuteStepRange, id: \.self) { m in
                                Text(String(format: "%02d", m))
                                    .font(.system(size: pickerFontSize, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .pickerStyle(.wheel)
                        .background(Color(hex: "#228B22"))
                        .overlay(Color.clear)
                        .disabled(isUnlimited)
                        .frame(height: isLarge ? 96 : 86)
                        .clipped()
                    }
                    .background(Color(hex: "#228B22"))
                }
                .padding(.top, -10)
                
                // No time limit checkbox (moved below pickers)
                Button {
                    isUnlimited.toggle()
                    if isUnlimited {
                        totalMinutes = 0
                    } else {
                        totalMinutes = hours * 60 + minutes
                    }
                } label: {
                    HStack(spacing: 8) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(isUnlimited ? Color.white : Color.clear)
                                .frame(width: 18, height: 18)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.white, lineWidth: 2)
                                )
                            if isUnlimited {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.black)
                            }
                        }
                        Text("No time limit")
                            .font(.system(size: isLarge ? 16 : 14, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Capsule())
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 15)
            }
            .padding(.top, -28)
            .onAppear {
                if totalMinutes == 0 {
                    isUnlimited = true
                } else {
                    isUnlimited = false
                    hours = totalMinutes / 60
                    minutes = totalMinutes % 60
                    let remainder = minutes % 5
                    if remainder != 0 { minutes -= remainder }
                }
            }
            .onChange(of: hours) { _, _ in
                if !isUnlimited { totalMinutes = hours * 60 + minutes }
            }
            .onChange(of: minutes) { _, _ in
                if !isUnlimited { totalMinutes = hours * 60 + minutes }
            }
        }
    }
}

struct FootballSetupView: View {
    @Environment(\.dismiss) private var dismiss
    var onDismissToSportList: (() -> Void)? = nil
    @State private var team1ColorIndex = TeamColor.red.rawValue
    @State private var team2ColorIndex = TeamColor.blue.rawValue
    @State private var selectedTime = 90
    @State private var currentStep = 0 // 0: Team 1, 1: Team 2, 2: Time
    @State private var showingScoreboard = false
    @State private var dismissToMain = false
    let themeColor: Color
    let sportIcon: String
    let showTimePicker: Bool
    
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
        default: themeColor
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
    
    private func cancelFromCurrentStep() {
        switch currentStep {
        case 0:
            exitToSportList()
        case 1:
            currentStep = 0
        case 2 where showTimePicker:
            currentStep = 1
        default:
            exitToSportList()
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
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
                                onNext: {
                                    if showTimePicker {
                                        currentStep = 2
                                    } else {
                                        showingScoreboard = true
                                    }
                                },
                                onCancel: cancelFromCurrentStep
                            )
                        default:
                            if showTimePicker {
                                VStack(spacing: 12) {
                                    TimeDurationPicker(totalMinutes: $selectedTime)
                                    Spacer(minLength: 0)
                                }
                                .padding(.top, -8)
                            }
                        }
                    }
                    .frame(maxHeight: .infinity, alignment: .center)
                }
                
                if showTimePicker && currentStep == 2 {
                    VStack {
                        Spacer()
                        HStack(spacing: 8) {
                            Button {
                                currentStep = 1
                            } label: {
                                Text("Back")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(Color.white.opacity(0.15))
                                    .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Button {
                                showingScoreboard = true
                            } label: {
                                Text("Start Game")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(Color.white)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(themeColor)
                        .frame(maxWidth: .infinity)
                    }
                    .position(x: geometry.size.width / 2, y: geometry.size.height - 50)
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
        }
        .onChange(of: team1ColorIndex) { _, _ in
            if team2ColorIndex == team1ColorIndex,
               let fallback = team2ColorIndices.first {
                team2ColorIndex = fallback
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingScoreboard) {
            ScoreboardView(
                team1Color: selectedTeam1Color,
                team2Color: selectedTeam2Color,
                totalMinutes: selectedTime,
                dismissToMain: $dismissToMain
            )
        }
        .onChange(of: dismissToMain) { _, newValue in
            if newValue {
                exitToSportList()
            }
        }
    }
}

struct ScoreboardView: View {
    @Environment(\.dismiss) private var dismiss
    let team1Color: Color
    let team2Color: Color
    let totalMinutes: Int
    @Binding var dismissToMain: Bool
    
    @State private var team1Score = 0
    @State private var team2Score = 0
    @State private var remainingSeconds: Int = 0
    @State private var isGameActive = true
    @State private var showingFinishAlert = false
    
    init(team1Color: Color, team2Color: Color, totalMinutes: Int, dismissToMain: Binding<Bool>) {
        self.team1Color = team1Color
        self.team2Color = team2Color
        self.totalMinutes = totalMinutes
        self._dismissToMain = dismissToMain
        self._remainingSeconds = State(initialValue: max(0, totalMinutes * 60))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Heart rate display (moved to top)
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
                    
                    // Score display
                    HStack(spacing: 12) {
                        // Team 1
                        VStack(spacing: 4) {
                            Circle()
                                .fill(team1Color)
                                .frame(width: 32, height: 32)
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            
                            Text("\(team1Score)")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { team1Score += 1 }
                        .gesture(
                            DragGesture().onEnded { value in
                                if abs(value.translation.height) > 20 {
                                    if team1Score > 0 { team1Score -= 1 }
                                }
                            }
                        )
                        
                        // VS separator
                        Text("VS")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.6))
                        
                        // Team 2
                        VStack(spacing: 4) {
                            Circle()
                                .fill(team2Color)
                                .frame(width: 32, height: 32)
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            
                            Text("\(team2Score)")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { team2Score += 1 }
                        .gesture(
                            DragGesture().onEnded { value in
                                if abs(value.translation.height) > 20 {
                                    if team2Score > 0 { team2Score -= 1 }
                                }
                            }
                        )
                    }
                    .padding(.top, 10)
                    
                    Spacer(minLength: 0)
                    
                    // Timer display (only if totalMinutes > 0)
                    if totalMinutes > 0 {
                        Text(timeString)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.bottom, 8)
                    }
                    
                    // Finish Match button
                    Button {
                        showingFinishAlert = true
                    } label: {
                        Text("Finish Match")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .onReceive(timer) { _ in
            if totalMinutes > 0 && isGameActive && remainingSeconds > 0 {
                remainingSeconds -= 1
            }
        }
        .alert("Finish Match?", isPresented: $showingFinishAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Yes, Finish", role: .destructive) {
                dismissToMain = true
                dismiss()
            }
        } message: {
            Text("Are you sure you want to finish the match?")
        }
        .navigationBarHidden(true)
    }
    
    private var timeString: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
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
    @State private var setupShowTimePicker: Bool = true
    
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
                    sportIcon: setupSportIcon,
                    showTimePicker: setupShowTimePicker
                )
                .opacity(setupCoverOpacity)
            }
        }
        .ignoresSafeArea()
    }
    
    private func beginSetup(for sport: Sport) {
        setupThemeColor = sport.color
        setupSportIcon = sport.icon
        setupShowTimePicker = (sport.name == "Football")
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
