//
//  NewsFeed.swift
//  Helldivers Companion
//
//  Created by James Poole on 24/02/2026.
//


struct NewsFeed: Decodable, Hashable {
    let id: Int
    var message: String?
    var title: String?
    let published: UInt32?
    let tagIds: [Int]?
    let type: Int?
    
    private enum CodingKeys: String, CodingKey {
        case id, message, published, tagIds, type
    }
    
    // custom init handles decoding/processing of message to seperate to title/message if possible
#if DEBUG
    init(id: Int, title: String?, message: String?, published: UInt32?) {
        self.id = id
        self.title = title
        self.message = message
        self.published = published
        self.tagIds = nil
        self.type = nil
    }
#endif

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        published = try container.decodeIfPresent(UInt32.self, forKey: .published)
        tagIds = try container.decodeIfPresent([Int].self, forKey: .tagIds)
        type = try container.decodeIfPresent(Int.self, forKey: .type)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        
        // processing into title/message, sanitise html tags
        if let msg = message {
            if let sanitised = removeHTMLTags(from: msg), !sanitised.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                if let newlineIndex = sanitised.firstIndex(of: "\n") {
                    title = String(sanitised[..<newlineIndex])
                    message = String(sanitised[sanitised.index(after: newlineIndex)...])
                } else {
                    title = "BREAKING NEWS"
                    message = sanitised
                }
            } else {
                // Sanitisation failed or returned empty — fall back to raw
                print("[Widget] Sanitised message was empty, falling back to raw message.")
                title = "BREAKING NEWS"
                message = msg
            }
        }
    }
}
