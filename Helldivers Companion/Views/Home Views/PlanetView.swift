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
    var playerCount: Int64 = 347246
    var planet: UpdatedPlanet? = nil
    var factionName: String? = nil // this is for widgets as they cannot access some conditions in the planets view model image function
    var factionColor: Color? = nil // this is for widgets as they cannot access some conditions in the planets view model color function
    var showHistory = true
    var showImage = true
    var showExtraStats = true
    var liberationType: LiberationType = .liberation
    var isWidget = false
    
    var eventExpirationTime: Date? = nil // for defense events
    
    var isInMapView = false // map view uses navigation view not navigationstack, due to the zoomable package/modifier not working in stack. so this is a workaround that allows us to change the navigationlink styling to the older deprecated way if we are in the map view
    
    var isActive = true // map view needs this, as it shows planet view for all planets even if they arent actively in a campaign. used to hide additional info such as liberation %
    
    @State private var showChart = false
    
    @State private var chartType: ChartType = .players
    
#if os(iOS)
    let raceIconSize: CGFloat = 25
    let spacingSize: CGFloat = 10
    
    let zStackAlignment: Alignment = .topTrailing
    
#elseif os(watchOS)
    let raceIconSize: CGFloat = 20
    let spacingSize: CGFloat = 4
    let zStackAlignment: Alignment = .topLeading
