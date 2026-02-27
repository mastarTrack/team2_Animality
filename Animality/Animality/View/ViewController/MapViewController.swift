//
//  MapViewController.swift
//  Animality
//
//  Created by t2025-m0143 on 2/27/26.
//
import UIKit
import SnapKit
import NMapsMap

class MapViewController: UIViewController {
    let mapView = NMFMapView(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMapView()
        setLayout()
    }
}

//MARK: Set MapView
extension MapViewController {
    private func setMapView() {
        mapView.mapType = .basic // 지도 유형 설정
        mapView.isNightModeEnabled = UITraitCollection.current.userInterfaceStyle == .dark // 다크모드 설정
        mapView.allowsTilting = false // 기울임 설정
    }
    
    private func setLayout() {
        view.addSubview(mapView)
        
        mapView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
