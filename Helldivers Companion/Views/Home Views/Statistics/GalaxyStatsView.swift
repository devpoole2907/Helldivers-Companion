//
//  GalaxyStatsView.swift
//  Helldivers Companion
//
//  Created by James Poole on 28/03/2024.
//

import SwiftUI
#if os(iOS)
import SwiftUIIntrospect
#endif

struct GalaxyStatsView: View {
    
    @EnvironmentObject var viewModel: PlanetsDataModel
    @EnvironmentObject var navPather: NavigationPather
    @EnvironmentObject var dbModel: DatabaseModel
    
    var body: some View {
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
                        StratagemsList().environmentObject(dbModel)
                    case .armourList:
                        ArmourList()
                    case .weaponList:
                        WeaponsList()
                    case .boosterList:
                        BoostersList().environmentObject(dbModel)
                    case .warbondsList:
                        WarBondsList().environmentObject(dbModel)
                    case .bestiary:
                        EnemiesList().environmentObject(dbModel)
                    
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
                        PlayerCountView().environmentObject(viewModel)
                    }
                    
#endif
                }
            #if os(iOS)
                .toolbarRole(.editor)
            #endif
            
        }
        
        
        
#if os(iOS)
        .introspect(.navigationStack, on: .iOS(.v16, .v17, .v18)) { controller in
            print("I am introspecting!")
            
            DispatchQueue.main.async {
                let largeFontSize: CGFloat = UIFont.preferredFont(forTextStyle: .largeTitle).pointSize
                let inlineFontSize: CGFloat = UIFont.preferredFont(forTextStyle: .body).pointSize
                
                // default to sf system font
                let largeFont = UIFont(name: "FSSinclair-Bold", size: largeFontSize) ?? UIFont.systemFont(ofSize: largeFontSize, weight: .bold)
                let inlineFont = UIFont(name: "FSSinclair-Bold", size: inlineFontSize) ?? UIFont.systemFont(ofSize: inlineFontSize, weight: .bold)
                
                
                let largeAttributes: [NSAttributedString.Key: Any] = [
                    .font: largeFont
                ]
                
                let inlineAttributes: [NSAttributedString.Key: Any] = [
                    .font: inlineFont
                ]
                
                controller.navigationBar.titleTextAttributes = inlineAttributes
                
                controller.navigationBar.largeTitleTextAttributes = largeAttributes
                
            }
            
        }
        
#endif
        
        
    }
}

#Preview {
    GalaxyStatsView().environmentObject(PlanetsDataModel()).environmentObject(NavigationPather())
}

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
        
        .background {
            
            Rectangle().stroke(style: StrokeStyle(lineWidth: 3, dash: dashPattern))
                .foregroundStyle(.gray)
                .opacity(0.5)
                .shadow(radius: 3)
            
        }
    }
    
    
    
    
}
