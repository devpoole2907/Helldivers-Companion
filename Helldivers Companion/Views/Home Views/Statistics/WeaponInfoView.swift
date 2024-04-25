//
//  WeaponInfoView.swift
//  Helldivers Companion
//
//  Created by James Poole on 25/04/2024.
//

import SwiftUI

struct WeaponInfoView: View {
    
    @EnvironmentObject var viewModel: PlanetsViewModel
    @EnvironmentObject var dbModel: DatabaseModel
    
    var weapon: Weapon? = nil
    
    var grenade: Grenade? = nil
    
    var weaponName: String {
        
        if let weapon = weapon {
            return weapon.name == "SG-225SP Breaker Spray&Pra" ? "SG-225SP Breaker Spray&Pray" : weapon.name
        } else if let grenade = grenade {
            return grenade.name
        }
        
        return "Error"
        
    }
    
    var weaponType: WeaponType? {
        
        if let weaponType = weapon?.type {
            return dbModel.types.first(where: { $0.id == weaponType })
        }
        
        return nil
        
    }
    
    var isGrenade: Bool {
        
        if grenade != nil {
            return true
        }  
        
        return false
        
        
    }
    
    var description: String? {
        
        if let weaponDescription = weapon?.description {
            return weaponDescription
        }
        
        if let grenadeDescription = grenade?.description {
            return grenadeDescription
        }
        
        return nil
    }
    
    var body: some View {
        ScrollView {
            
            VStack(alignment: .center) {
                //spray and pray weapon name is truncated in the json
                
                ZStack {
                    if !isGrenade {
                        Color.gray
                    }
                    Image(weaponName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    
                    
                }
                .frame(width: 240)
                .frame(maxHeight: 200)
                .offset(x: isGrenade ? -5 : 0)
                .border(isGrenade ? Color.clear : Color.white)
                .padding(4)
                .border(isGrenade ? Color.clear : Color.gray)
                .padding(4)
                
                
                
                HStack(spacing: 18) {
                    
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundStyle(.yellow)
                        .frame(width: 4)
                    
                    VStack(alignment: .leading) {
                        
                        if let weaponType = weaponType {
                            Text("\(weaponType.name)").foregroundStyle(.gray).bold()
                            
                        }
                        if let description = description {
                            Text(description).foregroundStyle(.white)
                            
                        }
                        
                        
                    }.font(Font.custom("FSSinclair", size: 20))
                    
                }.padding()
                
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
                
                if !isGrenade {
                
                ZStack(alignment: .topLeading) {
                    Color.gray.opacity(0.2)
                        .shadow(radius: 3)
                    VStack(alignment: .leading, spacing: 24) {
                        
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
                        
                    }  .font(Font.custom("FSSinclair", size: 20))
                    
                        .padding()
                    
                    
                        .background {
                            
                            Rectangle().stroke(style: StrokeStyle(lineWidth: 3, dash: dashPattern, dashPhase: 30))
                                .foregroundStyle(.gray)
                                .opacity(0.5)
                                .shadow(radius: 3)
                            
                        }
                    
                    Text("WEAPON TRAITS").offset(x: 20, y: -12).font(Font.custom("FSSinclair", size: 20)).bold().foregroundStyle(.white).opacity(0.8).shadow(radius: 5.0)
                    
                }.shadow(radius: 3.0)
                    .padding()
                
            }
                
                
                
            }.padding()

        }
        
        .toolbar {
            
            if grenade != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Image(weaponName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                }
            }
            
        }
        
        .conditionalBackground(viewModel: viewModel)
        
        .toolbarRole(.editor)
        .navigationTitle(weaponName)
        .navigationBarTitleDisplayMode(weaponName.count > 15 ? .inline : .automatic)
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
