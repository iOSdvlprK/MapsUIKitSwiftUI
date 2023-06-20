//
//  MapSearchingView.swift
//  MapsUIKitSwiftUI
//
//  Created by joe on 2023/06/19.
//

import SwiftUI
import MapKit
import Combine

var uRegion: MKCoordinateRegion?

struct MapViewContainer: UIViewRepresentable {
    
    var annotations = [MKPointAnnotation]()
    
    let mapView = MKMapView()
    
    func makeUIView(context: Context) -> MKMapView {
        setupRegionForMap()
        return mapView
    }
    
    fileprivate func setupRegionForMap() {
        let centerCoordinate = CLLocationCoordinate2D(latitude: 37.7666, longitude: -122.427290)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        uRegion = region
        mapView.setRegion(region, animated: true)
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        uiView.addAnnotations(annotations)
        uiView.showAnnotations(uiView.annotations, animated: false)
    }
    
    typealias UIViewType = MKMapView
}

// keep track of properties that view needs to render
class MapSearchingViewModel: ObservableObject {
    
    @Published var annotations = [MKPointAnnotation]()
    @Published var isSearching = false
    @Published var searchQuery = "" {
        didSet {
//            print("Search query changing:", _searchQuery)
//            performSearch(query: searchQuery)
        }
    }
    
    var cancellable: AnyCancellable?
    
    init() {
        print("Initializing view model")
        // combine code
        cancellable = $searchQuery.debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] searchTerm in
                self?.performSearch(query: searchTerm)
            }
    }
    
    fileprivate func performSearch(query: String) {
        isSearching = true
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        guard let uRegion = uRegion else { return }
        request.region = uRegion
        
        let localSearch = MKLocalSearch(request: request)
        localSearch.start { resp, err in
            // handle the error
            
            var airportAnnotations = [MKPointAnnotation]()
            
            resp?.mapItems.forEach({ mapItem in
                print(mapItem.name ?? "")
                let annotation = MKPointAnnotation()
                annotation.title = mapItem.name
                annotation.coordinate = mapItem.placemark.coordinate
                airportAnnotations.append(annotation)
            })
            
//            Thread.sleep(forTimeInterval: 1) // wait 1 sec for showing the text
            self.isSearching = false
            self.annotations = airportAnnotations
        }
    }
}

struct MapSearchingView: View {
    
//    @State private var annotations = [MKPointAnnotation]()
    @ObservedObject var vm = MapSearchingViewModel()
    
//    @State private var searchQuery = ""
    
    var body: some View {
        ZStack(alignment: .top) {
//            Color.yellow
            MapViewContainer(annotations: vm.annotations)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 12) {
                HStack {
                    TextField("Search terms", text: $vm.searchQuery)
//                        .padding()
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.white)
                }.shadow(radius: 3)
                    .padding()
                
                if vm.isSearching {
                    Text("Searching...")
                }
            }
            .padding(EdgeInsets(top: 1, leading: 0, bottom: 0, trailing: 0))
            
        }
    }
}

struct MapSearchingView_Previews: PreviewProvider {
    static var previews: some View {
        MapSearchingView()
    }
}
