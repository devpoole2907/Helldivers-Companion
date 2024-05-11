//
//  WarBondsList.swift
//  Helldivers Companion
//
//  Created by James Poole on 27/04/2024.
//

import SwiftUI

struct WarBondsList: View {
    @EnvironmentObject var dbModel: DatabaseModel
    @EnvironmentObject var viewModel: PlanetsViewModel
    
    // TODO: WAR BOND FETCHES SHOULD BE DYNAMIC
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                
                ZStack(alignment: .bottom) {
                    WarBondRow(warBondImageName: "polar patriots")
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .black]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .blendMode(.multiply)
                    Text("COMING SOON").foregroundStyle(.white).bold()
                        .font(Font.custom("FSSinclair-Bold", size: 24))
                        .padding(10)
                    
                    
                }
         
                    
                if let cuttingEdge = dbModel.cuttingEdge {
                    NavigationLink(value: cuttingEdge) {
                        //  different for cuttting edge due to image issue, duct tape fix
                        if let warbondName = cuttingEdge.warbondPages.first?.name?.rawValue {
                            WarBondRow(warBondImageName: "cuttingedge")
                        }
                    }
                }
                
                if let steeledVeterans = dbModel.steeledVeterans {
                    NavigationLink(value: steeledVeterans) {
                        if let warbondName = steeledVeterans.warbondPages.first?.name?.rawValue {
                            WarBondRow(warBondImageName: warbondName.lowercased())
                        }
                    }
                }
                
                if let helldiversMobilize = dbModel.helldiversMobilize {
                    NavigationLink(value: helldiversMobilize) {
                        if let warbondName = helldiversMobilize.warbondPages.first?.name?.rawValue {
                            WarBondRow(warBondImageName: warbondName.lowercased())
                        }
                    }
                }
                
                if let democraticDetonation = dbModel.democraticDetonation {
                    NavigationLink(value: democraticDetonation) {
                        if let warbondName = democraticDetonation.warbondPages.first?.name?.rawValue {
                            WarBondRow(warBondImageName: warbondName.lowercased())
                        }
                    }
                }
                
                
                
                
            }.padding(.horizontal)
            
   
            
            Spacer(minLength: 150)
            
            
        }          .conditionalBackground(viewModel: viewModel, grayscale: true, opacity: 0.6)
        
        
            .navigationTitle("Warbonds".uppercased())
        
            .toolbarRole(.editor)
        
    }
}

struct WarBondRow: View {
    
    let warBondImageName: String
    
    var body: some View {
        Image(warBondImageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: .infinity)
            .shadow(radius: 3.0)
    }
    
    
}

struct WarbondsItemsList: View {
    
    @EnvironmentObject var dbModel: DatabaseModel
    @EnvironmentObject var viewModel: PlanetsViewModel
    
    let warbond: FixedWarBond
    
    var warbondName: String? {
        return warbond.warbondPages.first?.name?.rawValue
    }
    
    var body: some View {
        
        
        // TODO: ITEMS SHOULD ACTUALLY BE STORED WITH THEIR ASSOCIATED WARBOND
        // LITERALLY EVERYTHING ABOUT WARBONDS IN THIS APP IS SO FKED UP BACK HERE .....
        ScrollView {
            LazyVStack(alignment: .leading) {
         
                    
                ForEach(warbond.warbondPages.sorted(by: { $0.medalsToUnlock < $1.medalsToUnlock }), id: \.id) { warBond in
                                    Section {
                          
                                        ForEach(dbModel.allWeapons.filter { weapon in
                                            warBond.items.contains(where: { $0.itemId == Int(weapon.id) })
                                        }, id: \.id) { weapon in
                                            NavigationLink(value: weapon) {
                                                ItemDetailRowView(dashPattern: [57, 19], item: weapon, showWarBondName: false)
                                            }
                                            .padding(.vertical, 5)
                                        }

                                  
                                        ForEach(dbModel.grenades.filter { grenade in
                                            warBond.items.contains(where: { $0.itemId == Int(grenade.id) })
                                        }, id: \.id) { grenade in
                                            NavigationLink(value: grenade) {
                                                ItemDetailRowView(dashPattern: [57, 19], item: grenade, showWarBondName: false)
                                            }
                                            .padding(.vertical, 5)
                                        }
                                        
                                        ForEach(dbModel.allArmour.filter { armour in
                                            warBond.items.contains(where: { $0.itemId == Int(armour.id) })
                                        }, id: \.id) { armour in
                                            NavigationLink(value: armour) {
                                                ArmourDetailRow(dashPattern: [57, 19], armour: armour, showWarBondName: false)
                                            }
                                            .padding(.vertical, 5)
                                        }
                                        
                                        ForEach(dbModel.boosters.filter { booster in
                                            warBond.items.contains(where: { $0.itemId == Int(booster.id) })
                                        }, id: \.id) { booster in
                                            
                                            
                                            BoosterRow(booster: booster, dashPattern: [64, 13], showWarBondName: false)
                                                .padding(.vertical, 5)
                                            
                                        }
                                        

                                     
                                    } header: {
                                        HStack(spacing: 2) {
                                            Image("medalSymbol")
                                                .resizable().aspectRatio(contentMode: .fit)
                                                .frame(width: 22, height: 22)
                                                .padding(.bottom, 1)
                                            Text("\(warBond.medalsToUnlock)") .foregroundStyle(.white).bold()
                                                .font(Font.custom("FSSinclair-Bold", size: 18))
                                        }
                                   
                                    }
                                }
                
                
            }.padding(.horizontal)
          
            
           
            
            Spacer(minLength: 150)
            
            
        }          .conditionalBackground(viewModel: viewModel, grayscale: true, opacity: 0.6)
        
        
        
            .navigationTitle(warbondName?.uppercased() ?? "Warbond".uppercased())
            .navigationBarTitleDisplayMode((warbondName ?? "").count > 15 ? .inline : .automatic)
        
            .toolbarRole(.editor)
        
        
    }
    
    
}
