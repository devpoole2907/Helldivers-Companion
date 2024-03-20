//
//  PlanetView.swift
//  Helldivers Companion
//
//  Created by James Poole on 14/03/2024.
//

import SwiftUI
import Charts
import WidgetKit

struct PlanetView: View {
    
    @EnvironmentObject var viewModel: PlanetsViewModel
    
    var planetName = "Meridia"
    var liberation = 24.13020
    var rate = 0.0
    var playerCount: Int = 347246
    var planet: PlanetStatus? = nil
    var showHistory = true
    var showImage = true
    var showExtraStats = true
    var liberationType: LiberationType = .liberation
    
    @State private var showChart = false
    
    @State private var chartType: ChartType = .players
    
    var chartTypes: [ChartType] {
        switch liberationType {
        case .liberation:
            return [.liberation, .players]
        case .defense:
            return [.defense, .players]
        }
    }
    
    @State private var chartSelection: Date? = nil
    
#if os(iOS)
let helldiverImageSize: CGFloat = 25
let raceIconSize: CGFloat = 25
    let spacingSize: CGFloat = 10
    let chartHeight: CGFloat = 240
    let chartSectionHeight: CGFloat = 300

#elseif os(watchOS)
    let helldiverImageSize: CGFloat = 10
    let raceIconSize: CGFloat = 20
    let spacingSize: CGFloat = 4
    let chartHeight: CGFloat = 160
    let chartSectionHeight: CGFloat = 210
#endif

        private var planetData: [PlanetDataPoint] {
            viewModel.planetHistory[planetName] ?? []
        }
    
    private var defensePlanetData: [PlanetDataPoint] {
        viewModel.eventHistory[planetName] ?? []
    }
    
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
    
