//
//  MainController.swift
//  MapsUIKitSwiftUI
//
//  Created by joe on 2023/06/03.
//

import UIKit
import MapKit
import LBTATools
import Combine

extension MainController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKPointAnnotation) {
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "id")
            annotationView.canShowCallout = true
            //        annotationView.image = #imageLiteral(resourceName: "tourist.png")
            return annotationView
        }
        return nil
    }
}

class MainController: UIViewController, CLLocationManagerDelegate {
    
    let mapView = MKMapView()
    
    let locationManager = CLLocationManager()

    fileprivate func requestUserLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            print("Received authorization of user location")
            // request for where the user actually is
            locationManager.startUpdatingLocation()
        default:
            print("Failed to authorize")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let firstLocation = locations.first else { return }
        mapView.setRegion(MKCoordinateRegion(center: firstLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)), animated: false)
        
        locationManager.stopUpdatingLocation() // for saving iPhone's GPS power
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestUserLocation()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        view.addSubview(mapView)
        mapView.fillSuperview()
        
        setupRegionForMap()
//        setupAnnotationsForMap()
        performLocalSearch()
        setupSearchUI()
        setupLocationCarousel()
        locationsController.mainController = self
    }
    
    let locationsController = LocationsCarouselController(scrollDirection: .horizontal)
    
    fileprivate func setupLocationCarousel() {
        let locationView = locationsController.view!
        view.addSubview(locationView)
        locationView.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor, size: CGSizeMake(0, 150))
    }
    
    let searchTextField = UITextField(placeholder: "Search query")
    
    var cancellable: AnyCancellable?
    
    fileprivate func setupSearchUI() {
        let whiteContainer = UIView(backgroundColor: .white)
        view.addSubview(whiteContainer)
        whiteContainer.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        
        whiteContainer.stack(searchTextField).withMargins(UIEdgeInsets.allSides(16))
        
        // listen for text changes and then perform new search
        // OLD style
//        searchTextField.addTarget(self, action: #selector(handleSearchChanges), for: .editingChanged)
        
        // NEW STYLE - Search Throttling
        // search on the last keystroke of text changes and basically wait 500 milliseconds
        cancellable = NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: searchTextField)
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { _ in
                self.performLocalSearch()
            }
    }
    
    @objc fileprivate func handleSearchChanges() {
        performLocalSearch()
    }
    
    fileprivate func performLocalSearch() {
        guard let region = self.region else { return }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchTextField.text
//        request.region = mapView.region
        request.region = region
        
        let localSearch = MKLocalSearch(request: request)
        localSearch.start { resp, err in
            if let err = err {
                print("Failed local search:", err)
                return
            }
            
            // Success
            // remove old annotations
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.locationsController.items.removeAll()
            
            resp?.mapItems.forEach({ mapItem in
                print(mapItem.address())
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = mapItem.placemark.coordinate
                annotation.title = mapItem.name
                self.mapView.addAnnotation(annotation)
                
                // tell the locationCarouselController
                self.locationsController.items.append(mapItem)
            })
            
            /* error occurs:
            self.locationsController.collectionView.scrollToItem(at: [0, 0], at: .centeredHorizontally, animated: true)
            */
            
            self.mapView.showAnnotations(self.mapView.annotations, animated: true)
        }
    }
    
    fileprivate func setupAnnotationsForMap() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: 37.7666, longitude: -122.427290)
        annotation.title = "San Francisco"
        annotation.subtitle = "CA"
        mapView.addAnnotation(annotation)
        
        let appleCampusAnnotation = MKPointAnnotation()
        appleCampusAnnotation.coordinate = CLLocationCoordinate2D(latitude: 37.3326, longitude: -122.030024)
        appleCampusAnnotation.title = "Apple Campus"
        appleCampusAnnotation.subtitle = "Cupertino, CA"
        mapView.addAnnotation(appleCampusAnnotation)
        
        mapView.showAnnotations(self.mapView.annotations, animated: true)
    }
    
    fileprivate var region: MKCoordinateRegion?

    fileprivate func setupRegionForMap() {
        let centerCoordinate = CLLocationCoordinate2D(latitude: 37.7666, longitude: -122.427290)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        self.region = region
        mapView.setRegion(region, animated: true)
    }
}

// SwiftUI Preview
import SwiftUI

struct MainPreview: PreviewProvider {
    static var previews: some View {
//        Text("Main Preview HERE")
        ContainerView()
            .edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> MainController {
            return MainController()
        }
        
        func updateUIViewController(_ uiViewController: MainController, context: Context) {
        }
        
        typealias UIViewControllerType = MainController
    }
}

