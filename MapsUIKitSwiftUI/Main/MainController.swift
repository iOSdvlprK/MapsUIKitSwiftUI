//
//  MainController.swift
//  MapsUIKitSwiftUI
//
//  Created by joe on 2023/06/03.
//

import UIKit
import MapKit
import LBTATools

class MainController: UIViewController {
    
    let mapView = MKMapView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        mapView.fillSuperview()
        
        mapView.mapType = .hybridFlyover
        
        /*
        // enable auto layout
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        */
    }


}

