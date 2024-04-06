//
//  Helldivers_Companion_Widgets.swift
//  Helldivers Companion Widgets
//
//  Created by James Poole on 18/03/2024.
//

import WidgetKit
import SwiftUI

struct PlanetStatusProvider: TimelineProvider {
    typealias Entry = SimplePlanetStatus
    
    var planetsModel = PlanetsViewModel()
    
    func placeholder(in context: Context) -> SimplePlanetStatus {
        SimplePlanetStatus(date: Date(), planetName: "Meridia", liberation: 86.54, playerCount: 264000, liberationType: .liberation, terminidRate: "-5%", automatonRate: "-1.5%", bugOrAutomaton: .terminid)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimplePlanetStatus) -> Void) {
        
        let entry = SimplePlanetStatus(date: Date(), planetName: "Meridia", liberation: 86.54, playerCount: 264000, liberationType: .liberation, terminidRate: "-5%", automatonRate: "-1.5%", bugOrAutomaton: .terminid)
        
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimplePlanetStatus>) -> Void) {
        
        // fetches from github instead to save on api call
        let urlString = "https://raw.githubusercontent.com/devpoole2907/helldivers-api-cache/main/data/currentPlanetStatus.json"
        
        var entries: [SimplePlanetStatus] = []
        
        planetsModel.fetchConfig { configData in
    //    planetsModel.fetchCurrentWarSeason() { season in
            planetsModel.fetchPlanetStatuses(using: urlString, for: configData?.season ?? "801") { planets in
                if let highestPlanet = planets.0.max(by: { $0.players < $1.players }) {
                    if let defenseEvent = planets.1.first(where: { $0.planet.index == highestPlanet.planet.index }) {
                        
                        let entry = SimplePlanetStatus(date: Date(), planetName: highestPlanet.planet.name, liberation: defenseEvent.defensePercentage, playerCount: highestPlanet.players, planet: highestPlanet, liberationType: .defense, terminidRate: configData?.terminidRate ?? "0%", automatonRate: configData?.automatonRate ?? "0%", bugOrAutomaton: highestPlanet.owner == "Terminids" ? .terminid : .automaton, eventExpirationTime: defenseEvent.expireTimeDate)
                        entries.append(entry)
                        
                    } else {
                        let entry = SimplePlanetStatus(date: Date(), planetName: highestPlanet.planet.name, liberation: highestPlanet.liberation, playerCount: highestPlanet.players, terminidRate: configData?.terminidRate ?? "0%", automatonRate: configData?.automatonRate ?? "0%", bugOrAutomaton: highestPlanet.owner == "Terminids" ? .terminid : .automaton)
                        entries.append(entry)
                    }
                    
                    print("appending entry!")
                    
                }
                
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
            }
      //  }
        
    }
    }
    
}


struct SimplePlanetStatus: TimelineEntry {
    var date: Date
    var planetName: String
    var liberation: Double
    var playerCount: Int
    var planet: PlanetStatus? = nil
    var liberationType: LiberationType = .liberation
    var terminidRate: String
    var automatonRate: String
    var bugOrAutomaton: EnemyType
    var eventExpirationTime: Date? = nil
}


struct Helldivers_Companion_WidgetsEntryView : View {
    
    @Environment(\.widgetFamily) var widgetFamily
    
    var entry: PlanetStatusProvider.Entry
    
    var body: some View {
        
        switch widgetFamily {
        case .accessoryRectangular:
            RectangularPlanetWidgetView(entry: entry)
        case .accessoryInline:
            InlinePlanetWidgetView(entry: entry)
#if os(watchOS)
        case .accessoryCorner:
            CornerPlanetWidgetView(entry: entry)
                .widgetAccentable()
#endif
        default:
            
            
#if os(iOS)
            
            
            ZStack {
                
                entry.bugOrAutomaton == .automaton ? Color(.red).opacity(0.6) : Color(.yellow).opacity(0.6)
                
                ContainerRelativeShape()
                    .inset(by: 4)
                    .fill(Color.black)
                
                PlanetView(planetName: entry.planetName, liberation: entry.liberation, playerCount: entry.playerCount, planet: entry.planet, showHistory: false, showImage: widgetFamily != .systemMedium, showExtraStats: widgetFamily != .systemMedium, liberationType: entry.liberationType, isWidget: true, bugOrAutomaton: entry.bugOrAutomaton, terminidRate: entry.terminidRate, automatonRate: entry.automatonRate, eventExpirationTime: entry.eventExpirationTime).environmentObject(PlanetsViewModel())
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                
            }
#else
            Text("You shouldnt see this")
#endif
        }
        
        
        
    }
}

