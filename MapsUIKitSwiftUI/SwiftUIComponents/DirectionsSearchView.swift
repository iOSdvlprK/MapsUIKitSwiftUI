//
//  DirectionsSearchView.swift
//  MapsUIKitSwiftUI
//
//  Created by joe on 2023/06/22.
//

import SwiftUI
import MapKit

struct DirectionsMapView: UIViewRepresentable {
    typealias UIViewType = MKMapView
    
    func makeUIView(context: Context) -> MKMapView {
        MKMapView()
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        
    }
}

struct DirectionsSearchView: View {
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                VStack {
                    HStack(spacing: 16) {
                        Image("start_location_circles")
                            .frame(width: 24)
                        HStack {
                            Text("Source")
                            Spacer()
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(3)
                    }
                    HStack(spacing: 16) {
                        Image("annotation_icon")
                            .renderingMode(.template)
                            .foregroundColor(.white)
                            .frame(width: 24)
                        HStack {
                            Text("Destination")
                            Spacer()
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(3)
                    }
                }
                .padding()
                .background(Color.blue)
                
                DirectionsMapView()
                    .edgesIgnoringSafeArea(.bottom)
            }
            
            /*
            // status bar area cover solution (FYI)
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let window = windowScene?.windows.first
            VStack {
                Spacer()
                    .frame(width: window?.frame.width ?? 0, height: window?.safeAreaInsets.top ?? 0)
                    .background(Color.red)
                    .edgesIgnoringSafeArea(.top)
            }
            */
        }
    }
}

struct DirectionsSearchView_Previews: PreviewProvider {
    static var previews: some View {
        DirectionsSearchView()
    }
}
