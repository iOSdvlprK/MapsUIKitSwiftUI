//
//  DirectionsController.swift
//  MapsUIKitSwiftUI
//
//  Created by joe on 2023/06/10.
//

import UIKit
import LBTATools
import MapKit
import SwiftUI
import JGProgressHUD

class DirectionsController: UIViewController, MKMapViewDelegate {
    
    let mapView = MKMapView()
    let navBar = UIView(backgroundColor: #colorLiteral(red: 0.115295358, green: 0.5173764825, blue: 0.9352841377, alpha: 1))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        view.addSubview(mapView)
        
        setupRegionForMap()
        
        setupNavBarUI()
        mapView.anchor(top: navBar.bottomAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        
//        mapView.showsUserLocation = true
        
//        setupStartEndDummyAnnotations()
//        requestForDirections()
    }
    
    fileprivate func setupStartEndDummyAnnotations() {
        let startAnnotation = MKPointAnnotation()
        startAnnotation.coordinate = CLLocationCoordinate2D(latitude: 37.7666, longitude: -122.427290)
        startAnnotation.title = "Start"
        
        let endAnnotation = MKPointAnnotation()
        endAnnotation.coordinate = CLLocationCoordinate2D(latitude: 37.331352, longitude: -122.030331)
        endAnnotation.title = "End"
        
        mapView.addAnnotation(startAnnotation)
        mapView.addAnnotation(endAnnotation)
        
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    fileprivate func requestForDirections() {
        let request = MKDirections.Request()
        
//        let startingPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 37.7666, longitude: -122.427290))
//        request.source = MKMapItem(placemark: startingPlacemark)
        request.source = startMapItem
        
//        let endingPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 37.331352, longitude: -122.030331))
//        request.destination = MKMapItem(placemark: endingPlacemark)
        request.destination = endMapItem
        
//        request.transportType = .walking
//        request.requestsAlternateRoutes = true
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Routing..."
        hud.show(in: view)
        
        let directions = MKDirections(request: request)
        directions.calculate { resp, err in
            hud.dismiss()
            
            if let err = err {
                print("Failed to find routing info:", err)
                return
            }
            
            // success
            print("Found the directions/routing...")
//            guard let route = resp?.routes.first else { return }
//
//            print(route.expectedTravelTime / 60 / 60)
            
//            self.mapView.addOverlay(route.polyline)
            
            resp?.routes.forEach({ route in
                self.mapView.addOverlay(route.polyline)
            })
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = #colorLiteral(red: 0.115295358, green: 0.5173764825, blue: 0.9352841377, alpha: 1)
        polylineRenderer.lineWidth = 5
        return polylineRenderer
    }
    
    let startTextField = IndentedTextField(padding: 12, cornerRadius: 5)
    let endTextField = IndentedTextField(padding: 12, cornerRadius: 5)
    
    fileprivate func setupNavBarUI() {
        view.addSubview(navBar)
        navBar.setupShadow(opacity: 0.5, radius: 5)
        navBar.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: -120, right: 0))
        
        startTextField.attributedPlaceholder = NSAttributedString(string: "Start", attributes: [.foregroundColor: UIColor(white: 1, alpha: 0.5)])
        endTextField.attributedPlaceholder = NSAttributedString(string: "End", attributes: [.foregroundColor: UIColor(white: 1, alpha: 0.5)])
        [startTextField, endTextField].forEach { tf in
            tf.backgroundColor = UIColor(white: 1, alpha: 0.3)
            tf.textColor = .white
        }
        
        let containerView = UIView(backgroundColor: .clear)
        navBar.addSubview(containerView)
        containerView.fillSuperviewSafeAreaLayoutGuide()
        
        let startIcon = UIImageView(image: UIImage(named: "start_location_circles"), contentMode: .scaleAspectFit)
        startIcon.constrainWidth(20)
        
        let endIcon = UIImageView(image: UIImage(named: "annotation_icon")?.withRenderingMode(.alwaysTemplate), contentMode: .scaleAspectFit)
        endIcon.constrainWidth(20)
        endIcon.tintColor = .white
        
        containerView.stack(
            containerView.hstack(startIcon, startTextField, spacing: 16),
            containerView.hstack(endIcon, endTextField, spacing: 16),
            spacing: 12,
            distribution: .fillEqually
        ).withMargins(UIEdgeInsets(top: 0, left: 16, bottom: 12, right: 16))
        
        startTextField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleChangeStartLocation)))
        
        endTextField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleChangeEndLocation)))
        
        navigationController?.navigationBar.isHidden = true
    }
    
    var startMapItem: MKMapItem?
    var endMapItem: MKMapItem?
    
    @objc fileprivate func handleChangeStartLocation() {
        let vc = LocationSearchController()
        vc.selectionHandler = { [weak self] mapItem in
            self?.startTextField.text = mapItem.name
            
            // add starting annotation and also show it in the map
            self?.startMapItem = mapItem
            self?.refreshMap()
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    fileprivate func refreshMap() {
        // remove everything from map
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        if let mapItem = startMapItem {
            let annotation = MKPointAnnotation()
            annotation.coordinate = mapItem.placemark.coordinate
            annotation.title = mapItem.name
            mapView.addAnnotation(annotation)
        }
        
        if let mapItem = endMapItem {
            let annotation = MKPointAnnotation()
            annotation.coordinate = mapItem.placemark.coordinate
            annotation.title = mapItem.name
            mapView.addAnnotation(annotation)
        }
        
        requestForDirections()
        
        mapView.showAnnotations(mapView.annotations, animated: false)
    }
    
    @objc fileprivate func handleChangeEndLocation() {
        let vc = LocationSearchController()
        vc.selectionHandler = { [weak self] mapItem in
            self?.endTextField.text = mapItem.name
            
            // add ending annotation and also show it in the map
            self?.endMapItem = mapItem
            self?.refreshMap()
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc fileprivate func handleBack() {
        navigationController?.popViewController(animated: true)
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

struct DirectionsPreview: PreviewProvider {
    static var previews: some View {
        ContainerView()
            .edgesIgnoringSafeArea(.all)
//            .environment(\.colorScheme, .dark)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> some UIViewController {
            return UINavigationController(rootViewController: DirectionsController())
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        }
    }
}
