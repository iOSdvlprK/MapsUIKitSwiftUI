//
//  SlideMenuView.swift
//  MapsUIKitSwiftUI
//
//  Created by joe on 2023/06/27.
//

import SwiftUI
import MapKit

struct MenuItem: Identifiable, Hashable {
    let id = UUID().uuidString
    let title: String
    let mapType: MKMapType
    let imageName: String
}

struct SlideMenuView: View {
    @State var isMenuShowing = false
    @State var mapType: MKMapType = .standard
    
    let menuItems: [MenuItem] = [
        MenuItem(title: "Standard", mapType: .standard, imageName: "car"),
        MenuItem(title: "Hybrid", mapType: .hybrid, imageName: "antenna.radiowaves.left.and.right"),
        MenuItem(title: "Globe", mapType: .satelliteFlyover, imageName: "safari")
    ]
    
    var body: some View {
        ZStack {
            SlideMenuMapView(mapType: mapType)
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
                    
                    HStack {
                        VStack {
                            HStack {
                                Text("Menu")
                                    .font(.system(size: 26, weight: .bold))
                                Spacer()
                            }
                            .padding()
                            
                            VStack {
                                ForEach(menuItems, id: \.self) { item in
                                    Button(action: {
                                        self.mapType = item.mapType
                                        self.isMenuShowing.toggle()
                                    }, label: {
                                        HStack(spacing: 16) {
                                            Image(systemName: item.imageName)
                                            Text(item.title)
                                            Spacer()
                                        }
                                        .padding()
                                    })
                                    .foregroundColor(.black)
                                }
                            }
                            
                            Spacer()
                        }
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
    
    var mapType: MKMapType
    
    func makeUIView(context: Context) -> MKMapView {
        MKMapView()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.mapType = mapType
    }
}

struct SlideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        SlideMenuView()
    }
}
