//
//  ScoreboardView.swift
//  ScoreTracker Watch App
//
//  Created by Turgut Egemen Özyürek on 30.08.2025.
//

import SwiftUI

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
    private var isTennis: Bool { sportName == "Tennis" }
    private var showsMatchEndScreen: Bool {
        isBasketball || sportName == "Football" || isTennis
    }
    
    /// Setler eşitken (ör. 0–0) maç sonu skoru ve kazanan game sayısına göre.
    private var tennisMatchEndUsesGames: Bool {
        tennisState.set1 == tennisState.set2
    }
    
    private var tennisMatchWinner: Int? {
        guard isTennis else { return nil }
        if tennisState.set1 != tennisState.set2 {
            return tennisState.set1 > tennisState.set2 ? 1 : 2
        }
        if tennisState.game1 > tennisState.game2 { return 1 }
        if tennisState.game2 > tennisState.game1 { return 2 }
        return nil
    }
    
    private var matchEndTeam1Score: Int {
        if isTennis {
            return tennisMatchEndUsesGames ? tennisState.game1 : tennisState.set1
        }
        return team1Score
    }
    
    private var matchEndTeam2Score: Int {
        if isTennis {
            return tennisMatchEndUsesGames ? tennisState.game2 : tennisState.set2
        }
        return team2Score
    }
    
    @State private var team1Score = 0
    @State private var team2Score = 0
    @State private var tennisState = TennisMatchState()
    @State private var timerSeconds: Int = 0
    @State private var isGameActive = true
    @State private var showingFinishAlert = false
    @State private var showingMatchEnd = false
    @State private var showingStats = false
    @State private var scoreHistory: [ScoreSnapshot] = []
    @State private var tennisHistory: [TennisMatchState] = []
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
                            MatchTopHeaderView(timeString: isTennis ? timeString : nil)
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
                            } else if isTennis {
                                TennisScoreboardRow(
                                    team1Color: team1Color,
                                    team2Color: team2Color,
                                    sportIcon: sportIcon,
                                    tennisState: tennisState,
                                    team1Spin: team1Spin,
                                    team2Spin: team2Spin,
                                    isScoringEnabled: !isScoreIncreaseLocked,
                                    onPointTeam1: { awardTennisPoint(to: 1) },
                                    onPointTeam2: { awardTennisPoint(to: 2) }
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
                        .padding(.top, isBasketball ? 0 : (isTennis ? 0 : 10))
                        .offset(y: isBasketball ? -12 : (isTennis ? -18 : 2))
                        .overlay(alignment: .bottom) {
                            if !isBasketball && !isTennis {
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
                            isEnabled: isTennis ? !tennisHistory.isEmpty : !scoreHistory.isEmpty,
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
                        team1Score: matchEndTeam1Score,
                        team2Score: matchEndTeam2Score,
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
        if isTennis {
            switch tennisMatchWinner {
            case 1: return "Player 1 wins"
            case 2: return "Player 2 wins"
            default: return "Draw"
            }
        }
        if team1Score > team2Score { return "Team 1 wins" }
        if team2Score > team1Score { return "Team 2 wins" }
        return "Draw"
    }
    
    private var matchEndBackgroundColor: Color {
        if isTennis {
            switch tennisMatchWinner {
            case 1: return team1Color
            case 2: return team2Color
            default: return .gray
            }
        }
        if team1Score > team2Score { return team1Color }
        if team2Score > team1Score { return team2Color }
        return .gray
    }
    
    func requestFinishFromWhistle() {
        guard !showingMatchEnd else { return }
        showingFinishAlert = true
    }
    
    func presentMatchEnd() {
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
    
    func exitToSportList() {
        dismissToMain = true
        dismiss()
    }
    
    func pushScoreHistory() {
        scoreHistory.append(ScoreSnapshot(team1: team1Score, team2: team2Score))
    }
    
    func pushTennisHistory() {
        tennisHistory.append(tennisState)
    }
    
    func awardTennisPoint(to team: Int) {
        guard !isScoreIncreaseLocked else { return }
        isScoreIncreaseLocked = true
        pushTennisHistory()
        tennisState.awardPoint(to: team)
        
        if team == 1 {
            withAnimation(.easeInOut(duration: TeamScoreBall.spinDuration)) {
                team1Spin += 360
            }
        } else {
            withAnimation(.easeInOut(duration: TeamScoreBall.spinDuration)) {
                team2Spin += 360
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + TeamScoreBall.spinDuration) {
            isScoreIncreaseLocked = false
        }
    }
    
    func scorePoints(for team: Int, points: Int) {
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
    
    func adjustTeam1Score(by delta: Int) {
        guard delta < 0 else { return }
        let newScore = team1Score + delta
        guard newScore >= 0 else { return }
        pushScoreHistory()
        team1Score = newScore
    }
    
    func adjustTeam2Score(by delta: Int) {
        guard delta < 0 else { return }
        let newScore = team2Score + delta
        guard newScore >= 0 else { return }
        pushScoreHistory()
        team2Score = newScore
    }
    
    func revertLastScoreChange() {
        if isTennis {
            guard let previous = tennisHistory.popLast() else { return }
            tennisState = previous
            return
        }
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
