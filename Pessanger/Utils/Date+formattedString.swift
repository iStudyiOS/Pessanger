//
//  Date+formattedString.swift
//  Pessanger
//
//  Created by 홍경표 on 2021/05/30.
//

import Foundation

extension Date {
    
    enum DateFormatType {
        
        /// " · M월 dd일"
        case one
      
        /// "yyyy년 MM월 dd일 a h:mm"
        case two
        
        var formatter: DateFormatter {
            let dateFormatter = DateFormatter()
            switch self {
            case .one:
                dateFormatter.dateFormat = " · M월 dd일"
                
            case .two:
                dateFormatter.dateFormat = "yyyy년 MM월 dd일 a h:mm"
            }
            return dateFormatter
        }
        
    }
    
    func formattedString(type: DateFormatType) -> String {
        return type.formatter.string(from: self)
    }
    
}
