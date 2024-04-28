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
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                
                if dbModel.selectedWeaponCategory == .all || dbModel.selectedWeaponCategory == .primary {
                    Section {
                        ForEach(dbModel.primaryWeapons.filter { weapon in
                            dbModel.searchText.isEmpty || weapon.name.localizedCaseInsensitiveContains(dbModel.searchText)
                        }, id: \.name) { weapon in
                            
                            NavigationLink(value: weapon) {
                                
                                ItemDetailRowView(dashPattern: [57, 19], item: weapon)
                                
                            }      .padding(.vertical, 5)
                            
                        }
                    } header: {
                        Text("Primary".uppercased())
                            .font(Font.custom("FSSinclair-Bold", size: 16))
                            .foregroundStyle(.white).opacity(0.8)
                            .padding(.horizontal)
                            .padding(.bottom, -8)
                        
                    }
                }
                
                if dbModel.selectedWeaponCategory == .all || dbModel.selectedWeaponCategory == .secondary {
                    
                    Section {
                        ForEach(dbModel.secondaryWeapons.filter { weapon in
                            dbModel.searchText.isEmpty || weapon.name.localizedCaseInsensitiveContains(dbModel.searchText)
                        }, id: \.name) { weapon in
                            
                            NavigationLink(value: weapon) {
                                
                                ItemDetailRowView(dashPattern: [57, 19], item: weapon)
                                
                            }      .padding(.vertical, 5)
                            
                        }
                    } header: {
                        Text("Secondary".uppercased())
                            .font(Font.custom("FSSinclair-Bold", size: 16))
                            .foregroundStyle(.white).opacity(0.8)
                            .padding(.horizontal)
                            .padding(.bottom, -8)
                        
                    }
                }
                
                if dbModel.selectedWeaponCategory == .all || dbModel.selectedWeaponCategory == .grenades {
                    
                    Section {
                        ForEach(dbModel.grenades.filter { grenade in
                            dbModel.searchText.isEmpty || grenade.name.localizedCaseInsensitiveContains(dbModel.searchText)
                        }, id: \.name) { grenade in
                            
                            NavigationLink(value: grenade) {
                                
                                
                                ItemDetailRowView(dashPattern: [57, 19], item: grenade)
                                
                            }      .padding(.vertical, 5)
                            
                        }
                    } header: {
                        Text("Grenades".uppercased())
                            .font(Font.custom("FSSinclair-Bold", size: 16))
                            .foregroundStyle(.white).opacity(0.8)
                            .padding(.horizontal)
                            .padding(.bottom, -8)
                        
                    }
                    
                }
                
                
            }.padding(.horizontal)
            
                .animation(.bouncy, value: dbModel.selectedWeaponCategory)
            
            Spacer(minLength: 150)
            
            
        }          .conditionalBackground(viewModel: viewModel, grayscale: true, opacity: 0.6)
        
        
            .navigationTitle("Weapons".uppercased())
        
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    
                    
                    Menu {
                        
                        Picker("Sort", selection: $dbModel.selectedWeaponCategory){
                            ForEach(DatabaseModel.WeaponCategory.allCases) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                        
                        
                    } label: {
                        
                        Image(systemName: "line.horizontal.3.decrease.circle").bold()
                        
                        
                        
                    }
                    
                    
                    
                    
                }
            }
        
            .toolbarRole(.editor)
            .searchable(text: $dbModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Weapons").disableAutocorrection(true)
        
        
          
        
    }
}


struct ItemDetailRowView: View {
    
    @EnvironmentObject var dbModel: DatabaseModel
    
    let dashPattern: [CGFloat]
    let item: DetailItem
    var showWarBondName = true
    
    var body: some View {
        ZStack(alignment: .trailing) {
            Color.gray.opacity(0.2).shadow(radius: 3)
            
            HStack {
                // Display item image if exists
                if UIImage(named: item.name) != nil {
                    Image(uiImage: UIImage(named: item.name)!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    VStack(alignment: .leading, spacing: 0){
                        HStack {
                            
                            Text(item.name.uppercased())
                                .font(Font.custom("FSSinclair-Bold", size: 18))
                                .tint(.white)
                                .padding(.top, 2)
                                .multilineTextAlignment(.leading)
                            
                         
                            
                            
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.gray)
                                .opacity(0.5)
                                .bold()
                            
                            Spacer()
                        }
                        if showWarBondName, let id = Int(item.id), let warBondName = dbModel.warBond(for: id)?.name?.rawValue {
                            Text(warBondName.uppercased()).foregroundStyle(.white).opacity(0.8)  .font(Font.custom("FSSinclair", size: 14))
                                .multilineTextAlignment(.leading)
                        }
                        
                        
                    }
                    
                    HStack {
                     
                        
                        if let grenade = item as? Grenade {
                            
                         
                            ArmourRowStatView(image: "flame.fill", value: grenade.damage)
                            
                            
                            if let penetration = grenade.penetration {
                                ArmourRowStatView(image: "arrow.merge", value: penetration)
                            }
                            if let outerRadius = grenade.outerRadius {
                                ArmourRowStatView(image: "circle.lefthalf.fill", value: outerRadius)
                            }
                            if let fuseTime = grenade.fuseTime {
                                ArmourRowStatView(image: "timer", value: Int(fuseTime))
                            }
                        } else if let weapon = item as? Weapon {
                            ArmourRowStatView(image: "battery.75percent", value: weapon.capacity)
                            ArmourRowStatView(image: "arrow.left.and.right.righttriangle.left.righttriangle.right.fill", value: weapon.recoil)
                            ArmourRowStatView(image: "hare.fill", value: weapon.fireRate)
                        }
                        
                        if let id = Int(item.id), let medalCost = dbModel.itemMedalCost(for: id) {
                            ArmourRowStatView(image: "medalSymbol", value: medalCost, isSystemImage: false)
                                .tint(.white)
                                .bold()
                        }
                        
                        Spacer()
                    }
                }
            }
            .frame(maxWidth: .infinity)
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

