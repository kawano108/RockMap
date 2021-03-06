//
//  CourseDetailRouter.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/03.
//

import UIKit

struct CourseDetailRouter: RouterProtocol {

    typealias Destination = DestinationType
    typealias ViewModel = CourseDetailViewModel

    enum DestinationType: DestinationProtocol {
        case registerClimbed
        case climbedUserList
        case parentRock(FIDocument.Rock)
    }

    weak var viewModel: ViewModel!

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    func route(
        to destination: Destination,
        from: UIViewController
    ) {
        switch destination {
            case .registerClimbed:
                presentRegisterClimbedBottomSheet(from)

            case .climbedUserList:
                pushClimbedUserList(from)

            case .parentRock(let rock):
                transitionToParentRock(from, rock: rock)

        }
    }

    private func presentRegisterClimbedBottomSheet(_ from: UIViewController) {

        guard
            AuthManager.shared.isLoggedIn
        else {
            from.showNeedsLoginAlert(message: "完登を記録するにはログインが必要です。ログインして完登を記録しますか？")
            return
        }

        let vm = RegisterClimbRecordViewModel(registerType: .create(viewModel.course))
        let vc = RegisterClimbRecordBottomSheetViewController.createInstance(viewModel: vm)

        from.present(vc, animated: true)
    }

    private func pushClimbedUserList(_ from: UIViewController) {
        from.navigationController?.pushViewController(
            ClimbedUserListViewController.createInstance(course: viewModel.course),
            animated: true
        )
    }

    private func transitionToParentRock(
        _ from: UIViewController,
        rock: FIDocument.Rock
    ) {
        if
            let index = from.navigationController?.viewControllers.firstIndex(of: from),
            let previousVc = from.navigationController?.viewControllers.any(at: index - 1),
            let rockDetailVc = previousVc as? RockDetailViewController,
            rockDetailVc.viewModel.rockId == rock.id
        {
            from.navigationController?.popViewController(animated: true)
        } else {
            let viewModel = RockDetailViewModel(rock: rock)
            let vc = RockDetailViewController.createInstance(viewModel: viewModel)
            from.navigationController?.pushViewController(vc, animated: true)
        }
    }

}
