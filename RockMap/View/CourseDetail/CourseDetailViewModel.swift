//
//  CourseDetailViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/19.
//

import Combine
import Foundation

final class CourseDetailViewModel {
    
    struct UserCellStructure: Hashable {
        var photoURL: URL?
        var name: String = ""
        var registeredDate: Date?
    }
    
    @Published var course: FIDocument.Course
    @Published var courseImageReferences: [StorageManager.Reference] = []
    @Published var courseName = ""
    @Published private var registeredUserId = ""
    @Published var userStructure: UserCellStructure = .init()

    private var bindings = Set<AnyCancellable>()
    
    init(course: FIDocument.Course) {
        self.course = course
        
        setupBindings()
        
        courseName = course.name
        registeredUserId = course.registedUserId
        userStructure.registeredDate = course.createdAt
    }
    
    private func setupBindings() {
        $courseName
            .sink { [weak self] name in
                
                guard let self = self else { return }
                
                let reference = StorageManager.makeReference(
                    parent: FINameSpace.Course.self,
                    child: name
                )
                
                StorageManager.getAllReference(reference: reference) { result in
                    
                    guard
                        case let .success(references) = result
                    else {
                        return
                    }
                    
                    self.courseImageReferences.append(contentsOf: references)
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
                    
                    self.userStructure.name = unwrappedUser.name
                    self.userStructure.photoURL = unwrappedUser.photoURL
                }
            }
            .store(in: &bindings)
    }
    
    func registerClimbed(
        climbedDate: Date,
        type: FIDocument.Climbed.ClimbedRecordType,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let parentPath = FIDocument.Climbed.makeParentPath(
            parentPath: course.parentPath,
            parentCollection: FIDocument.Course.colletionName,
            documentId: course.id
        )
        let climbed = FIDocument.Climbed(
            id: UUID().uuidString,
            parentCourseId: course.id,
            createdAt: Date(),
            updatedAt: nil,
            parentPath: parentPath,
            climbedDate: climbedDate,
            type: type,
            climbedUserId: AuthManager.uid
        )
        
        let path = [climbed.parentPath, FIDocument.Climbed.colletionName].joined(separator: "/")
        FirestoreManager.db.collection(path).document(climbed.id).setData(climbed.dictionary) { error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success(()))
        }
    }
}