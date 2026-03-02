//
//  StratagemsList.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/04/2024.
//

import SwiftUI

struct StratagemsList: View {
    
    @Environment(PlanetsDataModel.self) var viewModel
    @Environment(DatabaseModel.self) var dbModel
    
    
    let stratagems: [StratagemType: [Stratagem]]

       init() {
           self.stratagems = Dictionary(grouping: globalStratagems, by: { $0.type })
       }
    
    let buttonTextSize: CGFloat = 18
    
    
    var body: some View {
        @Bindable var dbModel = dbModel
        
            ZStack(alignment: .bottom) {
            ScrollView {
                
                LazyVStack(alignment: .leading) {
                    
                    ForEach(StratagemType.allCases.indices, id: \.self) { index in
                                            let type = StratagemType.allCases[index]
                                            let stratagemsOfType = stratagems[type] ?? []
                        let filteredStratagems = stratagemsOfType.filter { dbModel.searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(dbModel.searchText) }
                                            
                                            // display section if no search text or there are matching stratagems
                        if dbModel.searchText.isEmpty || !filteredStratagems.isEmpty {
                                                Section {
                                                    ForEach(filteredStratagems, id: \.id) { stratagem in
                                                        let pattern = viewModel.dashPattern(for: stratagem)
                                                        NavigationLink(value: stratagem) {
                                                            StratagemDetailRow(stratagem, dashPattern: pattern)
                                                        }
                                                        .padding(.horizontal)
                                                        .padding(.vertical, 5)
                                                    }
                                                } header: {
                                                    Text(type.title.uppercased()).dbSectionHeader()
                                                }
                                                .id(index + 1)
                                            }
                                        }
                                    
                    
                }
                
                Spacer(minLength: 100)
                
            }.scrollContentBackground(.hidden)

        }
        
            .conditionalBackground(viewModel: viewModel, grayscale: true, opacity: 0.6)
            
            .toolbarRole(.editor)
                .navigationTitle("STRATAGEMS")
                .inlineLargeTitleiOS17()
        
                .searchable(text: $dbModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search Stratagems").disableAutocorrection(true)
        
             

            

    }
}
@available(iOS 17.0, *)
#Preview {
    StratagemGlossaryView()
}

struct StratagemDetailRow: View {
    
    var stratagem: Stratagem
    let dashPattern: [CGFloat]
    
    init(_ stratagem: Stratagem, dashPattern: [CGFloat]) {
        self.stratagem = stratagem
        self.dashPattern = dashPattern
    }

    let stackSpacing: CGFloat = 6
    let fontSize: CGFloat = 20
    let imageSize: CGFloat = 30
    
    var body: some View {

        ZStack(alignment: .trailing) {
            Color.gray.opacity(0.2)
                .shadow(radius: 3)
            HStack {
                Image(uiImage: getImage(named: stratagem.name))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: imageSize, height: imageSize)
                VStack(alignment: .leading, spacing: 0){
                    Text(stratagem.name.uppercased())
                        .font(Font.custom("FSSinclair-Bold", size: fontSize))
                        .padding(.top, 2)
                        .multilineTextAlignment(.leading)
                    
                }.tint(.white)
                
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .opacity(0.5)
                    .bold()
                
                Spacer()
            }.frame(maxWidth: .infinity)
                .padding(.leading, 10)
                .padding(.vertical, 8)
            
    
            
        }
        
        .dashedRowBackground(dashPattern: dashPattern)
        
        
    
        
    }
    
}
