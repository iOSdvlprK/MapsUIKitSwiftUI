//
//  MapSearchingView.swift
//  MapsUIKitSwiftUI
//
//  Created by joe on 2023/06/19.
//

import SwiftUI
import MapKit

struct MapViewContainer: UIViewRepresentable {
    
    let mapView = MKMapView()
    
    func makeUIView(context: Context) -> MKMapView {
        setupRegionForMap()
        return mapView
    }
    
    fileprivate func setupRegionForMap() {
        let centerCoordinate = CLLocationCoordinate2D(latitude: 37.7666, longitude: -122.427290)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        
    }
    
    typealias UIViewType = MKMapView
}

struct MapSearchingView: View {
    var body: some View {
        ZStack(alignment: .top) {
//            Color.yellow
            MapViewContainer()
                .edgesIgnoringSafeArea(.all)
            
            HStack {
                Button(action: {
                    
                }, label: {
                    Text("Search for airports")
                        .padding()
                        .background(Color.white)
                })
                
                Button(action: {
                    
                }, label: {
                    Text("Clear Annotations")
                        .padding()
                        .background(Color.white)
                })
            }.shadow(radius: 2)
        }
    }
}

struct MapSearchingView_Previews: PreviewProvider {
    static var previews: some View {
        MapSearchingView()
    }
}
