//
//  EnemiesList.swift
//  Helldivers Companion
//
//  Created by James Poole on 04/05/2024.
//

import SwiftUI

struct EnemiesList: View {
    
    @EnvironmentObject var dbModel: DatabaseModel
    @EnvironmentObject var viewModel: PlanetsDataModel
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                
            //    AlertView(alert: "The Bestiary is still under development and will be continuously expanded on in the near future.")

                Section{
                    ForEach(dbModel.illuminateEnemies.filter { enemy in
                        dbModel.searchText.isEmpty || enemy.name.localizedCaseInsensitiveContains(dbModel.searchText)
                        || "illuminate".hasPrefix(dbModel.searchText.lowercased()) }, id: \.id) { enemy in
                        NavigationLink(value: enemy) {
                            EnemyDetailRow(dashPattern: [57, 13], enemy: enemy)
                        }
                                    }
                                } header: {
                                    Text("Illuminate".uppercased())
                                        .font(Font.custom("FSSinclair-Bold", size: 22))
                                        .foregroundStyle(.purple)
                                        .padding(.horizontal)
                                        .padding(.bottom, -2)
                                        .minimumScaleFactor(0.8)
                                }
                
                Section{
                    ForEach(dbModel.automatonEnemies.filter { enemy in
                        dbModel.searchText.isEmpty || enemy.name.localizedCaseInsensitiveContains(dbModel.searchText) || "automaton".hasPrefix(dbModel.searchText.lowercased()) }
                    , id: \.id) { enemy in
                        
                        NavigationLink(value: enemy) {
                            EnemyDetailRow(dashPattern: [57, 13], enemy: enemy)
                            
                        }
                                    }
                                } header: {
                                    Text("Automaton".uppercased())
                                        .font(Font.custom("FSSinclair-Bold", size: 22))
                                        .foregroundStyle(.red)
                                        .padding(.horizontal)
                                        .padding(.bottom, -2)
                                        .minimumScaleFactor(0.8)
                                }
                
                Section{
                    ForEach(dbModel.terminidsEnemies.filter { enemy in
                        dbModel.searchText.isEmpty || enemy.name.localizedCaseInsensitiveContains(dbModel.searchText)
                        || "terminids".hasPrefix(dbModel.searchText.lowercased()) }, id: \.id) { enemy in
                        NavigationLink(value: enemy) {
                            EnemyDetailRow(dashPattern: [57, 13], enemy: enemy)
                        }
                                    }
                                } header: {
                                    Text("Terminids".uppercased())
                                        .font(Font.custom("FSSinclair-Bold", size: 22))
                                        .foregroundStyle(.yellow)
                                        .padding(.horizontal)
                                        .padding(.bottom, -2)
                                        .minimumScaleFactor(0.8)
                                }

                
            }.padding(.horizontal)
            
                .animation(.bouncy, value: dbModel.selectedArmourCategory)
                .animation(.bouncy, value: dbModel.sortCriteria)
            
            Spacer(minLength: 150)
            
            
        }         .conditionalBackground(viewModel: viewModel, grayscale: true, opacity: 0.6)
        
        
            .navigationTitle("Bestiary".uppercased())
        
            .toolbarRole(.editor)
            .searchable(text: $dbModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Bestiary").disableAutocorrection(true)
    
          
    }
}

struct EnemyDetailRow: View {
    
    @EnvironmentObject var dbModel: DatabaseModel
    
    let dashPattern: [CGFloat]
    let enemy: Enemy
    
    var body: some View {
        ZStack(alignment: .trailing) {
            Color.gray.opacity(0.2).shadow(radius: 3)
            
            HStack {
        
         
                AsyncImageView(imageUrl: enemy.imageUrl)
                        .frame(width: 50, height: 50)
                
                
                VStack(alignment: .leading, spacing: 2) {
                    VStack(alignment: .leading, spacing: 0){
                        HStack {
                            
                            Text(enemy.name.uppercased())
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
