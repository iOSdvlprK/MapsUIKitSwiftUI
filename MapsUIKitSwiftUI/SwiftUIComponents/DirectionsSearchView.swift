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

struct SelectLocationView: View {
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack {
            Button(action: {
                // need to dismiss this view
                self.isShowing = false
            }, label: {
                Text("Dismiss")
            })
        }
        .navigationBarHidden(true)
    }
}

struct DirectionsSearchView: View {
    @State private var isSelectingSource = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    VStack {
                        HStack(spacing: 16) {
                            Image("start_location_circles")
                                .frame(width: 24)
                            HStack {
//                                Text("Source")
                                Button(action: {
                                    isSelectingSource = true
                                }, label: {
                                    Text("Source")
                                })
                                .foregroundColor(Color.gray)
                                Spacer()
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(3)
                        }
                        .navigationDestination(isPresented: $isSelectingSource, destination: {
                            SelectLocationView(isShowing: $isSelectingSource)
                        })
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
            }
//            .navigationBarTitle("DIRECTIONS")
//            .navigationBarHidden(true)
        }
    }
}

struct DirectionsSearchView_Previews: PreviewProvider {
    static var previews: some View {
        DirectionsSearchView()
    }
}
