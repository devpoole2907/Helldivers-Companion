//
//  ItemDetailView.swift
//  Helldivers Companion
//
//  Created by James Poole on 25/04/2024.
//

import SwiftUI

struct ItemDetailView: View {
    
    @EnvironmentObject var viewModel: PlanetsViewModel
    @EnvironmentObject var dbModel: DatabaseModel
   

    
    var weapon: Weapon? = nil
    
    var grenade: Grenade? = nil
    
    var armour: Armour? = nil
    
    var itemName: String {
        
        if let weapon = weapon {
            return weapon.name
        } else if let grenade = grenade {
            return grenade.name
        } else if let armour = armour {
            return armour.name
        }
        
        return "Error"
        
    }
    
    var itemId: String? {
        
        if let weapon = weapon {
            return weapon.id
        } else if let grenade = grenade {
            return grenade.id
        } else if let armour = armour {
            return armour.id
        }
        
        return nil
        
    }
    
    var weaponType: WeaponType? {
        
        if let weaponType = weapon?.type {
            return dbModel.types.first(where: { $0.id == weaponType })
        }
        
        return nil
        
    }
    
    var slot: ArmourSlot? {
        
        if let armourSlot = armour?.slot {
            return dbModel.armourSlots.first(where: { $0.id == armourSlot })
        }
        
        return nil
        
    }
    
    var passive: Passive? {
        
        if let passive = armour?.passive {
            return dbModel.passives.first(where: { $0.id == passive })
        }
        return nil
    }
    
    enum ItemType: CaseIterable {
        
        case armour
        case grenade
        case weapon
        
        
    }
    
    enum WarBondName: String, CaseIterable {
        
        case cuttingEdge = "Cutting Edge"
        case steeledVeterans = "Steeled Veterans"
        case helldiversMobilize = "Helldivers Mobilize"
        case democraticDetonation = "Democratic Detonation"
        
    }
    
    var itemType: ItemType {
        
        if grenade != nil {
            return .grenade
        } else if armour != nil {
            return .armour
        } else {
            return .weapon
        }
        
    }
    
    var description: String? {
        
        if let weaponDescription = weapon?.description {
            return weaponDescription
        }
        
        if let grenadeDescription = grenade?.description {
            return grenadeDescription
        }
        
        if let armourDescription = armour?.description {
            return armourDescription
        }
        
        return nil
    }
    

       var warBond: WarBond? {
           guard let itemId = itemId, let id = Int(itemId) else { return nil }
           return dbModel.warBond(for: id)
       }
       
       // Get the item medal cost for this item
       var itemMedalCost: Int? {
           guard let itemId = itemId, let id = Int(itemId) else { return nil }
           return dbModel.itemMedalCost(for: id)
       }
    
