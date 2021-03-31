//
//  File.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/10.
//

import UIKit
import CoreLocation

extension RockRegisterViewController {
    
    enum SectionLayoutKind: CaseIterable {
        case name
        case desc
        case location
        case season
        case lithology
        case headerImage
        case images
        case confirmation
        
        var headerTitle: String {
            switch self {
            case .name:
                return "岩名"
                
            case .desc:
                return "岩の説明"
                
            case .location:
                return "住所"
                
            case .season:
                return "シーズン"
                
            case .lithology:
                return "岩質"

            case .headerImage:
                return "ヘッダー画像"
                
            case .images:
                return "それ以外の画像"
                
            default:
                return ""
                
            }
        }
        
        var headerIdentifer: String {
            switch self {
                case .name, .desc, .location, .season, .lithology, .images, .headerImage:
                return TitleSupplementaryView.className
                
            default:
                return ""
            }
        }
        
        var initialItems: [ItemKind] {
            switch self {
            case .name:
                return [.name]
                
            case .desc:
                return [.desc]

            case .headerImage:
                return [.noImage(.header)]

            case .images:
                return [.noImage(.normal)]
                
            case .confirmation:
                return [.confirmation]
                
            default:
                return []
            }
        }
    }
    
    enum ItemKind: Hashable {
        case name
        case desc
        case location(LocationManager.LocationStructure)
        case season(season: FIDocument.Rock.Season, isSelecting: Bool)
        case lithology(FIDocument.Rock.Lithology)
        case noImage(ImageType)
        case headerImage(IdentifiableData)
        case images(IdentifiableData)
        case confirmation
        case error(ValidationError)
        
        var isErrorItem: Bool {
            if case .error = self {
                return true
                
            } else {
                return false
                
            }
        }
    }
    
}