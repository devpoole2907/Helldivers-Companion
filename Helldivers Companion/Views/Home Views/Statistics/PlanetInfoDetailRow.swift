//
//  PlanetInfoDetailRow.swift
//  Helldivers Companion
//
//  Created by James Poole on 01/04/2024.
//

import SwiftUI

struct PlanetInfoDetailRow: View {
    
    var planetStatus: PlanetStatus? = nil
    
    private var formattedPlanetImageName: String {
        
        PlanetImageFormatter.formattedPlanetImageName(for: planetStatus?.planet.name ?? "Fori Prime")
    
        }
    
    
    
    
    var body: some View {
      
            ZStack(alignment: .bottomLeading) {
                Image(formattedPlanetImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                
                HStack(spacing: 4) {
                    Text(planetStatus?.planet.name ?? "Unknown")
                        .padding(.vertical, 4)
                        .textCase(.uppercase)
                        .font(Font.custom("FS Sinclair", size: largeFont))
                        .foregroundStyle(.white)
                        .padding(.leading)
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .bold()
                        .foregroundStyle(.white)
                        .opacity(0.8)
                        .padding(.bottom, 1.7)
                    Spacer()
                    
                    if let weathers = planetStatus?.planet.environmentals {
                       
                        HStack(spacing: 6) {
                            ForEach(weathers, id: \.name) { weather in
                                
                                Image(weather.name).resizable().aspectRatio(contentMode: .fit)
                                
                                    .frame(width: 13, height: 13)
                                    .padding(4)
                                    .background{
                                        Circle().foregroundStyle(Color.white)
                                            .shadow(radius: 3.0)
                                    }
                            }
                        }.opacity(0.7)
                            
                            .padding(.trailing, 10)
                            .padding(.bottom, 1.3)
                        
                    }
                    
                }
                .frame(maxWidth: .infinity)
                .background{
                    Color.black.opacity(0.5)
                }
            }
 
            
        .border(.white, width: 2)
        .padding(4)
        .border(Color.gray)
      //  .frame(maxHeight: 50)
        
        
        
  
    }
}

#Preview {
    PlanetInfoDetailRow()
}
