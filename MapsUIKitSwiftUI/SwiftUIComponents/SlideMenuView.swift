//
//  SlideMenuView.swift
//  MapsUIKitSwiftUI
//
//  Created by joe on 2023/06/27.
//

import SwiftUI
import MapKit

struct SlideMenuView: View {
    @State var isMenuShowing = false
    
    var body: some View {
        ZStack {
            SlideMenuMapView()
                .edgesIgnoringSafeArea(.all)
            
            HStack {
                VStack {
                    Button(action: {
                        self.isMenuShowing.toggle()
                    }, label: {
                        Image(systemName: "line.horizontal.3.decrease.circle.fill")
                            .font(.system(size: 34))
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                    })
                    Spacer()
                }
                Spacer()
            }
            .padding()
            
            Color(UIColor(white: 0, alpha: self.isMenuShowing ? 0.5 : 0))
                .edgesIgnoringSafeArea(.all)
                .animation(.spring(), value: self.isMenuShowing)
            
            HStack {
                ZStack {
                    Color.white
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            self.isMenuShowing.toggle()
                        }
                    
                    VStack {
                        Text("Menu")
                        Spacer()
                    }
                }
                .frame(width: 230)
                
                Spacer()
            }
            .offset(x: self.isMenuShowing ? 0 : -230)
//            .animation(.spring())
            .animation(.spring(), value: self.isMenuShowing)
        }
    }
}

struct SlideMenuMapView: UIViewRepresentable {
    typealias UIViewType = MKMapView
    
    func makeUIView(context: Context) -> MKMapView {
        MKMapView()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

struct SlideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SlideMenuView()
    }
}
