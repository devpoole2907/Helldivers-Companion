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
        SimplePlanetStatus(date: Date(), planetName: "Meridia", liberation: 86.54, playerCount: 264000, liberationType: .liberation, faction: "terminid", factionColor: .yellow)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimplePlanetStatus) -> Void) {
        
        let entry = SimplePlanetStatus(date: Date(), planetName: "Meridia", liberation: 86.54, playerCount: 264000, liberationType: .liberation, faction: "terminid", factionColor: .yellow)
        
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimplePlanetStatus>) -> Void) {
        
        // fetches from github instead to save on api call
        
        let urlString = "https://raw.githubusercontent.com/devpoole2907/helldivers-api-cache/main/newData/currentCampaigns.json"
        
        var entries: [SimplePlanetStatus] = []

        planetsModel.fetchConfig { configData in
            planetsModel.fetchUpdatedCampaigns(using: urlString) { campaigns, defenseCampaigns in
                
                if let highestPlanetCampaign = campaigns.max(by: { $0.planet.statistics.playerCount < $1.planet.statistics.playerCount }) {
                    let highestPlanet = highestPlanetCampaign.planet
                    if let defenseEvent = defenseCampaigns.first(where: { $0.planet.index == highestPlanet.index }) {
                        
                        let eventExpirationTime = highestPlanet.event?.expireTimeDate
                        
                        // faction always humans when defending, so put event faction here manually because we cant access the extra conditions in the view models faction image or color functions
                        
                        var enemyType = "terminid"
                        var factionColor = Color.yellow
                        
                        if defenseEvent.planet.event?.faction == "Automaton" {
                            enemyType = "automaton"
                            factionColor = .red
                        } else if defenseEvent.planet.event?.faction == "Illuminate" {
                            enemyType = "illuminate"
                            factionColor = .blue
                        }

                        let entry = SimplePlanetStatus(date: Date(), planetName: highestPlanet.name, liberation: highestPlanet.percentage, playerCount: highestPlanet.statistics.playerCount, planet: highestPlanet, liberationType: .defense, faction: enemyType, factionColor: factionColor, eventExpirationTime: eventExpirationTime)
                        entries.append(entry)
                        
                    } else {
                        // we dont need to access the view models faction image function's additional conditions here, because the planet is definitely not defending and is definitely a campaign, so we can just use it in the view directly as it will fall through to the check we need anyway
                        
                        let entry = SimplePlanetStatus(date: Date(), planetName: highestPlanet.name, liberation: highestPlanet.percentage, playerCount: highestPlanet.statistics.playerCount, planet: highestPlanet)
                        entries.append(entry)
                    }
                    
                    print("appending entry!")
                    
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
    var planet: UpdatedPlanet? = nil
    var liberationType: LiberationType = .liberation
    var faction: String? // optional for the same reasons below
    var factionColor: Color? // this is optional and fetched in the app if state is liberation not defense because the viewmodel doesnt need its state for defense planets in that case, it falls through the if statements anyway
    var eventExpirationTime: Date? = nil
}


struct Helldivers_Companion_WidgetsEntryView : View {
    
    @Environment(\.widgetFamily) var widgetFamily
    
    let planetsModel = PlanetsViewModel()
    
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
                
                if let factionColor = entry.factionColor {
                    factionColor.opacity(0.6)
                } else {
                    // must be liberating
                    
                    planetsModel.getColorForPlanet(planet: entry.planet).opacity(0.6)
                }
               
                
                ContainerRelativeShape()
                    .inset(by: 4)
                    .fill(Color.black)
                
                PlanetView(planetName: entry.planetName, liberation: entry.liberation, playerCount: entry.playerCount, planet: entry.planet, factionName: entry.faction, factionColor: entry.factionColor, showHistory: false, showImage: widgetFamily != .systemMedium, showExtraStats: widgetFamily != .systemMedium, liberationType: entry.liberationType, isWidget: true, eventExpirationTime: entry.eventExpirationTime).environmentObject(PlanetsViewModel())
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
                // nil coalesced with get image name for planet, because entry.faction wouldnt be nil if it was defending - and using view models function for image name is fine when liberating
                
                Image(entry.faction ?? PlanetsViewModel().getImageNameForPlanet(entry.planet)).resizable().aspectRatio(contentMode: .fit).frame(width: 13, height: 13)
                    .padding(.bottom, 2)
                Text(entry.planetName) .font(Font.custom("FS Sinclair Bold", size: 16))
                
                
                Image(systemName: entry.liberationType == .defense ? "shield.lefthalf.filled" : "target")
                    .font(.footnote)
                    .padding(.bottom, 1)
                
                
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
            Image(entry.faction ?? "terminid").resizable().aspectRatio(contentMode: .fit).frame(width: 13, height: 13)
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
    SimplePlanetStatus(date: Date(), planetName: "Meridia", liberation: 86.54, playerCount: 264000, liberationType: .liberation, faction: "terminid")
}

