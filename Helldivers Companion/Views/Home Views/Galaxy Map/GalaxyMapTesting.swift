//
//  GalaxyMapTesting.swift
//  Helldivers Companion
//
//  Created by James Poole on 02/04/2024.
//

import SwiftUI
import Zoomable

struct DraggablePlanetView: View {
    @Binding var location: CGPoint
    var imageSize: CGSize
    
    @Binding var position: String

    var body: some View {
        Circle()
            .frame(width: 6, height: 6)
            .foregroundColor(.blue)
            .position(x: location.x, y: location.y)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        self.location = CGPoint(x: value.location.x, y: value.location.y)
                    }
                    .onEnded { value in
                        self.location = CGPoint(x: value.location.x, y: value.location.y)
                        printPosition()
                    }
            )
        
    
          
    }

    private func printPosition() {
        let xPercentage = location.x / imageSize.width
        let yPercentage = location.y / imageSize.height
        print(".position(x: imageSize.width * \(xPercentage), y: imageSize.height * \(yPercentage))")
        self.position = "\(xPercentage), \(yPercentage))"
    }
}


struct GalaxyMapTesting: View {
    @Binding var selectedPlanet: PlanetStatus?
    @State var planetLocation: CGPoint = CGPoint(x: 100, y: 100)
    