    var bugOrAutomaton: String {

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
            
            VStack(spacing: showExtraStats ? 6 : 2) {
                
                headerWithImage
                
                if showChart {
                    
                    HistoryChart(liberationType: liberationType, defensePlanetData: defensePlanetData, planetData: planetData, chartSelection: $chartSelection, chartHeight: chartHeight, chartSectionHeight: chartSectionHeight, chartType: $chartType, chartTypes: chartTypes, bugOrAutomaton: bugOrAutomaton).environmentObject(viewModel)

                    
                }
                VStack(spacing: 0) {
                    
                    VStack {
                        HStack {
                            
                            // health bar
                            
                            RectangleProgressBar(value: liberation / 100, secondaryColor: bugOrAutomaton == "terminid" ? Color.yellow : Color.red)
                            
                                .padding(.horizontal, 6)
                                .padding(.trailing, 2)
                            
                            
                            
                        }.frame(height: showExtraStats ? 34 : 30)
                            .foregroundStyle(Color.clear)
                            .border(Color.orange, width: 2)
                            .padding(.horizontal, 4)
                    }  .padding(.vertical, 5)
                    
                    Rectangle()
                        .fill(.white)
                        .frame(height: 1)
                    
                    VStack {
                        Text("\(liberation)% \(liberationType == .liberation ? "Liberated" : "Defended")").textCase(.uppercase)
                            .foregroundStyle(.white).bold()
                            .font(Font.custom("FS Sinclair", size: showExtraStats ? mediumFont : smallFont))
                            .multilineTextAlignment(.center)
                        
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
                if showExtraStats {
                HStack {
                    
                    HStack(alignment: .center, spacing: spacingSize) {
                        
                        if liberationType == .liberation {
                            
                            Image(bugOrAutomaton).resizable().aspectRatio(contentMode: .fit)
                                .frame(width: raceIconSize, height: raceIconSize)
                            
                            Text(bugOrAutomaton == "terminid" ? "\(viewModel.configData.terminidRate) / h" : "\(viewModel.configData.automatonRate) / h").foregroundStyle(bugOrAutomaton == "terminid" ? Color.yellow : Color.red).bold()
                                .font(Font.custom("FS Sinclair", size: mediumFont))
                                .padding(.top, 3)
                            
                        } else {
                            Text("DEFEND") .font(Font.custom("FS Sinclair", size: largeFont))
                        }
                        
                    }.frame(maxWidth: .infinity)
                    
                    Rectangle().frame(width: 1, height: 30).foregroundStyle(Color.white)
                        .padding(.vertical, 10)
                    
                    
                    HStack(spacing: spacingSize) {
                        
                        
                        Image("helldiverIcon").resizable().aspectRatio(contentMode: .fit)
                            .frame(width: helldiverImageSize, height: helldiverImageSize)
                        Text("\(playerCount)").textCase(.uppercase)
                            .foregroundStyle(.white).bold()
                            .font(Font.custom("FS Sinclair", size: mediumFont))
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
                
            }
                
                
            }
            
            
        }.padding(5)
            .background {
                Color.black
            }
            .border(.yellow, width: 2)
    }
    
    var headerWithImage: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Image(bugOrAutomaton).resizable().aspectRatio(contentMode: .fit)
                    .frame(width: raceIconSize, height: raceIconSize)
                Text(planetName).textCase(.uppercase).foregroundStyle(bugOrAutomaton == "terminid" ? Color.yellow : Color.red)
                    .font(Font.custom("FS Sinclair", size: largeFont))
                    .padding(.top, 3)
                
                Spacer()
                
                
                if !showExtraStats {
                    HStack(spacing: spacingSize) {
                        
                        
                        Image("helldiverIcon").resizable().aspectRatio(contentMode: .fit)
                            .frame(width: 16, height: 16)
                        Text("\(playerCount)").textCase(.uppercase)
                            .foregroundStyle(.white).bold()
                            .font(Font.custom("FS Sinclair", size: smallFont))
                            .padding(.top, 3)
                        
                    }.padding(.trailing, 4)
                }
                
                if showHistory {
                Button(action: {
                    
                    
                    withAnimation {
                        showChart.toggle()
                    }
                }){
                    HStack(alignment: .bottom, spacing: 4) {
                        
                        Image(systemName: "chart.xyaxis.line").bold()
                            .padding(.bottom, 2)
#if os(iOS)
                        Text("History")   .font(Font.custom("FS Sinclair", size: smallFont))
#endif
                    }
                }
                
#if os(watchOS)
                .frame(width: 14, height: 14)
                .buttonStyle(PlainButtonStyle())
                
#endif
                .padding(.trailing, 2)
#if os(iOS)
                
                .tint(.white)
                
                .padding(4)
                .border(.yellow)
#endif
                
                
            }
                
            }.padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background{ Color.black}
            
            if showImage {
                if !showChart {
                    Image(formattedPlanetImageName).resizable().aspectRatio(contentMode: .fit)
                }
            }
            
        }.border(Color.white)
            .padding(4)
            .border(Color.gray)
    }
    
