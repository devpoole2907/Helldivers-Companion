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
                
                AlertView(alert: "The Super Store is currently under development - please be aware that you may encounter some issues. We appreciate your patience, and welcome any feedback!")
         
           /*     if let storeItems = dbModel.storeRotation?.items {
                                   ForEach(storeItems, id: \.name) { item in
                                       Text(item.name)
                                           .padding(.vertical, 2)
                                   }
                               } else {
                                   Text("No items in store rotation.")
                               }
                
 */
                                        ForEach(filteredArmour, id: \.id) { armour in
                                            NavigationLink(value: armour) {
                                                ArmourDetailRow(dashPattern: [57, 19], armour: armour, showWarBondName: false)
                                            }
                                            .padding(.vertical, 5)
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
