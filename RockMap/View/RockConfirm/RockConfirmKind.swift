//
//  RockConfirmKind.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/12.
//

import Foundation

extension RockConfirmViewController {
    
    enum SectionLayoutKind: CaseIterable {
        case name
        case desc
        case location
        case images
        case register
        
        var headerTitle: String {
            switch self {
            case .name:
                return "岩名"
                
            case .desc:
                return "詳細"
                
            case .location:
                return "住所"
                
            case .images:
                return "画像"
                
            default:
                return ""
                
            }
        }
        
        var headerIdentifer: String {
            switch self {
            case .name, .desc, .location, .images:
                return TitleSupplementaryView.className
                
            default:
                return ""
            }
        }
    }
    
    enum ItemKind: Hashable {
        case name(String)
        case desc(String)
        case location(LocationManager.LocationStructure)
        case images(IdentifiableData)
        case register
    }
    
}
