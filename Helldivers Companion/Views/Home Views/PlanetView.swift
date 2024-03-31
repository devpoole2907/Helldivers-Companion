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
    
    @EnvironmentObject var navPather: NavigationPather
    
    var planetName = "Meridia"
    var liberation = 24.13020
    var rate = 0.0
    var playerCount: Int = 347246
    var planet: PlanetStatus? = nil
    var showHistory = true
    var showImage = true
    var showExtraStats = true
    var liberationType: LiberationType = .liberation
    var isWidget = false
    // for widgets, pass remote config info
    
    @State var bugOrAutomaton: EnemyType
    
    var terminidRate: String
    var automatonRate: String
    
    @State private var showChart = false
    
    @State private var chartType: ChartType = .players
    
#if os(iOS)
let raceIconSize: CGFloat = 25
    let spacingSize: CGFloat = 10
    let weatherIconSize: CGFloat = 28

#elseif os(watchOS)
    let raceIconSize: CGFloat = 20
    let spacingSize: CGFloat = 4
    let weatherIconSize: CGFloat = 14
#endif

        private var planetData: [PlanetDataPoint] {
            viewModel.planetHistory[planetName] ?? []
        }
    
    private var formattedPlanetImageName: String {
        
        PlanetImageFormatter.formattedPlanetImageName(for: planetName)
    
        }
    
    func showChartToggler() {
        withAnimation(.bouncy) {
            showChart.toggle()
        }
    }
    
    var body: some View {
        
        VStack {
            
            VStack(spacing: showExtraStats ? 6 : 2) {
                
                headerWithImage
                
                if showChart {
                    
                    HistoryChart(liberationType: liberationType, planetData: planetData, bugOrAutomaton: bugOrAutomaton).environmentObject(viewModel)
                    
                }
                
                
                // put it here
                
                CampaignPlanetStatsView(liberation: liberation, bugOrAutomaton: bugOrAutomaton, liberationType: liberationType, showExtraStats: showExtraStats, planetName: planetName, playerCount: playerCount, isWidget: isWidget, terminidRate: terminidRate, automatonRate: automatonRate)
                
                

            
                
                
            }.onTapGesture {
                // show chart if tapped anywhere
               // showChartToggler()
                // nav to planet info view if tapped anywhere
                if let planet = planet {
                    navPather.navigationPath.append(planet)
                } else {
                    showChartToggler()
                }
                
            }
            
            
        }.padding(5)
            .background {
                if isWidget {
                    Color.clear
                } else {
                    Color.black
                }
            }
            .border(bugOrAutomaton == .terminid ? .yellow : .red, width: isWidget ? 0 : 2)
        
        
            .onAppear {
                print("passed value is \(bugOrAutomaton.rawValue)")
            }
    }
    
    var planetNameAndIcon: some View {
        return Group {
        Image(bugOrAutomaton.rawValue).resizable().aspectRatio(contentMode: .fit)
            .frame(width: raceIconSize, height: raceIconSize)
        HStack(spacing: 2){
            Text(planetName).textCase(.uppercase).foregroundStyle(bugOrAutomaton == .terminid ? Color.yellow : Color.red)
                .font(Font.custom("FS Sinclair", size: largeFont))
                .padding(.top, 3)
            if !isWidget {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.gray)
                    .opacity(0.7)
                    .bold()
                    .font(.footnote)
            }
        }
        
    }
    }
    
    var headerWithImage: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                if isWidget {
                    planetNameAndIcon
                } else {
                    NavigationLink(value: planet) {
                       planetNameAndIcon
                    }
                }
                
                Spacer()
                
                if !showExtraStats {
                    HStack(spacing: spacingSize) {
                        
                        
                        Image("diver").resizable().aspectRatio(contentMode: .fit)
                            .frame(width: 16, height: 16)
                        Text("\(playerCount)").textCase(.uppercase)
                            .foregroundStyle(.white).bold()
                            .font(Font.custom("FS Sinclair", size: smallFont))
                            .padding(.top, 3)
                        
                    }.padding(.trailing, 4)
                }
                
                if showHistory {
                Button(action: {
                    showChartToggler()
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
                .border(bugOrAutomaton == .terminid ? .yellow : .red)
#endif
                
                
            }
                
            }.padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background{ Color.black}
            
            if showImage {
                if !showChart {
                    imageWithEnvironmentalInfo
                    
                }
            }
            
        }.border(Color.white)
            .padding(4)
            .border(Color.gray)
    }
    
    var imageWithEnvironmentalInfo: some View {
        ZStack(alignment: .bottom) {
            Image(formattedPlanetImageName).resizable().aspectRatio(contentMode: .fit)
            
                .onAppear {
                    print("weathers are: \(planet?.planet.environmentals)")
                }
            
            // show weather icons
            if let weathers = planet?.planet.environmentals {
                VStack {
                    if !isWidget {
                        Spacer()
                    }
                HStack(spacing: 10) {
                    ForEach(weathers, id: \.name) { weather in
                        
                        Image(weather.name).resizable().aspectRatio(contentMode: .fit)
                        
                            .frame(width: weatherIconSize, height: weatherIconSize)
                            .padding(4)
                            .background{
                                Circle().foregroundStyle(Color.white)
                                    .shadow(radius: 3.0)
                            }
                    }
                }.opacity(0.7)
                    
                }.padding(.bottom, 8)
                
                
            }
            
        }
    }
    
}

