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
    
    @State private var pulsate = false
    
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
    
    var formattedPlanetImageName: String {
          //  let cleanedName = planetName
          //  .filter { !$0.isPunctuation }   // no apostrophes etc
        //    .replacingOccurrences(of: " ", with: "_")
        
  //      let imageName = "\(cleanedName)_Landscape"
        
        switch planetName {
            
        case "Alaraph", "Veil", "Bashyr", "Solghast", "Alderidge Cove", "Ain-5", "Aesir Pass", "Pandion-XXIV", "Penta", "Haka", "Nivel 43", "Cirrus", "Troost", "Skat Bay", "X-45":
            return "Troost"
        case "Ubanea", "Fort Sanctuary", "Freedom Peak", "Crimsica", "Kharst", "Minchir", "Elysian Meadows", "Providence", "Valgaard", "Gatria", "Enuliale", "Liberty Ridge", "Stout", "Genesis Prime", "Valmox", "Gunvald", "Overgoe Prime", "Kuper", "Acrab XI", "Ingmar", "Yed Prior":
            return "Ingmar"
        case "Wezen", "Pöpli IX", "Imber", "Partion", "Karlia", "Hellmire", "Menkent", "Blistica", "Adhara", "Grand Errant", "Bore Rock", "Marre IV", "Kneth Port", "Asperoth Prime":
            return "Hellmire"
        case "Alathfar XI", "Marfark", "Arkturus", "Kelvinor", "Ivis", "Hadar", "Okul VI", "Khandark", "New Stockholm", "New Kiruna", "Epsilon Phoencis VI", "Tarsh", "Mog", "Julheim", "Heeth", "Parsh", "Hesoe Prime", "Borea", "Vog-sojoth", "Merga IV", "Vandalon IV", "Vega Bay":
            return "Vandalon IV"
        case "Meissa", "Mantes", "Meridia", "Caph", "East Iridium Trading Bay", "Clasa", "Gaellivare", "Irulta", "Rogue 5", "Oasis", "Spherion", "Regnus", "Baldrick Prime", "Navi VII", "Alta V", "Zegema Paradise", "Gar Haren", "Primordia", "Pollux 31", "Nublaria I", "Fornskogur II", "Kirrik", "Klaka 5":
            return "Mantes"
        case "Malevelon Creek", "Peacock", "Brink-2", "Gemma", "Siemnot", "Veld", "Seasse", "Chort Bay", "Nabatea Secundus", "Atrama", "Alairt III", "Prosperity Falls", "New Haven":
            return "Malevelon Creek"
        case "Fenrir III", "Zosma", "Euphoria III", "RD-4", "Sirius":
            return "Fenrir III"
        case "Estanu", "Krakatwo", "Martyr's Bay", "Deneb Secundus", "Krakabos", "Igla", "Inari", "Lesath", "Halies Port", "Barabos", "Eukoria", "Stor Tha Prime", "Grafmere", "Oslo Station", "Choepessa IV", "Acrux IX", "Mekbuda":
            return "Estanu"
        case "Omicron", "Angel's Venture", "Demiurg", "Aurora Bay":
            return "Omicron"
        case "Vindemitarix Prime", "Turing", "Zefia", "Shallus", "Tibit", "Iridica", "Mordia 9", "Sulfura", "Seyshel Beach":
            return "Turing"
        case "Emeria", "Kraz", "Pioneer II", "Hydrofall Prime", "Achird III", "Effluvia", "Fori Prime", "Prasa", "Kuma", "Myrium", "Senge 23", "Azterra", "Calypso", "Castor", "Cyberstan":
            return "Fori Prime"
        case "Draupnir", "Varylia 5", "The Weir", "Reaf", "Iro", "Termadon", "Fort Union", "Oshaune", "Fenmire", "Gemstone Bluffs", "Volterra", "Acamar IV", "Skitter", "Bellatrix", "Mintoria", "Afoyay Bay", "Pherkad Secundus", "Obari", "Achernar Secundus", "Electra Bay", "Matar Bay", "Pathfinder V":
            return "Draupnir"
        case "Tien Kwan":
            return "Tien Kwan"
        default:
            return "Ustotu"
        }
    
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
                    
                    HistoryChart(liberationType: liberationType, planetData: planetData, chartSelection: $chartSelection, chartHeight: chartHeight, chartSectionHeight: chartSectionHeight, chartType: $chartType, chartTypes: chartTypes, bugOrAutomaton: bugOrAutomaton).environmentObject(viewModel)

                    
                }
                VStack(spacing: 0) {
                    
                    VStack {
                        HStack {
                            
                            // health bar
                            
                            RectangleProgressBar(value: liberation / 100, secondaryColor: bugOrAutomaton == .terminid ? Color.yellow : Color.red)
                            
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
                        HStack{
                            Text("\(liberation, specifier: "%.3f")% \(liberationType == .liberation ? "Liberated" : "Defended")").textCase(.uppercase)
                                .foregroundStyle(.white).bold()
                                .font(Font.custom("FS Sinclair", size: showExtraStats ? mediumFont : smallFont))
                                .multilineTextAlignment(.leading)
                            
                            if let liberationRate = viewModel.averageLiberationRate(for: planetName) {
                                Spacer()
                                HStack(alignment: .top, spacing: 4) {
                                    Image(systemName: "chart.line.uptrend.xyaxis")
                                        .padding(.top, 2)
                                    Text("\(liberationRate, specifier: "%.2f")% / h")
                                        .foregroundStyle(.white)
                                        .font(Font.custom("FS Sinclair", size: showExtraStats ? mediumFont : smallFont))
                                        .multilineTextAlignment(.trailing)
                                }
                                    }
                            
                        }   .padding(.horizontal)
                        
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
                            
                            Image(bugOrAutomaton.rawValue).resizable().aspectRatio(contentMode: .fit)
                                .frame(width: raceIconSize, height: raceIconSize)
                            
                            Text(bugOrAutomaton == .terminid ? "\(terminidRate) / h" : "\(automatonRate) / h").foregroundStyle(bugOrAutomaton == .terminid ? Color.yellow : Color.red).bold()
                                .font(Font.custom("FS Sinclair", size: mediumFont))
                                .padding(.top, 3)
                            
                        } else {
                            Text("DEFEND") .font(Font.custom("FS Sinclair", size: largeFont))
                            
                            // defense is important, so pulsate
                                .foregroundStyle(isWidget ? .white : (pulsate ? .red : .white))
                                .opacity(isWidget ? 1.0 : (pulsate ? 1.0 : 0.0))
                                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: pulsate)
                            
                                .onAppear {
                                                pulsate = true
                                            }
                                
                        }
                        
                    }.frame(maxWidth: .infinity)
                    
                    Rectangle().frame(width: 1, height: 30).foregroundStyle(Color.white)
                        .padding(.vertical, 10)
                    
                    
                    HStack(spacing: spacingSize) {
                        
                        
                        Image("diver").resizable().aspectRatio(contentMode: .fit)
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
                
                
            }.onTapGesture {
                // show chart if tapped anywhere
                showChartToggler()
            }
            
            
        }.padding(5)
            .background {
                if isWidget {
                    Color.clear
                } else {
                    Color.black
                }
            }
            .border(.yellow, width: isWidget ? 0 : 2)
        
        
            .onAppear {
                print("passed value is \(bugOrAutomaton.rawValue)")
            }
    }
    
    var headerWithImage: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Image(bugOrAutomaton.rawValue).resizable().aspectRatio(contentMode: .fit)
                    .frame(width: raceIconSize, height: raceIconSize)
                Text(planetName).textCase(.uppercase).foregroundStyle(bugOrAutomaton == .terminid ? Color.yellow : Color.red)
                    .font(Font.custom("FS Sinclair", size: largeFont))
                    .padding(.top, 3)
                
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
    @Binding var chartSelection: Date?
    var chartHeight: CGFloat = 200
    var chartSectionHeight: CGFloat = 300
    @Binding var chartType: ChartType
    var chartTypes: [ChartType] = []
    var bugOrAutomaton: EnemyType

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
