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
    var selectedMapItem: MKMapItem?
    var currentLocation = CLLocationCoordinate2D(latitude: 37.7666, longitude: -122.427290)
    
    let mapView = MKMapView()

    func makeCoordinator() -> Coordinator {
        return Coordinator(mapView: mapView)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        init(mapView: MKMapView) {
            super.init()
            mapView.delegate = self
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if !(annotation is MKPointAnnotation) { return nil } // displays user's current location in blue point
            
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "id")
            pinAnnotationView.canShowCallout = true
            return pinAnnotationView
        }
    }
    
    func makeUIView(context: Context) -> MKMapView {
        setupRegionForMap()
        mapView.showsUserLocation = true
        return mapView
    }
    
    fileprivate func setupRegionForMap() {
        let centerCoordinate = CLLocationCoordinate2D(latitude: 37.7666, longitude: -122.427290)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        uRegion = region
        mapView.setRegion(region, animated: true)
    }
    
    /*
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeAnnotations(uiView.annotations)
        uiView.addAnnotations(annotations)
        uiView.showAnnotations(uiView.annotations, animated: false)
        
        uiView.annotations.forEach { annotation in
            if annotation.title == selectedMapItem?.name {
                uiView.selectAnnotation(annotation, animated: true)
            }
        }
    }
    */
    
    // solution to the flashing problem of the map when tapping on one of the carousel buttons
    func updateUIView(_ uiView: MKMapView, context: Context) {
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: currentLocation, span: span)
        uiView.setRegion(region, animated: true)
        
        if annotations.count == 0 {
            uiView.removeAnnotations(uiView.annotations)
            return
        }
        
        if shouldRefreshAnnotations(mapView: uiView) {
            uiView.removeAnnotations(uiView.annotations)
            uiView.addAnnotations(annotations)
            uiView.showAnnotations(uiView.annotations, animated: false)
        }
        
        uiView.annotations.forEach { (annotation) in
            if annotation.title == selectedMapItem?.name {
                uiView.selectAnnotation(annotation, animated: true)
            }
        }
    }
    
    // This checks to see whether or not annotations have changed.  The algorithm generates a hashmap/dictionary for all the annotations and then goes through the map to check if they exist. If it doesn't currently exist, we treat this as a need to refresh the map
    fileprivate func shouldRefreshAnnotations(mapView: MKMapView) -> Bool {
        let grouped = Dictionary(grouping: mapView.annotations, by: { $0.title ?? ""})
        for annotation in annotations {
            if grouped[annotation.title ?? ""] == nil {
                return true
            }
        }
        return false
    }
    
    typealias UIViewType = MKMapView
}

// keep track of properties that view needs to render
class MapSearchingViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var annotations = [MKPointAnnotation]()
    @Published var isSearching = false
    @Published var searchQuery = ""
    @Published var mapItems = [MKMapItem]()
    @Published var selectedMapItem: MKMapItem?
    @Published var currentLocation = CLLocationCoordinate2D(latitude: 37.7666, longitude: -122.427290)
    
    var cancellable: AnyCancellable?
    
    // figure out the user's location
    let locationManager = CLLocationManager()
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let firstLocation = locations.first else { return }
//        print(firstLocation)
        self.currentLocation = firstLocation.coordinate
    }
    
    override init() {
        super.init()
        print("Initializing view model")
        // combine code
        cancellable = $searchQuery.debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] searchTerm in
                self?.performSearch(query: searchTerm)
            }
        
        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()   // not necessarily needed
    }
    
    fileprivate func performSearch(query: String) {
        isSearching = true
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
//        guard let uRegion = uRegion else { return }
//        request.region = uRegion
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        request.region = MKCoordinateRegion(center: currentLocation, span: span)
        
        let localSearch = MKLocalSearch(request: request)
        localSearch.start { resp, err in
            // handle the error
            
            self.mapItems = resp?.mapItems ?? []
            
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
    
    @ObservedObject var vm = MapSearchingViewModel()
    
    var body: some View {
        ZStack(alignment: .top) {
//            Color.yellow
            MapViewContainer(annotations: vm.annotations, selectedMapItem: vm.selectedMapItem, currentLocation: vm.currentLocation)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 12) {
                HStack {
                    TextField("Search terms", text: $vm.searchQuery)
//                        .padding()
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.white)
                }
                .padding()
                .shadow(radius: 3)
                
                if vm.isSearching {
                    Text("Searching...")
                }
                
                Spacer()
                
                ScrollView(.horizontal) {
                    HStack(spacing: 16) {
                        ForEach(vm.mapItems, id: \.self) { item in
                            
                            Button(action: {
                                print(item.name ?? "")
                                self.vm.selectedMapItem = item
                            }, label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.name ?? "")
                                        .font(.headline)
                                    Text(item.placemark.title ?? "")
                                }
                            })
                            .foregroundColor(.black)
                            .padding()
                            .frame(width: 200)
                            .background(Color.white)
                            .cornerRadius(5)
                        }
                    }.padding(.horizontal, 16)
                }.shadow(radius: 5)
            }.padding(EdgeInsets(top: 1, leading: 0, bottom: 0, trailing: 0))
        }
    }
}

struct MapSearchingView_Previews: PreviewProvider {
    static var previews: some View {
        MapSearchingView()
    }
}
