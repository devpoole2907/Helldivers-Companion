//
//  BoostersList.swift
//  Helldivers Companion
//
//  Created by James Poole on 25/04/2024.
//

import SwiftUI

struct BoostersList: View {
    
    @EnvironmentObject var dbModel: DatabaseModel
    @EnvironmentObject var viewModel: PlanetsViewModel
    
    @State private var searchText = ""
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                
              
                    Section {
                        ForEach(dbModel.boosters.filter { booster in
                            searchText.isEmpty || booster.name.localizedCaseInsensitiveContains(searchText)
                        }, id: \.name) { booster in
                            
                         
                                
                                BoosterRow(booster: booster, dashPattern: [64, 13])
                                
                                 .padding(.vertical, 5)
                            
                        }
                    } 
                
   
                
                
            }.padding(.horizontal)
            
            Spacer(minLength: 150)
            
            
        }      .conditionalBackground(viewModel: viewModel)
        
        
            .navigationTitle("Boosters".uppercased())
        
            .toolbarRole(.editor)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Boosters").disableAutocorrection(true)
        
        
    }
}

struct BoosterRow: View {
    
    let booster: Booster
    let dashPattern: [CGFloat]
    
    var body: some View {
        
        
        ZStack(alignment: .trailing) {
            Color.gray.opacity(0.2)
                .shadow(radius: 3)
            HStack {
                
                Image(booster.name)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                
                RoundedRectangle(cornerRadius: 25)
                    .foregroundStyle(.yellow)
                    .frame(width: 4)
                
                VStack(alignment: .leading, spacing: 2){
                    Text(booster.name.uppercased())
                        .font(Font.custom("FSSinclair-Bold", size: 18))
                        .padding(.top, 2)
                        .tint(.white)
                   
                    
                    Text(booster.description)
                        .font(Font.custom("FSSinclair", size: 12))
                        .foregroundStyle(Color.white).opacity(0.8)
                    
                }.padding(.leading, 6)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
            
                
            }.frame(maxWidth: .infinity)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
            
    
            
        }.frame(minHeight: 100)
        
        .background {
            
            Rectangle().stroke(style: StrokeStyle(lineWidth: 3, dash: dashPattern))
                .foregroundStyle(.gray)
                .opacity(0.5)
                .shadow(radius: 3)
            
        }
        
        
    }
    
    
}
