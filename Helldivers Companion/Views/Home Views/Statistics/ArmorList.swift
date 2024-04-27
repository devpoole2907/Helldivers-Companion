//
//  ArmourList.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/04/2024.
//

import SwiftUI

struct ArmourList: View {
    
    @EnvironmentObject var dbModel: DatabaseModel
    @EnvironmentObject var viewModel: PlanetsViewModel
    
    
    // TODO: CHANGE THE DAMN SORTING IN THIS! SPEED RUNNING RN JEEZ
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                
              /*  AlertView(alert: "The Armoury is still under development. Super Earth High Command appreciates your assistance in the development of War Monitor by contacting support via Discord or email to send in additional armour images, and to notify of incorrectly categorised armour.")*/
                
                if dbModel.selectedArmourCategory == .all || dbModel.selectedArmourCategory == .body {
                Section {
                    ForEach(dbModel.chests.filter { armour in
                        dbModel.searchText.isEmpty || armour.name.localizedCaseInsensitiveContains(dbModel.searchText)
                    }.sorted(by: { (lhs, rhs) -> Bool in
                        switch dbModel.sortCriteria {
                        case .staminaRegen:
                            return lhs.staminaRegen > rhs.staminaRegen
                        case .armourRating:
                            return lhs.armourRating > rhs.armourRating
                        case .speed:
                            return lhs.speed > rhs.speed
                        }
                    }), id: \.id) { armour in
                        
                        
                        NavigationLink(value: armour) {
                            
                            ArmourDetailRow(dashPattern: [57, 19], armour: armour)
                            
                     
                            
                        }      .padding(.vertical, 5)
                        
                    }
                } header: {
                    Text("Body".uppercased())
                        .font(Font.custom("FSSinclair-Bold", size: 16))
                        .foregroundStyle(.white).opacity(0.8)
                        .padding(.horizontal)
                        .padding(.bottom, -8)
                        .minimumScaleFactor(0.8)
                }
                
            }
                
                if dbModel.selectedArmourCategory == .all || dbModel.selectedArmourCategory == .helmet {
                    Section {
                        ForEach(dbModel.helmets.filter { armour in
                            dbModel.searchText.isEmpty || armour.name.localizedCaseInsensitiveContains(dbModel.searchText)
                        }.sorted(by: { (lhs, rhs) -> Bool in
                            switch dbModel.sortCriteria {
                            case .staminaRegen:
                                return lhs.staminaRegen > rhs.staminaRegen
                            case .armourRating:
                                return lhs.armourRating > rhs.armourRating
                            case .speed:
                                return lhs.speed > rhs.speed
                            }
                        }), id: \.id) { armour in
                            
                            
                            NavigationLink(value: armour) {
                                
                                ArmourDetailRow(dashPattern: [57, 19], armour: armour)
                                
                            }      .padding(.vertical, 5)
                            
                        }
                    } header: {
                        Text("Helmets".uppercased())
                            .font(Font.custom("FSSinclair-Bold", size: 16))
                            .foregroundStyle(.white).opacity(0.8)
                            .padding(.horizontal)
                            .padding(.bottom, -8)
                            .minimumScaleFactor(0.8)
                    }
                    
                }
                
           
                if dbModel.selectedArmourCategory == .all || dbModel.selectedArmourCategory == .cloak {
                    Section {
                        ForEach(dbModel.cloaks.filter { armour in
                            dbModel.searchText.isEmpty || armour.name.localizedCaseInsensitiveContains(dbModel.searchText)
                        }.sorted(by: { (lhs, rhs) -> Bool in
                            switch dbModel.sortCriteria {
                            case .staminaRegen:
                                return lhs.staminaRegen > rhs.staminaRegen
                            case .armourRating:
                                return lhs.armourRating > rhs.armourRating
                            case .speed:
                                return lhs.speed > rhs.speed
                            }
                        }), id: \.id) { armour in
                            
                            
                            NavigationLink(value: armour) {
                                
                                ArmourDetailRow(dashPattern: [57, 19], armour: armour)
                                
                            }      .padding(.vertical, 5)
                            
                        }
                    } header: {
                        Text("Cloak".uppercased())
                            .font(Font.custom("FSSinclair-Bold", size: 16))
                            .foregroundStyle(.white).opacity(0.8)
                            .padding(.horizontal)
                            .padding(.bottom, -8)
                            .minimumScaleFactor(0.8)
                    }
                }

                    

                
                
            }.padding(.horizontal)
            
                .animation(.bouncy, value: dbModel.selectedArmourCategory)
                .animation(.bouncy, value: dbModel.sortCriteria)
            
            Spacer(minLength: 150)
            
            
        }         .conditionalBackground(viewModel: viewModel, grayscale: true, opacity: 0.6)
        
        
            .navigationTitle("Armoury".uppercased())
        
            .toolbar {
                       ToolbarItem(placement: .topBarTrailing) {
                           
                           
                           Menu {
                               
                               Picker("Category", selection: $dbModel.selectedArmourCategory){
                                   ForEach(DatabaseModel.ArmourCategory.allCases) { category in
                                       Text(category.rawValue).tag(category)
                                   }
                               }
                               
                               Picker("Sort By", selection: $dbModel.sortCriteria) {
                                   ForEach(DatabaseModel.ArmourSortCriteria.allCases) { criteria in
                                               Text(criteria.rawValue).tag(criteria)
                                           }
                                       }
                               
                               
                           } label: {
                               
                               Image(systemName: "line.horizontal.3.decrease.circle").bold()
                               
                           
                               
                           }
                           
                         
                        
                           
                       }
                   }


            .toolbarRole(.editor)
            .searchable(text: $dbModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Armoury").disableAutocorrection(true)
    
          
    }
}