    var historyChart: some View {

            return VStack { 
                
                if viewModel.planetHistory.isEmpty {
                    
                    ProgressView()
                        .frame(minHeight: chartHeight)
                    
                } else {
                
                    Chart {
                        
                        if liberationType == .defense {
                            
                            ForEach(defensePlanetData, id: \.timestamp) { dataPoint in
                                
                                
                                
                                
                                
                                
                                
                            }
                            
                            
                            
                        }
                        
                        ForEach(planetData, id: \.timestamp) { dataPoint in
                        
                        if let status = dataPoint.status {
                            LineMark(
                                x: .value("Time", dataPoint.timestamp),
                                y: .value(
                                    chartType == .liberation ? "Liberation" :
                                        chartType == .defense ? "Defense" : "Players",
                                    chartType == .liberation ? status.liberation :
                                        chartType == .defense ? status.defensePercentage ?? 0.0 :
                                        Double(status.players)
                                )
                            ).foregroundStyle(bugOrAutomaton == "terminid" ? Color.yellow : Color.red)
                                .lineStyle(StrokeStyle(lineWidth: 2.0))
                                .interpolationMethod(.catmullRom)
                            
                            
                            
                            
                            if let chartSelection = chartSelection, Calendar.current.isDate(chartSelection, equalTo: dataPoint.timestamp, toGranularity: .minute) {
                                
                                
                                
                                let ruleMark = RuleMark(x: .value("Time", chartSelection))
                                let annotationValue = chartType == .liberation ? "\(String(format: "%.2f%%", status.liberation))" :
                                chartType == .defense ? "\(String(format: "%.2f%%", status.defensePercentage ?? 0.0))" :
                                "\(status.players)"
                                let annotationView = ChartAnnotationView(value: annotationValue, date: dataPoint.timestamp.formatted(date: .omitted, time: .shortened))
                                ruleMark.opacity(0.5)
                                
                                
                                
                                
                                    .annotation(position: .topLeading, alignment: .top, overflowResolution: .init(x: .fit(to: .chart), y: .fit)){
                                        
                                        annotationView
                                        
                                        
                                        
                                    }
                                
                                
                                
                            }
                            
                        }
                        
                    }
                    
                    
            }.chartYScale(domain: [0, chartType == .players ? 350000 : 100])
                
                    .chartXSelection(value: $chartSelection)
                
                    .padding(10)
                    .frame(minHeight: chartHeight)
                
                    .onChange(of: chartSelection) { newValue in
                        
                        // find nearest data point to the current selection, jump to it
                        if let newValue = newValue, !planetData.isEmpty {
                            let closest = planetData.min(by: { abs($0.timestamp.timeIntervalSince1970 - newValue.timeIntervalSince1970) < abs($1.timestamp.timeIntervalSince1970 - newValue.timeIntervalSince1970) })
                            chartSelection = closest?.timestamp
                        }
                        
                    }
                
            }
            
            CustomSegmentedPicker(selection: $chartType, items: chartTypes)
                #if os(watchOS)
                
                    .padding(.trailing, 1.5)
                
                #endif
            
        }.frame(minHeight: chartSectionHeight)
        
    
           
        
    }
    
}

#Preview {
    
    PlanetView().environmentObject(PlanetsViewModel())
}

enum ChartType: String, SegmentedItem {
    case liberation = "Liberation"
    case players = "Players"
    case defense = "Defense"

    var contentType: SegmentedContentType {
        switch self {
        case .liberation:
            return .text("Liberation")
        case .players:
            return .text("Players")
        case .defense:
            return .text("Defense")
        }
    }
}

enum LiberationType: String {
    
    case liberation = "Liberation"
    case defense = "Defense"
    
}


struct ChartAnnotationView: View {
    
    var chartType: ChartType = .players
    var bugOrAutomaton = "terminid"
     var value: String = "55.1586%"
     var date: String = "4:41PM"
    
#if os(iOS)
let valueFont: CGFloat = 32

#elseif os(watchOS)
    let valueFont: CGFloat = 16

#endif
    
    var body: some View{
        HStack{
            VStack(alignment: .leading, spacing: -5){
            
            Text("TOTAL")
                    .font(Font.custom("FS Sinclair", size: smallFont))
                .foregroundStyle(.gray)
                .padding(.top, 1)
            
            Text(value)
              
                .foregroundStyle(bugOrAutomaton == "terminid" ? Color.yellow : Color.red)
                .font(Font.custom("FS Sinclair", size: valueFont))
            
            Text(date)
                .foregroundColor(.gray)
                .font(Font.custom("FS Sinclair", size: smallFont))
                
           
        }.padding(.leading, 8)
                .padding(.trailing)
        Spacer()
        }
            .padding(.vertical, 4)
        
           
            .border(Color.white)
                .padding(4)
                .border(Color.gray)
                .background{ Color.black}
    }
}

#Preview {
    ChartAnnotationView()
}

