//
//  ClimbedUserListViewModel.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/04.
//

import Combine
import Foundation

protocol ClimbedUserListViewModelProtocol: ViewModelProtocol {
    var input: ClimbedUserListViewModel.Input { get }
    var output: ClimbedUserListViewModel.Output { get }
}

class ClimbedUserListViewModel: ClimbedUserListViewModelProtocol {

    var input: Input = .init()
    var output: Output = .init()

    private let course: FIDocument.Course
    private var bindings = Set<AnyCancellable>()
    private let fetchClimbedSubject = PassthroughSubject<String, Error>()

    init(course: FIDocument.Course) {
        self.course = course
        setupOutput()
        fetchClimbed()
    }

    private func fetchClimbed() {
        FirestoreManager.db
            .collectionGroup(FIDocument.ClimbRecord.colletionName)
            .whereField("parentCourseId", in: [course.id])
            .order(by: "climbedDate")
            .getDocuments(FIDocument.ClimbRecord.self)
            .catch { _ in Empty() }
            .assign(to: &output.$climbRecordList )
    }

    private func setupOutput() {

        let share = output.$climbRecordList 
            .filter { !$0.isEmpty }
            .share()

        share
            .flatMap { _ in
                FirestoreManager.db
                    .collection(FIDocument.User.colletionName)
                    .document(AuthManager.shared.uid)
                    .getDocument(FIDocument.User.self)
            }
            .catch { _ in Empty() }
            .compactMap { $0 }
            .sink { [weak self] user in

                guard let self = self else { return }

                self.output.myClimbedCellData = self.output.climbRecordList
                    .filter { $0.registeredUserId == AuthManager.shared.uid }
                    .map {
                        ClimbedCellData(
                            climbed: $0,
                            user: user,
                            isOwned: true
                        )
                    }
            }
            .store(in: &bindings)

        share
            .map { $0.filter { $0.registeredUserId != AuthManager.shared.uid } }
            .map { Set($0) }
            .map { array in
                array.map {
                    FirestoreManager.db
                        .collection(FIDocument.User.colletionName)
                        .document($0.registeredUserId)
                }
            }
            .flatMap {
                $0.getDocuments(FIDocument.User.self)
            }
            .breakpointOnError()
            .catch { _ in Empty() }
            .sink { [weak self] climbedUserList in

                guard let self = self else { return }

                let cellData = self.output.climbRecordList.compactMap { climbed -> ClimbedCellData? in

                    guard
                        let user = climbedUserList.first(where: { climbed.registeredUserId == $0.id })
                    else {
                        return nil
                    }

                    return .init(
                        climbed: climbed,
                        user: user,
                        isOwned: false
                    )
                }

                self.output.climbedCellData = cellData
            }
            .store(in: &bindings)
    }

    func deleteClimbRecord(
        climbRecord: FIDocument.ClimbRecord,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        climbRecord
            .makeDocumentReference()
            .delete { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                completion(.success(()))
            }
    }

    func updateClimbedData(
        id: String,
        date: Date,
        type: FIDocument.ClimbRecord.ClimbedRecordType
    ) {
        guard
            let index = output.myClimbedCellData.firstIndex(where: { $0.climbed.id == id })
        else {
            return
        }

        output.myClimbedCellData[index].climbed.climbedDate = date
        output.myClimbedCellData[index].climbed.type = type

        output.myClimbedCellData.sort(
            by: { $0.climbed.climbedDate < $1.climbed.climbedDate }
        )

    }
}

extension ClimbedUserListViewModel {

    struct ClimbedCellData: Hashable {
        var climbed: FIDocument.ClimbRecord
        let user: FIDocument.User
        let isOwned: Bool
    }

}

extension ClimbedUserListViewModel {

    struct Input {
    }

    final class Output {
        @Published var climbRecordList: [FIDocument.ClimbRecord] = []
        @Published var myClimbedCellData: [ClimbedCellData] = []
        @Published var climbedCellData: [ClimbedCellData] = []
    }
}
