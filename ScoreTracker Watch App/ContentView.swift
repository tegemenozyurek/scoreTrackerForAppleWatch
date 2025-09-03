//
//  ContentView.swift
//  ScoreTracker Watch App
//
//  Created by Turgut Egemen Özyürek on 30.08.2025.
//

import SwiftUI

struct ColorSelectionView: View {
    let title: String
    @Binding var selectedColor: Color
    let colors: [Color]
    @State private var currentColorIndex = 0
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Circle()
                    .fill(selectedColor)
                    .frame(width: 70, height: 70)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                    )
                    .scaleEffect(1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedColor)
                    .offset(x: dragOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation.width
                            }
                            .onEnded { value in
                                let threshold: CGFloat = 30
                                if value.translation.width > threshold {
                                    currentColorIndex = (currentColorIndex + 1) % colors.count
                                    selectedColor = colors[currentColorIndex]
                                } else if value.translation.width < -threshold {
                                    currentColorIndex = (currentColorIndex - 1 + colors.count) % colors.count
                                    selectedColor = colors[currentColorIndex]
                                }
                                dragOffset = 0
                            }
                    )
                
                HStack {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.system(size: 12, weight: .bold))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.system(size: 12, weight: .bold))
                }
                .frame(width: 100)
            }
            
            Text("Swipe to change")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.horizontal, 16)
        .onAppear {
            if let index = colors.firstIndex(of: selectedColor) {
                currentColorIndex = index
            }
        }
    }
}

struct ColorGridSelectionView: View {
    let title: String
    @Binding var selectedColor: Color
    let colors: [Color]
    
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let horizontalPadding: CGFloat = 8
            let availableWidth = width - (horizontalPadding * 2)
            let columns = 4
            let spacing: CGFloat = 6
            let cellSize = (availableWidth - CGFloat(columns - 1) * spacing) / CGFloat(columns)
            let displayCircleSize = max(40, min(50, cellSize + 8))
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: width > 170 ? 18 : 16, weight: .bold))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.8)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns), spacing: spacing) {
                    ForEach(Array(colors.prefix(8).enumerated()), id: \.offset) { index, color in
                        Button {
                            selectedColor = color
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(color)
                                    .frame(width: cellSize, height: cellSize)
                                    .overlay(
                                        Circle().stroke(Color.black, lineWidth: 2)
                                    )
                                if color == selectedColor {
                                    Circle()
                                        .stroke(Color.white, lineWidth: 2)
                                        .frame(width: cellSize, height: cellSize)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, horizontalPadding)
            }
            .padding(.top, -20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
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

struct ColorButton: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Circle().stroke(Color.black, lineWidth: 2)
                    )
                
                if isSelected {
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: 32, height: 32)
                }
            }
            .scaleEffect(isSelected ? 1.1 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FootballSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTeam1Color = Color.red
    @State private var selectedTeam2Color = Color.blue
    @State private var selectedTime = 90
    @State private var currentStep = 0 // 0: Team 1, 1: Team 2, 2: Time
    @State private var dragOffset: CGFloat = 0
    let themeColor: Color
    let showTimePicker: Bool
    
    var teamColors: [Color] {
        [
            Color.red, Color.blue, Color.green, Color.yellow,
             Color.orange, Color.purple, Color.pink, Color.gray
        ]
    }
    
    var timeOptions: [Int] {
        [45, 60, 75, 90, 105, 120] // Common football match durations
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                themeColor
                    .ignoresSafeArea(.container, edges: .top)
                
                VStack(spacing: 0) {
                    let maxStep = showTimePicker ? 2 : 1
                    TabView(selection: $currentStep) {
                                        VStack(spacing: 0) {
                    ColorGridSelectionView(
                        title: "Choose Team 1 Color",
                        selectedColor: $selectedTeam1Color,
                        colors: teamColors
                    )
                    Spacer(minLength: 0)
                }
                .padding(.top, 0)
                .tag(0)
                
                VStack(spacing: 0) {
                    ColorGridSelectionView(
                        title: "Choose Team 2 Color",
                        selectedColor: $selectedTeam2Color,
                        colors: teamColors.filter { $0 != selectedTeam1Color }
                    )
                    Spacer(minLength: 0)
                }
                .padding(.top, 0)
                .tag(1)
                        
                        if showTimePicker {
                            VStack(spacing: 12) {
                                TimeDurationPicker(totalMinutes: $selectedTime)
                                Spacer(minLength: 0)
                            }
                            .padding(.top, -8)
                            .tag(2)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .frame(maxHeight: .infinity, alignment: .top)
                }
                
                // Navigation bar positioned absolutely at bottom
                VStack {
                    Spacer()
                    HStack(spacing: 8) {
                        Button {
                            if currentStep > 0 { currentStep -= 1 }
                            else { dismiss() }
                        } label: {
                            Text(currentStep == 0 ? "Cancel" : "Back")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if currentStep < (showTimePicker ? 2 : 1) {
                            Button {
                                if currentStep < (showTimePicker ? 2 : 1) { currentStep += 1 }
                            } label: {
                                Text("Next")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(Color.white)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        } else {
                            Button {
                                print("Start Game - Team 1: \(selectedTeam1Color), Team 2: \(selectedTeam2Color), Time: \(selectedTime) min")
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
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(themeColor)
                    .frame(maxWidth: .infinity)
                }
                                 .position(x: geometry.size.width / 2, y: geometry.size.height - 50)
            }
        }
        .navigationBarHidden(true)
    }
}

struct SportCard: View {
    let sport: Sport
    let action: () -> Void
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Full screen background
            sport.color
                .ignoresSafeArea()
            
            // Content
            Button(action: action) {
                Image(systemName: sport.icon)
                    .font(.system(size: 80, weight: .medium))
                    .foregroundColor(.white)
                    .scaleEffect(isAnimating ? 1.15 : 0.95)
                    .rotationEffect(.degrees(isAnimating ? 8 : -8))
                    .animation(
                        Animation.easeInOut(duration: 2.0)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            isAnimating = true
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
    @State private var showingFootballSetup = false
    @State private var setupThemeColor: Color = Color(hex: "#228B22")
    @State private var setupShowTimePicker: Bool = true
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(Array(sports.enumerated()), id: \.offset) { index, sport in
                        SportCard(sport: sport) {
                            setupThemeColor = sport.color
                            setupShowTimePicker = (sport.name == "Football")
                            showingFootballSetup = true
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
        .ignoresSafeArea()
        .sheet(isPresented: $showingFootballSetup) {
            NavigationView {
                FootballSetupView(themeColor: setupThemeColor, showTimePicker: setupShowTimePicker)
            }
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