    var body: some View {
        ScrollView {
            
            VStack(alignment: .center) {
                
                if UIImage(named: itemType != .armour ? itemName : armour?.id ?? "") != nil {
                    
                    
                    Image(itemType != .armour ? itemName : armour?.id ?? "")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    
                        .frame(width: itemType == .armour ? 200 : 240)
                        .frame(maxHeight: itemType == .armour ? 160 : 200)
                        .offset(x: itemType == .grenade ? -5 : 0)
                    
                }
                
                
                HStack(spacing: 18) {
                    
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundStyle(.yellow)
                        .frame(width: 4)
                    
                    VStack(alignment: .leading) {
                        
                        if let weaponType = weaponType {
                            Text("\(weaponType.name)").foregroundStyle(.gray).bold()
                            
                        } else if let slot = slot {
                            Text("\(slot.name)").foregroundStyle(.gray).bold()
                        }
                        
                        
                        if let description = description {
                            Text(description).foregroundStyle(.white)
                        }
                        
                        
                    }.font(Font.custom("FSSinclair", size: 20))
                    
                }.padding()

                if let warBond = warBond, let itemMedalCost = itemMedalCost {
                    
                    
                    ItemDetailCostView(name: warBond.name?.rawValue, image: "medalSymbol", cost: itemMedalCost)
                    
                } else if let itemCreditCost = dbModel.storeCost(for: itemName) {
                    
                    ItemDetailCostView(name: "Super Store", image: "superCredit", cost: itemCreditCost)
                }
                
   
                
            
                
                
                ZStack(alignment: .topLeading) {
                    Color.gray.opacity(0.2)
                        .shadow(radius: 3)
                    VStack(spacing: 24) {
                        
                        if let weaponDamage = weapon?.damage {
                            WeaponStatRow(title: "DAMAGE", value: Double(weaponDamage))
                        }
                        
                        if let capacity = weapon?.capacity {
                            WeaponStatRow(title: "CAPACITY", value: Double(capacity))
                        }
                        
                        
                        if let recoil = weapon?.recoil {
                            WeaponStatRow(title: "RECOIL", value: Double(recoil))
                        }
                        
                        if let fireRate = weapon?.fireRate {
                            WeaponStatRow(title: "FIRE RATE", value: Double(fireRate))
                        }
                        
                        if let grenadeDamage = grenade?.damage {
                            WeaponStatRow(title: "DAMAGE", value: Double(grenadeDamage))
                        }
                        
                        if let penetration = grenade?.penetration {
                            WeaponStatRow(title: "PENETRATION", value: Double(penetration))
                        }
                        
                        if let outerRadius = grenade?.outerRadius {
                            WeaponStatRow(title: "OUTER RADIUS", value: Double(outerRadius))
                        }
                        
                        if let fuseTime = grenade?.fuseTime {
                            WeaponStatRow(title: "FUSE TIME", value: fuseTime)
                        }
                        
                        if let rating = armour?.armourRating {
                            WeaponStatRow(title: "ARMOR RATING", value: Double(rating))
                        }
                        
                        if let speed = armour?.speed {
                            WeaponStatRow(title: "SPEED", value: Double(speed))
                        }
                        
                        if let regen = armour?.staminaRegen {
                            WeaponStatRow(title: "STAMINA REGEN", value: Double(regen))
                        }
                        
                    }  .font(Font.custom("FSSinclair", size: 20))
                    
                        .padding()
                    
                    
                        .background {
                            
                            Rectangle().stroke(style: StrokeStyle(lineWidth: 3, dash: dashPattern, dashPhase: 30))
                                .foregroundStyle(.gray)
                                .opacity(0.5)
                                .shadow(radius: 3)
                            
                        }
                    
                    Text("STATS").offset(x: 20, y: -12).font(Font.custom("FSSinclair", size: 20)).bold().foregroundStyle(.white).opacity(0.8).shadow(radius: 5.0)
                    
                }.shadow(radius: 3.0)
                    .padding()
                
                
                if itemType != .grenade {
                ZStack(alignment: .topLeading) {
                    Color.gray.opacity(0.2)
                        .shadow(radius: 3)
                    VStack(alignment: .leading, spacing: 24) {
                        
                        
                        if itemType == .weapon {
                            if let traits = weapon?.traits {
                                ForEach(traits, id: \.self) { trait in
                                    
                                    if let trait = dbModel.traits.first(where: { $0.id == trait }) {
                                        HStack {
                                            
                                            RoundedRectangle(cornerRadius: 14)
                                                .foregroundStyle(.white)
                                                .frame(width: 2)
                                            
                                            Text(trait.description).foregroundStyle(.white).bold()
                                            
                                            Spacer()
                                            
                                        }
                                    }
                                    
                                }
                                
                            }
                            
                        } else { // armor passive
                            
                            if let passive = passive {
                                
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("\(passive.name.uppercased())").bold()
                                            .multilineTextAlignment(.leading)
                                        
                                        Text("\(passive.description)")
                                            .multilineTextAlignment(.leading)
                                        
                                    }
                                    Spacer()
                                }
                            }
                            
                            
                        }
                        
                    }  .font(Font.custom("FSSinclair", size: 20))
                    
                        .padding()
                    
                    
                        .background {
                            
                            Rectangle().stroke(style: StrokeStyle(lineWidth: 3, dash: dashPattern, dashPhase: 30))
                                .foregroundStyle(.gray)
                                .opacity(0.5)
                                .shadow(radius: 3)
                            
                        }
                    
                    Text(itemType == .weapon ? "WEAPON TRAITS" : "ARMOUR PASSIVE").offset(x: 20, y: -12).font(Font.custom("FSSinclair", size: 20)).bold().foregroundStyle(.white).opacity(0.8).shadow(radius: 5.0)
                    
                }.shadow(radius: 3.0)
                    .padding()
                
            }
            
                
                Text("Images from https://divers.gg, Helldivers 2 Wiki, and https://helldiverscompanion.app - go check them out!").textCase(.uppercase)
                    .opacity(0.5)
                    .foregroundStyle(.gray)
                    .font(Font.custom("FSSinclair-Bold", size: smallFont))
                    .padding()
                    .multilineTextAlignment(.center)
                
                
            }.padding()

        }
        
        .toolbar {
            
            if UIImage(named: itemType != .armour ? itemName : armour?.id ?? "") != nil {
                
                ToolbarItem(placement: .topBarTrailing) {
                    Image(itemType == .armour ? itemId ?? "" : itemName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                }
                
            }
            
            
        }
        
        .conditionalBackground(viewModel: viewModel, grayscale: true, opacity: 0.6)
        
        .toolbarRole(.editor)
        .navigationTitle(itemName)
        .navigationBarTitleDisplayMode(itemName.count > 15 ? .inline : .automatic)
    }
}

struct WeaponStatRow: View {
    
    let title: String
    let value: Double
    
    var body: some View {
        HStack {
            Text(title).foregroundStyle(.white).opacity(0.8)
            
            Spacer()
            Text("\(String(format: "%.1f", value))")         .foregroundStyle(.white).bold()
            
        }
    }
    
    
}



struct ItemCostRow: View {
    
    let image: String
    let value: Int
    
    var body: some View {
        
        HStack(spacing: 4){
            Text("COST").foregroundStyle(.white).opacity(0.8)
            
            Spacer()
            Image(image)
                .resizable().aspectRatio(contentMode: .fit)
                .frame(width: 18, height: 18)
                .padding(.bottom, 1)
            Text("\(value)")         .foregroundStyle(.white).bold()
            
        }
        
        
    }
    
}

struct ItemDetailCostView: View {
    
    var name: String? = nil
    let image: String
    let cost: Int
    
    var body: some View {
        
        
        
        ZStack(alignment: .topLeading) {
            Color.gray.opacity(0.2)
                .shadow(radius: 3)
            VStack(alignment: .leading, spacing: 24) {
                
                ItemCostRow(image: image, value: cost)
                
                
            }  .font(Font.custom("FSSinclair", size: 20))
            
                .padding()
            
            
                .background {
                    
                    Rectangle().stroke(style: StrokeStyle(lineWidth: 3, dash: dashPattern, dashPhase: 30))
                        .foregroundStyle(.gray)
                        .opacity(0.5)
                        .shadow(radius: 3)
                    
                }
            
            if let name = name {
                Text("\(name.uppercased())").offset(x: 20, y: -12).font(Font.custom("FSSinclair", size: 20)).bold().foregroundStyle(.white).opacity(0.8).shadow(radius: 5.0)
            }
            
        }.shadow(radius: 3.0)
            .padding()
        
    }
    
    
    
}
