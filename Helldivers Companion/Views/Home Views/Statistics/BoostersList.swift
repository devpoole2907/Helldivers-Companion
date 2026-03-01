//
//  BoostersList.swift
//  Helldivers Companion
//
//  Created by James Poole on 25/04/2024.
//

import SwiftUI

struct BoostersList: View {
    
    @Environment(DatabaseModel.self) var dbModel
    @Environment(PlanetsDataModel.self) var viewModel
    
    var body: some View {
        @Bindable var dbModel = dbModel
        ScrollView {
            LazyVStack(alignment: .leading) {
                
              
                    Section {
                        ForEach(dbModel.boosters.filter { booster in
                            dbModel.searchText.isEmpty || booster.name.localizedCaseInsensitiveContains(dbModel.searchText)
                        }, id: \.name) { booster in
                            
                         
                                
                                BoosterRow(booster: booster)
                                
                                 .padding(.vertical, 5)
                            
                        }
                    } 
                
   
                
                
            }.padding(.horizontal)
            
            Spacer(minLength: 150)
            
            
        }            .conditionalBackground(viewModel: viewModel, grayscale: true, opacity: 0.6)
        
        
            .navigationTitle("Boosters".uppercased())
        
            .toolbarRole(.editor)
            .searchable(text: $dbModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Boosters").disableAutocorrection(true)
        
        
    }
}

struct BoosterRow: View {
    
    @Environment(DatabaseModel.self) var dbModel
    
    let booster: Booster
    var dashPattern: [CGFloat] = [64, 13]
    var showWarBondName = true
    
    var body: some View {
        
        
        ZStack(alignment: .trailing) {
            Color.gray.opacity(0.2)
                .shadow(radius: 3)
            HStack {
                
                VStack(spacing: 4) {
                    Image(booster.name)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                    
                    if let id = Int(booster.id), let cost = dbModel.itemMedalCost(for: id) {
                        HStack(spacing: 2) {
                            Image("medalSymbol")
                                .resizable().aspectRatio(contentMode: .fit)
                                .frame(width: 15, height: 15)
                                .padding(.bottom, 1)
                            Text("\(cost)")         .foregroundStyle(.white).bold()
                                .font(Font.custom("FSSinclair-Bold", size: 16))
                        }
                    }
                    
                }
                
                RoundedRectangle(cornerRadius: 25)
                    .foregroundStyle(.yellow)
                    .frame(width: 4)
                
                VStack(alignment: .leading, spacing: 2){
                    Text(booster.name.uppercased())
                        .font(Font.custom("FSSinclair-Bold", size: 18))
                        .padding(.top, 2)
                        .tint(.white)
                    
                    if showWarBondName, let id = Int(booster.id), let warBondName = dbModel.warBond(for: id)?.name {
                        Text(warBondName.uppercased())
                            .font(Font.custom("FSSinclair", size: 14))
                            .foregroundStyle(Color.white).opacity(0.8)
                    }
                    
                    Text(booster.description)
                        .font(Font.custom("FSSinclair", size: 12))
                        .foregroundStyle(Color.white).opacity(0.7)
                    
                }.padding(.leading, 6)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
            
                
            }.frame(maxWidth: .infinity)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
            
    
            
        }.frame(minHeight: 100)
        
        .dashedRowBackground(dashPattern: dashPattern)
        
        
    }
    
    
}
