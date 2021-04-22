//
//  MyPageViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/10/31.
//

import Combine
import UIKit

class MyPageViewController: UIViewController, CompositionalColectionViewControllerProtocol {

    var collectionView: UICollectionView!
    var viewModel: MyPageViewModel!
    var router: MyPageRouter!
    var snapShot = NSDiffableDataSourceSnapshot<SectionKind, ItemKind>()
    var datasource: UICollectionViewDiffableDataSource<SectionKind, ItemKind>!

    private var bindings = Set<AnyCancellable>()

    static func createInstance(
        viewModel: MyPageViewModel
    ) -> MyPageViewController {
        let instance = MyPageViewController()
        instance.router = .init(viewModel: viewModel)
        instance.viewModel = viewModel
        return instance
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupCollectionView()
        configureSections()
        bindViewModelOutput()
    }

    private func setupNavigationBar() {
        navigationItem.title = "マイページ"
        navigationItem.setRightBarButton(
            .init(
                title: nil,
                image: UIImage.SystemImages.gearshapeFill,
                primaryAction: .init { _ in

                },
                menu: nil
            ),
            animated: true
        )
    }

    private func setupCollectionView() {
        configureCollectionView()
        collectionView.layoutMargins = .init(top: 8, left: 16, bottom: 8, right: 16)
        collectionView.contentInset = .init(top: 16, left: 0, bottom: 16, right: 0)
    }

    private func bindViewModelOutput() {
        viewModel.output
            .$headerImageReference
            .receive(on: RunLoop.main)
            .sink { [weak self] reference in

                guard let self = self else { return }

                self.snapShot.appendItems([.headerImage(reference)], toSection: .headerImage)
                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)
    }

    private func configureSections() {
        snapShot.appendSections(SectionKind.allCases)
        SectionKind.allCases.forEach {
            snapShot.appendItems($0.initialItems, toSection: $0)
        }
        snapShot.appendItems(FIDocument.User.SocialLinkType.allCases.map { ItemKind.socialLink($0) }, toSection: .socialLink)
        datasource.apply(snapShot)
    }
}
