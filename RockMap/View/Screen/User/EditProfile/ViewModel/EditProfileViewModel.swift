//
//  EditProfileViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/05/10.
//


import Combine
import Foundation

protocol EditProfileViewModelProtocol: ViewModelProtocol {
    var input: EditProfileViewModel.Input { get }
    var output: EditProfileViewModel.Output { get }
}

class EditProfileViewModel: EditProfileViewModelProtocol {

    var input: Input = .init()
    var output: Output = .init()
    let user: FIDocument.User

    private var bindings = Set<AnyCancellable>()
    private let uploader = StorageUploader()

    init(user: FIDocument.User) {
        self.user = user
        bindInput()
        bindOutput()

        input.nameSubject.send(user.name)
        input.introductionSubject.send(user.introduction)
        fetchImageStorage()
        user.socialLinks.forEach {
            input.socialLinkSubject.send($0)
        }
    }

    private func bindInput() {
        input.nameSubject
            .removeDuplicates()
            .compactMap { $0 }
            .assign(to: &output.$name)

        input.introductionSubject
            .removeDuplicates()
            .compactMap { $0 }
            .assign(to: &output.$introduction)

        input.setImageSubject
            .sink(receiveValue: setImage)
            .store(in: &bindings)

        input.deleteImageSubject
            .sink(receiveValue: deleteImage)
            .store(in: &bindings)

        input.socialLinkSubject
            .sink { [weak self] socialLink in

                guard
                    let self = self,
                    let index = self.output.socialLinks.firstIndex(
                        where: { $0.linkType == socialLink.linkType }
                    )
                else {
                    return
                }

                self.output.socialLinks[index].link = socialLink.link
            }
            .store(in: &bindings)
    }

    private func bindOutput() {
        uploader.$uploadState
            .assign(to: &output.$imageUploadState)

        output.$name
            .dropFirst()
            .removeDuplicates()
            .map { name -> ValidationResult in CourseNameValidator().validate(name) }
            .assign(to: &output.$nameValidationResult)
    }

    private func fetchImageStorage() {
        StorageManager
            .getReference(
                destinationDocument: FINameSpace.Users.self,
                documentId: user.id,
                imageType: .header
            )
            .catch { error -> Empty in
                print(error)
                return Empty()
            }
            .map {
                CrudableImage<FIDocument.User>(storageReference: $0, imageType: .icon)
            }
            .assign(to: &output.$header)

        StorageManager
            .getReference(
                destinationDocument: FINameSpace.Users.self,
                documentId: user.id,
                imageType: .icon
            )
            .catch { error -> Empty in
                print(error)
                return Empty()
            }
            .map {
                CrudableImage<FIDocument.User>(storageReference: $0, imageType: .icon)
            }
            .assign(to: &output.$icon)
    }

    private func setImage(imageType: ImageType, data: Data) {
        switch imageType {
            case .icon:
                output.icon.updateData = data

            case .header:
                output.header.updateData = data
                output.header.shouldDelete = false

            case .normal:
                break
        }
    }

    private func deleteImage(imageType: ImageType) {
        switch imageType {
            case .icon:
                output.icon.updateData = nil

            case .header:
                output.header.updateData = nil

                if output.header.storageReference != nil {
                    output.header.shouldDelete = true
                }

            case .normal:
                break
        }
    }

    func callValidations() -> Bool {
        if !output.nameValidationResult.isValid {
            output.nameValidationResult = UserNameValidator().validate(output.name)
        }
        return [
            output.nameValidationResult
        ]
        .map(\.isValid)
        .allSatisfy { $0 }
    }

    func uploadImage() {
        uploader.addData(image: output.icon, id: user.id)
        uploader.addData(image: output.header, id: user.id)
        uploader.start()
    }

    func editProfile() {

        output.userUploadState = .loading

        var updateUserDocument: FIDocument.User {
            var updateUser = user
            updateUser.name = output.name
            updateUser.introduction = output.introduction
            updateUser.socialLinks = output.socialLinks
            return updateUser
        }
        updateUserDocument.makeDocumentReference()
            .setData(from: updateUserDocument)
            .sinkState { [weak self] state in
                self?.output.userUploadState = state
            }
            .store(in: &bindings)
    }
}

extension EditProfileViewModel {

    struct Input {
        let nameSubject = PassthroughSubject<String?, Never>()
        let introductionSubject = PassthroughSubject<String?, Never>()
        let setImageSubject = PassthroughSubject<(ImageType, Data), Never>()
        let deleteImageSubject = PassthroughSubject<ImageType, Never>()
        let socialLinkSubject = PassthroughSubject<FIDocument.User.SocialLink, Never>()
    }

    final class Output {
        @Published var name = ""
        @Published var introduction = ""
        @Published var header: CrudableImage<FIDocument.User> = .init(imageType: .header)
        @Published var icon: CrudableImage<FIDocument.User> = .init(imageType: .icon)
        @Published var socialLinks: [FIDocument.User.SocialLink] = FIDocument.User.SocialLinkType.allCases.map {
            FIDocument.User.SocialLink(linkType: $0, link: "")
        }
        @Published var nameValidationResult: ValidationResult = .none

        @Published var imageUploadState: StorageUploader.UploadState = .stanby
        @Published var userUploadState: LoadingState<Void> = .stanby
    }
}
