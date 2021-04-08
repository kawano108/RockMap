//
//  RockDetailViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/11/19.
//

import Combine
import Foundation

final class RockDetailViewModel {
    @Published var rockDocument: FIDocument.Rock
    @Published var rockName = ""
    @Published var registeredUserId = ""
    @Published var registeredUser: FIDocument.User?
    @Published var rockDesc = ""
    @Published var seasons: Set<FIDocument.Rock.Season> = []
    @Published var lithology: FIDocument.Rock.Lithology = .unKnown
    @Published var rockLocation = LocationManager.LocationStructure()
    @Published var headerImageReference: StorageManager.Reference?
    @Published var courses: [FIDocument.Course] = []
    
    private var bindings = Set<AnyCancellable>()
    
    init(rock: FIDocument.Rock) {
        self.rockDocument = rock

        setupBindings()
        
        self.rockName = rock.name
        self.rockDesc = rock.desc
        self.registeredUserId = rock.registeredUserId
        self.rockLocation = .init(
            location: .init(
                latitude: rock.location.latitude,
                longitude: rock.location.longitude
            ),
            address: rock.address,
            prefecture: rock.prefecture
        )
        self.seasons = rock.seasons
        self.lithology = rock.lithology
        self.updateCouses(by: rock)
    }
    
    private func setupBindings() {
        $rockName
            .drop(while: { $0.isEmpty })
            .sink { [weak self] name in
                
                guard let self = self else { return }
                
                let rockReference = StorageManager.makeReference(
                    parent: FINameSpace.Rocks.self,
                    child: name
                )
                StorageManager.getHeaderReference(reference: rockReference) { [weak self] result in

                    guard let self = self else { return }

                    guard
                        case let .success(reference) = result
                    else {
                        return
                    }
                    
                    self.headerImageReference = reference
                }
            }
            .store(in: &bindings)
        
        $registeredUserId
            .sink { id in
                FirestoreManager.fetchById(id: id) { [weak self] (result: Result<FIDocument.User?, Error>) in
                    
                    guard
                        let self = self,
                        case let .success(user) = result,
                        let unwrappedUser = user
                    else {
                        return
                    }
                    
                    self.registeredUser = unwrappedUser
                }
            }
            .store(in: &bindings)
    }
    
    func updateCouses(by rockdocument: FIDocument.Rock) {
        let coureseCollection = FirestoreManager.db
            .collection(FIDocument.User.colletionName)
            .document(rockdocument.registeredUserId)
            .collection(FIDocument.Rock.colletionName)
            .document(rockdocument.id)
            .collection(FIDocument.Course.colletionName)
        
        coureseCollection.getDocuments { [weak self] snap, error in
            
            guard let self = self else { return }
            
            guard
                error == nil
            else {
                self.courses = []
                return
            }

            guard let snap = snap else { return }
            
            self.courses = snap.documents.compactMap {
                FIDocument.Course.initializeDocument(json: $0.data())
            }
        }
    }
}

