//
//  CourseConfirmViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/03.
//

import Combine
import Foundation

class CourseConfirmViewModel {
    
    let rock: CourseRegisterViewModel.RockHeaderStructure
    let courseName: String
    let grade: FIDocument.Course.Grade
    let shape: Set<FIDocument.Course.Shape>
    let header: IdentifiableData
    let images: [IdentifiableData]
    let desc: String
    
    @Published private(set) var imageUploadState: StorageUploader.UploadState = .stanby
    @Published private(set) var courseUploadState: StoreUploadState = .stanby
    @Published private(set) var addIdState: StoreUploadState = .stanby
    
    private let uploader = StorageUploader()
    
    init(
        rock: CourseRegisterViewModel.RockHeaderStructure,
        courseName: String,
        grade: FIDocument.Course.Grade,
        shape: Set<FIDocument.Course.Shape>,
        header: IdentifiableData,
        images: [IdentifiableData],
        desc: String
    ) {
        self.rock = rock
        self.courseName = courseName
        self.grade = grade
        self.shape = shape
        self.header = header
        self.images = images
        self.desc = desc
        
        bindImageUploader()
    }
    
    private func bindImageUploader() {
        uploader.$uploadState
            .assign(to: &$imageUploadState)
    }
    
    func uploadImages() {
        let reference = StorageManager.makeReference(
            parent: FINameSpace.Course.self,
            child: courseName
        )

        let headerReference = reference
            .child(ImageType.header.typeName)
            .child(UUID().uuidString)
        uploader.addData(data: header.data, reference: headerReference)

        let normalReference = reference
            .child(ImageType.normal.typeName)
            .child(AuthManager.uid)
        images.forEach {
            let imageReference = normalReference.child(UUID().uuidString)
            uploader.addData(data: $0.data, reference: imageReference)
        }
        
        uploader.start()
    }
    
    func registerCourse() {
        
        courseUploadState = .loading
        
        let parentPath = FIDocument.Course.makeParentPath(
            parentPath: rock.rockParentPath,
            parentCollection: FIDocument.Rock.colletionName,
            documentId: rock.rockId
        )
        
        let course = FIDocument.Course(
            id: UUID().uuidString,
            parentPath: parentPath,
            createdAt: Date(),
            updatedAt: nil,
            name: courseName,
            desc: desc,
            grade: grade,
            shape: shape,
            climbedUserIdList: [],
            registedUserId: AuthManager.uid
        )

        let path = [course.parentPath, FIDocument.Course.colletionName].joined(separator: "/")
        FirestoreManager.db.collection(path).document(course.id).setData(course.dictionary) { [weak self] error in

            guard let self = self else { return }
            
            if
                let error = error
            {
                self.courseUploadState = .failure(error)
            }
            
            self.courseUploadState = .finish
        }
    }
}