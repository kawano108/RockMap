//
//  RockRegisterLayout.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/10.
//

import UIKit

extension RockRegisterViewControllerV2 {
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env -> NSCollectionLayoutSection in
            
            let section: NSCollectionLayoutSection
            
            let sectionType = SectionLayoutKind.allCases[sectionNumber]
            switch sectionType {
            case .name:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(44)
                    )
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: item.layoutSize.heightDimension
                    ),
                    subitems: [item]
                )
                section = .init(group: group)
                
            case .desc:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(88)
                    )
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: item.layoutSize.heightDimension
                    ),
                    subitems: [item]
                )
                section = .init(group: group)
                
            case .location:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(88)
                    )
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: item.layoutSize.heightDimension
                    ),
                    subitems: [item]
                )
                section = .init(group: group)
                
            case .images:
                
                let item: NSCollectionLayoutItem
                let group: NSCollectionLayoutGroup
                
                if self.snapShot.numberOfItems(inSection: .images) == 1 {
                    item = .init(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(44)
                        )
                    )
                    group = NSCollectionLayoutGroup.horizontal(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: item.layoutSize.heightDimension
                        ),
                        subitems: [item]
                    )
                    section = .init(group: group)
                    
                } else {
                    item = NSCollectionLayoutItem(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .fractionalWidth(1)
                        )
                    )
                    group = NSCollectionLayoutGroup.horizontal(
                        layoutSize: .init(
                            widthDimension: .fractionalWidth(0.25),
                            heightDimension: .fractionalWidth(0.25)
                        ),
                        subitems: [item]
                    )
                    section = .init(group: group)
                    section.interGroupSpacing = 4
                    
                }
                
                section.orthogonalScrollingBehavior = .continuous

            case .confirmation:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(64)
                    )
                )
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: item.layoutSize.heightDimension
                    ),
                    subitems: [item]
                )
                section = .init(group: group)
                section.contentInsets.top = 16
            }
            
            if !sectionType.headerIdentifer.isEmpty {
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(44)
                    ),
                    elementKind: sectionType.headerIdentifer,
                    alignment: .top
                )
                section.boundarySupplementaryItems = [sectionHeader]
            }
            
            let sectionBackgroundDecoration = NSCollectionLayoutDecorationItem.background(elementKind: SectionBackgroundDecorationView.className)
            section.decorationItems = [sectionBackgroundDecoration]
            section.contentInsetsReference = .layoutMargins
            
            return section

        }
        
        layout.register(
            SectionBackgroundDecorationView.self,
            forDecorationViewOfKind: SectionBackgroundDecorationView.className
        )
        return layout
    }
}
