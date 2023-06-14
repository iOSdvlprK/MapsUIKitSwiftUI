//
//  RoutesController.swift
//  MapsUIKitSwiftUI
//
//  Created by joe on 2023/06/14.
//

import SwiftUI
import LBTATools
import MapKit

class RouteStepCell: LBTAListCell<MKRoute.Step> {
    override var item: MKRoute.Step! {
        didSet {
            nameLabel.text = item.instructions
//                distanceLabel.text = "\(item.distance) m"
            distanceLabel.text = String(format: "%.2f m", item.distance)
//                let milesConversion = item.distance * 0.00062137
//                distanceLabel.text = String(format: "%.2f mi", milesConversion)
        }
    }
    
    let nameLabel = UILabel(text: "Name", numberOfLines: 0)
    let distanceLabel = UILabel(text: "Distance", textAlignment: .right)
    
    override func setupViews() {
        hstack(
            nameLabel,
            distanceLabel.withWidth(80)
        ).withMargins(.allSides(16))
        
        addSeparatorView(leadingAnchor: nameLabel.leadingAnchor)
    }
}

class RoutesController: LBTAListHeaderController<RouteStepCell, MKRoute.Step, RouteHeader>, UICollectionViewDelegateFlowLayout {
    
    var route: MKRoute!
    
    override func setupHeader(_ header: RouteHeader) {
        header.nameLabel.attributedText = header.generateAttributedString(title: "Route", description: route.name)
        
        let kilometersDistance = route.distance / 1000
        let kilometersString = String(format: "%.2f km", kilometersDistance)
//            let milesDistance = route.distance * 0.00062137
//            let milesString = String(format: "%.2f mi", milesDistance)
        header.distanceLabel.attributedText = header.generateAttributedString(title: "Distance", description: kilometersString)
        
        var timeString = ""
        if route.expectedTravelTime > 3600 {
            let h = Int(route.expectedTravelTime / 60 / 60)
            let m = Int((route.expectedTravelTime.truncatingRemainder(dividingBy: 60 * 60)) / 60)
            timeString = String(format: "%d hr %d min", h, m)
        } else {
            let time = Int(route.expectedTravelTime / 60)
            timeString = String(format: "%d min", time)
        }
        header.estimatedTimeLabel.attributedText = header.generateAttributedString(title: "Estimated Time", description: timeString)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: 0, height: 120)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: view.frame.width, height: 70)
    }
}

/*
struct RoutesController_Previews: PreviewProvider {
    static var previews: some View {
        Container()
    }
    
    struct Container: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> some UIViewController {
            RoutesController()
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        }
    }
}
*/