struct ArmourRowStatView: View {
    
    let image: String
    let value: Int
    
    var isSystemImage = true
    
    var body: some View {
        
        HStack(spacing: 2) {
            
            if isSystemImage {
                Image(systemName: image)
                    .font(.footnote)
            } else {

                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 12, height: 12)
                    .padding(.bottom, 1)
            }
            
            Text("\(value)")
            
                .font(Font.custom("FSSinclair", size: 14))
            
        }
        
        
    }
    
    
    
}

struct ArmourDetailRow: View {
    
    @EnvironmentObject var dbModel: DatabaseModel
    
    let dashPattern: [CGFloat]
    let armour: Armour
    var showWarBondName = true
    
    var body: some View {
        
        ZStack(alignment: .trailing) {
            Color.gray.opacity(0.2)
                .shadow(radius: 3)
            
            HStack {
                
                if UIImage(named: armour.id) != nil {
                    Image(uiImage: UIImage(named: armour.id)!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                }
                
            VStack(alignment: .leading, spacing: 2) {
                VStack(alignment: .leading, spacing: 0){
                    HStack {
                        
                        
                        
                        
                        Text(armour.name.uppercased())
                            .font(Font.custom("FSSinclair-Bold", size: 18))
                            .padding(.top, 2)
                            .tint(.white)
                        
                      
                        
                        
                        
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.gray)
                            .opacity(0.5)
                            .bold()
                        
                        Spacer()
                        
                        
                        
                    }
                    
                    if showWarBondName, let id = Int(armour.id), let warBondName = dbModel.warBond(for: id)?.name?.rawValue {
                        Text(warBondName.uppercased()).foregroundStyle(.white).opacity(0.8)  .font(Font.custom("FSSinclair", size: 14))
                    }
                    
                }
                
                HStack {
                    
                    ArmourRowStatView(image: "shield.fill", value: armour.armourRating)
                    
                    ArmourRowStatView(image: "figure.run", value: armour.speed)
                    
                    ArmourRowStatView(image: "bolt.fill", value: armour.staminaRegen)
                    
                    if let id = Int(armour.id), let medalCost = dbModel.itemMedalCost(for: id) {
                        ArmourRowStatView(image: "medalSymbol", value: medalCost, isSystemImage: false).tint(.white).bold()
                    }
                    
                    // add armour row stat view with "superCredit" as the image
                    
                    if let cost = dbModel.storeCost(for: armour.name) {
                        ArmourRowStatView(image: "superCredit", value: cost, isSystemImage: false).tint(.white).bold()
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
