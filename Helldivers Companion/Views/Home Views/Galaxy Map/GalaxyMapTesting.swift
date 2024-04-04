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
        PlanetPosition(name: "Aesir Pass", xMultiplier: 0.3295573311865301, yMultiplier: 0.358154903867812),
        PlanetPosition(name: "Nivel 43", xMultiplier: 0.7361429346008855, yMultiplier: 0.2909816143379798),
        PlanetPosition(name: "Zagon Prime", xMultiplier: 0.7746847886241806, yMultiplier: 0.2598691283676274),
        PlanetPosition(name: "Oshaune", xMultiplier: 0.8070688172352688, yMultiplier: 0.30275751141320695),
        PlanetPosition(name: "Hellmire", xMultiplier: 0.7525436023620994, yMultiplier: 0.3289626000751579),
        PlanetPosition(name: "Estanu", xMultiplier: 0.7889382845490037, yMultiplier: 0.3593497043818859),
        PlanetPosition(name: "Crimsica", xMultiplier: 0.8024757796775192, yMultiplier: 0.3915002451438423),
        PlanetPosition(name: "Fori Prime", xMultiplier: 0.8403091221000497, yMultiplier: 0.3541212208675948),
        PlanetPosition(name: "Navi VII", xMultiplier: 0.882045452882993, yMultiplier: 0.3329452360573202),
        PlanetPosition(name: "Partion", xMultiplier: 0.9147589382707978, yMultiplier: 0.45235491458932386),
        PlanetPosition(name: "Peacock", xMultiplier: 0.9590520534286878, yMultiplier: 0.49822160692328593),
        PlanetPosition(name: "Azur Secundus", xMultiplier: 0.9294494557543453, yMultiplier: 0.3274386386519451),
        PlanetPosition(name: "Trandor", xMultiplier: 0.9514951118071128, yMultiplier: 0.5613735435108829),
        PlanetPosition(name: "Epsilon Phoencis VI", xMultiplier: 0.7776432263300389, yMultiplier: 0.20079762926684974),
        PlanetPosition(name: "Enuliale", xMultiplier: 0.7340683204700845, yMultiplier: 0.16452247801882489),
        PlanetPosition(name: "Diaspora X", xMultiplier: 0.7590414587218323, yMultiplier: 0.12621453302501223),
        PlanetPosition(name: "Omicron", xMultiplier: 0.834960770881576, yMultiplier: 0.26104292824950404),
        PlanetPosition(name: "Nabatea Secundus", xMultiplier: 0.876263110753426, yMultiplier: 0.23912563575411871),
        PlanetPosition(name: "Gemstone Bluffs", xMultiplier: 0.8237958561208288, yMultiplier: 0.19982692246747702),
        PlanetPosition(name: "Blistica", xMultiplier: 0.41814371250787175, yMultiplier: 0.100993288145485),
        PlanetPosition(name: "Kuma", xMultiplier: 0.5163659870323297, yMultiplier: 0.04444234125195041),
        PlanetPosition(name: "Mordia 9", xMultiplier: 0.6529783810585763, yMultiplier: 0.12199034298999062),
        PlanetPosition(name: "Seasse", xMultiplier: 0.5515901082895129, yMultiplier: 0.9070767285034171),
        PlanetPosition(name: "Keid", xMultiplier: 0.3726764699075898, yMultiplier: 0.831345850033847),
        PlanetPosition(name: "Khandark", xMultiplier: 0.3179710500901591, yMultiplier: 0.7603730946933747),
        PlanetPosition(name: "Botein", xMultiplier: 0.31104463902898405, yMultiplier: 0.7154279010396212),
        PlanetPosition(name: "Elysian Meadows", xMultiplier: 0.37610143643043864, yMultiplier: 0.6691695807852359),
        PlanetPosition(name: "Calypso", xMultiplier: 0.3984759850931511, yMultiplier: 0.705443916784242),
        PlanetPosition(name: "Alaraph", xMultiplier: 0.4821858774545993, yMultiplier: 0.7700535898229325),
        PlanetPosition(name: "Alathfar XI", xMultiplier: 0.4391815831867706, yMultiplier: 0.7509604707003373),
        PlanetPosition(name: "Andar", xMultiplier: 0.4008125077212436, yMultiplier: 0.7426339472242769),
        PlanetPosition(name: "Asperoth Prime", xMultiplier: 0.3830288398661124, yMultiplier: 0.78197258878753),
        PlanetPosition(name: "Rogue 5", xMultiplier: 0.5721286123872024, yMultiplier: 0.9478593770915831),
        PlanetPosition(name: "Rirga Bay", xMultiplier: 0.5469416024754225, yMultiplier: 0.8565527189237997),
        PlanetPosition(name: "Hydrobius", xMultiplier: 0.47768957814948315, yMultiplier: 0.846311976424117),
        PlanetPosition(name: "Haka", xMultiplier: 0.7860038047917166, yMultiplier: 0.72447057807493),
        PlanetPosition(name: "Afoyay Bay", xMultiplier: 0.6502492276392899, yMultiplier: 0.7136072908984642),
        PlanetPosition(name: "Myrium", xMultiplier: 0.5620816032765965, yMultiplier: 0.6508602639948299),
        PlanetPosition(name: "Prosperity Falls", xMultiplier: 0.4992268253569308, yMultiplier: 0.5625194987765264),
        PlanetPosition(name: "Crucible", xMultiplier: 0.6160498924469091, yMultiplier: 0.5140317422728461),
        PlanetPosition(name: "Marre IV", xMultiplier: 0.599386874236101, yMultiplier: 0.5703442379884682),
        PlanetPosition(name: "Caramoor", xMultiplier: 0.6585832771357206, yMultiplier: 0.5617590894323342),
        PlanetPosition(name: "Inari", xMultiplier: 0.7168374075966262, yMultiplier: 0.5293230203357617),
        PlanetPosition(name: "Okul VI", xMultiplier: 0.47016712985462356, yMultiplier: 0.5798324643989486),
        PlanetPosition(name: "Solghast", xMultiplier: 0.4529295438535695, yMultiplier: 0.614141756495475),
        PlanetPosition(name: "Diluvia", xMultiplier: 0.43286851371716106, yMultiplier: 0.5978614577013275),
        PlanetPosition(name: "Maw", xMultiplier: 0.33598957998949325, yMultiplier: 0.5249579647509706),
        PlanetPosition(name: "Wraith", xMultiplier: 0.4293224081648655, yMultiplier: 0.49090614285198586),
        PlanetPosition(name: "Atrama", xMultiplier: 0.3789014877301184, yMultiplier: 0.4853033846858009),
        PlanetPosition(name: "Emeria", xMultiplier: 0.38042738618722316, yMultiplier: 0.45163109500187376),
        PlanetPosition(name: "Igla", xMultiplier: 0.41579245331039566, yMultiplier: 0.46509212720386217),
        PlanetPosition(name: "Mastia", xMultiplier: 0.437163990793065, yMultiplier: 0.3496879242315055),
        PlanetPosition(name: "Barabos", xMultiplier: 0.4081076855804344, yMultiplier: 0.43019618311324015),
        PlanetPosition(name: "Borea", xMultiplier: 0.34502307935915333, yMultiplier: 0.4361879529576179),
        PlanetPosition(name: "Oslo Station", xMultiplier: 0.29175028059000385, yMultiplier: 0.47633213293745835),
        PlanetPosition(name: "New Kiruna", xMultiplier: 0.44113310295242486, yMultiplier: 0.44686210705674795),
        PlanetPosition(name: "Pathfinder V", xMultiplier: 0.5232165370652127, yMultiplier: 0.4211536016010964),
        PlanetPosition(name: "Sulfura", xMultiplier: 0.5847716636303844, yMultiplier: 0.40933338342131),
        PlanetPosition(name: "Nublaria I", xMultiplier: 0.6006652707602507, yMultiplier: 0.43651228599158987),
        PlanetPosition(name: "Moradesh", xMultiplier: 0.663271720104393, yMultiplier: 0.42678510948868026),
        PlanetPosition(name: "Shallus", xMultiplier: 0.46964149826110446, yMultiplier: 0.37935673546253595),
        PlanetPosition(name: "Shelt", xMultiplier: 0.47232911787580556, yMultiplier: 0.32224399856365443),
        PlanetPosition(name: "Gaellivare", xMultiplier: 0.4209604539845787, yMultiplier: 0.297626426756639),
        PlanetPosition(name: "Mortax Prime", xMultiplier: 0.5166584626692373, yMultiplier: 0.2342689023400032),
        PlanetPosition(name: "Kirrik", xMultiplier: 0.5620584167371291, yMultiplier: 0.243240450703276),
        PlanetPosition(name: "Deneb Secundus", xMultiplier: 0.5454705705767486, yMultiplier: 0.13836773371948838),
        PlanetPosition(name: "Electra Bay", xMultiplier: 0.6068969247787105, yMultiplier: 0.1533773986894868),
        PlanetPosition(name: "Euphoria III", xMultiplier: 0.6583456153764962, yMultiplier: 0.07230251218534288),
        PlanetPosition(name: "Skitter", xMultiplier: 0.5758116367845796, yMultiplier: 0.046217295809218746),
        PlanetPosition(name: "Senge 23", xMultiplier: 0.4841570270511618, yMultiplier: 0.9128236044399665),
        PlanetPosition(name: "Vernon Wells", xMultiplier: 0.36962835867708294, yMultiplier: 0.3149168483178319),
        PlanetPosition(name: "Menkent", xMultiplier: 0.3472407062968212, yMultiplier: 0.27474959167663177),
        PlanetPosition(name: "Claorell", xMultiplier: 0.47807136972024994, yMultiplier: 0.2405101564981644),
        PlanetPosition(name: "Vog-sojoth", xMultiplier: 0.4402403996424072, yMultiplier: 0.23182205213342935),
        PlanetPosition(name: "Chort Bay", xMultiplier: 0.33575785468295233, yMultiplier: 0.2291925736194368),
        PlanetPosition(name: "Fort Justice", xMultiplier: 0.46567249242306824, yMultiplier: 0.4485362782650637),
        PlanetPosition(name: "Kelvinor", xMultiplier: 0.4300729618283213, yMultiplier: 0.5147190237394556),
        PlanetPosition(name: "Obari", xMultiplier: 0.3821435759559584, yMultiplier: 0.5499943007637347),
        PlanetPosition(name: "Fort Sanctuary", xMultiplier: 0.5752936554549206, yMultiplier: 0.6017686123271623),
        PlanetPosition(name: "Volterra", xMultiplier: 0.6477465063833985, yMultiplier: 0.5164586892766384),
        PlanetPosition(name: "Alta V", xMultiplier: 0.6802864592706263, yMultiplier: 0.5226495235342576),
        PlanetPosition(name: "Skaash", xMultiplier: 0.7059168923845217, yMultiplier: 0.5830260375765806),
        PlanetPosition(name: "Hadar", xMultiplier: 0.7550483076105056, yMultiplier: 0.686023859718506),
        PlanetPosition(name: "Herthon Secundus", xMultiplier: 0.6314405037013746, yMultiplier: 0.7884149787800677),
        PlanetPosition(name: "Heze Bay", xMultiplier: 0.5228979420098998, yMultiplier: 0.8148917952654249),
        PlanetPosition(name: "Karlia", xMultiplier: 0.43515901999958134, yMultiplier: 0.8209275639784579),
        PlanetPosition(name: "Setia", xMultiplier: 0.422364273741221, yMultiplier: 0.920809143733048),
        PlanetPosition(name: "RD-4", xMultiplier: 0.6408613076255166, yMultiplier: 0.9275913068577621),
        PlanetPosition(name: "Halies Port", xMultiplier: 0.7364142249139981, yMultiplier: 0.7872423463545123),
        PlanetPosition(name: "Prasa", xMultiplier: 0.8253598023881523, yMultiplier: 0.7794196737402732),
        PlanetPosition(name: "Myradesh", xMultiplier: 0.38571677126110415, yMultiplier: 0.5147218600255961),
        PlanetPosition(name: "Gunvald", xMultiplier: 0.330037332000711, yMultiplier: 0.4725227854902603),
        PlanetPosition(name: "Fenmire", xMultiplier: 0.4167211803711799, yMultiplier: 0.4008753692441861),
        PlanetPosition(name: "Tarsh", xMultiplier: 0.39898333209469433, yMultiplier: 0.36066957801309835),
        PlanetPosition(name: "Tien Kwan", xMultiplier: 0.19218924835264609, yMultiplier: 0.5601358847190583),
        PlanetPosition(name: "Kuper", xMultiplier: 0.2731445554050094, yMultiplier: 0.5436176279647271),
        PlanetPosition(name: "The Weir", xMultiplier: 0.292231173629539, yMultiplier: 0.5134153234822127),
        PlanetPosition(name: "Caph", xMultiplier: 0.24523777350404483, yMultiplier: 0.5180445281238022),
        PlanetPosition(name: "Castor", xMultiplier: 0.22809724060707537, yMultiplier: 0.553573190462778),
        PlanetPosition(name: "Lastofe", xMultiplier: 0.19617200665607248, yMultiplier: 0.520589725988763),
        PlanetPosition(name: "Hort", xMultiplier: 0.6204544062281538, yMultiplier: 0.8414615567329763),
        PlanetPosition(name: "Hesoe Prime", xMultiplier: 0.6765406795776299, yMultiplier: 0.8621195480577696),
        PlanetPosition(name: "Ras Algethi", xMultiplier: 0.7427431641053328, yMultiplier: 0.849296217634122),
        PlanetPosition(name: "Propus", xMultiplier: 0.788961010495404, yMultiplier: 0.832734667560541),
        PlanetPosition(name: "Zea Rugosia", xMultiplier: 0.6785916719345066, yMultiplier: 0.7552068607013058),
        PlanetPosition(name: "Haldus", xMultiplier: 0.7278131041489989, yMultiplier: 0.7206689309371214),
        PlanetPosition(name: "Seyshel Beach", xMultiplier: 0.5459253805089503, yMultiplier: 0.6086293338251524),
        PlanetPosition(name: "Midasburg", xMultiplier: 0.5329706110058554, yMultiplier: 0.5715406161846743),
        PlanetPosition(name: "Veil", xMultiplier: 0.6147569963126004, yMultiplier: 0.5465710459800907),
        PlanetPosition(name: "Widow's Harbor", xMultiplier: 0.5596571776509977, yMultiplier: 0.4447195843420879)
        
        
    ]
    

    var body: some View {
        GeometryReader { geometry in
            let imageSize = geometry.size
            ZStack {
                Image("sectorMap")
                    .resizable()
                    .frame(width: imageSize.width, height: imageSize.height)
                    .opacity(0.8)
            
                
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
