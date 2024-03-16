//
//  PlanetView.swift
//  Helldivers Companion
//
//  Created by James Poole on 14/03/2024.
//

import SwiftUI

struct PlanetView: View {
    
    var planetName = "Meridia"
    var liberation = 24.13020
    var rate = 0.0
    var playerCount: Int = 0
    var planet: PlanetStatus? = nil
    
    var formattedPlanetImageName: String {
            let cleanedName = planetName
            .filter { !$0.isPunctuation }   // no apostrophes etc
            .replacingOccurrences(of: " ", with: "_")
        
        let imageName = "\(cleanedName)_Landscape"
        
        if UIImage(named: imageName) != nil {
                return imageName
            } else {
                // if asset doesn't exist return a default preview image (Fenrir 3 i guess?)
                return "Fenrir_III_Landscape"
            }
        }
    
    var bugOrAutomation: String {

        if let planet = planet {
            
            if planet.planet.initialOwner.lowercased() == "terminid" || planet.owner.lowercased() == "terminid" {
                return "terminid"
            } else if planet.planet.initialOwner.lowercased() == "automaton" || planet.owner.lowercased() == "automaton" {
                return "automaton"
            }
        
        }
        
        
        return "terminid"
    }
    
    var body: some View {
        
        VStack {
            
            VStack(spacing: 6) {
                VStack(spacing: 0) {
                    HStack {
                        Image(bugOrAutomation).resizable().aspectRatio(contentMode: .fit)
                            .frame(width: 35, height: 35)
                        Text(planetName).textCase(.uppercase).foregroundStyle(bugOrAutomation == "terminid" ? Color.yellow : Color.red)
                            .font(.system(size: 24)).fontWeight(.heavy)
                        Spacer()
                        
                    }.padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background{ Color.black}
                    
                    Image(formattedPlanetImageName).resizable().aspectRatio(contentMode: .fit)
                    
                }.border(Color.white)
                    .padding(4)
                    .border(Color.gray)
                
                VStack(spacing: 0) {
                    
                    VStack {
                        HStack {
                            
                            // health bar
                            
                                RectangleProgressBar(value: liberation / 100, secondaryColor: bugOrAutomation == "terminid" ? Color.yellow : Color.red)
                            
                                .padding(.horizontal, 6)
                                .padding(.trailing, 2)
                               
                            
                            
                        }.frame(height: 34)
                            .foregroundStyle(Color.clear)
                            .border(Color.orange, width: 2)
                            .padding(.horizontal, 4)
                    }  .padding(.vertical, 5)
                    
                    Rectangle()
                        .fill(.white)
                        .frame(height: 1)
                    
                    VStack {
                        Text("\(liberation)% Liberated").textCase(.uppercase)
                            .foregroundStyle(.white).bold()
                        
                           
                    }
                    .frame(maxWidth: .infinity)
                    .background {
                        Color.black
                    }
                    .padding(.vertical, 5)
                    
              
                
                    
                }
                    .border(Color.white)
                    .padding(4)
                    .border(Color.gray)
                
                HStack {
                    
                    HStack(spacing: 5) {
                        Image(bugOrAutomation).resizable().aspectRatio(contentMode: .fit)
                            .frame(width: 35, height: 35)
                        
                        Text(bugOrAutomation == "terminid" ? "- 3% / h" : "- 1.5% / h").foregroundStyle(bugOrAutomation == "terminid" ? Color.yellow : Color.red).bold()
                        
                    }.frame(maxWidth: .infinity)
                    
                    Rectangle().frame(width: 1, height: 30).foregroundStyle(Color.white)
                        .padding(.vertical, 10)
                
                    HStack(spacing: 5) {
                        
                        Image("helldiverIcon").resizable().aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25)
                        Text("\(playerCount)").textCase(.uppercase)
                            .foregroundStyle(.white).bold()
                        
                    }.frame(maxWidth: .infinity)
                  
                
                }
              
                .background {
                    Color.black
                }
                .padding(.horizontal)
                .border(Color.white)
                .padding(4)
                .border(Color.gray)
                
                
            }
            
            
        }.padding(5)
            .background {
                Color.black
            }
            .border(.yellow, width: 2)
    }
}

#Preview {
    PlanetView()
}
