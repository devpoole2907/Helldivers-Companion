//
//  MajorOrderTimeView.swift
//  Helldivers Companion
//
//  Created by James Poole on 21/03/2024.
//

import SwiftUI

struct MajorOrderTimeView: View {
    
    var timeRemaining = 0
    
    var isWidget = false
    
    var nameSize: CGFloat {
        return isWidget ? 14 : mediumFont
    }
    
    #if os(iOS)
    let alignment: VerticalAlignment = .bottom
    #elseif os(watchOS)
    let alignment: VerticalAlignment = .center
    #endif
    
    var body: some View {
        HStack(alignment: alignment) {
            Text("Major Order ends in:").foregroundStyle(.white)
            #if os(watchOS)
            
                .multilineTextAlignment(.center)
            
            #endif
            Text("\(formatDuration(seconds: timeRemaining))").padding(.top, 2).padding(.horizontal, 16).background(Color.yellow).foregroundStyle(Color.black)
        }.font(Font.custom("FS Sinclair", size: nameSize))
    }
}

#Preview {
    MajorOrderTimeView()
}
