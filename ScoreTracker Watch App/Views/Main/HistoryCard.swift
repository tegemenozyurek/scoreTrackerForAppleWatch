//
//  HistoryCard.swift
//  ScoreTracker Watch App
//
//  Created by Turgut Egemen Özyürek on 30.08.2025.
//

import SwiftUI

struct HistoryCard: View {
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 80, weight: .medium))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