#endif
    
    private var planetData: [UpdatedPlanetDataPoint] {
        viewModel.updatedPlanetHistory[planetName] ?? []
    }
    
    private var formattedPlanetImageName: String {
        
        PlanetImageFormatter.formattedPlanetImageName(for: planetName)
        
    }
    
    private var factionImage: String {
        
        if let imageName = factionName {
            return imageName
        }
        
        // if faction name is nil, we must be in the app - faction is only passed to this view as a widget because widgets cannot access all conditions for this function - unless it is liberating (not defense), liberating campaigns can access the required conditionals so no faction image or color is passed to this view in that case either
        
        return viewModel.getImageNameForPlanet(planet)
        
    }
    
    private var foreColor: Color {
        
        if let color = factionColor {
            return color
        }
        
        // see above computed prop comments for more info, its the same reasoning
        // if faction color is nil, we must be in the app - faction is only passed to this view as a widget because widgets cannot access all conditions for this function
        
        return viewModel.getColorForPlanet(planet: planet)
        
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
                    
                    HistoryChart(liberationType: liberationType, planetData: planetData, factionColor: foreColor).environmentObject(viewModel)
                    
                }
                
         
                    
                CampaignPlanetStatsView(liberation: liberation, liberationType: liberationType, showExtraStats: showExtraStats, planetName: planetName, planet: planet, factionColor: foreColor, factionImage: factionImage, playerCount: playerCount, isWidget: isWidget, eventExpirationTime: eventExpirationTime, isActive: isActive)
                    
                
                
                
                
                
            }.onTapGesture {
                // show chart if tapped anywhere
                // showChartToggler()
                // nav to planet info view if tapped anywhere
                if let planet = planet {
                    navPather.navigationPath.append(planet)
                } else {
                    // showChartToggler()
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
            .border(foreColor, width: isWidget ? 0 : 2)
     
    }
    
    var planetNameAndIcon: some View {
        return Group {
            Image(viewModel.getImageNameForPlanet(planet)).resizable().aspectRatio(contentMode: .fit)
                .frame(width: raceIconSize, height: raceIconSize)
                .shadow(radius: 3)
            HStack(spacing: 2){
                Text(planetName).textCase(.uppercase).foregroundStyle(foreColor)
                    .font(Font.custom("FS Sinclair", size: largeFont))
                    .padding(.top, 3)
                #if os(iOS)
                    .lineLimit(2)
                #elseif os(watchOS)
                    .lineLimit(1)
                #endif
                    .multilineTextAlignment(.leading)
                    .lineSpacing(0)
                if !isWidget {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.gray)
                        .opacity(0.7)
                        .bold()
                        .font(.footnote)
                } else {
                    Image(systemName: liberationType == .defense ? "shield.lefthalf.filled" : "target")
                        .font(.footnote)
                        .padding(.leading, 2)
                        .foregroundStyle(.white)
                }
                
             
                
                
            }  .shadow(radius: 3)
            
        }
    }
    
    var headerWithImage: some View {
        ZStack(alignment: .bottom){
            
            if showImage {
                if !showChart {
                    
                    // this really messes with the widgets so ive done it in an... odd way
                    ZStack(alignment: zStackAlignment){
                        ZStack(alignment: .bottom) {
                            
                            planetaryImage
                            
                            
                            LinearGradient(
                                gradient: Gradient(colors: [.clear, .black]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .blendMode(.multiply)
                            
                            .frame(maxHeight: 80)
                            
                        }
                        
                        // show weather icons
                        if let weathers = planet?.environmentals {
                            
                         
                            
                            HStack(spacing: 8) {
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
                            
                                .padding(5)
                            
                            
                            
                            
                        }
                        
                        
                    }
                    
                }
            }
            
     
                HStack(alignment: .center) {
                    
#if os(iOS)
                    if isWidget {
                        planetNameAndIcon
                    }  else {
                        NavigationLink(value: planet) {
                            planetNameAndIcon
                        }
                    }
                    // map view isnt coming to the watch so no need to change the nav link method there
#else
                    
                    Button(action: {
                        if let planet = planet {
                            navPather.navigationPath.append(planet)
                        }
                        
                    }){
                        planetNameAndIcon
                    }.buttonStyle(PlainButtonStyle())
                    
#endif
                    
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
                    
                }.padding(.horizontal, 5)
                    .padding(.vertical, 2)
                
            
            
            
        }.border(Color.white)
            .padding(4)
            .border(Color.gray)
    }
    
    var planetaryImage: some View {
        
        Image(formattedPlanetImageName).resizable().aspectRatio(contentMode: .fit)
        
        
        
        
        
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
    var factionColor: Color
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
                    .font(Font.custom("FS Sinclair Bold", size: smallFont))
                    .foregroundStyle(.gray)
                    .padding(.top, 1)
                
                Text(value)
                
                    .foregroundStyle(factionColor)
                    .font(Font.custom("FS Sinclair Bold", size: valueFont))
                
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

struct HistoryChart: View {
    @EnvironmentObject var viewModel: PlanetsViewModel
    var liberationType: LiberationType
    var planetData: [UpdatedPlanetDataPoint]
    @State private var chartSelection: Date? = nil
    @State var chartType: ChartType = .players
    var factionColor: Color
    
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
            if viewModel.updatedPlanetHistory.isEmpty {
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
                if let planet = dataPoint.planet {
                    chartLineMark(for: dataPoint, planet)
                    
                    if let chartSelection = chartSelection, Calendar.current.isDate(chartSelection, equalTo: dataPoint.timestamp, toGranularity: .minute) {
                        chartRuleMark(for: dataPoint, planet)
                    }
                }
            }
            
        }
        .chartYScale(domain: [0, chartType == .players ? 350000 : 100])
        .chartXSelectioniOS17Modifier($chartSelection)
        
        .chartOverlayiOS16 { proxy in
            
            GeometryReader { innerProxy in
                
                Rectangle()
                    .fill(.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged{ value in
                                
                                
                                
                                let location = value.location
                                
                                if let date: Date = proxy.value(atX: location.x){
                           
                                    print("date is \(date)")
                                    
                                    chartSelection = date
                                }
                                
                                
                            } .onEnded{ value in
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        
                                        
                                        chartSelection = nil
                                        
                                    }
                                }
                            }
                    )
                
            }
            
            
            
        }
        
        .padding(10)
        .frame(minHeight: chartHeight)
        .onChange(of: chartSelection) { newValue in
            // Jump to nearest data point logic
            if let newValue = newValue, !planetData.isEmpty {
                chartSelection = planetData.min(by: { abs($0.timestamp.timeIntervalSince(newValue)) < abs($1.timestamp.timeIntervalSince(newValue)) })?.timestamp
            }
        }
    }
    
    private func chartLineMark(for dataPoint: UpdatedPlanetDataPoint, _ planet: UpdatedPlanet) -> some ChartContent {
        
        
        LineMark(
            x: .value("Time", dataPoint.timestamp),
            y: .value(
                chartType == .liberation ? "Liberation" :
                    chartType == .defense ? "Defense" : "Players",
                // use event percentage if defending
                chartType != .players ? (chartType == .defense ? dataPoint.planet?.event?.percentage : dataPoint.planet?.percentage) ?? 0.0 :
                    Double(dataPoint.planet?.statistics.playerCount ?? 0)
            )
        )
        .foregroundStyle(factionColor)
        .lineStyle(StrokeStyle(lineWidth: 2.0))
        .interpolationMethod(.catmullRom)
        
        
        
        
        
    }
    
    
    private func chartRuleMark(for dataPoint: UpdatedPlanetDataPoint, _ planet: UpdatedPlanet) -> some ChartContent {
        
        let ruleMark = RuleMark(x: .value("Time", chartSelection!))
        let annotationValue = chartType != .players ? "\(String(format: "%.2f%%", planet.percentage))" : "\(planet.statistics.playerCount)"
        
        let annotationView = ChartAnnotationView(factionColor: factionColor, value: annotationValue, date: dataPoint.timestamp.formatted(date: .omitted, time: .shortened))
        if #available(iOS 17, *), #available(watchOS 10, *) {
               return ruleMark
                   .opacity(0.5)
                   .annotation(position: .topLeading, alignment: .top, overflowResolution: .init(x: .fit(to: .chart), y: .fit)) {
                       annotationView
                   }
           } else {
               return ruleMark
                   .opacity(0.5)
                   // Apply the annotation without the overflowResolution for iOS 16 and earlier
                   .annotation(position: .leading, alignment: .top) {
                       annotationView
                   }
           }
  
    }
    
}

