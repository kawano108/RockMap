//
//  User.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/12/02.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

extension FIDocument {
    struct User: FIDocumentProtocol {
        
        typealias Collection = FINameSpace.Users
        
        var id: String = UUID().uuidString
        var createdAt: Date = Date()
        var updatedAt: Date?
        var parentPath: String = ""
        var name: String
        var email: String?
        var photoURL: URL?
        var socialLinks: [SocialLink] = []
        var introduction: String?
        
        var isRoot: Bool { true }

        struct SocialLink: Hashable, Codable {
            let linkType: SocialLinkType
            var link: String
        }

        enum SocialLinkType: String, CaseIterable, Codable {
            case facebook
            case twitter
            case instagram
            case other

            var icon: UIImage {
                switch self {
                    case .facebook:
                        return UIImage.AssetsImages.facebook

                    case .twitter:
                        return UIImage.AssetsImages.twitter

                    case .instagram:
                        return UIImage.AssetsImages.instagram

                    case .other:
                        return UIImage.AssetsImages.link

                }
            }

            var placeHolder: String {
                switch self {
                    case .facebook, .twitter, .instagram:
                        return "@"

                    case .other:
                        return "ページURL"

                }
            }

        }
    }
}

extension Array where Element == FIDocument.User.SocialLink {

    func getLink(type: FIDocument.User.SocialLinkType) -> FIDocument.User.SocialLink? {
        return self.first(where: { $0.linkType == type })
    }

    mutating func updateLink(type: FIDocument.User.SocialLinkType, link: String) {

        guard
            let index = self.firstIndex(where: { $0.linkType == type })
        else {
            return
        }

        self[index].link = link
    }
}