    @Binding var position: String

    
    let planetPositions: [PlanetPosition] = [
        PlanetPosition(name: "Acamar IV", xMultiplier: 0.8088985069837181, yMultiplier: 0.44833480497713774),
        PlanetPosition(name: "Gacrux", xMultiplier: 0.8584175800663212, yMultiplier: 0.4312410907085902),
        PlanetPosition(name: "Pandion XXIV", xMultiplier: 0.8491230873444532, yMultiplier: 0.46738390849692896),
        PlanetPosition(name: "Phact bay", xMultiplier: 0.8711934532294411, yMultiplier: 0.514356678175981),
        PlanetPosition(name: "Gatria", xMultiplier: 0.9021505557799113, yMultiplier: 0.568458366397176),
        PlanetPosition(name: "Gar Haren", xMultiplier: 0.8612166626587775, yMultiplier: 0.5638736462802169),
        PlanetPosition(name: "Darius II", xMultiplier: 0.8116802439569999, yMultiplier: 0.5189622249437714),
        PlanetPosition(name: "Achernar Secundus", xMultiplier: 0.8125118712823384, yMultiplier: 0.5548291728806366),
        PlanetPosition(name: "Ursica XI", xMultiplier: 0.7665766690170598, yMultiplier: 0.5437368980443972),
        PlanetPosition(name: "Achird III", xMultiplier: 0.7788256510820165, yMultiplier: 0.5215970257189424),
        PlanetPosition(name: "Turing", xMultiplier: 0.7599730066420102, yMultiplier: 0.4457182610132032),
        PlanetPosition(name: "Meridia", xMultiplier: 0.751210417577945, yMultiplier: 0.4033121064823447),
        PlanetPosition(name: "Fenrir III", xMultiplier: 0.7304660507229549, yMultiplier: 0.36624244845221804),
        PlanetPosition(name: "Erata Prime", xMultiplier: 0.7094967141621236, yMultiplier: 0.33263635494847693),
        PlanetPosition(name: "Bore Rock", xMultiplier: 0.6619755239851236, yMultiplier: 0.29326318348450553),
        PlanetPosition(name: "Esker", xMultiplier: 0.6856529623326364, yMultiplier: 0.24528171788841566),
        PlanetPosition(name: "Socorro III", xMultiplier: 0.6963919865195263, yMultiplier: 0.20553339029901982),
        PlanetPosition(name: "Erson Sands", xMultiplier: 0.7311272304938697, yMultiplier: 0.227366969759545),
        PlanetPosition(name: "Demiurg", xMultiplier: 0.52860051814428, yMultiplier: 0.17970952610456592),
        
        PlanetPosition(name: "Troost", xMultiplier: 0.05797556360145297, yMultiplier: 0.4291013063143269),
        PlanetPosition(name: "Ustotu", xMultiplier: 0.10235968656408743, yMultiplier: 0.3980286260202744),
        PlanetPosition(name: "Vandalon IV", xMultiplier: 0.0852293685955439, yMultiplier: 0.46857213204813053),
        PlanetPosition(name: "Choepessa IV", xMultiplier: 0.15411234988965536, yMultiplier: 0.373775628216436),
        PlanetPosition(name: "Varylia", xMultiplier: 0.13274545677415236, yMultiplier: 0.33191198553875095),
        PlanetPosition(name: "Charball-VII", xMultiplier: 0.20697799408793074, yMultiplier: 0.4004355711147335),
        PlanetPosition(name: "Charon Prime", xMultiplier: 0.215970652409185, yMultiplier: 0.37161514093276143),
        PlanetPosition(name: "Martale", xMultiplier: 0.23789019143282672, yMultiplier: 0.3326430637132476),
        PlanetPosition(name: "Marfark", xMultiplier: 0.28566475379318823, yMultiplier: 0.33898786051308044),
        PlanetPosition(name: "Matar Bay", xMultiplier: 0.25752033759403176, yMultiplier: 0.29783792945645704),
        
        PlanetPosition(name: "Termadon", xMultiplier: 0.07773588071374862, yMultiplier: 0.6777913840104929),
        PlanetPosition(name: "Tibit", xMultiplier: 0.1182239882639655, yMultiplier: 0.6647976513495751),
      
        PlanetPosition(name: "Leng Secundus", xMultiplier: 0.16332445244189825, yMultiplier: 0.6266981526884378),
        PlanetPosition(name: "Stor Tha Prime", xMultiplier: 0.13462501992456022, yMultiplier: 0.7513075564577133),
        PlanetPosition(name: "Stout", xMultiplier: 0.19381576312939297, yMultiplier: 0.6985918191349529),
        PlanetPosition(name: "Spherion", xMultiplier: 0.1975955945014963, yMultiplier: 0.7696878310389543),
        
        PlanetPosition(name: "Sirius", xMultiplier: 0.22266665767372776, yMultiplier: 0.8290964808849243),
        PlanetPosition(name: "Skat Bay", xMultiplier: 0.25982664284515744, yMultiplier: 0.7780724169274271),
        PlanetPosition(name: "Siemnot", xMultiplier: 0.2872638071118411, yMultiplier: 0.8733980398046884),
        PlanetPosition(name: "Shete", xMultiplier: 0.3446906468101753, yMultiplier: 0.9084078170771185),
        PlanetPosition(name: "Kneth Port", xMultiplier: 0.2564382034332835, yMultiplier: 0.7034575741471976),
        PlanetPosition(name: "Klaka 5", xMultiplier: 0.22616106540389655, yMultiplier: 0.6520791703492643),
        PlanetPosition(name: "Kraz", xMultiplier: 0.2002743562000524, yMultiplier: 0.6003709820173129),
        PlanetPosition(name: "Osupsam", xMultiplier: 0.2679223966537059, yMultiplier: 0.6526728633959832),
        PlanetPosition(name: "Brink-Z", xMultiplier: 0.29715785030250524, yMultiplier: 0.6665502968223783),
        PlanetPosition(name: "East Iridium Trading Bay", xMultiplier: 0.3321835480939284, yMultiplier: 0.6460311339940333),
        PlanetPosition(name: "Bunda Secundus", xMultiplier: 0.2441719956729707, yMultiplier: 0.5921839597718096),
        PlanetPosition(name: "Canopus", xMultiplier: 0.2688372167921489, yMultiplier: 0.6113944477851209),
        PlanetPosition(name: "Liberty Ridge", xMultiplier: 0.3004250608954688, yMultiplier: 0.5883486888277971),
        PlanetPosition(name: "Baldrick Prime", xMultiplier: 0.3292855272339756, yMultiplier: 0.5629065460421545),
        PlanetPosition(name: "Ilduna Prime", xMultiplier: 0.3586752539506844, yMultiplier: 0.5769069776719743),
        PlanetPosition(name: "Emorath", xMultiplier: 0.36891922952601147, yMultiplier: 0.6106700504280422),
        
        PlanetPosition(name: "Ubanea", xMultiplier: 0.09958506381642818, yMultiplier: 0.6064129977511812),
        PlanetPosition(name: "Draupnir", xMultiplier: 0.13498782460136913, yMultiplier: 0.5618581323825148),
        PlanetPosition(name: "Mantes", xMultiplier: 0.1342588720551752, yMultiplier: 0.5165691967488754),
        PlanetPosition(name: "Mort", xMultiplier: 0.16837715456412045, yMultiplier: 0.4362988829065489),
        PlanetPosition(name: "Ingmar", xMultiplier: 0.13818584548048157, yMultiplier: 0.471959285014821),
        PlanetPosition(name: "Pöpli IX", xMultiplier: 0.18838032850885303, yMultiplier: 0.4773451192268572),
        PlanetPosition(name: "Dolph", xMultiplier: 0.24007163277310686, yMultiplier: 0.4699173317084291),
        PlanetPosition(name: "Julheim", xMultiplier: 0.24374642266462787, yMultiplier: 0.4284426611392734),
        PlanetPosition(name: "Bekvam III", xMultiplier: 0.2601987065189976, yMultiplier: 0.3948452216399934),
        PlanetPosition(name: "Duma Tyr", xMultiplier: 0.29764731606484507, yMultiplier: 0.42167469846219013),
        PlanetPosition(name: "Aesir Pass", xMultiplier: 0.3295573311865301, yMultiplier: 0.358154903867812)
        
    ]
    

