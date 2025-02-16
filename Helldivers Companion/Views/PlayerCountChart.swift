//
//  PlayerCountChart.swift
//  Helldivers Companion
//
//  Created by James Poole on 16/02/2025.
//

import SwiftUI
import Charts
import TipKit

#if os(iOS)
@available(iOS 17.0, *)

struct PlayerCountPieChart: View {
    
    private var tip: PieChartTip {
        PieChartTip()
    }

    
    @EnvironmentObject var viewModel: PlanetsDataModel
    
    @State private var liveAngle: Double?
    @State private var persistentAngle: Double? // saved angle
    
    var distribution: [PlayerDistributionItem] {
        viewModel.playerDistribution.sorted { $0.faction < $1.faction }
    }

    var body: some View {
        
               // Build an array of (item, range) so we know which angles map to each item.
               var runningTotal = 0.0
               let distributionRanges: [(item: PlayerDistributionItem, range: Range<Double>)] = distribution.map { distItem in
                   let start = runningTotal
                   runningTotal += Double(distItem.count)
                   return (distItem, start..<runningTotal)
               }
               
               // Figure out the selected item based on `selectedAngle`
               let selectedItem: PlayerDistributionItem? = {
                   guard let angle = persistentAngle else { return nil }
                   return distributionRanges.first(where: { $0.range.contains(angle) })?.item
               }()
        
        
        ScrollView {
            VStack(spacing: 20) {
                
                PlayerCountView(showFullSize: true)
                    .padding(.top)
                
                if viewModel.playerDistribution.isEmpty {
                    Text("No data available")
                        .foregroundColor(.secondary)
                } else {
                    
                    
                    TipView(tip, arrowEdge: .bottom)
                        .onTapGesture {
                        tip.invalidate(reason: .actionPerformed)
                      }
      
                    Chart(distribution) { item in
                        SectorMark(
                            angle: .value("Players", item.count),
                            innerRadius: .ratio(0.6),
                            angularInset: 2
                        )
                        .cornerRadius(5)
                        .foregroundStyle(item.color)
                        .opacity(item.id == selectedItem?.id ? 1 : 0.5)
                    }
                    .chartAngleSelection(value: $liveAngle)
                    
                    .frame(height: 220)
                    .chartBackground { chartProxy in
                                          GeometryReader { geometry in
                                              if let anchor = chartProxy.plotFrame {
                                                  let frame = geometry[anchor]
                                                  
                                          
                                                  VStack(spacing: 2) {
                                                      if let sel = selectedItem {
                                                      
                                                          Text(sel.faction)
                                                              .lineLimit(1)
                                                              .truncationMode(.tail)
                                                              .foregroundStyle(.white)
                                                              .font(Font.custom("FSSinclair-Bold", size: 18))
                                                          
                                                          HStack(spacing: 4) {
                                                              Image("diver").resizable().aspectRatio(contentMode: .fit)
                                                                  .frame(width: 10, height: 10)
                                                                  .padding(.bottom, 1.8)
                                                              
                                                              Text("\(sel.count)")
                                                                  .lineLimit(1)
                                                                  .truncationMode(.tail)
                                                                  .foregroundStyle(.white)
                                                                  .font(Font.custom("FSSinclair", size: 14))
                                                          }
                                                      } 
                                                  }
                                                  .position(x: frame.midX, y: frame.midY)
                                              }
                                          }
                                      }

                    
                }

                ForEach(viewModel.playerDistribution.sorted { $0.faction < $1.faction }) { item in
                    
                    let percentage = ((Double(item.count)) / (Double(viewModel.totalPlayerCount)) * 100.0)

                    let formattedPercent = String(format: "%.3f", percentage) + "%"
                    
                    PlayerCountRow(playerCount: "\(item.count)", factionName: "\(item.faction)", percent: formattedPercent, factionColor: item.color)
                    
                    
                    
                }
                
            }
            .padding()
            
            .onChange(of: liveAngle) { newAngle in
                        if let newAngle {
                            persistentAngle = newAngle
                        }
                    }
            
            .onAppear {
                    
                if persistentAngle == nil, let largest = distributionRanges.max(by: {
                                $0.item.count < $1.item.count
                            }) {
                        
                                let midpoint = (largest.range.lowerBound + largest.range.upperBound) / 2
                    persistentAngle = midpoint
                            }
                        }
            
            Spacer()
            
        }.scrollContentBackground(.hidden)
        
            .presentationDetents([.fraction(0.8)])
            .customSheetBackground(ultraThin: true)
            .presentationDragIndicator(.visible)
    }
}


struct PlayerCountRow: View {
    
    let playerCount: String
    let factionName: String
    let percent: String
    let factionColor: Color
    
    let fontSize: CGFloat = 20
    let imageSize: CGFloat = 30
    
    var image: String {
        switch factionName {
        case "Terminids":
            return "terminid"
        case "Other":
            return "human"
        default:
            return factionName.lowercased()
        }
    }
    
    var body: some View {
        
        ZStack(alignment: .trailing) {
            Color.gray.opacity(0.16)
                .shadow(radius: 3)
            HStack(spacing: 12) {
                
                Image(image)
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: imageSize, height: imageSize)
                    .foregroundStyle(factionColor)
                
                
                    Text(playerCount)
                        .font(Font.custom("FSSinclair-Bold", size: fontSize))
                        .padding(.top, 2)
                    
            
                
                
                Spacer()
                
                Text(percent)
                    .font(Font.custom("FSSinclair-Bold", size: fontSize))
                    .padding(.top, 2)
              
            }.frame(maxWidth: .infinity)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
            
            
            
        }
        
        .background {
            
            Rectangle().stroke(style: StrokeStyle(lineWidth: 3, dash: dashPattern))
                .foregroundStyle(.gray)
                .opacity(0.5)
                .shadow(radius: 3)
            
        }
        
    }
        
}

#endif
