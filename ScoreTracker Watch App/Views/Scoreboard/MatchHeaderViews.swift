//
//  MatchHeaderViews.swift
//  ScoreTracker Watch App
//
//  Created by Turgut Egemen Özyürek on 30.08.2025.
//

import SwiftUI

struct MatchBPMHeaderView: View {
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: "heart.fill")
                .foregroundColor(.red)
                .font(.system(size: 13))
            
            Text("--")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
            
            Text("BPM")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(Color.white.opacity(0.1))
        .clipShape(Capsule())
        .frame(height: MatchScreenMetrics.bpmBandHeight)
    }
}

struct MatchTopHeaderView: View {
    let timeString: String?
    
    var body: some View {
        ZStack {
            MatchBPMHeaderView()
            
            if let timeString {
                HStack {
                    Text(timeString)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white.opacity(0.85))
                        .monospacedDigit()
                        .padding(.leading, 10)
                    Spacer(minLength: 0)
                }
                .frame(height: MatchScreenMetrics.bpmBandHeight)
            }
        }
        .frame(height: MatchScreenMetrics.bpmBandHeight)
    }
}
