//
//  Error.swift
//  Animality
//
//  Created by t2025-m0143 on 2/27/26.
//
import UIKit

enum NetworkingError: Error {
    case invalid
    case noData
    case failedToDecode
}

enum UIError: String, Error {
    case invalidLocation = "현재 위치를 찾을 수 없습니다."
}

extension UIAlertController {
    convenience init(status: UIError) {
        self.init(title: "오류", message: status.rawValue, preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "확인", style: .default)
        addAction(confirm)
    }
}
