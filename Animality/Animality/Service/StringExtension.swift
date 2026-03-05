//
//  StringExtension.swift
//  Animality
//
//  Created by t2025-m0143 on 3/4/26.
//

import Foundation
import UIKit

extension String {
    func htmlToString() -> NSAttributedString? {
        guard let data = self.data(using: .utf8) else { return nil }
        return try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
    }
}
