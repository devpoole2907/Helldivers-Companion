//
//  Helldivers_Companion_Major_Order_Widget.swift
//  Helldivers Companion Major Order Widget
//
//  Created by James Poole on 24/03/2024.
//

import WidgetKit
import SwiftUI

struct MajorOrderProvider: TimelineProvider {
    
    var planetsModel = PlanetsViewModel()
    
    func placeholder(in context: Context) -> MajorOrderEntry {
        MajorOrderEntry(date: Date(), title: "Stand by.", description: "Await further orders from Super Earth High Command.", taskPlanets: [], rewardValue: 35, rewardType: 1, timeRemaining: 129600)
    }

    func getSnapshot(in context: Context, completion: @escaping (MajorOrderEntry) -> ()) {
        let entry = MajorOrderEntry(date: Date(), title: "Stand by.", description: "Await further orders from Super Earth High Command.", taskPlanets: [], rewardValue: 35, rewardType: 1, timeRemaining: 129600)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [MajorOrderEntry] = []

        planetsModel.fetchConfig() { config in
            planetsModel.fetchPlanetStatuses(for: config?.season ?? "801") { _, _, planetStatuses in
                planetsModel.fetchMajorOrder(for: config?.season ?? "801", with: planetStatuses) { planets, order in
                
                let entry = MajorOrderEntry(date: Date(), title: order?.setting.taskDescription, description: order?.setting.overrideBrief, taskPlanets: planets, rewardValue: order?.setting.reward.amount, rewardType: order?.setting.reward.type, timeRemaining: order?.expiresIn)
                
                print("apending entry, this many planets: \(planets.count)")
                
                entries.append(entry)
                
                
                
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
            }
            
        }
            
            
            
        }

       
    }
}

struct MajorOrderEntry: TimelineEntry {
    let date: Date
    let title: String?
    let description: String?
    let taskPlanets: [PlanetStatus]
    let rewardValue: Int?
    let rewardType: Int?
    let timeRemaining: Int64?
}

struct Helldivers_Companion_Major_Order_WidgetEntryView : View {
    
    @Environment(\.widgetFamily) var widgetFamily
    
    var entry: MajorOrderProvider.Entry

    var body: some View {
        
        switch widgetFamily {
            
        case .accessoryRectangular:
            RectangularOrdersTimeLeftView(timeRemaining: entry.timeRemaining)
                .widgetAccentable()
                
                .padding(.leading, 5)
                    .padding(.vertical, 2)
                //background breaks the watch version
                #if os(iOS)
                    .background(in: RoundedRectangle(cornerRadius: 5.0))
                #endif
            
        case .accessoryInline:
            InlineOrdersTimeLeftWidget(timeRemaining: entry.timeRemaining)
                .widgetAccentable()
        
        default:
            #if os(iOS)
            ZStack {
                
                Color(.cyan).opacity(0.6)
                
                ContainerRelativeShape()
                    .inset(by: 4)
                    .fill(Color.black)
                
                OrdersWidgetView(title: entry.title, description: entry.description, taskPlanets: entry.taskPlanets, rewardValue: entry.rewardValue, rewardType: entry.rewardType, timeRemaining: entry.timeRemaining)
                
                
            }
            #else
            Text("This is an error, you shouldn't see this.")
            #endif
        }
    }
}

struct Helldivers_Companion_Major_Order_Widget: Widget {
    let kind: String = "Helldivers_Companion_Major_Order_Widget"
    
#if os(watchOS)
    let supportedFamilies: [WidgetFamily] = [.accessoryRectangular, .accessoryInline]
#elseif os(iOS)
    let supportedFamilies: [WidgetFamily] = [.accessoryRectangular, .accessoryInline, .systemMedium, .systemLarge, .systemExtraLarge]
#endif

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MajorOrderProvider()) { entry in
       
                Helldivers_Companion_Major_Order_WidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            
        }
        .configurationDisplayName("Major Order")
        .description("Displays the current major order.")
        .contentMarginsDisabled()
        .supportedFamilies(supportedFamilies)
    }
}
#if os(iOS)
#Preview(as: .systemSmall) {
    Helldivers_Companion_Major_Order_Widget()
} timeline: {
    MajorOrderEntry(date: Date(), title: "Stand by.", description: "Await further orders from Super Earth High Command.", taskPlanets: [], rewardValue: 35, rewardType: 1, timeRemaining: 129600)
}