    var body: some View {
        GeometryReader { geometry in
            let imageSize = geometry.size
            ZStack {
                Image("sectorMap")
                    .resizable()
                    .frame(width: imageSize.width, height: imageSize.height)

            
                
                ForEach(planetPositions, id: \.name) { planet in
                                    Circle()
                                        .frame(width: 6, height: 6)
                                        .position(
                                            x: imageSize.width * planet.xMultiplier,
                                            y: imageSize.height * planet.yMultiplier
                                        )
                                        .foregroundColor(.cyan)
                                        .onTapGesture {
                                            print("\(planet.name) tapped")
                                        
                                        }
                                }
                
                
                DraggablePlanetView(location: $planetLocation, imageSize: imageSize, position: $position)
                
            }
        }
    }
}


#Preview {
    MapRootViewTest()
}

struct MapRootViewTest: View {
    
    @EnvironmentObject var viewModel: PlanetsViewModel
    
    @State var planetName: String = ""
    @State var position: String = ""
    
    var body: some View {
        
        // deprecated navview used here instead of stack, stack doesnt work with the zoomable modifier/package - leads to strange zooming to the upper left corner
        // nav is needed to be able to tap planets
        NavigationView {
            
            VStack(spacing: 0) {
                
                /*   if let selectedPlanet = viewModel.selectedPlanet {
                    if let defenseEvent = viewModel.defensePlanets.first(where: { $0.planet.index == selectedPlanet.planet.index }) {
                        // planet is defending, use defense percentage for liberation val
                        PlanetView(planetName: selectedPlanet.planet.name, liberation: defenseEvent.defensePercentage, rate: selectedPlanet.regenPerSecond, playerCount: selectedPlanet.players, planet: selectedPlanet, liberationType: .defense, bugOrAutomaton: selectedPlanet.owner == "Terminids" ? .terminid : .automaton, terminidRate: viewModel.configData.terminidRate, automatonRate: viewModel.configData.automatonRate, eventExpirationTime: defenseEvent.expireTimeDate).environmentObject(viewModel)
                            .padding(.horizontal)
                            .frame(maxHeight: 300)
                    } else {
                        // planet not defending, use liberation
                        PlanetView(planetName: selectedPlanet.planet.name, liberation: selectedPlanet.liberation, rate: selectedPlanet.regenPerSecond, playerCount: selectedPlanet.players, planet: selectedPlanet, liberationType: .liberation, bugOrAutomaton: selectedPlanet.owner == "Terminids" ? .terminid : .automaton, terminidRate: viewModel.configData.terminidRate, automatonRate: viewModel.configData.automatonRate).environmentObject(viewModel)
                            .padding(.horizontal)
                        
                            .frame(maxHeight: 300)
                     
                    }
                }*/
                
                TextField("Planet name", text: $planetName)
                
                Text("position: \(position)")
                    .font(.footnote)
                    .bold()
                
                GalaxyMapTesting(selectedPlanet: $viewModel.selectedPlanet, position: $position)
                  //  .frame(maxWidth: .infinity)
                
                    .frame(width: 300, height: 300)
                
                    .zoomable(
                        minZoomScale: 1.0,
                        doubleTapZoomScale: 2,
                        outOfBoundsColor: .clear
                    )
                
                    .padding()
                
                    .clipShape(Rectangle())
                
                    .padding(.bottom, 20)
                
            }
            .background {
                Image("BackgroundImage").blur(radius: 10).ignoresSafeArea()
            }
            
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("GALAXY MAP")
                        .font(Font.custom("FS Sinclair", size: 24))
                }
            }
            
            .navigationBarTitleDisplayMode(.inline)
            
        }
        
    }
    
    
}

struct PlanetPosition {
    let name: String
    let xMultiplier: Double
    let yMultiplier: Double
}
