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
    
    var body: some View {
        ScrollView {
            
            VStack(alignment: .center) {
                //spray and pray weapon name is truncated in the json
                
                ZStack {
                    Color.gray
                    Image(weaponName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    
                    
                }
                .frame(width: 240)
                .frame(maxHeight: 200)
                .border(Color.white)
                .padding(4)
                .border(Color.gray)
                .padding(4)
                
                
                
                HStack(spacing: 18) {
                    
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundStyle(.yellow)
                        .frame(width: 4)
                    
                    VStack(alignment: .leading) {
                        
                        if let weaponType = weaponType {
                            Text("\(weaponType.name)").foregroundStyle(.gray).bold()
                            
                        }
                        
                        Text("\(weapon?.description ?? "Unknown")").foregroundStyle(.white)
                        
                        
                    }.font(Font.custom("FSSinclair", size: 20))
                    
                }.padding()
                    
                    ZStack(alignment: .topLeading) {
                        Color.gray.opacity(0.2)
                                .shadow(radius: 3)
                    VStack(spacing: 24) {
                        HStack {
                            Text("DAMAGE").foregroundStyle(.gray)
                            
                            Spacer()
                            Text("\(weapon?.damage ?? 0)")         .foregroundStyle(.white).bold()
                            
                        }
                        
                       
                            HStack {
                                Text("CAPACITY").foregroundStyle(.gray)
                                
                                Spacer()
                                Text("\(weapon?.capacity ?? 0)")
                                    .foregroundStyle(.white).bold()
                                
                            }
                        
                        
                        HStack {
                            Text("RECOIL").foregroundStyle(.gray)
                            
                            Spacer()
                            Text("\(weapon?.recoil ?? 0)")     .foregroundStyle(.white).bold()
                            
                        }
                        
                        HStack {
                            Text("FIRE RATE").foregroundStyle(.gray)
                            
                            Spacer()
                            Text("\(weapon?.fireRate ?? 0)")       .foregroundStyle(.white).bold()
                            
                        }
                        
                    }  .font(Font.custom("FSSinclair", size: 20))
                    
                    .padding()
                    
                    
                    .background {
                        
                        Rectangle().stroke(style: StrokeStyle(lineWidth: 3, dash: dashPattern, dashPhase: 30))
                            .foregroundStyle(.gray)
                            .opacity(0.5)
                            .shadow(radius: 3)
                        
                    }
                        
                        Text("STATS").offset(x: 20, y: -12).font(Font.custom("FSSinclair", size: 20)).bold().foregroundStyle(.gray).shadow(radius: 5.0)
                    
                    }.shadow(radius: 3.0)
                    .padding()
                    
                    
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
                    
                    Text("WEAPON TRAITS").offset(x: 20, y: -12).font(Font.custom("FSSinclair", size: 20)).bold().foregroundStyle(.gray).shadow(radius: 5.0)
                
                }.shadow(radius: 3.0)
                .padding()
              
                
                
                
                
            }.padding()

        }
        
        .conditionalBackground(viewModel: viewModel)
        
        .toolbarRole(.editor)
        .navigationTitle(weaponName)
        .navigationBarTitleDisplayMode(weaponName.count > 15 ? .inline : .automatic)
    }
}