struct OrdersWidgetView: View {
    
    @Environment(\.widgetFamily) var widgetFamily
    
    var title: String?
    var description: String?
    var taskPlanets: [PlanetStatus]
    var rewardValue: Int?
    var rewardType: Int?
    var timeRemaining: Int64?
    
    var titleSize: CGFloat {
        switch widgetFamily {
        case .systemMedium:
            return 16
        @unknown default:
            return 20
        }
    }
    
    
    var body: some View {
        VStack {
            VStack(spacing: 6) {
                Text(title ?? "Stand by.").font(Font.custom("FS Sinclair", size: titleSize))
                    .foregroundStyle(Color.yellow).textCase(.uppercase)
                    .multilineTextAlignment(.center)
                    .lineLimit(widgetFamily != .systemMedium ? 3 : 2)
                    .padding(.horizontal)
                
                // dont show descript on medium widget
                if let description = description {
                    if widgetFamily != .systemMedium {
                        Text(description).font(Font.custom("FS Sinclair", size: 14))
                            .foregroundStyle(Color.cyan)
                            .padding(5)
                            .padding(.horizontal)
                    }
                        if let majorOrderTimeRemaining = timeRemaining,  majorOrderTimeRemaining > 0 {
                            MajorOrderTimeView(timeRemaining: majorOrderTimeRemaining, isWidget: true)
                                .padding(.bottom, widgetFamily != .systemMedium ? 6 : 0)
                        }
                    
                } else {
                    // but do show it if theres no major order right now
                    Text("Await further orders from Super Earth High Command.").font(Font.custom("FS Sinclair", size: 14))
                        .foregroundStyle(Color.cyan)
                        .padding(5)
                    
                }

                HStack(spacing: 0) {
                    if let majorOrderRewardValue = rewardValue, majorOrderRewardValue > 0 {
                        RewardView(rewardType: rewardType, rewardValue: majorOrderRewardValue, widgetMode: true)
                            .frame(maxWidth: 200)
                    }
                    
                    if !taskPlanets.isEmpty {
                        TasksView(taskPlanets: taskPlanets, isWidget: true)
                            .frame(maxWidth: .infinity)
                    }
                  
                   
                }.padding(.horizontal)
                

                
                
            }.frame(maxHeight: .infinity)
        }
    }
    
    
}
#endif

struct RectangularOrdersTimeLeftView: View {
    
    var timeRemaining: Int64?
    
    var body: some View {

        if let timeRemaining = timeRemaining {
            VStack(alignment: .leading, spacing: 4) {
                Text("Major Order").font(Font.custom("FS Sinclair", size: 16))
                RoundedRectangle(cornerRadius: 25).frame(width: 100, height: 2)
                HStack(spacing: 4) {
                    Text("Ends in").padding(.top, 1).font(Font.custom("FS Sinclair", size: 14))
                    Text("\(formatDuration(seconds: timeRemaining))").font(Font.custom("FS Sinclair", size: 12))
                    #if os(watchOS)
                        .padding(.top, 1.7)
                    #endif
            #if os(iOS)
                        .padding(.top, 2).padding(.horizontal, 8).background(Color.yellow).foregroundStyle(Color.black).clipShape(RoundedRectangle(cornerRadius: 6)).padding(.trailing, 5)
                    #endif
                        
                    
                }.font(Font.custom("FS Sinclair", size: 14))
            }
        } else {
            Text("No Current Major Order").font(Font.custom("FS Sinclair", size: 14))
        }
    }
}

struct InlineOrdersTimeLeftWidget: View {
    
    var timeRemaining: Int64?
    
    var body: some View {
        if let timeRemaining = timeRemaining {
            
            HStack(spacing: 4) {
                Text("MO")
                
                Text("\(formatDuration(seconds: timeRemaining))")
                    
                
            }.font(Font.custom("FS Sinclair", size: 14))
            
        } else {
            Text("Stand by.").font(Font.custom("FS Sinclair", size: 16))
        }
        
    }
}
