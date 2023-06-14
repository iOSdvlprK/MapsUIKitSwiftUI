//
//  RouteHeader.swift
//  MapsUIKitSwiftUI
//
//  Created by joe on 2023/06/14.
//

import SwiftUI

class RouteHeader: UICollectionReusableView {
    
    let nameLabel = UILabel(text: "Route Name", font: .systemFont(ofSize: 16))
    let distanceLabel = UILabel(text: "Distance", font: .systemFont(ofSize: 16))
    let estimatedTimeLabel = UILabel(text: "Estimated time...", font: .systemFont(ofSize: 16))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        backgroundColor = .systemGreen
        
        hstack(
            stack(
                nameLabel,
                distanceLabel,
                estimatedTimeLabel,
                spacing: 8
            ), alignment: .center
        ).withMargins(.allSides(16))
        
        nameLabel.attributedText = generateAttributedString(title: "Route", description: "US 101 S")
        distanceLabel.attributedText = generateAttributedString(title: "Distance", description: "13.14 mi")
        estimatedTimeLabel.attributedText = generateAttributedString(title: "Estimated Time", description: "23 min.")
    }
    
    func generateAttributedString(title: String, description: String) -> NSAttributedString {
        let attributeString = NSMutableAttributedString(string: title + ": ", attributes: [.font: UIFont.boldSystemFont(ofSize: 16)])
        attributeString.append(NSAttributedString(string: description, attributes: [.font: UIFont.systemFont(ofSize: 16)]))
        return attributeString
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct RouteHeader_Previews: PreviewProvider {
    static var previews: some View {
        Container()
    }
    
    struct Container: UIViewRepresentable {
        func makeUIView(context: Context) -> some UIView {
            RouteHeader()
        }
        
        func updateUIView(_ uiView: UIViewType, context: Context) {
        }
    }
}
