//
//  Error.swift
//  Animality
//
//  Created by t2025-m0143 on 2/27/26.
//
import UIKit

enum NetworkingError:String, Error {
    case invalid
    case noData
    case failedToDecode = "디코딩에 실패하였습니다."
}

enum UIError: String, Error {
    case deniedAuth = "위치 권한이 거절된 상태이므로 현재 위치를 찾을 수 없습니다.\n설정에서 Animality 앱의 위치 권한을 허용해 주세요."
    case invalidLocation = "현재 위치를 찾을 수 없습니다."
}

extension UIAlertController {
    convenience init(status: UIError) {
        self.init(title: "오류", message: status.rawValue, preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "확인", style: .default)
        addAction(confirm)
    }
    
    convenience init(status: NetworkingError) {
        self.init(title: "오류", message: status.rawValue, preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "확인", style: .default)
        addAction(confirm)
    }
}
