//
//  DirectionsSearchView.swift
//  MapsUIKitSwiftUI
//
//  Created by joe on 2023/06/22.
//

import SwiftUI
import MapKit

struct DirectionsMapView: UIViewRepresentable {
    
    @EnvironmentObject var env: DirectionsEnvironment
    
    typealias UIViewType = MKMapView
    
    let mapView = MKMapView()
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(mapView: mapView)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        init(mapView: MKMapView) {
            super.init()
            mapView.delegate = self
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor =  .red
            renderer.lineWidth = 5
            return renderer
        }
    }
    
    func makeUIView(context: Context) -> MKMapView {
        mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeOverlays(uiView.overlays)
        uiView.removeAnnotations(uiView.annotations)
        
        [env.sourceMapItem, env.destinationMapItem]
            .compactMap{$0}.forEach { mapItem in
                let annotation = MKPointAnnotation()
                annotation.title = mapItem.name
                annotation.coordinate = mapItem.placemark.coordinate
                uiView.addAnnotation(annotation)
            }
        uiView.showAnnotations(uiView.annotations, animated: false)
        
        if let route = env.route {
            uiView.addOverlay(route.polyline)
        }
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
        })
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

struct DirectionsSearchView: View {
    @EnvironmentObject var env: DirectionsEnvironment
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    VStack {
                        SourceMapItemView()
                        DestinationMapItemView()
                    }
                    .padding()
                    .background(Color.blue)
                    
                    DirectionsMapView()
                        .edgesIgnoringSafeArea(.bottom)
                }
                
                if env.isCalculatingDirections {
                    VStack {
                        Spacer()
                        VStack {
                            LoadingHUD()
                            Text("Loading...")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.black)
                        .cornerRadius(5)
                        
                        Spacer()
                    }
                }
            }
        }
    }
}

struct LoadingHUD: UIViewRepresentable {
    typealias UIViewType = UIActivityIndicatorView
    
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let aiv = UIActivityIndicatorView(style: .large)
        aiv.color = .white
        aiv.startAnimating()
        return aiv
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
        
    }
}

struct SourceMapItemView: View {
    @EnvironmentObject var env: DirectionsEnvironment
    
    var body: some View {
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
    }
}

struct DestinationMapItemView: View {
    @EnvironmentObject var env: DirectionsEnvironment
    
    var body: some View {
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
}

import Combine

// treat the env as the brain of the application
class DirectionsEnvironment: ObservableObject {
    @Published var isCalculatingDirections = false
    
    @Published var isSelectingSource = false
    @Published var isSelectingDestination = false
    
    @Published var sourceMapItem: MKMapItem?
    @Published var destinationMapItem: MKMapItem?
    
    @Published var route: MKRoute?
    
    var cancellable: AnyCancellable?
    
    init() {
        // listen for changes on sourceMapItem, destinationMapItem
        cancellable = Publishers.CombineLatest($sourceMapItem, $destinationMapItem).sink { [weak self] items in
            
            // searching for directions
            let request = MKDirections.Request()
            request.source = items.0
            request.destination = items.1
            let directions = MKDirections(request: request)
            
            self?.isCalculatingDirections = true
            self?.route = nil
            
            directions.calculate { [weak self] resp, err in
                self?.isCalculatingDirections = false
                
                if let err = err {
                    print("Failed to calculate directions:", err)
                    return
                }
                
                self?.route = resp?.routes.first
            }
        }
    }
}

struct DirectionsSearchView_Previews: PreviewProvider {
    static var env = DirectionsEnvironment()
    
    static var previews: some View {
        DirectionsSearchView().environmentObject(env)
    }
}
