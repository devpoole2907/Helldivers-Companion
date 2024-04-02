//
//  GalaxyMapTesting.swift
//  Helldivers Companion
//
//  Created by James Poole on 02/04/2024.
//

import SwiftUI

struct GalaxyMapTesting: View {
    

    
    
    var body: some View {
        Image("sectorMap")
            .resizable()
            .aspectRatio(contentMode: .fit)
                
                  
    }
}

#Preview {
    MapRootViewTest()
}

struct MapRootViewTest: View {
    
    @State private var currentZoom = 0.0
       @State private var totalZoom = 1.0
    
    @State private var viewOffset = CGSize.zero
     @State private var totalOffset = CGSize.zero
    
    var body: some View {
        
        let minZoom = 0.5
         let maxZoom = 3.0
        
        NavigationStack {
            
            GalaxyMapTesting()
                .scaleEffect(max(minZoom, min(maxZoom, currentZoom + totalZoom)))
            
                .gesture(
                    MagnifyGesture()
                        .onChanged { value in
                            
                         
                                
                                currentZoom = value.magnification - 1
                                
                            
                            
                        }
                        .onEnded { value in
                            totalZoom += currentZoom
                            currentZoom = 0
                        }
                )
            
                .simultaneousGesture(
                                  DragGesture()
                                      .onChanged { value in
                                          viewOffset = value.translation
                                      }
                                      .onEnded { value in
                                          totalOffset = CGSize(width: totalOffset.width + viewOffset.width, height: totalOffset.height + viewOffset.height)
                                          viewOffset = .zero
                                      }
                              )
            
        }
        
    }
    
    
}
