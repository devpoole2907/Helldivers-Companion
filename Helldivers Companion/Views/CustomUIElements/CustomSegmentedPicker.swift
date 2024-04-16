//
//  CustomSegmentedPicker.swift
//  Helldivers Companion
//
//  Created by James Poole on 17/03/2024.
//

import SwiftUI

struct CustomSegmentedPicker<Item: SegmentedItem>: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var selection: Item
    
    var items: [Item]
    
    var cornerRadius: CGFloat = 20.0
    var borderWidth: CGFloat = 2.0
    
#if os(iOS)
let pickerFontSize: CGFloat = 24


#elseif os(watchOS)
    let pickerFontSize: CGFloat = 10
#endif
    
    var body: some View {
        
        let iconColor = colorScheme == .dark ? Color.gray : Color.black
        
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                
                if let selectedIdx = items.firstIndex(of: selection) {
                    Rectangle()
                        .foregroundStyle(.yellow)
                        //.padding(EdgeInsets(top: borderWidth, leading: borderWidth, bottom: borderWidth, trailing: borderWidth))
                        .frame(width: geo.size.width / CGFloat(items.count))
                        .offset(x: geo.size.width / CGFloat(items.count) * CGFloat(selectedIdx), y: 0)
                      //  .animation(.spring().speed(1.5), value: )
                       
                }
                
                HStack(spacing: 0) {
                    ForEach(items, id: \.self) { item in
                        
                        Button(action: {
                           withAnimation(.spring().speed(1.5)) {
                                selection = item
                            }
                        }) {
                            
                            switch item.contentType {
                            case .image(let imageName):
                                Image(systemName: imageName)
                                    .foregroundStyle(iconColor)
                                    .frame(minWidth: geo.size.width / CGFloat(items.count), maxWidth: .infinity)
                            case .text(let text):
                                Text(text)
                                    .font(Font.custom("FS Sinclair Bold", size: pickerFontSize))
                                    .foregroundStyle(selection == item ? .black : .yellow)
                                    .frame(minWidth: geo.size.width / CGFloat(items.count), maxWidth: .infinity)
                                    .padding(.top, 2)
                            }
                        
                        }.buttonStyle(PlainButtonStyle())
                        
                    }
                                        
                                    
                                }
                                .frame(height: 30)
                                
                            }
            .frame(maxHeight: 30)
                                       .padding(4)
                                       .border(Color.white)
                                       .padding(4)
                                       .border(Color.gray)
                            
                        }
        .frame(maxWidth: 300).padding(.trailing, 14)
        
        
    }
}

#Preview {
    
    
    var items: [SimpleSegmentedItem] = [
            SimpleSegmentedItem(contentType: .text("Liberation")),
            SimpleSegmentedItem(contentType: .text("Players"))
        ]
        
    @State var selected = items[0] // Default selection
        
      
           return CustomSegmentedPicker(selection: $selected, items: items)
               
        
    
    
}

public enum SegmentedContentType {
    case image(String)
    case text(String)
}

protocol SegmentedItem: Hashable {
    var contentType: SegmentedContentType { get }
}

struct SimpleSegmentedItem: SegmentedItem {
    static func == (lhs: SimpleSegmentedItem, rhs: SimpleSegmentedItem) -> Bool {
        lhs.id == rhs.id
    }
    
    let id = UUID() // The unique identifier
    var contentType: SegmentedContentType

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        switch contentType {
        case .image(let imageName):
            hasher.combine(imageName)
        case .text(let text):
            hasher.combine(text)
        }
    }
}

struct CustomTogglePicker: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var selection: Bool
    
    var cornerRadius: CGFloat = 20.0
    var borderWidth: CGFloat = 2.0
    
    var body: some View {
        let iconColor = colorScheme == .dark ? Color.gray : Color.black
        
        
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundStyle(.yellow)
                    .frame(width: geo.size.width / 2, height: 30)
                    .offset(x: selection ? geo.size.width / 2 : 0, y: 0)
                    .animation(.spring().speed(1.5), value: selection)
                
                HStack(spacing: 0) {
                    Button(action: {
                        withAnimation(.spring().speed(1.5)) {
                            selection = false
                        }
                    }) {
                        Text("Disabled")
                            .font(Font.custom("FS Sinclair Bold", size: 18))
                            .foregroundStyle(selection ? iconColor : .black)
                            .frame(width: geo.size.width / 2, height: 30)
                    }.buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        withAnimation(.spring().speed(1.5)) {
                            selection = true
                        }
                    }) {
                        Text("Enabled")
                            .font(Font.custom("FS Sinclair Bold", size: 18))
                            .foregroundStyle(selection ? .black : iconColor)
                            .frame(width: geo.size.width / 2, height: 30)
                    }.buttonStyle(PlainButtonStyle())
                }
            }
            .frame(height: 30)
        }
        .frame(maxWidth: 300)
        
        
        
    }
}
