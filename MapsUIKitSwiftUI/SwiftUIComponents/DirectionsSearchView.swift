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
    @EnvironmentObject var env: DirectionsEnvironment
    
//    @Binding var isShowing: Bool
    @State private var mapItems = [MKMapItem]()
    @State private var searchQuery = ""
    
    var body: some View {
        VStack {
            HStack(spacing: 16) {
                Button(action: {
//                    self.isShowing = false
                    self.env.isSelectingSource = false
                    self.env.isSelectingDestination = false
                }, label: {
                    Image("back_arrow")
                        .renderingMode(.template)
                        .foregroundColor(.black)
                })
                
                TextField("Enter search term", text: $searchQuery)
                    .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification).debounce(for: .milliseconds(500), scheduler: RunLoop.main)) { _ in
                        // search
                        let request = MKLocalSearch.Request()
                        request.naturalLanguageQuery = self.searchQuery
                        let search = MKLocalSearch(request: request)
                        search.start { resp, err in
                            // check the error
                            self.mapItems = resp?.mapItems ?? []
                        }
                    }
            }
            .padding()
            
            ScrollView {
                ForEach(mapItems, id: \.self) { item in
                    Button(action: {
                        if self.env.isSelectingSource {
                            self.env.isSelectingSource = false
                            self.env.sourceMapItem = item
                        } else {
                            self.env.isSelectingDestination = false
                            self.env.destinationMapItem = item
                        }
                        
                    }, label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(item.name ?? "")")
                                    .font(.headline)
                                Text("\(item.address())")
                            }
                            Spacer()
                        }
                        .padding()
                    })
                    .foregroundColor(.black)
                }
            }
            
            Spacer()
        }
        .edgesIgnoringSafeArea(.bottom)
        .onAppear(perform: {
            // dummy search
//            let request = MKLocalSearch.Request()
//            request.naturalLanguageQuery = "Food"
//            let search = MKLocalSearch(request: request)
//            search.start { resp, err in
//                // check the error
//                self.mapItems = resp?.mapItems ?? []
//            }
        })
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

struct DirectionsSearchView: View {
    @EnvironmentObject var env: DirectionsEnvironment
    
//    @State private var isSelectingSource = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    VStack {
                        HStack(spacing: 16) {
                            Image("start_location_circles")
                                .frame(width: 24)
                            HStack {
                                Button(action: {
                                    env.isSelectingSource = true
                                }, label: {
                                    Text(env.sourceMapItem != nil ? (env.sourceMapItem?.name ?? "") : "Source") // come from an env object
                                    Spacer()
                                })
                                .foregroundColor(Color.gray)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(3)
                        }
                        .navigationDestination(isPresented: $env.isSelectingSource, destination: {
                            SelectLocationView()
                        })
                        HStack(spacing: 16) {
                            Image("annotation_icon")
                                .renderingMode(.template)
                                .foregroundColor(.white)
                                .frame(width: 24)
                            HStack {
                                Button(action: {
                                    env.isSelectingDestination = true
                                }, label: {
                                    Text(env.destinationMapItem != nil ? (env.destinationMapItem?.name ?? "") : "Destination")
                                    Spacer()
                                })
                                .foregroundColor(Color.gray)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(3)
                        }
                        .navigationDestination(isPresented: $env.isSelectingDestination) {
                            SelectLocationView()
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

// treat the env as the brain of the application
class DirectionsEnvironment: ObservableObject {
    @Published var isSelectingSource = false
    @Published var isSelectingDestination = false
    
    @Published var sourceMapItem: MKMapItem?
    @Published var destinationMapItem: MKMapItem?
}

struct DirectionsSearchView_Previews: PreviewProvider {
    static var env = DirectionsEnvironment()
    
    static var previews: some View {
        DirectionsSearchView().environmentObject(env)
    }
}
