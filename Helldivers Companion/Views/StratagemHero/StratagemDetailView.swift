//
//  StratagemDetailView.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/04/2024.
//

import SwiftUI
import AVKit

struct StratagemDetailView: View {
    
    @EnvironmentObject var viewModel: PlanetsDataModel
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
                
                StratagemVideoPlayer(stratagem: stratagem)
                   // .frame(maxWidth: .infinity)
                
                    .frame(width: UIScreen.main.bounds.width - 60)
                
                HStack(spacing: 18) {
                    
                    RoundedRectangle(cornerRadius: 25)
                        .foregroundStyle(.yellow)
                        .frame(width: 4)
                    
                    VStack(alignment: .leading) {
                        
                       
                        Text("\(stratagem.type.title)").foregroundStyle(.white).opacity(0.8).bold()
                            

                        
                        
                    }.font(Font.custom("FSSinclair", size: 20))
                    
                    Spacer()
                    
                }.padding()
                
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
        
        .conditionalBackground(viewModel: viewModel, grayscale: true, opacity: 0.6)
        
        .toolbar {
            
            
            ToolbarItem(placement: .topBarTrailing) {
                Image(uiImage: getImage(named: stratagem.name))
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
                Text("CALL-IN TIME").foregroundStyle(.white).opacity(0.8)
                
                Spacer()
                Text("\(activation ?? 0) SEC")         .foregroundStyle(.white).bold()
                
            }
            
            if let uses = uses {
                HStack {
                    Text("USES").foregroundStyle(.white).opacity(0.8)
                    
                    Spacer()
                    Text(uses)
                        .foregroundStyle(.white).bold()
                    
                }
            }
            
            HStack {
                Text("COOLDOWN TIME").foregroundStyle(.white).opacity(0.8)
                
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
            
            Text("STATS").offset(x: 20, y: -12).font(Font.custom("FSSinclair", size: 20)).bold().foregroundStyle(.white).opacity(0.8).shadow(radius: 5.0)
        
        }.shadow(radius: 3.0)
        
        
        
        
    }
    
}

struct StratagemVideoPlayer: View {
    
    @State private var player: AVPlayer?
    @State private var isLoading = true
    
    let stratagem: Stratagem
    
  /*  init(videoName: String, videoType: String) {
            if let path = Bundle.main.path(forResource: videoName, ofType: videoType) {
                let url = URL(fileURLWithPath: path)
                self.player = AVPlayer(url: url)
                self.videoName = videoName
            } else {
                self.player = nil
                self.videoName = "not found"
                print("Video file not found")
                
            }
        }*/
    
    var body: some View {
        
        VStack{
        if isLoading {
            DualRingSpinner()
        } else if let player = player {
            
            GeometryReader { geometry in
                VideoPlayer(player: player)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                
                
                
                
            }.frame(width: UIScreen.main.bounds.width - 40, height: 120)
                .border(Color.white)
                .padding(4)
                .border(Color.gray)
                .padding(4)
            
                .onAppear {
                    player.play()
                }
                .onDisappear {
                    player.pause()
                }
            
            
            
        } else {
            Text("Video not available")
                .font(Font.custom("FSSinclair-Bold", size: 14))
        }
        }
            .task {
                        await fetchVideo()
                    }
       
    }
    
    private func fetchVideo() async {
            let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let videoCacheURL = cacheDirectory.appendingPathComponent("\(stratagem.name.lowercased()).mp4")
            
            if FileManager.default.fileExists(atPath: videoCacheURL.path) {
                withAnimation {
                    player = AVPlayer(url: videoCacheURL)
                    isLoading = false
                }
                print("fetched video from cache")
                return
            }
            
        guard let url = URL(string: stratagem.videoUrl ?? "") else {
            withAnimation {
                isLoading = false
            }
                return
            }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                try data.write(to: videoCacheURL)
                withAnimation {
                    player = AVPlayer(url: videoCacheURL)
                }
            } catch {
                print("Failed to fetch video: \(error)")
            }
        withAnimation {
            isLoading = false
        }
        }
    
    
}

extension String {
    func normalized() -> String {
        // remove non-alphanum chars and convert to lower case
        return self.components(separatedBy: CharacterSet.alphanumerics.inverted).joined().lowercased()
    }
}