#Preview {
    
    PlanetView(bugOrAutomaton: .terminid, terminidRate: "-5%", automatonRate: "-1.5%").environmentObject(PlanetsViewModel())
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
    var bugOrAutomaton: EnemyType
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
              
                    .foregroundStyle(bugOrAutomaton == .terminid ? Color.yellow : Color.red)
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
    ChartAnnotationView(bugOrAutomaton: .terminid)
}

struct HistoryChart: View {
    @EnvironmentObject var viewModel: PlanetsViewModel
    var liberationType: LiberationType
    var planetData: [PlanetDataPoint]
    @State private var chartSelection: Date? = nil
    @State var chartType: ChartType = .players
    var bugOrAutomaton: EnemyType
    
    #if os(watchOS)
    let chartHeight: CGFloat = 160
    let chartSectionHeight: CGFloat = 210
    #else
    let chartHeight: CGFloat = 240
    let chartSectionHeight: CGFloat = 300
    #endif
    
    var chartTypes: [ChartType] {
        switch liberationType {
        case .liberation:
            return [.liberation, .players]
        case .defense:
            return [.defense, .players]
        }
    }

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
 

                ForEach(planetData, id: \.timestamp) { dataPoint in
                    if let status = dataPoint.status {
                        chartLineMark(for: dataPoint, status)
                        
                        if let chartSelection = chartSelection, Calendar.current.isDate(chartSelection, equalTo: dataPoint.timestamp, toGranularity: .minute) {
                            chartRuleMark(for: dataPoint, status)
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
                    chartType != .players ? dataPoint.status?.liberation ?? 0.0 :
                        Double(dataPoint.status?.players ?? 0)
                )
            )
           .foregroundStyle(bugOrAutomaton == .terminid ? Color.yellow : Color.red)
            .lineStyle(StrokeStyle(lineWidth: 2.0))
            .interpolationMethod(.catmullRom)
            
          
        
        
        
    }
    
    
    private func chartRuleMark(for dataPoint: PlanetDataPoint, _ status: PlanetStatus) -> some ChartContent {

            let ruleMark = RuleMark(x: .value("Time", chartSelection!))
        let annotationValue = chartType != .players ? "\(String(format: "%.2f%%", status.liberation))" : "\(status.players)"
            
        let annotationView = ChartAnnotationView(bugOrAutomaton: bugOrAutomaton, value: annotationValue, date: dataPoint.timestamp.formatted(date: .omitted, time: .shortened))
          return  ruleMark.opacity(0.5)
                .annotation(position: .topLeading, alignment: .top, overflowResolution: .init(x: .fit(to: .chart), y: .fit)){
                    
                    annotationView
                    
                    
                    
                }

            
        
        
    }
    
}