struct HistoryChart: View {
    @EnvironmentObject var viewModel: PlanetsViewModel
    var liberationType: LiberationType
    var defensePlanetData: [PlanetDataPoint]
    var planetData: [PlanetDataPoint]
    @Binding var chartSelection: Date?
    var chartHeight: CGFloat = 200
    var chartSectionHeight: CGFloat = 300
    @Binding var chartType: ChartType
    var chartTypes: [ChartType] = []
    var bugOrAutomaton: String = "terminid"

    var body: some View {
        VStack {
            if viewModel.planetHistory.isEmpty {
                ProgressView()
                    .frame(minHeight: chartHeight)
            } else {
                chartView
            }
            CustomSegmentedPicker(selection: $chartType, items: chartTypes)
                #if os(watchOS)
                .padding(.trailing, 1.5)
                #endif
        }
        .frame(minHeight: chartSectionHeight)
    }

    private var chartView: some View {
        Chart {
            if liberationType == .defense {
                ForEach(defensePlanetData, id: \.timestamp) { dataPoint in
                    if let status = dataPoint.status {
                        chartLineMark(for: dataPoint, status)
                        
                        if let chartSelection = chartSelection, Calendar.current.isDate(chartSelection, equalTo: dataPoint.timestamp, toGranularity: .minute) {
                            chartRuleMark(for: dataPoint, status)
                        }
                    }
                }
            } else {
                ForEach(planetData, id: \.timestamp) { dataPoint in
                    if let status = dataPoint.status {
                        chartLineMark(for: dataPoint, status)
                        
                        if let chartSelection = chartSelection, Calendar.current.isDate(chartSelection, equalTo: dataPoint.timestamp, toGranularity: .minute) {
                            chartRuleMark(for: dataPoint, status)
                        }
                    }
                }
            }
        }
        .chartYScale(domain: [0, chartType == .players ? 350000 : 100])
        .chartXSelection(value: $chartSelection)
        .padding(10)
        .frame(minHeight: chartHeight)
        .onChange(of: chartSelection) { newValue in
            // Jump to nearest data point logic
            if let newValue = newValue, !planetData.isEmpty {
                chartSelection = planetData.min(by: { abs($0.timestamp.timeIntervalSince(newValue)) < abs($1.timestamp.timeIntervalSince(newValue)) })?.timestamp
            }
        }
    }

    private func chartLineMark(for dataPoint: PlanetDataPoint, _ status: PlanetStatus) -> some ChartContent {
        
        
           LineMark(
                x: .value("Time", dataPoint.timestamp),
                y: .value(
                    chartType == .liberation ? "Liberation" :
                        chartType == .defense ? "Defense" : "Players",
                    chartType == .liberation ? dataPoint.status?.liberation ?? 0.0 :
                        chartType == .defense ? dataPoint.status?.defensePercentage ?? 0.0 :
                        Double(dataPoint.status?.players ?? 0)
                )
            )
            .foregroundStyle(bugOrAutomaton == "terminid" ? Color.yellow : Color.red)
            .lineStyle(StrokeStyle(lineWidth: 2.0))
            .interpolationMethod(.catmullRom)
            
          
        
        
        
    }
    
    
    private func chartRuleMark(for dataPoint: PlanetDataPoint, _ status: PlanetStatus) -> some ChartContent {
        
        
     
            
            
            
            let ruleMark = RuleMark(x: .value("Time", chartSelection!))
            let annotationValue = chartType == .liberation ? "\(String(format: "%.2f%%", status.liberation))" :
            chartType == .defense ? "\(String(format: "%.2f%%", status.defensePercentage ?? 0.0))" :
            "\(status.players)"
            let annotationView = ChartAnnotationView(value: annotationValue, date: dataPoint.timestamp.formatted(date: .omitted, time: .shortened))
          return  ruleMark.opacity(0.5)
                .annotation(position: .topLeading, alignment: .top, overflowResolution: .init(x: .fit(to: .chart), y: .fit)){
                    
                    annotationView
                    
                    
                    
                }

            
        
        
    }
    
}

