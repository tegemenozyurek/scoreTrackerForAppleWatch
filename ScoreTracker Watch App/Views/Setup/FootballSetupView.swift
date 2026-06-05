//
//  FootballSetupView.swift
//  ScoreTracker Watch App
//
//  Created by Turgut Egemen Özyürek on 30.08.2025.
//

import SwiftUI

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
    let defaultHasTimeLimit: Bool
    
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
        self.defaultHasTimeLimit = defaultHasTimeLimit
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
    
    func exitToSportList() {
        if let onDismissToSportList {
            onDismissToSportList()
        } else {
            dismiss()
        }
    }
    
    func startMatch() {
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
    
    func cancelFromCurrentStep() {
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
                                usesPlayerLabel: sportName == "Tennis",
                                sportIcon: sportIcon,
                                colorIndex: $team1ColorIndex,
                                availableColorIndices: allColorIndices,
                                onNext: { currentStep = 1 },
                                onCancel: cancelFromCurrentStep
                            )
                        case 1:
                            TeamColorWheelSelectionView(
                                teamNumber: 2,
                                usesPlayerLabel: sportName == "Tennis",
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
                                        isPrimaryPulsing: isStartPulsing,
                                        primaryMatchesSecondaryStyle: !defaultHasTimeLimit
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
                if !defaultHasTimeLimit {
                    hasTimeLimit = false
                    selectedTime = 0
                    isStartPulsing = false
                } else {
                    withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                        isStartPulsing = true
                    }
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
