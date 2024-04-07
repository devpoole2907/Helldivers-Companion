//
//  GalaxyMapTesting.swift
//  Helldivers Companion
//
//  Created by James Poole on 02/04/2024.
//

import SwiftUI
import Zoomable
import SwiftUIIntrospect

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
    @Binding var selectedPlanet: UpdatedPlanet?
    @State var planetLocation: CGPoint = CGPoint(x: 100, y: 100)
    
    @Binding var position: String
    @Binding var showSupplyLines: Bool
    @Binding var showAllPlanets: Bool
    
    @EnvironmentObject var viewModel: PlanetsViewModel
    
    
    let planetPositions: [PlanetPosition] = [
        PlanetPosition(name: "Acamar IV", index: 129, xMultiplier: 0.8088985069837181, yMultiplier: 0.44833480497713774),
        PlanetPosition(name: "Gacrux", index: 171, xMultiplier: 0.8584175800663212, yMultiplier: 0.4312410907085902),
        PlanetPosition(name: "Pandion-XXIV", index: 214, xMultiplier: 0.8491230873444532, yMultiplier: 0.46738390849692896),
        PlanetPosition(name: "Phact bay", index: 217, xMultiplier: 0.8711934532294411, yMultiplier: 0.514356678175981),
        PlanetPosition(name: "Gatria", index: 173, xMultiplier: 0.9021505557799113, yMultiplier: 0.568458366397176),
        PlanetPosition(name: "Gar Haren", index: 172, xMultiplier: 0.8612166626587775, yMultiplier: 0.5638736462802169),
        PlanetPosition(name: "Darius II", index: 128, xMultiplier: 0.8116802439569999, yMultiplier: 0.5189622249437714),
        PlanetPosition(name: "Achernar Secundus", index: 130, xMultiplier: 0.8125118712823384, yMultiplier: 0.5548291728806366),
        PlanetPosition(name: "Ursica XI", index: 82, xMultiplier: 0.7665766690170598, yMultiplier: 0.5437368980443972),
        PlanetPosition(name: "Achird III", index: 131, xMultiplier: 0.7788256510820165, yMultiplier: 0.5215970257189424),
        PlanetPosition(name: "Turing", index: 126, xMultiplier: 0.7599730066420102, yMultiplier: 0.4457182610132032),
        PlanetPosition(name: "Meridia", index: 64, xMultiplier: 0.751210417577945, yMultiplier: 0.4033121064823447),
        PlanetPosition(name: "Fenrir III", index: 125, xMultiplier: 0.7304660507229549, yMultiplier: 0.36624244845221804),
        PlanetPosition(name: "Erata Prime", index: 168, xMultiplier: 0.7094967141621236, yMultiplier: 0.33263635494847693),
        PlanetPosition(name: "Bore Rock", index: 124, xMultiplier: 0.6619755239851236, yMultiplier: 0.29326318348450553),
        PlanetPosition(name: "Esker", index: 75, xMultiplier: 0.6856529623326364, yMultiplier: 0.24528171788841566),
        PlanetPosition(name: "Socorro III", index: 123, xMultiplier: 0.6963919865195263, yMultiplier: 0.20553339029901982),
        PlanetPosition(name: "Erson Sands", index: 122, xMultiplier: 0.7311272304938697, yMultiplier: 0.227366969759545),
        PlanetPosition(name: "Demiurg", index: 163, xMultiplier: 0.52860051814428, yMultiplier: 0.17970952610456592),
        PlanetPosition(name: "Troost", index: 240, xMultiplier: 0.05797556360145297, yMultiplier: 0.4291013063143269),
        PlanetPosition(name: "Ustotu", index: 242, xMultiplier: 0.10235968656408743, yMultiplier: 0.3980286260202744),
        PlanetPosition(name: "Vandalon IV", index: 243, xMultiplier: 0.0852293685955439, yMultiplier: 0.46857213204813053),
        PlanetPosition(name: "Choepessa IV", index: 158, xMultiplier: 0.15411234988965536, yMultiplier: 0.373775628216436),
        PlanetPosition(name: "Varylia 5", index: 244, xMultiplier: 0.13274545677415236, yMultiplier: 0.33191198553875095),
        PlanetPosition(name: "Charbal-VII", index: 156, xMultiplier: 0.20697799408793074, yMultiplier: 0.4004355711147335),
        PlanetPosition(name: "Charon Prime", index: 157, xMultiplier: 0.215970652409185, yMultiplier: 0.37161514093276143),
        PlanetPosition(name: "Martale", index: 199, xMultiplier: 0.23789019143282672, yMultiplier: 0.3326430637132476),
        PlanetPosition(name: "Marfark", index: 198, xMultiplier: 0.28566475379318823, yMultiplier: 0.33898786051308044),
        PlanetPosition(name: "Matar Bay", index: 200, xMultiplier: 0.25752033759403176, yMultiplier: 0.29783792945645704),
        PlanetPosition(name: "Termadon", index: 237, xMultiplier: 0.07773588071374862, yMultiplier: 0.6777913840104929),
        PlanetPosition(name: "Tibit", index: 238, xMultiplier: 0.1182239882639655, yMultiplier: 0.6647976513495751),
        PlanetPosition(name: "Leng Secundus", index: 193, xMultiplier: 0.16332445244189825, yMultiplier: 0.6266981526884378),
        PlanetPosition(name: "Stor Tha Prime", index: 235, xMultiplier: 0.13462501992456022, yMultiplier: 0.7513075564577133),
        PlanetPosition(name: "Stout", index: 236, xMultiplier: 0.19381576312939297, yMultiplier: 0.6985918191349529),
        PlanetPosition(name: "Spherion", index: 234, xMultiplier: 0.1975955945014963, yMultiplier: 0.7696878310389543),
        PlanetPosition(name: "Sirius", index: 232, xMultiplier: 0.22266665767372776, yMultiplier: 0.8290964808849243),
        PlanetPosition(name: "Skat Bay", index: 233, xMultiplier: 0.25982664284515744, yMultiplier: 0.7780724169274271),
        PlanetPosition(name: "Siemnot", index: 231, xMultiplier: 0.2872638071118411, yMultiplier: 0.8733980398046884),
        PlanetPosition(name: "Shete", index: 230, xMultiplier: 0.3446906468101753, yMultiplier: 0.9084078170771185),
        PlanetPosition(name: "Kneth Port", index: 189, xMultiplier: 0.2564382034332835, yMultiplier: 0.7034575741471976),
        PlanetPosition(name: "Klaka 5", index: 188, xMultiplier: 0.22616106540389655, yMultiplier: 0.6520791703492643),
        PlanetPosition(name: "Kraz", index: 190, xMultiplier: 0.2002743562000524, yMultiplier: 0.6003709820173129),
        PlanetPosition(name: "Osupsam", index: 146, xMultiplier: 0.2679223966537059, yMultiplier: 0.6526728633959832),
        PlanetPosition(name: "Brink-2", index: 147, xMultiplier: 0.29715785030250524, yMultiplier: 0.6665502968223783),
        PlanetPosition(name: "East Iridium Trading Bay", index: 101, xMultiplier: 0.3321835480939284, yMultiplier: 0.6460311339940333),
        PlanetPosition(name: "Bunda Secundus", index: 148, xMultiplier: 0.2441719956729707, yMultiplier: 0.5921839597718096),
        PlanetPosition(name: "Canopus", index: 149, xMultiplier: 0.2688372167921489, yMultiplier: 0.6113944477851209),
        PlanetPosition(name: "Liberty Ridge", index: 102, xMultiplier: 0.3004250608954688, yMultiplier: 0.5883486888277971),
        PlanetPosition(name: "Baldrick Prime", index: 103, xMultiplier: 0.3292855272339756, yMultiplier: 0.5629065460421545),
        PlanetPosition(name: "Ilduna Prime", index: 62, xMultiplier: 0.3586752539506844, yMultiplier: 0.5769069776719743),
        PlanetPosition(name: "Emorath", index: 61, xMultiplier: 0.36891922952601147, yMultiplier: 0.6106700504280422),
        PlanetPosition(name: "Ubanea", index: 241, xMultiplier: 0.09958506381642818, yMultiplier: 0.6064129977511812),
        PlanetPosition(name: "Draupnir", index: 153, xMultiplier: 0.13498782460136913, yMultiplier: 0.5618581323825148),
        PlanetPosition(name: "Mantes", index: 197, xMultiplier: 0.1342588720551752, yMultiplier: 0.5165691967488754),
        PlanetPosition(name: "Mort", index: 154, xMultiplier: 0.16837715456412045, yMultiplier: 0.4362988829065489),
        PlanetPosition(name: "Ingmar", index: 155, xMultiplier: 0.13818584548048157, yMultiplier: 0.471959285014821),
        PlanetPosition(name: "Pöpli IX", index: 107, xMultiplier: 0.18838032850885303, yMultiplier: 0.4773451192268572),
        PlanetPosition(name: "Dolph", index: 109, xMultiplier: 0.24007163277310686, yMultiplier: 0.4699173317084291),
        PlanetPosition(name: "Julheim", index: 72, xMultiplier: 0.24374642266462787, yMultiplier: 0.4284426611392734),
        PlanetPosition(name: "Bekvam III", index: 110, xMultiplier: 0.2601987065189976, yMultiplier: 0.3948452216399934),
        PlanetPosition(name: "Duma Tyr", index: 111, xMultiplier: 0.29764731606484507, yMultiplier: 0.42167469846219013),
        PlanetPosition(name: "Aesir Pass", index: 113, xMultiplier: 0.3295573311865301, yMultiplier: 0.358154903867812),
        PlanetPosition(name: "Nivel 43", index: 211, xMultiplier: 0.7361429346008855, yMultiplier: 0.2909816143379798),
        PlanetPosition(name: "Zagon Prime", index: 258, xMultiplier: 0.7746847886241806, yMultiplier: 0.2598691283676274),
        PlanetPosition(name: "Oshaune", index: 212, xMultiplier: 0.8070688172352688, yMultiplier: 0.30275751141320695),
        PlanetPosition(name: "Hellmire", index: 34, xMultiplier: 0.7525436023620994, yMultiplier: 0.3289626000751579),
        PlanetPosition(name: "Estanu", index: 169, xMultiplier: 0.7889382845490037, yMultiplier: 0.3593497043818859),
        PlanetPosition(name: "Crimsica", index: 78, xMultiplier: 0.8024757796775192, yMultiplier: 0.3915002451438423),
        PlanetPosition(name: "Fori Prime", index: 170, xMultiplier: 0.8403091221000497, yMultiplier: 0.3541212208675948),
        PlanetPosition(name: "Navi VII", index: 210, xMultiplier: 0.882045452882993, yMultiplier: 0.3329452360573202),
        PlanetPosition(name: "Partion", index: 215, xMultiplier: 0.9147589382707978, yMultiplier: 0.45235491458932386),
        PlanetPosition(name: "Peacock", index: 216, xMultiplier: 0.9590520534286878, yMultiplier: 0.49822160692328593),
        PlanetPosition(name: "Azur Secundus", index: 50, xMultiplier: 0.9294494557543453, yMultiplier: 0.3274386386519451),
        PlanetPosition(name: "Trandor", index: 100, xMultiplier: 0.9514951118071128, yMultiplier: 0.5613735435108829),
        PlanetPosition(name: "Epsilon Phoencis VI", index: 167, xMultiplier: 0.7776432263300389, yMultiplier: 0.20079762926684974),
        PlanetPosition(name: "Enuliale", index: 166, xMultiplier: 0.7340683204700845, yMultiplier: 0.16452247801882489),
        PlanetPosition(name: "Diaspora X", index: 256, xMultiplier: 0.7590414587218323, yMultiplier: 0.12621453302501223),
        PlanetPosition(name: "Omicron", index: 259, xMultiplier: 0.834960770881576, yMultiplier: 0.26104292824950404),
        PlanetPosition(name: "Nabatea Secundus", index: 209, xMultiplier: 0.876263110753426, yMultiplier: 0.23912563575411871),
        PlanetPosition(name: "Gemstone Bluffs", index: 257, xMultiplier: 0.8237958561208288, yMultiplier: 0.19982692246747702),
        PlanetPosition(name: "Blistica", index: 70, xMultiplier: 0.41814371250787175, yMultiplier: 0.100993288145485),
        PlanetPosition(name: "Kuma", index: 191, xMultiplier: 0.5163659870323297, yMultiplier: 0.04444234125195041),
        PlanetPosition(name: "Mordia 9", index: 208, xMultiplier: 0.6529783810585763, yMultiplier: 0.12199034298999062),
        PlanetPosition(name: "Seasse", index: 227, xMultiplier: 0.5515901082895129, yMultiplier: 0.9070767285034171),
        PlanetPosition(name: "Keid", index: 186, xMultiplier: 0.3726764699075898, yMultiplier: 0.831345850033847),
        PlanetPosition(name: "Khandark", index: 187, xMultiplier: 0.3179710500901591, yMultiplier: 0.7603730946933747),
        PlanetPosition(name: "Botein", index: 145, xMultiplier: 0.31104463902898405, yMultiplier: 0.7154279010396212),
        PlanetPosition(name: "Elysian Meadows", index: 98, xMultiplier: 0.37610143643043864, yMultiplier: 0.6691695807852359),
        PlanetPosition(name: "Calypso", index: 97, xMultiplier: 0.3984759850931511, yMultiplier: 0.705443916784242),
        PlanetPosition(name: "Alaraph", index: 140, xMultiplier: 0.4821858774545993, yMultiplier: 0.7700535898229325),
        PlanetPosition(name: "Alathfar XI", index: 141, xMultiplier: 0.4391815831867706, yMultiplier: 0.7509604707003373),
        PlanetPosition(name: "Andar", index: 142, xMultiplier: 0.4008125077212436, yMultiplier: 0.7426339472242769),
        PlanetPosition(name: "Asperoth Prime", index: 143, xMultiplier: 0.3830288398661124, yMultiplier: 0.78197258878753),
        PlanetPosition(name: "Rogue 5", index: 225, xMultiplier: 0.5721286123872024, yMultiplier: 0.9478593770915831),
        PlanetPosition(name: "Rirga Bay", index: 226, xMultiplier: 0.5469416024754225, yMultiplier: 0.8565527189237997),
        PlanetPosition(name: "Hydrobius", index: 184, xMultiplier: 0.47768957814948315, yMultiplier: 0.846311976424117),
        PlanetPosition(name: "Haka", index: 177, xMultiplier: 0.7860038047917166, yMultiplier: 0.72447057807493),
        PlanetPosition(name: "Afoyay Bay", index: 136, xMultiplier: 0.6502492276392899, yMultiplier: 0.7136072908984642),
        PlanetPosition(name: "Myrium", index: 56, xMultiplier: 0.5620816032765965, yMultiplier: 0.6508602639948299),
        PlanetPosition(name: "Prosperity Falls", index: 12, xMultiplier: 0.4992268253569308, yMultiplier: 0.5625194987765264),
        PlanetPosition(name: "Crucible", index: 29, xMultiplier: 0.6160498924469091, yMultiplier: 0.5140317422728461),
        PlanetPosition(name: "Marre IV", index: 31, xMultiplier: 0.599386874236101, yMultiplier: 0.5703442379884682),
        PlanetPosition(name: "Caramoor", index: 53, xMultiplier: 0.6585832771357206, yMultiplier: 0.5617590894323342),
        PlanetPosition(name: "Inari", index: 83, xMultiplier: 0.7168374075966262, yMultiplier: 0.5293230203357617),
        PlanetPosition(name: "Okul VI", index: 13, xMultiplier: 0.47016712985462356, yMultiplier: 0.5798324643989486),
        PlanetPosition(name: "Solghast", index: 36, xMultiplier: 0.4529295438535695, yMultiplier: 0.614141756495475),
        PlanetPosition(name: "Diluvia", index: 37, xMultiplier: 0.43286851371716106, yMultiplier: 0.5978614577013275),
        PlanetPosition(name: "Maw", index: 63, xMultiplier: 0.33598957998949325, yMultiplier: 0.5249579647509706),
        PlanetPosition(name: "Wraith", index: 18, xMultiplier: 0.4293224081648655, yMultiplier: 0.49090614285198586),
        PlanetPosition(name: "Atrama", index: 41, xMultiplier: 0.3789014877301184, yMultiplier: 0.4853033846858009),
        PlanetPosition(name: "Emeria", index: 42, xMultiplier: 0.38042738618722316, yMultiplier: 0.45163109500187376),
        PlanetPosition(name: "Igla", index: 19, xMultiplier: 0.41579245331039566, yMultiplier: 0.46509212720386217),
        PlanetPosition(name: "Mastia", index: 45, xMultiplier: 0.437163990793065, yMultiplier: 0.3496879242315055),
        PlanetPosition(name: "Barabos", index: 43, xMultiplier: 0.4081076855804344, yMultiplier: 0.43019618311324015),
        PlanetPosition(name: "Borea", index: 65, xMultiplier: 0.34502307935915333, yMultiplier: 0.4361879529576179),
        PlanetPosition(name: "Oslo Station", index: 106, xMultiplier: 0.29175028059000385, yMultiplier: 0.47633213293745835),
        PlanetPosition(name: "New Kiruna", index: 20, xMultiplier: 0.44113310295242486, yMultiplier: 0.44686210705674795),
        PlanetPosition(name: "Pathfinder V", index: 2, xMultiplier: 0.5232165370652127, yMultiplier: 0.4211536016010964),
        PlanetPosition(name: "Sulfura", index: 25, xMultiplier: 0.5847716636303844, yMultiplier: 0.40933338342131),
        PlanetPosition(name: "Nublaria I", index: 26, xMultiplier: 0.6006652707602507, yMultiplier: 0.43651228599158987),
        PlanetPosition(name: "Moradesh", index: 85, xMultiplier: 0.663271720104393, yMultiplier: 0.42678510948868026),
        PlanetPosition(name: "Shallus", index: 46, xMultiplier: 0.46964149826110446, yMultiplier: 0.37935673546253595),
        PlanetPosition(name: "Shelt", index: 68, xMultiplier: 0.47232911787580556, yMultiplier: 0.32224399856365443),
        PlanetPosition(name: "Gaellivare", index: 116, xMultiplier: 0.4209604539845787, yMultiplier: 0.297626426756639),
        PlanetPosition(name: "Mortax Prime", index: 119, xMultiplier: 0.5166584626692373, yMultiplier: 0.2342689023400032),
        PlanetPosition(name: "Kirrik", index: 118, xMultiplier: 0.5620584167371291, yMultiplier: 0.243240450703276),
        PlanetPosition(name: "Deneb Secundus", index: 164, xMultiplier: 0.5454705705767486, yMultiplier: 0.13836773371948838),
        PlanetPosition(name: "Electra Bay", index: 165, xMultiplier: 0.6068969247787105, yMultiplier: 0.1533773986894868),
        PlanetPosition(name: "Euphoria III", index: 255, xMultiplier: 0.6583456153764962, yMultiplier: 0.07230251218534288),
        PlanetPosition(name: "Skitter", index: 254, xMultiplier: 0.5758116367845796, yMultiplier: 0.046217295809218746),
        PlanetPosition(name: "Senge 23", index: 228, xMultiplier: 0.4841570270511618, yMultiplier: 0.9128236044399665),
        PlanetPosition(name: "Vernen Wells", index: 112, xMultiplier: 0.36962835867708294, yMultiplier: 0.3149168483178319),
        PlanetPosition(name: "Menkent", index: 203, xMultiplier: 0.3472407062968212, yMultiplier: 0.27474959167663177),
        PlanetPosition(name: "Claorell", index: 161, xMultiplier: 0.47807136972024994, yMultiplier: 0.2405101564981644),
        PlanetPosition(name: "Vog-sojoth", index: 117, xMultiplier: 0.4402403996424072, yMultiplier: 0.23182205213342935),
        PlanetPosition(name: "Chort Bay", index: 160, xMultiplier: 0.33575785468295233, yMultiplier: 0.2291925736194368),
        PlanetPosition(name: "Fort Justice", index: 21, xMultiplier: 0.46567249242306824, yMultiplier: 0.4485362782650637),
        PlanetPosition(name: "Kelvinor", index: 17, xMultiplier: 0.4300729618283213, yMultiplier: 0.5147190237394556),
        PlanetPosition(name: "Obari", index: 39, xMultiplier: 0.3821435759559584, yMultiplier: 0.5499943007637347),
        PlanetPosition(name: "Fort Sanctuary", index: 32, xMultiplier: 0.5752936554549206, yMultiplier: 0.6017686123271623),
        PlanetPosition(name: "Volterra", index: 28, xMultiplier: 0.6477465063833985, yMultiplier: 0.5164586892766384),
        PlanetPosition(name: "Alta V", index: 81, xMultiplier: 0.6802864592706263, yMultiplier: 0.5226495235342576),
        PlanetPosition(name: "Skaash", index: 84, xMultiplier: 0.7059168923845217, yMultiplier: 0.5830260375765806),
        PlanetPosition(name: "Hadar", index: 176, xMultiplier: 0.7550483076105056, yMultiplier: 0.686023859718506),
        PlanetPosition(name: "Herthon Secundus", index: 180, xMultiplier: 0.6314405037013746, yMultiplier: 0.7884149787800677),
        PlanetPosition(name: "Heze Bay", index: 182, xMultiplier: 0.5228979420098998, yMultiplier: 0.8148917952654249),
        PlanetPosition(name: "Karlia", index: 185, xMultiplier: 0.43515901999958134, yMultiplier: 0.8209275639784579),
        PlanetPosition(name: "Setia", index: 229, xMultiplier: 0.422364273741221, yMultiplier: 0.920809143733048),
        PlanetPosition(name: "RD-4", index: 224, xMultiplier: 0.6408613076255166, yMultiplier: 0.9275913068577621),
        PlanetPosition(name: "Halies Port", index: 179, xMultiplier: 0.7364142249139981, yMultiplier: 0.7872423463545123),
        PlanetPosition(name: "Prasa", index: 221, xMultiplier: 0.8253598023881523, yMultiplier: 0.7794196737402732),
        PlanetPosition(name: "Myradesh", index: 40, xMultiplier: 0.38571677126110415, yMultiplier: 0.5147218600255961),
        PlanetPosition(name: "Gunvald", index: 108, xMultiplier: 0.330037332000711, yMultiplier: 0.4725227854902603),
        PlanetPosition(name: "Fenmire", index: 44, xMultiplier: 0.4167211803711799, yMultiplier: 0.4008753692441861),
        PlanetPosition(name: "Tarsh", index: 67, xMultiplier: 0.39898333209469433, yMultiplier: 0.36066957801309835),
        PlanetPosition(name: "Tien Kwan", index: 239, xMultiplier: 0.19218924835264609, yMultiplier: 0.5601358847190583),
        PlanetPosition(name: "Kuper", index: 105, xMultiplier: 0.2731445554050094, yMultiplier: 0.5436176279647271),
        PlanetPosition(name: "The Weir", index: 104, xMultiplier: 0.292231173629539, yMultiplier: 0.5134153234822127),
        PlanetPosition(name: "Caph", index: 150, xMultiplier: 0.24523777350404483, yMultiplier: 0.5180445281238022),
        PlanetPosition(name: "Castor", index: 151, xMultiplier: 0.22809724060707537, yMultiplier: 0.553573190462778),
        PlanetPosition(name: "Lastofe", index: 192, xMultiplier: 0.19617200665607248, yMultiplier: 0.520589725988763),
        PlanetPosition(name: "Hort", index: 183, xMultiplier: 0.6204544062281538, yMultiplier: 0.8414615567329763),
        PlanetPosition(name: "Hesoe Prime", index: 181, xMultiplier: 0.6765406795776299, yMultiplier: 0.8621195480577696),
        PlanetPosition(name: "Ras Algethi", index: 223, xMultiplier: 0.7427431641053328, yMultiplier: 0.849296217634122),
        PlanetPosition(name: "Propus", index: 222, xMultiplier: 0.788961010495404, yMultiplier: 0.832734667560541),
        PlanetPosition(name: "Zea Rugosia", index: 7, xMultiplier: 0.6785916719345066, yMultiplier: 0.7552068607013058),
        PlanetPosition(name: "Haldus", index: 178, xMultiplier: 0.7278131041489989, yMultiplier: 0.7206689309371214),
        PlanetPosition(name: "Seyshel Beach", index: 33, xMultiplier: 0.5459253805089503, yMultiplier: 0.6086293338251524),
        PlanetPosition(name: "Midasburg", index: 10, xMultiplier: 0.5329706110058554, yMultiplier: 0.5715406161846743),
        PlanetPosition(name: "Veil", index: 30, xMultiplier: 0.6147569963126004, yMultiplier: 0.5465710459800907),
        PlanetPosition(name: "Widow's Harbor", index: 3, xMultiplier: 0.5596571776509977, yMultiplier: 0.4447195843420879),
        PlanetPosition(name: "Curia", index: 66, xMultiplier: 0.3803400048638415, yMultiplier: 0.3930604028352513),
        PlanetPosition(name: "Martyr's Bay", index: 14, xMultiplier: 0.450935559403025, yMultiplier: 0.5525136593166721),
        PlanetPosition(name: "Viridia Prime", index: 38, xMultiplier: 0.4065379686333233, yMultiplier: 0.5704006358303754),
        PlanetPosition(name: "Freedom Peak", index: 15, xMultiplier: 0.41617846993197705, yMultiplier: 0.5407831753245607),
        PlanetPosition(name: "Zegema Paradise", index: 22, xMultiplier: 0.4832848649186075, yMultiplier: 0.42762415047705804),
        PlanetPosition(name: "Imber", index: 69, xMultiplier: 0.4699831267537061, yMultiplier: 0.27969046091363997),
        PlanetPosition(name: "Choohe", index: 159, xMultiplier: 0.30616631767807534, yMultiplier: 0.24897531664574846),
        PlanetPosition(name: "Lesath", index: 194, xMultiplier: 0.3887513840907775, yMultiplier: 0.2560730513252773),
        PlanetPosition(name: "Penta", index: 115, xMultiplier: 0.3698698802676918, yMultiplier: 0.20864584348613952),
        PlanetPosition(name: "Irulta", index: 60, xMultiplier: 0.4052130758022227, yMultiplier: 0.6406390000108091),
        PlanetPosition(name: "Outpost 32", index: 96, xMultiplier: 0.4329170212681342, yMultiplier: 0.6953839951247979),
        PlanetPosition(name: "Reaf", index: 59, xMultiplier: 0.4438043767823522, yMultiplier: 0.6583364899271215),
        PlanetPosition(name: "Pioneer II", index: 121, xMultiplier: 0.641710436993065, yMultiplier: 0.18746001286297645),
        PlanetPosition(name: "Wilford Station", index: 120, xMultiplier: 0.5968890315643888, yMultiplier: 0.21321938997290812),
        PlanetPosition(name: "Arkturus", index: 74, xMultiplier: 0.6257000447622564, yMultiplier: 0.24203040590134212),
        PlanetPosition(name: "Ivis", index: 51, xMultiplier: 0.6397960784229237, yMultiplier: 0.4472846060411966),
        PlanetPosition(name: "Krakatwo", index: 27, xMultiplier: 0.6230081852133303, yMultiplier: 0.47422243772963846),
        PlanetPosition(name: "Slif", index: 52, xMultiplier: 0.6656799755831654, yMultiplier: 0.4759704373405109),
        PlanetPosition(name: "Hydrofall Prime", index: 6, xMultiplier: 0.5679891758836135, yMultiplier: 0.5164397460812405),
        PlanetPosition(name: "Darrowsport", index: 8, xMultiplier: 0.5476902542090705, yMultiplier: 0.539772872932701),
        PlanetPosition(name: "Fornskogur II", index: 9, xMultiplier: 0.5767919829820582, yMultiplier: 0.5467273293599644),
        PlanetPosition(name: "Cerberus IIIc", index: 11, xMultiplier: 0.5019946363407655, yMultiplier: 0.593136921820333),
        PlanetPosition(name: "Effluvia", index: 35, xMultiplier: 0.4898897995860783, yMultiplier: 0.6191775788057223),
        PlanetPosition(name: "Super Earth", index: 0, xMultiplier: 0.5, yMultiplier: 0.5),
        PlanetPosition(name: "Veld", index: 80, xMultiplier: 0.7159982543364164, yMultiplier: 0.46782872429388467),
        PlanetPosition(name: "Angel's Venture", index: 127, xMultiplier: 0.716856871584672, yMultiplier: 0.42555237069407864),
        PlanetPosition(name: "Heeth", index: 79, xMultiplier: 0.6908253813690813, yMultiplier: 0.36872425772414646),
        PlanetPosition(name: "Fort Union", index: 16, xMultiplier: 0.6321935205923247, yMultiplier: 0.3977322099909968),
        PlanetPosition(name: "Azterra", index: 49, xMultiplier: 0.60951013325528, yMultiplier: 0.36022534799340045),
        PlanetPosition(name: "Cirrus", index: 77, xMultiplier: 0.6565503532776144, yMultiplier: 0.3711073466410754),
        PlanetPosition(name: "Terrek", index: 76, xMultiplier: 0.6315762443635128, yMultiplier: 0.3275361116406011),
        PlanetPosition(name: "Clasa", index: 162, xMultiplier: 0.46699755702922585, yMultiplier: 0.18673292165322927),
        PlanetPosition(name: "Maia", index: 195, xMultiplier: 0.042455869058871124, yMultiplier: 0.5176247891610795),
        PlanetPosition(name: "Eukoria", index: 55, xMultiplier: 0.5931632262870994, yMultiplier: 0.6380742359290226),
        PlanetPosition(name: "Regnus", index: 88, xMultiplier: 0.6221908632588867, yMultiplier: 0.6569017489266386),
        PlanetPosition(name: "Mog", index: 89, xMultiplier: 0.6424682184954074, yMultiplier: 0.6730250630791889),
        PlanetPosition(name: "Adhara", index: 135, xMultiplier: 0.6803472769822542, yMultiplier: 0.6988017082902191),
        PlanetPosition(name: "Acubens Prime", index: 134, xMultiplier: 0.6940770390048726, yMultiplier: 0.668110559839513),
        PlanetPosition(name: "Rasp", index: 86, xMultiplier: 0.6939893170811958, yMultiplier: 0.6278449653863285),
        PlanetPosition(name: "Kharst", index: 54, xMultiplier: 0.6327575443707785, yMultiplier: 0.6031943552332578),
        PlanetPosition(name: "Bashyr", index: 87, xMultiplier: 0.6600680610868331, yMultiplier: 0.6275850703710993),
        PlanetPosition(name: "Alairt III", index: 138, xMultiplier: 0.5576724926524862, yMultiplier: 0.7901660588368167),
        PlanetPosition(name: "Valmox", index: 90, xMultiplier: 0.5924603562713632, yMultiplier: 0.6861257731329146),
        PlanetPosition(name: "Genesis Prime", index: 95, xMultiplier: 0.4624916090476724, yMultiplier: 0.7177131648237158),
        PlanetPosition(name: "Parsh", index: 58, xMultiplier: 0.48030658522760233, yMultiplier: 0.6613171436163755),
        PlanetPosition(name: "Kerth Secundus", index: 57, xMultiplier: 0.5236499688678392, yMultiplier: 0.6652887565302629),
        PlanetPosition(name: "Grafmere", index: 92, xMultiplier: 0.5317478296266223, yMultiplier: 0.6977269212539294),
        PlanetPosition(name: "Ain-5", index: 137, xMultiplier: 0.6068873001977115, yMultiplier: 0.7389829740080184),
        PlanetPosition(name: "Alamak VII", index: 139, xMultiplier: 0.5301789919777963, yMultiplier: 0.7587967530605242),
        PlanetPosition(name: "New Stockholm", index: 93, xMultiplier: 0.5734192357872637, yMultiplier: 0.7477415395345797),
        PlanetPosition(name: "Iro", index: 91, xMultiplier: 0.5757457350094041, yMultiplier: 0.7127509854407853),
        PlanetPosition(name: "Oasis", index: 94, xMultiplier: 0.5023260166612308, yMultiplier: 0.7154711478964171),
        PlanetPosition(name: "Gemma", index: 174, xMultiplier: 0.7731726797018019, yMultiplier: 0.6336912346602118),
        PlanetPosition(name: "Grand Errant", index: 175, xMultiplier: 0.8375992779152016, yMultiplier: 0.6192076811010954),
        PlanetPosition(name: "Pollux 31", index: 220, xMultiplier: 0.8750844138357307, yMultiplier: 0.7323915900370993),
        PlanetPosition(name: "Overgoe Prime", index: 213, xMultiplier: 0.9489768763805315, yMultiplier: 0.40585299527850655),
        PlanetPosition(name: "Providence", index: 23, xMultiplier: 0.5149347694141551, yMultiplier: 0.3875682014794003),
        PlanetPosition(name: "Klen Dahth II", index: 1, xMultiplier: 0.5258927329042502, yMultiplier: 0.44981368342159556),
        PlanetPosition(name: "Pilen V", index: 5, xMultiplier: 0.5769586702891163, yMultiplier: 0.4809376910878071),
        PlanetPosition(name: "Valgaard", index: 73, xMultiplier: 0.5825016962137285, yMultiplier: 0.29845923453784295),
        PlanetPosition(name: "New Haven", index: 4, xMultiplier: 0.5496336959163884, yMultiplier: 0.47340321244730593),
        PlanetPosition(name: "Acrab XI", index: 132, xMultiplier: 0.7478506064084655, yMultiplier: 0.604033184386196),
        PlanetPosition(name: "Acrux IX", index: 133, xMultiplier: 0.7785694898352888, yMultiplier: 0.5949498206852407),
        PlanetPosition(name: "Bellatrix", index: 144, xMultiplier: 0.34984443290845246, yMultiplier: 0.7250544083961437),
        PlanetPosition(name: "Alderidge Cove", index: 99, xMultiplier: 0.34748591232322085, yMultiplier: 0.6933457791980411),
        PlanetPosition(name: "Malevelon Creek", index: 196, xMultiplier: 0.08410897382831509, yMultiplier: 0.5504921958009737),
        PlanetPosition(name: "Durgen", index: 152, xMultiplier: 0.049140630733922774, yMultiplier: 0.5820841983319105),
        PlanetPosition(name: "Polaris Prime", index: 219, xMultiplier: 0.8726326351128662, yMultiplier: 0.6662302032337033),
        PlanetPosition(name: "Pherkad Secundus", index: 218, xMultiplier: 0.9246883671797628, yMultiplier: 0.6433570322779485),
        PlanetPosition(name: "Primordia", index: 24, xMultiplier: 0.5461321474538012, yMultiplier: 0.37531451452636344),
        PlanetPosition(name: "Ratch", index: 71, xMultiplier: 0.5255754120733388, yMultiplier: 0.2909894470364045),
        PlanetPosition(name: "Krakabos", index: 47, xMultiplier: 0.5201948627982851, yMultiplier: 0.34084922803828005),
        PlanetPosition(name: "Iridica", index: 48, xMultiplier: 0.5550310110709022, yMultiplier: 0.33388486178309534),
        PlanetPosition(name: "Mintoria", index: 207, xMultiplier: 0.4742289309552572, yMultiplier: 0.08538525975779357),
        PlanetPosition(name: "Minchir", index: 206, xMultiplier: 0.5415521038005128, yMultiplier: 0.09003636854339397),
        PlanetPosition(name: "Zzaniah Prime", index: 253, xMultiplier: 0.40291211601390947, yMultiplier: 0.044209084680176175),
        PlanetPosition(name: "Zosma", index: 252, xMultiplier: 0.3239112840305582, yMultiplier: 0.06702604329306772),
        PlanetPosition(name: "Zefia", index: 251, xMultiplier: 0.4773767852096095, yMultiplier: 0.14486722960701082),
        PlanetPosition(name: "Yed Prior", index: 250, xMultiplier: 0.4341651186403509, yMultiplier: 0.1519406042849129),
        PlanetPosition(name: "Meissa", index: 201, xMultiplier: 0.2196648052559523, yMultiplier: 0.25685958209683746),
        PlanetPosition(name: "Wezen", index: 247, xMultiplier: 0.07460478230276553, yMultiplier: 0.3279779436278944),
        PlanetPosition(name: "Vega Bay", index: 246, xMultiplier: 0.11030948318897056, yMultiplier: 0.255142410091064),
        PlanetPosition(name: "X-45", index: 249, xMultiplier: 0.16123724618806737, yMultiplier: 0.2070540328249113),
        PlanetPosition(name: "Wasat", index: 245, xMultiplier: 0.17726245407641525, yMultiplier: 0.27872489074580487),
        PlanetPosition(name: "Vindemitarix Prime", index: 248, xMultiplier: 0.22312748616769426, yMultiplier: 0.1212479457143628),
        PlanetPosition(name: "Merga IV", index: 205, xMultiplier: 0.3364416594627106, yMultiplier: 0.13677942250231065),
        PlanetPosition(name: "Cyberstan", index: 260, xMultiplier: 0.28217194139992635, yMultiplier: 0.15999592053953823),
        PlanetPosition(name: "Mekbuda", index: 202, xMultiplier: 0.23639421575825936, yMultiplier: 0.18259686182545137),
        PlanetPosition(name: "Aurora Bay", index: 114, xMultiplier: 0.2787754500632348, yMultiplier: 0.20883035025392876),
        PlanetPosition(name: "Merak", index: 204, xMultiplier: 0.3248534155378594, yMultiplier: 0.18564327679754544),
    ]
    
    func updatedPlanet(for position: PlanetPosition) -> UpdatedPlanet? {
        viewModel.updatedPlanets.first(where: { $0.index == position.index })
    }
    
    
    // to get position for planet so we can draw supply lines
    private func position(forPlanetIndex index: Int, in size: CGSize) -> CGPoint? {
        guard let planetPosition = planetPositions.first(where: { $0.index == index }) else {
            return nil
        }
        return CGPoint(x: size.width * planetPosition.xMultiplier, y: size.height * planetPosition.yMultiplier)
    }
    
    func getColorForPlanet(planetPosition: PlanetPosition) -> Color {
        
        guard let planet = updatedPlanet(for: planetPosition) else {
            print("planet is not found for color")
            return .gray // default color if no matching planet found
        }
        
        
        if planet.currentOwner == "Humans" {
            if viewModel.updatedDefenseCampaigns.contains(where: { $0.planet.index == planet.index }) {
                let campaign = viewModel.updatedDefenseCampaigns.first { $0.planet.index == planet.index }
                switch campaign?.planet.event?.faction {
                case "Terminids": return .yellow
                case "Automaton": return .red
                case "Illuminate": return .blue
                default: return .cyan
                }
            } else {
                return .cyan
            }
        } else if viewModel.updatedCampaigns.contains(where: { $0.planet.index == planet.index }) {
            if !viewModel.updatedDefenseCampaigns.contains(where: { $0.planet.index == planet.index }) {
                switch planet.currentOwner {
                case "Automaton": return .red
                case "Terminids": return .yellow
                case "Illuminate": return .blue
                default: return .gray // default color if currentOwner dont match any known factions
                }
            }
        } else {
            // planet musnt be part of any campaigns, colour it based on current owner
            switch planet.currentOwner {
            case "Automaton": return .red
            case "Terminids": return .yellow
            case "Illuminate": return .blue
            default: return .gray
            }
        }
        
        
        return .gray // if no conditions meet for some reason
        
        
    }
    
    
    var body: some View {
        GeometryReader { geometry in
            let imageSize = geometry.size
            ZStack {
                Image("sectorMap")
                    .resizable()
                    .frame(width: imageSize.width, height: imageSize.height)
                    .opacity(0.4)
                
                if showSupplyLines {
                    
                    // for supply lines, lines between each planet using the planets waypoints variable
                    ForEach(viewModel.updatedPlanets, id: \.index) { updatedPlanet in
                        if let startPoint = position(forPlanetIndex: updatedPlanet.index, in: imageSize) {
                            ForEach(updatedPlanet.waypoints, id: \.self) { waypointIndex in
                                if let endPoint = position(forPlanetIndex: waypointIndex, in: imageSize) {
                                    Path { path in
                                        path.move(to: startPoint)
                                        path.addLine(to: endPoint)
                                    }
                                    .stroke(Color.white.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [2, 1]))
                                    .allowsHitTesting(false)
                                }
                            }
                        }
                    }
                    
                }
                
                ForEach(planetPositions.filter { planet in
                    showAllPlanets || viewModel.updatedCampaigns.contains(where: { $0.planet.index == planet.index })
                }, id: \.index) { planet in
                    
                    
                    // determine if in an active campaign,
                    let isInActiveCampaign = viewModel.updatedCampaigns.contains(where: { $0.planet.index == planet.index })
                    
                    // change size of circle, if its in a campaign or selected it should be larger
                    let circleSize = viewModel.selectedPlanet?.index == planet.index ? 10 :
                    (isInActiveCampaign ? 8 : 6)
                    
                    Circle()
                        .frame(width: viewModel.selectedPlanet?.index == planet.index ? 10 : 6, height: viewModel.selectedPlanet?.index == planet.index ? 10 : 6)
                        .position(
                            x: imageSize.width * planet.xMultiplier,
                            y: imageSize.height * planet.yMultiplier
                        )
                    
                    
                        .foregroundColor(
                            getColorForPlanet(planetPosition: planet)
                        )
                    
                        .overlay(
                            Group {
                                if viewModel.selectedPlanet?.index == planet.index {
                                    Circle()
                                        .stroke(Color.white, lineWidth: 0.6)
                                        .frame(width: 12, height: 12)
                                        .position(
                                            x: imageSize.width * planet.xMultiplier,
                                            y: imageSize.height * planet.yMultiplier
                                        )
                                }
                            }
                        )
                    
                        .onTapGesture {
                            print("\(planet.name) tapped")
                            withAnimation(.bouncy) {
                                viewModel.selectedPlanet = viewModel.updatedPlanets.first(where: { $0.index == planet.index })
                                
                            }
                            
                        }
                }
                
                
                
                
                /*
                 DraggablePlanetView(location: $planetLocation, imageSize: imageSize, position: $position)
                 */
            }.shadow(radius: 3)
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
    
    @State var showSupplyLines = false
    @State var showAllPlanets = false
    
    // to determine if it is actively in a campaign
    var isActive: Bool {
        
        if let selectedPlanet = viewModel.selectedPlanet {
            
            viewModel.updatedCampaigns.contains(where: { $0.planet.index == selectedPlanet.index })
            
        } else {
            false
        }
        
    }
    // to determine if it is actively in a defense campaign
    var isDefending: Bool {
        
        if let selectedPlanet = viewModel.selectedPlanet {
            
            viewModel.updatedDefenseCampaigns.contains(where: { $0.planet.index == selectedPlanet.index })
            
        } else {
            false
        }
        
        
    }
    
    var liberationPercentage: Double {
        
        if let selectedPlanet = viewModel.selectedPlanet {
            if isDefending || isActive {
                return selectedPlanet.percentage
            } else if selectedPlanet.currentOwner == "Humans" {
                
                return 100
                
                
            } else {
                // must be owned by another faction and not actively in campaign so 0
                return 0
            }
            
            
        }
        
        return 0
        
        
        
    }
    
    var body: some View {
        
        // deprecated navview used here instead of stack, stack doesnt work with the zoomable modifier/package - leads to strange zooming to the upper left corner
        // nav is needed to be able to tap planets
        NavigationView {
            
            VStack(spacing: 0) {
                
                if let selectedPlanet = viewModel.selectedPlanet {
                    
                    
                    let eventExpirationTime = viewModel.eventExpirationDate(from: selectedPlanet.event?.endTime)
                    
               
                        
                        PlanetView(planetName: selectedPlanet.name, liberation: liberationPercentage, rate: selectedPlanet.regenPerSecond, playerCount: selectedPlanet.statistics.playerCount, planet: selectedPlanet, liberationType: isDefending ? .defense : .liberation, terminidRate: viewModel.configData.terminidRate, automatonRate: viewModel.configData.automatonRate, illuminateRate: viewModel.configData.illuminateRate, eventExpirationTime: eventExpirationTime, isInMapView: true, isActive: isActive).environmentObject(viewModel)
                            .padding(.horizontal)
                            .frame(maxHeight: 300)
                            .animation(.bouncy, value: isActive)
                        
                            // wrapping the planet view as a nav link directly doesnt work, but overlaying a clear view that is the nav link does! ebic hax
                    
                            .overlay {
                                NavigationLink(destination: PlanetInfoView(planet: selectedPlanet)) {
                                    
                                    Color.clear
                                    
                                }
                            }
                    
                    
                }
                
                GalaxyMapTesting(selectedPlanet: $viewModel.selectedPlanet, position: $position, showSupplyLines: $showSupplyLines, showAllPlanets: $showAllPlanets).environmentObject(viewModel)
                
                    .frame(width: 300, height: 300)
                    .contentShape(Rectangle())
                    .zoomable(
                        minZoomScale: 1.0,
                        doubleTapZoomScale: 3,
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
                
                ToolbarItem(placement: .topBarLeading) {
                    
                    Button(action: {
                        
                        MapSettingsPopup(showSupplyLines: $showSupplyLines, showAllPlanets: $showAllPlanets).showAndStack()
                        
                    }){
                        Image(systemName: "gearshape.fill")
                    }.tint(.white)
                    
                }
                
                ToolbarItem(placement: .principal) {
                    Text("GALAXY MAP")
                        .font(Font.custom("FS Sinclair", size: 24))
                }
                
                if #unavailable(iOS 17.0) {
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        
                        Button(action: {
                            
                            iOS16AlertPopup().showAndStack()
                            
                        }){
                            Image(systemName: "exclamationmark.triangle.fill")
                               
                        } .tint(.red)
                        
                    }
                    
                    
                }
                
                
            }
            
            .navigationBarTitleDisplayMode(.inline)
            
        }
        // set custom nav title front
        .introspect(.navigationView(style: .stack), on: .iOS(.v16, .v17)) { controller in
            print("I am introspecting!")
            
            
            let largeFontSize: CGFloat = UIFont.preferredFont(forTextStyle: .largeTitle).pointSize
            let inlineFontSize: CGFloat = UIFont.preferredFont(forTextStyle: .body).pointSize
            
            // default to sf system font
            let largeFont = UIFont(name: "FS Sinclair", size: largeFontSize) ?? UIFont.systemFont(ofSize: largeFontSize, weight: .bold)
            let inlineFont = UIFont(name: "FS Sinclair", size: inlineFontSize) ?? UIFont.systemFont(ofSize: inlineFontSize, weight: .bold)
            
            
            let largeAttributes: [NSAttributedString.Key: Any] = [
                .font: largeFont
            ]
            
            let inlineAttributes: [NSAttributedString.Key: Any] = [
                .font: inlineFont
            ]
            
            controller.navigationBar.titleTextAttributes = inlineAttributes
            
            controller.navigationBar.largeTitleTextAttributes = largeAttributes
            
            
            
        }
        
    }
    
    
}

struct PlanetPosition {
    let name: String
    let index: Int
    let xMultiplier: Double
    let yMultiplier: Double
}
