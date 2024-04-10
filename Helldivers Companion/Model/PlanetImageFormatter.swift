//
//  PlanetImageFormatter.swift
//  Helldivers Companion
//
//  Created by James Poole on 31/03/2024.
//

import Foundation

class PlanetImageFormatter {
    
    static func formattedPlanetImageName(for planetName: String) -> String {
        switch planetName {
    case "Alaraph", "Veil", "Bashyr", "Solghast", "Alderidge Cove", "Ain-5", "Aesir Pass", "Pandion-XXIV", "Penta", "Haka", "Nivel 43", "Cirrus", "Troost", "Skat Bay", "X-45":
        return "Troost"
    case "Ubanea", "Fort Sanctuary", "Freedom Peak", "Crimsica", "Kharst", "Minchir", "Elysian Meadows", "Providence", "Valgaard", "Gatria", "Enuliale", "Liberty Ridge", "Stout", "Genesis Prime", "Valmox", "Gunvald", "Overgoe Prime", "Kuper", "Acrab XI", "Ingmar", "Yed Prior":
        return "Ingmar"
    case "Wezen", "Pöpli IX", "Imber", "Partion", "Karlia", "Hellmire", "Menkent", "Blistica", "Adhara", "Grand Errant", "Bore Rock", "Marre IV", "Kneth Port", "Asperoth Prime":
        return "Hellmire"
    case "Alathfar XI", "Marfark", "Arkturus", "Kelvinor", "Ivis", "Hadar", "Okul VI", "Khandark", "New Stockholm", "New Kiruna", "Epsilon Phoencis VI", "Tarsh", "Mog", "Julheim", "Heeth", "Parsh", "Hesoe Prime", "Borea", "Vog-sojoth", "Merga IV", "Vandalon IV", "Vega Bay":
        return "Vandalon IV"
    case "Meissa", "Mantes", "Meridia", "Caph", "East Iridium Trading Bay", "Clasa", "Gaellivare", "Irulta", "Rogue 5", "Oasis", "Spherion", "Regnus", "Baldrick Prime", "Navi VII", "Alta V", "Zegema Paradise", "Gar Haren", "Primordia", "Pollux 31", "Nublaria I", "Fornskogur II", "Kirrik", "Klaka 5":
        return "Mantes"
    case "Malevelon Creek", "Peacock", "Brink-2", "Gemma", "Siemnot", "Veld", "Seasse", "Nabatea Secundus", "Atrama", "Alairt III", "Prosperity Falls", "New Haven":
        return "Malevelon Creek"
    case "Fenrir III", "Zosma", "Euphoria III", "Rd-4", "Sirius", "Maia", "Widow's Harbor":
        return "Fenrir III"
    case "Estanu", "Krakatwo", "Martyr's Bay", "Deneb Secundus", "Krakabos", "Igla", "Inari", "Lesath", "Halies Port", "Barabos", "Eukoria", "Stor Tha Prime", "Grafmere", "Oslo Station", "Choepessa IV", "Acrux IX", "Mekbuda":
        return "Estanu"
    case "Omicron", "Angel's Venture", "Demiurg", "Aurora Bay":
        return "Omicron"
    case "Vindemitarix Prime", "Turing", "Zefia", "Shallus", "Tibit", "Iridica", "Mordia 9", "Sulfura", "Seyshel Beach":
        return "Turing"
    case "Emeria", "Kraz", "Pioneer II", "Hydrofall Prime", "Achird III", "Effluvia", "Fori Prime", "Prasa", "Kuma", "Myrium", "Senge 23", "Azterra", "Calypso", "Castor", "Cyberstan":
        return "Fori Prime"
    case "Draupnir", "Varylia 5", "The Weir", "Reaf", "Iro", "Termadon", "Fort Union", "Oshaune", "Fenmire", "Gemstone Bluffs", "Volterra", "Acamar IV", "Skitter", "Bellatrix", "Mintoria", "Afoyay Bay", "Pherkad Secundus", "Obari", "Achernar Secundus", "Electra Bay", "Matar Bay", "Pathfinder V":
        return "Draupnir"
        case "Ustotu", "Pilen V", "Mortax Prime", "Erata Prime", "Cerberus IIIc", "Erson Sands", "Polaris Prime", "Zea Rugosia", "Myradesh", "Choohe", "Hydrobius", "Azur Secundus", "Canopus":
        return "Ustotu"
    case "Durgen", "Viridia Prime", "Moradesh", "Zzaniah Prime", "Heze Bay", "Ratch", "Phact Bay", "Caramoor", "Diaspora X", "Propus", "Mastia", "Zagon Prime", "Setia", "Outpost 32", "Osupsam", "Lastofe", "Klen Dahth II", "Keid":
        return "Durgen"
        case "Chort Bay", "Charbal-VII", "Wilford Station", "Darrowsport", "Darius II", "Slif", "Esker", "Botein", "Vernen Wells", "Wraith", "Leng Secundus", "Rirga Bay", "Skaash", "Merak", "Shete", "Wasat":
        return "Merak"
    
    case "Tien Kwan":
        return "Tien Kwan"
    default:
        return "MissingPlanetImage"
    }
    
}
    }
