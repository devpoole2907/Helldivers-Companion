//
//  SuperStoreList.swift
//  Helldivers Companion
//
//  Created by James Poole on 28/04/2024.
//

import SwiftUI

struct SuperStoreList: View {
    
    @EnvironmentObject var viewModel: PlanetsDataModel
    @EnvironmentObject var dbModel: DatabaseModel
    
    var filteredArmour: [Armour] {
         
        let superStoreNames = dbModel.storeRotation?.items.map { $0.name }
            
        if let names = superStoreNames {
     
            return dbModel.allArmour.uniqued().filter { names.contains($0.name) }
        }
        return []
        }
    
    // find unmatched superstore items
    var unmatchedSuperStoreItems: [StoreItem] {
        let matchedArmourNames = Set(filteredArmour.map { $0.name })
        return dbModel.storeRotation?.items.filter { !matchedArmourNames.contains($0.name) } ?? []
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack {
                
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        
                        AlertView(alert: "Please be advised the SUPERSTORE is an experimental feature.")
                        
                        
                        
                        // display matching filtered armours
                        ForEach(filteredArmour, id: \.id) { armour in
                            NavigationLink(value: armour) {
                                ArmourDetailRow(dashPattern: [57, 19], armour: armour, showWarBondName: false)
                            }
                            .padding(.vertical, 5)
                        }
                        
                        // find unmatched superstore items
                        
                        // display unmatched superstore items as new armours
                        ForEach(unmatchedSuperStoreItems, id: \.name) { item in
                            // create new unknown armour
                            
                            // try find passive id
                            let passiveId = dbModel.passives.first(where: { $0.name.lowercased() == item.passive.name.lowercased() })?.id ?? -1
                            //try find slot id
                            let slotId = dbModel.armourSlots.first(where: { $0.name.lowercased() == item.slot.lowercased() })?.id ?? -1
                            
                            // type is not currently used
                            let unknownArmour = Armour(id: UUID().uuidString, name: item.name, description: item.description, type: 0, slot: slotId, armourRating: item.armorRating, speed: item.speed, staminaRegen: item.staminaRegen, passive: passiveId)
                            
                            NavigationLink(value: unknownArmour) {
                                ArmourDetailRow(dashPattern: [57, 19], armour: unknownArmour, showWarBondName: false)
                            }
                            .padding(.vertical, 5)
                        }
                        
                        
                        
                        
                        
                        
                    }.padding(.horizontal)
                    
                    
                    
                    
                    Spacer(minLength: 150)
                    
                    
                }
                
                
                
                if filteredArmour.isEmpty && unmatchedSuperStoreItems.isEmpty {
                    VStack {
                        Image("truthministry").resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                        
                        Text("These items are awaiting review from the Ministry of Truth.")
                            .foregroundStyle(.white) .font(Font.custom("FSSinclair", size: mediumFont))
                            .multilineTextAlignment(.center)
                    }.padding()
                }
                
                
                
                
            }
            
            Button(action: {
                viewModel.popToWarBonds.send()
            }) {
            
                ZStack {
                    Image("viewwarbonds").resizable()
                        .scaledToFill()
                        .frame(height: 60, alignment: .top)
                        .clipped()
                        .padding(10)
                        .shadow(radius: 3.0)
                        .grayscale(0.5)
                        .brightness(-0.2)
                    
                            Text("VIEW WARBONDS")
                                .foregroundStyle(.white) .font(Font.custom("FSSinclair-Bold", size: mediumFont))
                                .shadow(radius: 3.0)
                                .multilineTextAlignment(.center)
                        
                    
                }

                
            }
                
            
        }
        
        .toolbar {
            
            if let expireDate = dbModel.storeRotation?.expireTime {
                let timeRemaining = expireDate.timeIntervalSince(Date())

                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.footnote)
                        OrderTimeView(timeRemaining: Int64(timeRemaining), isMini: true)
                            .padding(.bottom, 0.5)
                    }
                }
            }
        }
        
        
        .conditionalBackground(viewModel: viewModel, grayscale: true, opacity: 0.6)
        
        
            .navigationDestination(for: Armour.self) { armour in
                
                ItemDetailView(armour: armour)
                
            }
        
            .navigationTitle("Super Store".uppercased())
        
            .inlineLargeTitleiOS17()
        
            .toolbarRole(.editor)
    }
}

#Preview {
    SuperStoreList()
}
