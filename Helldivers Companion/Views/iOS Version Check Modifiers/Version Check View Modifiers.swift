//
//  Version Check View Modifiers.swift
//  Helldivers Companion
//
//  Created by James Poole on 06/04/2024.
//

import SwiftUI
import Charts

#if os(iOS)
struct TitleDisplayModeToolbariOS17: ViewModifier {
    
    func body(content: Content) -> some View {
        
        if #available(iOS 17.0, *) {
            content.toolbarTitleDisplayMode(.inlineLarge)
        } else {
            content
        }
    }
    
}

extension View {
    func inlineLargeTitleiOS17() -> some View {
        self.modifier(TitleDisplayModeToolbariOS17())
    }
}

struct ScrollTargetLayoutiOS17: ViewModifier {
    
    func body(content: Content) -> some View {
        
        if #available(iOS 17.0, *) {
            content.scrollTargetLayout()
        } else {
            content
        }
    }
    
}

extension View {
    func scrollTargetLayoutiOS17() -> some View {
        self.modifier(ScrollTargetLayoutiOS17())
    }
}

struct ScrollPositioniOS17: ViewModifier {
    
    @Binding var scrollPosition: Int?
    
    func body(content: Content) -> some View {
        
        if #available(iOS 17.0, *) {
            content.scrollPosition(id: $scrollPosition)
        } else {
            content
        }
    }
    
}

extension View {
    func scrollPositioniOS17(_ scrollPosition: Binding<Int?>) -> some View {
        self.modifier(ScrollPositioniOS17(scrollPosition: scrollPosition))
    }
}
#endif

struct chartXSelectioniOS17: ViewModifier {
    
    @Binding var selection: Date?
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *), #available(watchOS 10.0, *) {
            
            content.chartXSelection(value: $selection)
            
        } else {
            content
        }
    }
    
}

extension View {
    func chartXSelectioniOS17Modifier(_ selection: Binding<Date?>) -> some View {
        self.modifier(chartXSelectioniOS17(selection: selection))
    }
}

struct CustomChartOverlayModifier<V: View>: ViewModifier {

    let overlayContent: (ChartProxy) -> V
    
    func body(content: Content) -> some View {
        
        if #available(iOS 17.0, *), #available(watchOS 10, *) {
            // do nothing, use built-in modifier .chartXselection
            
            content
            
        } else {
            
        
                content.chartOverlay(content: overlayContent)
           
            
        }
    }
    
    
}

extension View {
    
    func chartOverlayiOS16<V: View>(content: @escaping (ChartProxy) -> V) -> some View {
        
        self.modifier(CustomChartOverlayModifier(overlayContent: content))
        
    }
    
}

struct CustomSheetBackgroundModifier: ViewModifier {
    
    var ultraThin: Bool = true
    
    func body(content: Content) -> some View {
        if #available(iOS 16.4, *), #available(watchOS 10, *) {
            content
                .presentationBackground(ultraThin ? .ultraThinMaterial : .thinMaterial)
        } else {
            content
        }
    }
    
    
}


extension View {
    func customSheetBackground(ultraThin: Bool = true) -> some View {
        self.modifier(CustomSheetBackgroundModifier(ultraThin: ultraThin))
    }
}

struct ConditionalNavigationViewModifier: ViewModifier {
    func body(content: Content) -> some View {

        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
           content.navigationViewStyle(StackNavigationViewStyle())
        } else {
            content
        }
        #else
            content
        #endif
    }
}

extension View {
    func conditionalNavigationViewStyle() -> some View {
        self.modifier(ConditionalNavigationViewModifier())
    }
}
