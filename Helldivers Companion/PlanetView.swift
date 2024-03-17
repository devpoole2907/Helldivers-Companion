//
//  PlanetView.swift
//  Helldivers Companion
//
//  Created by James Poole on 14/03/2024.
//

import SwiftUI
import Charts

struct PlanetView: View {
    
    @EnvironmentObject var viewModel: PlanetsViewModel
    
    var planetName = "Meridia"
    var liberation = 24.13020
    var rate = 0.0
    var playerCount: Int = 347246
    var planet: PlanetStatus? = nil
    
    @State private var showChart = false
    
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
                    HStack(alignment: .bottom) {
                        Image(bugOrAutomation).resizable().aspectRatio(contentMode: .fit)
                            .frame(width: 35, height: 35)
                        Text(planetName).textCase(.uppercase).foregroundStyle(bugOrAutomation == "terminid" ? Color.yellow : Color.red)
                            .font(Font.custom("FS Sinclair", size: 24))
                        Spacer()
                        
                        Button(action: {
                            
                         
                            withAnimation {
                                showChart.toggle()
                            }
                        }){
                            HStack(alignment: .center, spacing: 4) {
                                
                                Image(systemName: "chart.xyaxis.line").bold()
                                    .padding(.bottom, 4)
                                Text("History")   .font(Font.custom("FS Sinclair", size: 24))
                                
                            }
                        }.padding(.trailing, 5)
                            .tint(.white)
                        
                        
                            .background {
                                Color.gray.opacity(0.4)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                    }.padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background{ Color.black}
                    
                    if !showChart {
                        Image(formattedPlanetImageName).resizable().aspectRatio(contentMode: .fit)
                    }
                    
                }.border(Color.white)
                    .padding(4)
                    .border(Color.gray)
                if !showChart {
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
                            .font(Font.custom("FS Sinclair", size: 18))
                        
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
                    
                    HStack(alignment: .center, spacing: 10) {
                        Image(bugOrAutomation).resizable().aspectRatio(contentMode: .fit)
                            .frame(width: 35, height: 35)
                        
                        Text(bugOrAutomation == "terminid" ? "- 3% / h" : "- 1.5% / h").foregroundStyle(bugOrAutomation == "terminid" ? Color.yellow : Color.red).bold()
                            .font(Font.custom("FS Sinclair", size: 18))
                            .padding(.top, 3)
                        
                    }.frame(maxWidth: .infinity)
                    
                    Rectangle().frame(width: 1, height: 30).foregroundStyle(Color.white)
                        .padding(.vertical, 10)
                    
                    HStack(spacing: 10) {
                        
                        Image("helldiverIcon").resizable().aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25)
                        Text("\(playerCount)").textCase(.uppercase)
                            .foregroundStyle(.white).bold()
                            .font(Font.custom("FS Sinclair", size: 18))
                            .padding(.top, 3)
                        
                    }.frame(maxWidth: .infinity)
                    
                    
                }
                
                .background {
                    Color.black
                }
                .padding(.horizontal)
                .border(Color.white)
                .padding(4)
                .border(Color.gray)
                
                } else {
                    historyChart
                }
            }
            
            
        }.padding(5)
            .background {
                Color.black
            }
            .border(.yellow, width: 2)
    }
    
    var historyChart: some View {
        
        Chart {
            ForEach(stackedBarData) { shape in
                LineMark(
                    x: .value("Shape Type", shape.type),
                    y: .value("Total Count", shape.count)
                )
                .foregroundStyle(by: .value("Shape Color", shape.color))
            }
        }.padding(15).frame(maxHeight: 200)
           
        
    }
    
}

#Preview {
    
    PlanetView().environmentObject(PlanetsViewModel())
}

struct ToyShape: Identifiable {
    var color: String
    var type: String
    var count: Double
    var id = UUID()
}

var stackedBarData: [ToyShape] = [
    .init(color: "Green", type: "Cube", count: 2),
    .init(color: "Green", type: "Sphere", count: 0),
    .init(color: "Green", type: "Pyramid", count: 1),
    .init(color: "Purple", type: "Cube", count: 1),
    .init(color: "Purple", type: "Sphere", count: 1),
    .init(color: "Purple", type: "Pyramid", count: 1),
    .init(color: "Pink", type: "Cube", count: 1),
    .init(color: "Pink", type: "Sphere", count: 2),
    .init(color: "Pink", type: "Pyramid", count: 0),
    .init(color: "Yellow", type: "Cube", count: 1),
    .init(color: "Yellow", type: "Sphere", count: 1),
    .init(color: "Yellow", type: "Pyramid", count: 2)
]
