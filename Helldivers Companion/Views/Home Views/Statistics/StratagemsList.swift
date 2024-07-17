//
//  StratagemsList.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/04/2024.
//

import SwiftUI

struct StratagemsList: View {
    
    @EnvironmentObject var viewModel: PlanetsDataModel
    @EnvironmentObject var dbModel: DatabaseModel
    
    
    let stratagems: [StratagemType: [Stratagem]]

       init() {
           self.stratagems = Dictionary(grouping: globalStratagems, by: { $0.type })
       }
    
    let buttonTextSize: CGFloat = 18
    
    
    var body: some View {
        
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
                                                        NavigationLink(value: stratagem) {
                                                            StratagemDetailRow(stratagem)
                                                        }
                                                        .padding(.horizontal)
                                                        .padding(.vertical, 5)
                                                    }
                                                } header: {
                                                    Text(type.title.uppercased())
                                                        .font(Font.custom("FSSinclair-Bold", size: 16))
                                                        .foregroundStyle(.white).opacity(0.8)
                                                        .padding(.horizontal)
                                                        .padding(.bottom, -8)
                                                        .minimumScaleFactor(0.8)
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
    
    @EnvironmentObject var viewModel: PlanetsDataModel
    
    let dashPattern: [CGFloat] = [CGFloat.random(in: 50...70), CGFloat.random(in: 5...20)]
    
    var stratagem: Stratagem
    
    init(_ stratagem: Stratagem) {
        self.stratagem = stratagem
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
        
        .background {
            
            Rectangle().stroke(style: StrokeStyle(lineWidth: 3, dash: viewModel.dashPattern(for: stratagem)))
                .foregroundStyle(.gray)
                .opacity(0.5)
                .shadow(radius: 3)
            
        }
        
        
    
        
    }
    
}


