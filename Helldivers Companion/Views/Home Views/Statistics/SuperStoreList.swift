//
//  SuperStoreList.swift
//  Helldivers Companion
//
//  Created by James Poole on 28/04/2024.
//

import SwiftUI

struct SuperStoreList: View {
    
    @EnvironmentObject var viewModel: PlanetsViewModel
    @EnvironmentObject var dbModel: DatabaseModel
    
    var filteredArmour: [Armour] {
         
        let superStoreNames = dbModel.storeRotation?.items.map { $0.name }
            
        if let names = superStoreNames {
     
            return dbModel.allArmour.uniqued().filter { names.contains($0.name) }
        }
        return []
        }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                
              /*  AlertView(alert: "The Super Store is currently under development - please be aware that you may encounter some issues. We appreciate your patience, and welcome any feedback!")*/
                
             
                              let superStoreItems = dbModel.storeRotation?.items ?? []
                
                
                ForEach(superStoreItems, id: \.id) { item in
                    // try find matching armour in db
                    if let armour = dbModel.allArmour.first(where: { $0.name == item.name }) {
                        NavigationLink(value: armour) {
                            ArmourDetailRow(dashPattern: [57, 19], armour: armour, showWarBondName: false)
                        }
                        .padding(.vertical, 5)
                        
                    } else {
                        
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
                    
                }

               
                
                
            }.padding(.horizontal)
          
            
           
            
            Spacer(minLength: 150)
            
            
        }        
        
        .toolbar {
            
            if let expireDate = dbModel.storeRotation?.expireTime {
                let timeRemaining = expireDate.timeIntervalSince(Date())

                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.footnote)
                        MajorOrderTimeView(timeRemaining: Int64(timeRemaining), isMini: true)
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