struct RectangularPlanetWidgetView: View {
    
    var entry: PlanetStatusProvider.Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            HStack(spacing: 3) {
                Image("terminid").resizable().aspectRatio(contentMode: .fit).frame(width: 13, height: 13)
                    .padding(.bottom, 2)
                Text(entry.planetName) .font(Font.custom("FS Sinclair", size: 16))
                
                
                Image(systemName: entry.liberationType == .defense ? "shield.lefthalf.filled" : "target")
                    .font(.footnote)
                
                
            }
            RoundedRectangle(cornerRadius: 25).frame(width: 100, height: 2)
            VStack (alignment: .leading, spacing: -3){
                HStack(spacing: 3) {
                    Image("diver").resizable().aspectRatio(contentMode: .fit).frame(width: 13, height: 13)
                        .padding(.bottom, 2)
                    Text("\(entry.playerCount)") .font(Font.custom("FS Sinclair", size: 16))
                    Spacer()
                }.padding(.leading, 5)
                HStack(spacing: 3) {
                    Image(systemName: "chart.xyaxis.line").resizable().aspectRatio(contentMode: .fit).frame(width: 13, height: 13)
                        .padding(.bottom, 2)
                    Text("\(entry.liberation)%") .font(Font.custom("FS Sinclair", size: 16))
                    Spacer()
                }.padding(.leading, 5)
            }.padding(.top, 2)
            
        }.widgetAccentable()
        
            .padding(.leading, 5)
            .padding(.vertical, 2)
        //background breaks the watch version
#if os(iOS)
            .background(in: RoundedRectangle(cornerRadius: 5.0))
#endif
    }
}
#if os(watchOS)
struct CornerPlanetWidgetView: View {
    var entry: PlanetStatusProvider.Entry
    var body: some View {
        
        if #available(iOS 17.0, *), #available(watchOS 10.0, *) {
            
            Text(entry.planetName)
                .font(.footnote)
                .scaledToFit()
                .minimumScaleFactor(0.2)
                .widgetCurvesContent()
                .widgetLabel {
                    ProgressView(value: entry.liberation, total: 100)
                        .tint(.yellow)
                }
        } else {
            Text(entry.planetName)
                .font(.footnote)
                .scaledToFit()
                .minimumScaleFactor(0.2)
               
                .widgetLabel {
                    ProgressView(value: entry.liberation, total: 100)
                        .tint(.yellow)
                }
        }
    }
}
#endif

struct InlinePlanetWidgetView: View {
    
    var entry: PlanetStatusProvider.Entry
    
    var body: some View {
        HStack(spacing: 3) {
            Image("terminid").resizable().aspectRatio(contentMode: .fit).frame(width: 13, height: 13)
                .padding(.bottom, 2)
            Text("\(entry.planetName)") .font(Font.custom("FS Sinclair", size: 16))
            Image(systemName: entry.liberationType == .defense ? "shield.lefthalf.filled" : "target")
                .font(.footnote)
            Text("\(String(format: "%.2f%%", entry.liberation))") .font(Font.custom("FS Sinclair", size: 16))
        }
        
    }
}

struct Helldivers_Companion_Planet_Widgets: Widget {
    let kind: String = "Helldivers_Companion_Widgets"
    
#if os(watchOS)
    let supportedFamilies: [WidgetFamily] = [.accessoryRectangular, .accessoryInline]
#elseif os(iOS)
    let supportedFamilies: [WidgetFamily] = [.accessoryRectangular, .accessoryInline, .systemMedium, .systemLarge]
#endif
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PlanetStatusProvider()) { entry in
            
            if #available(iOS 17.0, *) {
                Helldivers_Companion_WidgetsEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
                // for deeplinking to info of planet view
                    .widgetURL(URL(string: "helldiverscompanion://\(entry.planetName)"))
            } else {
                Helldivers_Companion_WidgetsEntryView(entry: entry)
            }
            
        }
        .configurationDisplayName("Player Count")
        .description("Shows the planet with the current highest player count.")
        .supportedFamilies(supportedFamilies)
        .contentMarginsDisabled()
    }
}
@available(iOS 17.0, *)
#Preview(as: .accessoryRectangular) {
    Helldivers_Companion_Planet_Widgets()
} timeline: {
    SimplePlanetStatus(date: Date(), planetName: "Meridia", liberation: 86.54, playerCount: 264000, liberationType: .liberation, terminidRate: "-5%", automatonRate: "-1.5%", bugOrAutomaton: .terminid)
}

