//
//  StratagemDetailView.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/04/2024.
//

import SwiftUI
import AVKit

struct StratagemDetailView: View {
    
    @EnvironmentObject var viewModel: PlanetsViewModel
    @EnvironmentObject var dbModel: DatabaseModel
    
    let stratagem: Stratagem
    
    var decodedStratagem: DecodedStratagem? {
        
        let normalizedInputName = stratagem.name.normalized()
        
        if let strat = dbModel.decodedStrats.first(where: { $0.name.normalized() == normalizedInputName }) {
            return strat
            
            // for some reason spear is called "spear launcher" in the hellhub api, so bit of duct tape here to account for that
        } else if normalizedInputName == "spear", let strat = dbModel.decodedStrats.first(where: { $0.name.normalized() == "spearlauncher"}) {
            return strat
        }
        
        return nil
        
    }
    
    var body: some View {
        
        
        ScrollView {
            
            VStack(alignment: .center) {
                
                StratagemVideoPlayer(videoName: stratagem.name, videoType: "mp4")
                   // .frame(maxWidth: .infinity)
                
                    .frame(width: UIScreen.main.bounds.width - 60)
                
                HStack {
                    ForEach(stratagem.sequence, id: \.self) { input in
                        
                        
                        if #available(iOS 17.0, *) {
                            Image(systemName: "arrowshape.\(input).fill")
                                .foregroundStyle(.white)
                                .shadow(radius: 3)
                            
                        } else {
                            Image(systemName: "arrowtriangle.\(input).fill")
                                .foregroundStyle(.white)
                                .shadow(radius: 3)
                            
                        }
                        
                        
                    }
                }.font(.title3)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
                
                StratagemStatView(dashPattern: [58, 40], activation: decodedStratagem?.activation, cooldown: decodedStratagem?.cooldown, uses: decodedStratagem?.uses)
                
                    .padding()
                
                
                
                
                
                
            }.padding()

        }
        
        .conditionalBackground(viewModel: viewModel)
        
        .toolbar {
            
            
            ToolbarItem(placement: .topBarTrailing) {
                Image(stratagem.name)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
            }
            
            
        }
        
        .toolbarRole(.editor)
        .navigationTitle(stratagem.name)
        .navigationBarTitleDisplayMode(stratagem.name.count > 12 ? .inline : .automatic)
        
    }
}

struct StratagemStatView: View {
    
    let dashPattern: [CGFloat]
    
    let activation: Int?
    let cooldown: Int?
    let uses: String?
    
    var body: some View {
        
        ZStack(alignment: .topLeading) {
            Color.gray.opacity(0.2)
                    .shadow(radius: 3)
        VStack(spacing: 24) {
            HStack {
                Text("CALL-IN TIME").foregroundStyle(.gray)
                
                Spacer()
                Text("\(activation ?? 0) SEC")         .foregroundStyle(.white).bold()
                
            }
            
            if let uses = uses {
                HStack {
                    Text("USES").foregroundStyle(.gray)
                    
                    Spacer()
                    Text(uses)
                        .foregroundStyle(.white).bold()
                    
                }
            }
            
            HStack {
                Text("COOLDOWN TIME").foregroundStyle(.gray)
                
                Spacer()
                Text("\(cooldown ?? 0) SEC")         .foregroundStyle(.white).bold()
                
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
        
        
        
        
    }
    
}

struct StratagemVideoPlayer: View {
    
    private var player: AVPlayer?
    
    init(videoName: String, videoType: String) {
            if let path = Bundle.main.path(forResource: videoName, ofType: videoType) {
                let url = URL(fileURLWithPath: path)
                self.player = AVPlayer(url: url)
            } else {
                self.player = nil
                print("Video file not found")
            }
        }
    
    var body: some View {
        GeometryReader { geometry in
            if let player = player {
                VideoPlayer(player: player)
                    .aspectRatio(contentMode: .fill) 
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                
                
          
              
                    .onAppear {
                        player.play()
                    }
                    .onDisappear {
                        player.pause()
                    }
            } else {
                EmptyView()
            }
        }.frame(width: UIScreen.main.bounds.width - 40, height: 120)
            .border(Color.white)
            .padding(4)
            .border(Color.gray)
            .padding(4)
    }
    
    
}

extension String {
    func normalized() -> String {
        // remove non-alphanum chars and convert to lower case
        return self.components(separatedBy: CharacterSet.alphanumerics.inverted).joined().lowercased()
    }
}
