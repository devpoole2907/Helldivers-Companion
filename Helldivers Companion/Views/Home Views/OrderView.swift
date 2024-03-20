//
//  OrderView.swift
//  Helldivers Companion
//
//  Created by James Poole on 16/03/2024.
//

import SwiftUI

struct OrderView: View {
    
    var majorOrderTitle: String = "Stand by."
    var majorOrderBody: String = "Await further orders from Super Earth High Command."
    var rewardValue: Int = 25
    var rewardType: Int = 1
    
    
    var body: some View {
        
   
        VStack(spacing: 12) {
                
            VStack(spacing: 12) {
                Text(majorOrderTitle).font(Font.custom("FS Sinclair", size: 24))
                    .foregroundStyle(Color.yellow).textCase(.uppercase)
                    .multilineTextAlignment(.center)
                
                Text(majorOrderBody).font(Font.custom("FS Sinclair", size: 18))
                    .foregroundStyle(Color.cyan)
                    .padding(5)
                
                
            }.frame(maxHeight: .infinity)
            if rewardValue > 0 {
                RewardView(rewardType: rewardType, rewardValue: rewardValue)
            }
            }  .frame(maxWidth: .infinity) .padding()  .background {
                Color.black
            }
          //  .padding(.horizontal)
          
            .border(Color.white)
            .padding(4)
            .border(Color.gray)
     
        
        
    }
}

#Preview {
    OrderView()
}

struct AngledLinesShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Determine line spacing
        let spacing: CGFloat = 12

        // Draw slanted lines
        for index in stride(from: 0, to: rect.width + rect.height, by: spacing) {
            path.move(to: CGPoint(x: index, y: 0))
            path.addLine(to: CGPoint(x: 0, y: index))
        }
        
        return path
    }
}

struct RewardView: View {
    
    var rewardType: Int = 1
    var rewardValue: Int = 0
    
    var body: some View {
        VStack(spacing: 6) {
            Text("Reward").textCase(.uppercase).font(Font.custom("FS Sinclair", size: 18))
            
            HStack(spacing: 4) {
                
                if rewardType == 1 {
                    Image("medalSymbol").resizable().aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                }
                
                Text("\(rewardValue)").font(Font.custom("FS Sinclair", size: 26))
                    .foregroundStyle(rewardType == 1 ? .white : .yellow)
                
            }
            
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            // Use the custom shape as a pattern
            AngledLinesShape()
                .stroke(lineWidth: 3)
                .foregroundColor(.white) // or any color you prefer
                .opacity(0.2) // Adjust for desired line opacity
                .clipped() // Ensure the pattern does not extend beyond the view bounds
        )
        .padding(.horizontal, 20)
        
    }
    
    
    
}
