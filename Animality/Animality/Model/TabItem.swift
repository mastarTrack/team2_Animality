//
//  TabItem.swift
//  Animality
//
//  Created by Hanjuheon on 2/27/26.
//

import UIKit

/// 탭바 정의 아이템 모델
struct TabItem {
    /// 타이틀
    let title: String
    /// 이미지 이름
    let imageName: String
    /// 선택됬을때 이미지 이름
    let selectedImageName: String?
    /// 뷰컨트롤러 타입 설정
    let makeViewController: () -> UIViewController
}
