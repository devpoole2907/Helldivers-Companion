//
//  WeaponsList.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/04/2024.
//

import SwiftUI

struct WeaponsList: View {
    
    @EnvironmentObject var dbModel: DatabaseModel
    @EnvironmentObject var viewModel: PlanetsViewModel
    
    @State private var searchText = ""
    @State private var selectedCategory: WeaponCategory = .all

      enum WeaponCategory: String, CaseIterable, Identifiable {
          case all = "All"
          case primary = "Primary"
          case secondary = "Secondary"
          case grenades = "Grenades"
          
          var id: String { self.rawValue }
      }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                
                if selectedCategory == .all || selectedCategory == .primary {
                    Section {
                        ForEach(dbModel.primaryWeapons.filter { weapon in
                            searchText.isEmpty || weapon.name.localizedCaseInsensitiveContains(searchText)
                        }, id: \.name) { weapon in
                            
                            NavigationLink(value: weapon) {
                                
                                DatabaseRow(title: weapon.name == "SG-225SP Breaker Spray&Pra" ? "SG-225SP Breaker Spray&Pray" : weapon.name, dashPattern: [57, 19])
                                
                            }      .padding(.vertical, 5)
                            
                        }
                    } header: {
                        Text("Primary".uppercased())
                            .font(Font.custom("FSSinclair-Bold", size: 16))
                            .foregroundStyle(.gray)
                            .padding(.horizontal)
                            .padding(.bottom, -8)
                        
                    }
                }
                
                if selectedCategory == .all || selectedCategory == .secondary {
                    
                    Section {
                        ForEach(dbModel.secondaryWeapons.filter { weapon in
                            searchText.isEmpty || weapon.name.localizedCaseInsensitiveContains(searchText)
                        }, id: \.name) { weapon in
                            
                            NavigationLink(value: weapon) {
                                
                                DatabaseRow(title: weapon.name, dashPattern: [57, 19])
                                
                            }      .padding(.vertical, 5)
                            
                        }
                    } header: {
                        Text("Secondary".uppercased())
                            .font(Font.custom("FSSinclair-Bold", size: 16))
                            .foregroundStyle(.gray)
                            .padding(.horizontal)
                            .padding(.bottom, -8)
                        
                    }
                }
                    
                if selectedCategory == .all || selectedCategory == .grenades {
                    
                    Section {
                        ForEach(dbModel.grenades.filter { grenade in
                            searchText.isEmpty || grenade.name.localizedCaseInsensitiveContains(searchText)
                        }, id: \.name) { grenade in
                            
                            NavigationLink(value: grenade) {
                                
                                DatabaseRow(title: grenade.name, dashPattern: [57, 19])
                                
                            }      .padding(.vertical, 5)
                            
                        }
                    } header: {
                        Text("Grenades".uppercased())
                            .font(Font.custom("FSSinclair-Bold", size: 16))
                            .foregroundStyle(.gray)
                            .padding(.horizontal)
                            .padding(.bottom, -8)
                        
                    }
                    
                }
                
                
            }.padding(.horizontal)
            
                .animation(.bouncy, value: selectedCategory)
            
            Spacer(minLength: 150)
            
            
        }      .conditionalBackground(viewModel: viewModel)
        
        
            .navigationTitle("Weapons".uppercased())
        
            .toolbar {
                       ToolbarItem(placement: .topBarTrailing) {
                           
                           
                           Menu {
                               
                               Picker("Sort", selection: $selectedCategory){
                                   ForEach(WeaponCategory.allCases) { category in
                                       Text(category.rawValue).tag(category)
                                   }
                               }
                               
                               
                           } label: {
                               
                               Image(systemName: "line.horizontal.3.decrease.circle").bold()
                               
                           
                               
                           }
                           
                         
                        
                           
                       }
                   }
            
            #if os(iOS)
            .toolbarRole(.editor)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Weapons").disableAutocorrection(true)
            #endif
        
            .navigationDestination(for: Weapon.self) { weapon in
                
                WeaponInfoView(weapon: weapon)
                
            }
        
            .navigationDestination(for: Grenade.self) { grenade in
                
                WeaponInfoView(grenade: grenade)
                
            }
        
    }
}


