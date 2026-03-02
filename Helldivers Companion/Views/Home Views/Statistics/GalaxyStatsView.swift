//
//  GalaxyStatsView.swift
//  Helldivers Companion
//
//  Created by James Poole on 28/03/2024.
//

import SwiftUI


struct GalaxyStatsView: View {
    
    @Environment(PlanetsDataModel.self) var viewModel
    @Environment(NavigationPather.self) var navPather
    @Environment(DatabaseModel.self) var dbModel
    
    var body: some View {
        @Bindable var navPather = navPather
        NavigationStack(path: $navPather.navigationPath) {
            
            ScrollView {
                VStack(alignment: .leading) {
                    
              
               
                        Section {
                            
                            GalaxyInfoView()
                        }
                        
                        .id(0)
               
                    
                    Section {
                        
                        NavigationLink(value: DatabasePage.bestiary) {
                            
                            
                            DatabaseRow(title: "Bestiary", dashPattern: [54, 13])
                            
                            
                        }.padding(.vertical, 5)
                        
                        NavigationLink(value: DatabasePage.planetList) {
                            
                            DatabaseRow(title: "Planets", dashPattern: [51, 19])
                            
                        }.padding(.vertical, 5)
                        
                        NavigationLink(value: DatabasePage.armourList) {
                            
                            
                            DatabaseRow(title: "Armoury", dashPattern: [69, 16])
                            
                            
                        }.padding(.vertical, 5)
                        
                        NavigationLink(value: DatabasePage.weaponList) {
                            
                            
                            DatabaseRow(title: "Weapons", dashPattern: [58, 17])
                            
                            
                        }.padding(.vertical, 5)
                        
                        NavigationLink(value: DatabasePage.stratList) {
                            
                            
                            DatabaseRow(title: "Stratagems", dashPattern: [54, 13])
                            
                            
                        }.padding(.vertical, 5)
                        
                       
                        
                        NavigationLink(value: DatabasePage.boosterList) {
                            
                            
                            DatabaseRow(title: "Boosters", dashPattern: [64, 12])
                            
                            
                        }.padding(.vertical, 5)
                        
                        NavigationLink(value: DatabasePage.warbondsList) {
                            
                            
                            DatabaseRow(title: "Warbonds", dashPattern: [54, 13])
                            
                            
                        }.padding(.vertical, 5)
                        
                        
                    }
                    
                    
                    
                    
                }.padding(.horizontal)
                
                Spacer(minLength: 150)

                
            }
            

            
            
#if os(iOS)

            // overlay conflicts with searchable
             /*   .overlay(
                    FactionImageView(faction: .human)

                        .padding(.trailing, 20)
                        .offset(x: 0, y: -45)
                    , alignment: .topTrailing)*/
            
            .conditionalBackground(viewModel: viewModel)
            
              //  .inlineLargeTitleiOS17()
            .navigationBarTitleDisplayMode(.inline)
#endif
            
             //   .navigationTitle("Database".uppercased())
            
            
            
                .navigationDestination(for: DatabasePage.self) { value in
                    
                    
                    switch value {
                        
                    case .planetList:
                        PlanetsList()
                    case .stratList:
                        StratagemsList().environment(dbModel)
                    case .armourList:
                        ArmourList()
                    case .weaponList:
                        WeaponsList()
                    case .boosterList:
                        BoostersList().environment(dbModel)
                    case .warbondsList:
                        WarBondsList().environment(dbModel)
                    case .bestiary:
                        EnemiesList().environment(dbModel)
                    
                    }
                   
                 
                    
                }
            
                .navigationDestination(for: Stratagem.self) { strat in
                    
                    StratagemDetailView(stratagem: strat)
                    
                }
            
                .navigationDestination(for: Weapon.self) { weapon in
                    
                    ItemDetailView(weapon: weapon)
                    
                }
            
                .navigationDestination(for: Enemy.self) { enemy in
                    
                    ItemDetailView(enemy: enemy)
                    
                }
            
                .navigationDestination(for: Armour.self) { armour in
                    
                    ItemDetailView(armour: armour)
                    
                }
            
                .navigationDestination(for: Grenade.self) { grenade in
                    
                    ItemDetailView(grenade: grenade)
                    
                }
            
                .navigationDestination(for: FixedWarBond.self) { warbond in
                    WarbondsItemsList(warbond: warbond)
                }
            
            
                .navigationDestination(for: Int.self) { index in
                    PlanetInfoView(planetIndex: index)
                }
            
                .toolbar {
                    
                    ToolbarItem(placement: .principal) {
                        
                        Text("DATABASE")
                            .font(Font.custom("FSSinclair", size: 24)).bold()
                        
                    }
#if os(iOS)
                    
                    
              
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        PlayerCountView().environment(viewModel)
                    }
                    
#endif
                }
            #if os(iOS)
                .toolbarRole(.editor)
            #endif
            
        }
        
        
        
#if os(iOS)
        .helldiversNavigationStyle()
#endif
        
        
    }
}

#if DEBUG
#Preview {
    GalaxyStatsView()
        .environment(PlanetsDataModel(apiService: MockAPIService()))
        .environment(NavigationPather())
        .environment(DatabaseModel())
}
#endif

enum DatabasePage: String, CaseIterable {
    
    case planetList = "Planets"
    case stratList = "Stratagems"
    case armourList = "Armour"
    case weaponList = "Weapons"
    case boosterList = "Boosters"
    case warbondsList = "Warbonds"
    case bestiary = "Bestiary"
    
    
    
}

struct DatabaseRow: View {
    
    let title: String
    let dashPattern: [CGFloat]
    
    var imageName: String?
    
    var body: some View {
        
        ZStack(alignment: .trailing) {
            Color.gray.opacity(0.2)
                .shadow(radius: 3)
            HStack {
                
                if let validImageName = imageName, UIImage(named: validImageName) != nil {
                                   Image(uiImage: UIImage(named: validImageName)!)
                                       .resizable()
                                       .aspectRatio(contentMode: .fit)
                                       .frame(width: 30, height: 30)
                               }
                
                VStack(alignment: .leading, spacing: 0){
                    Text(title.uppercased())
                        .font(Font.custom("FSSinclair-Bold", size: 18))
                        .padding(.top, 2)
                    
                }.tint(.white)
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .opacity(0.5)
                    .bold()
                
                Spacer()
                
            
                
            }.frame(maxWidth: .infinity)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
            
    
            
        }
        
        .dashedRowBackground(dashPattern: dashPattern)
    }
}
