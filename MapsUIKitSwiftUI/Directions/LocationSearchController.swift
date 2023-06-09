//
//  LocationSearchController.swift
//  MapsUIKitSwiftUI
//
//  Created by joe on 2023/06/11.
//

import SwiftUI
import LBTATools
import MapKit
import Combine

class LocationSearchCell: LBTAListCell<MKMapItem> {
    override var item: MKMapItem! {
        didSet {
//            print(item.name)
            nameLabel.text = item.name
            addressLabel.text = item.address()
        }
    }
    
    let nameLabel = UILabel(text: "Name", font: .boldSystemFont(ofSize: 16))
    let addressLabel = UILabel(text: "Address", font: .systemFont(ofSize: 14))
    
    override func setupViews() {
//        backgroundColor = .systemGreen
        stack(nameLabel,
              addressLabel
        ).withMargins(.allSides(16))
        
        addSeparatorView(leftPadding: 16)
    }
}

class LocationSearchController: LBTAListController<LocationSearchCell, MKMapItem> {
    
    var selectionHandler: ((MKMapItem) -> ())?
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        navigationController?.popViewController(animated: true)
        
        let mapItem = self.items[indexPath.item]
        selectionHandler?(mapItem)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.items = ["1", "2"]
        
        searchTextField.becomeFirstResponder()
        
        performLocalSearch()
        setupSearchBar()
    }
    
    let searchTextField = IndentedTextField(placeholder: "Enter search term", padding: 12)
    // #imageLiteral(resourceName: "back_arrow")
    let backIcon = UIButton(image: UIImage(named: "back_arrow")!, tintColor: .black, target: nil, action: #selector(handleBack)).withWidth(32)
    
    @objc fileprivate func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    let navBarHeight: CGFloat = 66
    
    fileprivate func setupSearchBar() {
        let navBar = UIView(backgroundColor: .white)
        view.addSubview(navBar)
        navBar.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 0, bottom: -navBarHeight, right: 0))
        collectionView.verticalScrollIndicatorInsets.top = navBarHeight
        
        let container = UIView()
        navBar.addSubview(container)
        container.fillSuperviewSafeAreaLayoutGuide()
        container.hstack(backIcon, searchTextField,
                         spacing: 12
        ).withMargins(UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16))
        searchTextField.layer.borderWidth = 2
        searchTextField.layer.borderColor = UIColor.lightGray.cgColor
        searchTextField.layer.cornerRadius = 5
        
        setupSearchListener()
    }
    
    var cancellable: AnyCancellable?
    
    fileprivate func setupSearchListener() {
        cancellable = NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: searchTextField)
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.performLocalSearch()
            }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: navBarHeight, left: 0, bottom: 0, right: 0)
    }
    
    fileprivate func performLocalSearch() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchTextField.text
        
        let search = MKLocalSearch(request: request)
        search.start { resp, err in
            // check err
            if let err = err {
                print("Failed local search:", err)
                return
            }
            
            self.items = resp?.mapItems ?? []
        }
    }
}

extension LocationSearchController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 70)
    }
}

struct LocationSearchController_Previews: PreviewProvider {
    static var previews: some View {
        ContainerView()
            .edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> some UIViewController {
            LocationSearchController()
        }
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        }
    }
}
