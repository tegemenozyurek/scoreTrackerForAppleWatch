//
//  MatchEndViews.swift
//  ScoreTracker Watch App
//
//  Created by Turgut Egemen Özyürek on 30.08.2025.
//

import SwiftUI

struct ConfettiParticle: Identifiable {
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

struct ConfettiPieceView: View {
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

struct MatchEndConfettiView: View {
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

struct MatchStatsPlaceholderView: View {
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

struct MatchEndView: View {
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
