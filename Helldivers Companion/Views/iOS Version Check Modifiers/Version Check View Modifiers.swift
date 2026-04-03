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

struct ChartXSelectioniOS17: ViewModifier {
    
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
        self.modifier(ChartXSelectioniOS17(selection: selection))
    }
}

@available(watchOS 9.0, *)
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
@available(watchOS 9.0, *)
extension View {
    
    func chartOverlayiOS16<V: View>(content: @escaping (ChartProxy) -> V) -> some View {
        
        self.modifier(CustomChartOverlayModifier(overlayContent: content))
        
    }
    
}

struct CustomSheetBackgroundModifier: ViewModifier {
    
    var ultraThin: Bool = true
    
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            // Let the system apply Liquid Glass sheet styling automatically
            content
        } else if #available(iOS 16.4, *), #available(watchOS 10, *) {
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

#if os(iOS)
/// Applies Liquid Glass button styling on iOS 26+, legacy material styling on older OS.
struct MajorOrderButtonStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 12))
        } else {
            content
                .background(Material.thin)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 3)
        }
    }
}

/// Positions the Major Order button above the tab bar.
/// On iOS 26+, reads the actual bottom safe area inset via GeometryReader and adds
/// a margin on top of it to clear the native tab bar. On older iOS, uses a fixed
/// bottom padding to clear the custom tab bar overlay.
/// Use only at the root ZStack level where GeometryReader can expand freely.
struct MajorOrderButtonPaddingModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            GeometryReader { geo in
                content
                    .padding(.bottom, geo.safeAreaInsets.bottom + 30)
                    .padding(.trailing, geo.safeAreaInsets.trailing + 10)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
        } else {
            content
                .padding(.bottom, 60)
                .padding(.trailing, 10)
        }
    }
}

/// Positions a floating button above the tab bar inside a ZStack.
/// Unlike MajorOrderButtonPaddingModifier, this does not use GeometryReader,
/// making it safe to use inside constrained layouts like PlanetInfoView's ZStack.
/// On iOS 26+, the native tab bar manages safe area so only a small margin is needed.
/// On older iOS, uses a fixed padding to clear the custom tab bar overlay.
struct FloatingButtonBottomPaddingModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content.safeAreaPadding(.bottom, 10)
        } else {
            content.padding(.bottom, 60)
        }
    }
}
#endif
