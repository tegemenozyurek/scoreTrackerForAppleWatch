//
//  ContentView.swift
//  ScoreTracker Watch App
//
//  Created by Turgut Egemen Özyürek on 30.08.2025.
//

import SwiftUI

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
                        
                        HistoryCard()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .scaleEffect(isTransitioning ? 0.85 : 1.0)
                            .opacity(isTransitioning ? 0.6 : 1.0)
                            .animation(
                                Animation.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.4),
                                value: isTransitioning
                            )
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
                    defaultHasTimeLimit: !["Basketball", "Tennis", "Volleyball"].contains(setupSportName)
                )
                .opacity(setupCoverOpacity)
            }
        }
        .ignoresSafeArea()
    }
    
    func beginSetup(for sport: Sport) {
        setupThemeColor = sport.color
        setupSportIcon = sport.icon
        setupSportName = sport.name
        isSelectingSport = false
        setupCoverOpacity = 1
        showingSetup = true
    }
    
    func exitSetup() {
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


#Preview {
    ContentView()
}
