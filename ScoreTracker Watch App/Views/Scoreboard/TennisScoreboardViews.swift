//
//  TennisScoreboardViews.swift
//  ScoreTracker Watch App
//
//  Created by Turgut Egemen Özyürek on 30.08.2025.
//

import SwiftUI

struct TennisStatValueLabel: View {
    let value: Int
    let accentColor: Color
    let columnWidth: CGFloat
    
    @State private var scale: CGFloat = 1
    
    var body: some View {
        Text("\(value)")
            .font(.system(size: 19, weight: .bold))
            .foregroundColor(accentColor)
            .monospacedDigit()
            .scaleEffect(scale)
            .frame(width: columnWidth)
            .onChange(of: value) { _, _ in
                pulseScale()
            }
    }
    
    func pulseScale() {
        withAnimation(.easeOut(duration: 0.2)) {
            scale = 1.85
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeIn(duration: 0.12)) {
                scale = 0.82
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.45)) {
                    scale = 1
                }
            }
        }
    }
}

struct TennisPlayerScoreRow: View {
    let accentColor: Color
    let sportIcon: String
    let spinDegrees: Double
    let sets: Int
    let games: Int
    let pointDisplay: String
    let isScoringEnabled: Bool
    let onTap: () -> Void
    
    private let iconColumnWidth: CGFloat = 58
    private let statColumnWidth: CGFloat = 36
    private let pointFontSize: CGFloat = 30
    
    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: sportIcon)
                .font(.system(size: 38, weight: .medium))
                .foregroundStyle(accentColor)
                .symbolRenderingMode(.monochrome)
                .rotationEffect(.degrees(spinDegrees))
                .animation(.easeInOut(duration: TeamScoreBall.spinDuration), value: spinDegrees)
                .frame(width: iconColumnWidth)
            
            columnDivider
            
            TennisStatValueLabel(
                value: sets,
                accentColor: accentColor,
                columnWidth: statColumnWidth
            )
            
            columnDivider
            
            TennisStatValueLabel(
                value: games,
                accentColor: accentColor,
                columnWidth: statColumnWidth
            )
            
            columnDivider
            
            Text(pointDisplay)
                .font(.system(size: pointFontSize, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.vertical, 11)
        .padding(.horizontal, 10)
        .contentShape(Rectangle())
        .onTapGesture {
            guard isScoringEnabled else { return }
            onTap()
        }
        .allowsHitTesting(isScoringEnabled)
    }
    
    private var columnDivider: some View {
        Rectangle()
            .fill(accentColor.opacity(0.28))
            .frame(width: 1)
            .padding(.vertical, 6)
    }
}

struct TennisServeIndicator: View {
    let servingPlayer: Int
    let serveSide: TennisServeSide
    let team1Color: Color
    let team2Color: Color
    
    private var serverColor: Color {
        servingPlayer == 1 ? team1Color : team2Color
    }
    
    var body: some View {
        Text(serveSide.rawValue)
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(serverColor)
            .frame(maxWidth: .infinity)
            .padding(.top, 10)
    }
}

struct TennisScoreboardRow: View {
    let team1Color: Color
    let team2Color: Color
    let sportIcon: String
    let tennisState: TennisMatchState
    let team1Spin: Double
    let team2Spin: Double
    let isScoringEnabled: Bool
    let onPointTeam1: () -> Void
    let onPointTeam2: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                TennisPlayerScoreRow(
                    accentColor: team1Color,
                    sportIcon: sportIcon,
                    spinDegrees: team1Spin,
                    sets: tennisState.set1,
                    games: tennisState.game1,
                    pointDisplay: tennisState.pointDisplay(forTeam: 1),
                    isScoringEnabled: isScoringEnabled,
                    onTap: onPointTeam1
                )
                
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [team1Color.opacity(0.55), team2Color.opacity(0.55)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)
                
                TennisPlayerScoreRow(
                    accentColor: team2Color,
                    sportIcon: sportIcon,
                    spinDegrees: team2Spin,
                    sets: tennisState.set2,
                    games: tennisState.game2,
                    pointDisplay: tennisState.pointDisplay(forTeam: 2),
                    isScoringEnabled: isScoringEnabled,
                    onTap: onPointTeam2
                )
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 4)
            .frame(height: 118)
            
            TennisServeIndicator(
                servingPlayer: tennisState.servingPlayer,
                serveSide: tennisState.serveSide,
                team1Color: team1Color,
                team2Color: team2Color
            )
        }
        .frame(maxWidth: .infinity)
    }
}
