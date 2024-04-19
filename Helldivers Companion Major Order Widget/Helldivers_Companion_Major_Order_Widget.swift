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
        MajorOrderEntry(date: Date(), majorOrder: nil, taskPlanets: [], eradicationProgress: nil, factionColor: .yellow, progressString: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (MajorOrderEntry) -> ()) {
        let entry = MajorOrderEntry(date: Date(), majorOrder: nil, taskPlanets: [], eradicationProgress: nil, factionColor: .yellow, progressString: nil)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [MajorOrderEntry] = []
        
        // TODO: CHANGE TO GET ALL PLANETS NOT JUST CURRENT CAMPAIGNS
        
        let urlString = "https://raw.githubusercontent.com/devpoole2907/helldivers-api-cache/main/newData/currentPlanets.json"

        planetsModel.fetchConfig() { config in
            
            planetsModel.fetchUpdatedPlanets(using: urlString) { planets in
                
                
                planetsModel.fetchMajorOrder(for: config?.season ?? "801", with: planets) { taskPlanets, order in
                    
                    let entry = MajorOrderEntry(date: Date(), majorOrder: order, taskPlanets: taskPlanets, eradicationProgress: order?.eradicationProgress, factionColor: order?.faction.color, progressString: order?.progressString)
                    
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
    let majorOrder: MajorOrder?
    let taskPlanets: [UpdatedPlanet]
    let eradicationProgress: Double?
    let factionColor: Color?
    let progressString: String?
}

struct Helldivers_Companion_Major_Order_WidgetEntryView : View {
    
    @Environment(\.widgetFamily) var widgetFamily
    
    var entry: MajorOrderProvider.Entry

    var body: some View {
        
        switch widgetFamily {
            
        case .accessoryRectangular:
            RectangularOrdersTimeLeftView(timeRemaining: entry.majorOrder?.expiresIn)
                .widgetAccentable()
                
                .padding(.leading, 5)
                    .padding(.vertical, 2)
                //background breaks the watch version
                #if os(iOS)
                    .background(in: RoundedRectangle(cornerRadius: 5.0))
                #endif
            
        case .accessoryInline:
            InlineOrdersTimeLeftWidget(timeRemaining: entry.majorOrder?.expiresIn)
                .widgetAccentable()
        
        default:
            #if os(iOS)
            ZStack {
                
                Color(.cyan).opacity(0.6)
                
                ContainerRelativeShape()
                    .inset(by: 4)
                    .fill(Color.black)
                
                OrdersWidgetView(title: entry.majorOrder?.setting.taskDescription, description: entry.majorOrder?.setting.overrideBrief, taskPlanets: entry.taskPlanets, rewardValue: entry.majorOrder?.setting.reward.amount, rewardType: entry.majorOrder?.setting.reward.type, timeRemaining: entry.majorOrder?.expiresIn, eradicationProgress: entry.eradicationProgress, factionColor: entry.factionColor, progressString: entry.progressString)
                
                
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
            
                
            if #available(iOSApplicationExtension 17.0, *) {
                Helldivers_Companion_Major_Order_WidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
                
                // for deeplinking to major order popup
                    .widgetURL(URL(string: "helldiverscompanion://orders"))
            } else {
                Helldivers_Companion_Major_Order_WidgetEntryView(entry: entry)
                
                // for deeplinking to major order popup
                    .widgetURL(URL(string: "helldiverscompanion://orders"))
            }
            
        }
        .configurationDisplayName("Major Order")
        .description("Displays the current major order.")
        .contentMarginsDisabled()
        .supportedFamilies(supportedFamilies)
    }
}
#if os(iOS)
@available(iOS 17.0, *)
#Preview(as: .systemSmall) {
    Helldivers_Companion_Major_Order_Widget()
} timeline: {
    MajorOrderEntry(date: Date(), majorOrder: nil, taskPlanets: [], eradicationProgress: nil, factionColor: .yellow, progressString: nil)
}

// this needs to be rewritten more in line with the different types of major orders
struct OrdersWidgetView: View {
    
    @Environment(\.widgetFamily) var widgetFamily
    
    var title: String?
    var description: String?
    var majorOrder: MajorOrder?
    var taskPlanets: [UpdatedPlanet]
    var rewardValue: Int?
    var rewardType: Int?
    var timeRemaining: Int64?
    var eradicationProgress: Double?
    var factionColor: Color?
    var progressString: String?
    
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
                Text(title ?? "Stand by.").font(Font.custom("FSSinclair", size: titleSize))
                    .foregroundStyle(Color.yellow).textCase(.uppercase)
                    .multilineTextAlignment(.center)
                    .lineLimit(widgetFamily != .systemMedium ? 3 : 2)
                    .padding(.horizontal)
                
                // dont show descript on medium widget
                if let description = description {
                    if widgetFamily != .systemMedium {
                        Text(description).font(Font.custom("FSSinclair", size: 14))
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
                    Text("Await further orders from Super Earth High Command.").font(Font.custom("FSSinclair", size: 14))
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
                    }  else if let eradicationProgress = eradicationProgress, let barColor = factionColor, let progressString = progressString {
                        
                        
                        // eradicate campaign
                        ZStack {
                            RectangleProgressBar(value: eradicationProgress, primaryColor: .cyan, secondaryColor: barColor)
                                .frame(height: 16)
                            
                            Text("\(progressString)").font(Font.custom("FSSinclair", size: 8)).foregroundStyle(.black)
                                .allowsTightening(true)
                                
                            
                            
                        }.padding(.bottom, 10)
                            .padding(.horizontal, 14)
                    }
                  
                   
                }.padding(.horizontal)
                

                
                
            }.frame(maxHeight: .infinity)
        }
    }
    
    
}
#endif

struct RectangularOrdersTimeLeftView: View {
    
    var timeRemaining: Int64?
    
#if os(iOS)
let headersFont: CGFloat = 16
let secondFont: CGFloat = 14
    let durationFont: CGFloat = 12
#else
let headersFont: CGFloat = 22
let secondFont: CGFloat = 18
    let durationFont: CGFloat = 14
#endif
    
    var body: some View {

        if let timeRemaining = timeRemaining {
            HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Major Order").font(Font.custom("FSSinclair", size: headersFont)).bold()
                RoundedRectangle(cornerRadius: 25).frame(width: 100, height: 2)
                HStack(spacing: 4) {
                    Text("Ends in").padding(.top, 1).font(Font.custom("FSSinclair", size: secondFont))
                    Text("\(formatDuration(seconds: timeRemaining))").font(Font.custom("FSSinclair", size: durationFont)).bold()
#if os(watchOS)
                        .padding(.top, 1.7)
#endif
#if os(iOS)
                        .padding(.top, 2).padding(.horizontal, 8).background(Color.yellow).foregroundStyle(Color.black).clipShape(RoundedRectangle(cornerRadius: 6)).padding(.trailing, 5)
#endif
                    
                    
                }.font(Font.custom("FSSinclair", size: secondFont))
            }
            
            Spacer()
        }
        } else {
            Text("No Current\nMajor Order").padding(.trailing, 6).font(Font.custom("FSSinclair", size: 18)).bold()
                .multilineTextAlignment(.center)
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
                    
                
            }.font(Font.custom("FSSinclair", size: 14))
            
        } else {
            Text("Stand by.").font(Font.custom("FSSinclair", size: 16))
        }
        
    }
}
