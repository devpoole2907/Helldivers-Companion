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
        SimplePlanetStatus(date: Date(), planetName: "Meridia", liberation: 86.54, playerCount: 264000)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimplePlanetStatus) -> Void) {
        
        let entry = SimplePlanetStatus(date: Date(), planetName: "Meridia", liberation: 86.54, playerCount: 264000)
        
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimplePlanetStatus>) -> Void) {
        

        
        
        var entries: [SimplePlanetStatus] = []

        planetsModel.fetchCurrentWarSeason() { season in
            planetsModel.fetchPlanetStatuses(for: season) { planets in
                if let highestPlanet = planets.max(by: { $0.players < $1.players }) {
                    let entry = SimplePlanetStatus(date: Date(), planetName: highestPlanet.planet.name, liberation: highestPlanet.liberation, playerCount: highestPlanet.players, planet: highestPlanet)
                    
                    print("appending entry!")
                    entries.append(entry)
                }

                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
            }
        }
    }

}


struct SimplePlanetStatus: TimelineEntry {
    var date: Date
    var planetName: String
    var liberation: Double
    var playerCount: Int
    var planet: PlanetStatus? = nil
}


struct Helldivers_Companion_WidgetsEntryView : View {
    
    @Environment(\.widgetFamily) var widgetFamily
    
    var entry: PlanetStatusProvider.Entry

    var body: some View {
        
        switch widgetFamily {
        case .accessoryRectangular:
            RectangularPlanetWidgetView(entry: entry)
        default:
            
            
            #if os(iOS)
            
            
            ZStack {
                
                Color(.yellow).opacity(0.6)
                
                ContainerRelativeShape()
                    .inset(by: 4)
                    .fill(Color.black)
                
                PlanetView(planetName: entry.planetName, liberation: entry.liberation, playerCount: entry.playerCount, planet: entry.planet, showHistory: false, showImage: widgetFamily != .systemMedium, showExtraStats: widgetFamily != .systemMedium, isWidget: true).environmentObject(PlanetsViewModel())
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
                Spacer()
            }
            RoundedRectangle(cornerRadius: 25).frame(width: 100, height: 2)
            VStack (alignment: .leading, spacing: -3){
                HStack(spacing: 3) {
                    Image("helldiverIcon").resizable().aspectRatio(contentMode: .fit).frame(width: 13, height: 13)
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
            
        }.padding(.leading, 5)
            .padding(.vertical, 2).background(in: RoundedRectangle(cornerRadius: 5.0))
    }
}

struct Helldivers_Companion_Planet_Widgets: Widget {
    let kind: String = "Helldivers_Companion_Widgets"
    
    #if os(watchOS)
    let supportedFamilies: [WidgetFamily] = [.accessoryRectangular]
    #elseif os(iOS)
    let supportedFamilies: [WidgetFamily] = [.accessoryRectangular, .systemMedium, .systemLarge]
    #endif

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PlanetStatusProvider()) { entry in

                Helldivers_Companion_WidgetsEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            
        }
        .configurationDisplayName("Player Count")
        .description("Shows the planet with the current highest player count.")
        .supportedFamilies(supportedFamilies)
        .contentMarginsDisabled()
    }
}
    
#Preview(as: .accessoryRectangular) {
    Helldivers_Companion_Planet_Widgets()
} timeline: {
    SimplePlanetStatus(date: Date(), planetName: "Meridia", liberation: 86.54, playerCount: 264000)
}

