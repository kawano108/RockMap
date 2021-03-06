//
//  MyPageRouter.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/20.
//

import UIKit

struct MyPageRouter: RouterProtocol {
    
    typealias Destination = DestinationType
    typealias ViewModel = MyPageViewModel

    enum DestinationType: DestinationProtocol {
        case climbedCourseList
        case courseDetail(FIDocument.Course)
        case rockList(DocumentRef?)
        case courseList(DocumentRef?)
        case editProfile(FIDocument.User)
        case settings
    }

    weak var viewModel: ViewModel!

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    func route(
        to destination: DestinationType,
        from context: UIViewController
    ) {
        switch destination {
            case .climbedCourseList:
                pushClimbedCourseList(context)

            case .courseDetail(let course):
                pushCourseDetail(context, course: course)

            case .rockList(let userReference):
                pushRockList(context, userReference: userReference)

            case .courseList(let userReference):
                pushCourseList(context, userReference: userReference)

            case .editProfile(let user):
                presentEditProfile(context, user: user)

            case .settings:
                presentSettings(context)
        }
    }

    private func pushClimbedCourseList(
        _ from: UIViewController
    ) {
        let vc = MyClimbedListViewController.createInstance(viewModel: .init())
        from.navigationController?.pushViewController(vc, animated: true)
    }

    private func pushCourseDetail(
        _ from: UIViewController,
        course: FIDocument.Course
    ) {
        let viewModel = CourseDetailViewModel(course: course)
        let vc = CourseDetailViewController.createInstance(viewModel: viewModel)
        from.navigationController?.pushViewController(vc, animated: true)
    }

    private func pushRockList(
        _ from: UIViewController,
        userReference: DocumentRef?
    ) {
        let viewModel = RockListViewModel(userId: viewModel.userKind.userId)
        let vc = RockListViewController.createInstance(viewModel: viewModel)
        from.navigationController?.pushViewController(vc, animated: true)
    }

    private func pushCourseList(
        _ from: UIViewController,
        userReference: DocumentRef?
    ) {
        let viewModel = CourseListViewModel(userId: viewModel.userKind.userId)
        let vc = CourseListViewController.createInstance(viewModel: viewModel)
        from.navigationController?.pushViewController(vc, animated: true)
    }

    private func presentEditProfile(
        _ from: UIViewController,
        user: FIDocument.User
    ) {
        let viewModel = EditProfileViewModel(user: user)
        let vc = EditProfileViewController.createInstance(viewModel: viewModel)
        let nc = RockMapNavigationController(rootVC: vc, naviBarClass: RockMapNoShadowNavigationBar.self)
        nc.isModalInPresentation = true
        from.present(nc, animated: true)
    }

    private func presentSettings(
        _ from: UIViewController
    ) {
        let nc = RockMapNavigationController(rootVC: SettingsViewController(), naviBarClass: RockMapNoShadowNavigationBar.self)
        from.present(nc, animated: true)
    }

}
