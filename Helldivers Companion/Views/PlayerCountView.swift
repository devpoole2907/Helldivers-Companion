//
//  PlayerCountView.swift
//  Helldivers Companion
//
//  Created by James Poole on 11/04/2024.
//

import SwiftUI

struct PlayerCountView: View {
    @EnvironmentObject var viewModel: PlanetsViewModel

    var body: some View {
        
        HStack(spacing: 4) {
            
            Image("diver").resizable().aspectRatio(contentMode: .fit)
                .frame(width: 10, height: 10)
                .padding(.bottom, 1.8)
            
            Text(viewModel.formattedPlayerCount)
                .lineLimit(1)
                .truncationMode(.tail)
                .foregroundStyle(.white)
                .font(Font.custom("FS Sinclair Bold", size: 14))
            
        }
    }
}
