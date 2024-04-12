//
//  PlanetImageFormatter.swift
//  Helldivers Companion
//
//  Created by James Poole on 31/03/2024.
//

import Foundation

class PlanetImageFormatter {
    
    static func formattedPlanetImageName(for planetName: String) -> String {
        switch planetName.lowercased() {
        case "alaraph", "veil", "bashyr", "solghast", "alderidge cove", "ain-5", "aesir pass", "pandion-xxiv", "penta", "haka", "nivel 43", "cirrus", "troost", "skat bay", "x-45":
        return "Troost"
    case "ubanea", "fort sanctuary", "freedom peak", "crimsica", "kharst", "minchir", "elysian meadows", "providence", "valgaard", "gatria", "enuliale", "liberty ridge", "stout", "genesis prime", "valmox", "gunvald", "overgoe prime", "kuper", "acrab xi", "ingmar", "yed prior":
        return "Ingmar"
    case "wezen", "pöpli ix", "imber", "partion", "karlia", "hellmire", "menkent", "blistica", "adhara", "grand errant", "bore rock", "marre iv", "kneth port", "asperoth prime":
        return "Hellmire"
    case "alathfar xi", "marfark", "arkturus", "kelvinor", "ivis", "hadar", "okul vi", "khandark", "new stockholm", "new kiruna", "epsilon phoencis vi", "tarsh", "mog", "julheim", "heeth", "parsh", "hesoe prime", "borea", "vog-sojoth", "merga iv", "vandalon iv", "vega bay":
        return "Vandalon IV"
    case "meissa", "mantes", "meridia", "caph", "east iridium trading bay", "clasa", "gaellivare", "irulta", "rogue 5", "oasis", "spherion", "regnus", "baldrick prime", "navi vii", "alta v", "zegema paradise", "gar haren", "primordia", "pollux 31", "nublaria i", "fornskogur ii", "kirrik", "klaka 5":
        return "Mantes"
    case "malevelon creek", "peacock", "brink-2", "gemma", "siemnot", "veld", "seasse", "nabatea secundus", "atrama", "alairt iii", "prosperity falls", "new haven":
        return "Malevelon Creek"
    case "fenrir iii", "zosma", "euphoria iii", "rd-4", "sirius", "maia", "widow's harbor":
        return "Fenrir III"
    case "estanu", "krakatwo", "martyr's bay", "deneb secundus", "krakabos", "igla", "inari", "lesath", "halies port", "barabos", "eukoria", "stor tha prime", "grafmere", "oslo station", "choepessa iv", "acrux ix", "mekbuda":
        return "Estanu"
    case "omicron", "angel's venture", "demiurg", "aurora bay", "martale":
        return "Omicron"
    case "vindemitarix prime", "turing", "zefia", "shallus", "tibit", "iridica", "mordia 9", "sulfura", "seyshel beach":
        return "Turing"
    case "emeria", "kraz", "pioneer ii", "hydrofall prime", "achird iii", "effluvia", "fori prime", "prasa", "kuma", "myrium", "senge 23", "azterra", "calypso", "castor", "cyberstan":
        return "Fori Prime"
    case "draupnir", "varylia 5", "the weir", "reaf", "iro", "termadon", "fort union", "oshaune", "fenmire", "gemstone bluffs", "volterra", "acamar iv", "skitter", "bellatrix", "mintoria", "afoyay bay", "pherkad secundus", "obari", "achernar secundus", "electra bay", "matar bay", "pathfinder v":
        return "Draupnir"
        case "ustotu", "pilen v", "mortax prime", "erata prime", "cerberus iiic", "erson sands", "polaris prime", "zea rugosia", "myradesh", "choohe", "hydrobius", "azur secundus", "canopus":
        return "Ustotu"
    case "durgen", "viridia prime", "moradesh", "zzaniah prime", "heze bay", "ratch", "phact bay", "caramoor", "diaspora x", "propus", "mastia", "zagon prime", "setia", "outpost 32", "osupsam", "lastofe", "klen dahth ii", "keid":
        return "Durgen"
        case "chort bay", "charbal-vii", "wilford station", "darrowsport", "darius ii", "slif", "esker", "botein", "vernen wells", "wraith", "leng secundus", "rirga bay", "skaash", "merak", "shete", "wasat":
        return "Merak"
    
    case "tien kwan":
        return "Tien Kwan"
    default:
        return "MissingPlanetImage"
    }
    
}
    }
