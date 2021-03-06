//
//  ClimbedUserListViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/04.
//

import UIKit
import Combine

class ClimbedUserListViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private var viewModel: ClimbedUserListViewModel!
    private var snapShot = NSDiffableDataSourceSnapshot<SectionKind, ClimbedUserListViewModel.ClimbedCellData>()
    private var datasource: UITableViewDiffableDataSource<SectionKind, ClimbedUserListViewModel.ClimbedCellData>!
    private var bindings = Set<AnyCancellable>()

    static func createInstance(course: FIDocument.Course) -> Self {
        let instance = Self()
        instance.viewModel = .init(course: course)
        return instance
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupNavigationBar()
        datasource = configureDatasource()
        setupSections()
        bindViewToViewModel()
    }

    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
        tableView.contentInset = .init(top: -16, left: 0, bottom: 0, right: 0)

        tableView.register(
            .init(
                nibName: ClimbRecordTableViewCell.className,
                bundle: nil
            ),
            forCellReuseIdentifier: ClimbRecordTableViewCell.className
        )
    }

    private func setupNavigationBar() {
        navigationItem.title = "完登者一覧"
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    private func configureDatasource() -> UITableViewDiffableDataSource<
        SectionKind,
        ClimbedUserListViewModel.ClimbedCellData
    > {
        return .init(tableView: tableView) { [weak self] tableView, index, cellData in

            guard let self = self else { return UITableViewCell() }

            guard
                let climbedCell = self.tableView.dequeueReusableCell(
                    withIdentifier: ClimbRecordTableViewCell.className,
                    for: index
                ) as? ClimbRecordTableViewCell
            else {
                return UITableViewCell()
            }

            climbedCell.configure(
                user: cellData.user,
                climbedDate: cellData.climbed.climbedDate,
                type: cellData.climbed.type,
                parentVc: self
            )
            return climbedCell

        }
    }

    private func setupSections() {
        snapShot.appendSections(SectionKind.allCases)
        datasource.apply(snapShot)
    }

    private func bindViewToViewModel() {
        viewModel.output.$myClimbedCellData
            .receive(on: RunLoop.main)
            .sink { [weak self] cellData in

                guard let self = self else { return }

                self.snapShot.deleteItems(self.snapShot.itemIdentifiers(inSection: .owned))
                self.snapShot.appendItems(cellData, toSection: .owned)

                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)

        viewModel.output.$climbedCellData
            .receive(on: RunLoop.main)
            .sink { [weak self] cellData in

                guard let self = self else { return }

                self.snapShot.deleteItems(self.snapShot.itemIdentifiers(inSection: .others))
                self.snapShot.appendItems(cellData, toSection: .others)

                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)
    }

    private func makeEditAction(
        to cellData: ClimbedUserListViewModel.ClimbedCellData
    ) -> UIAction {

        return .init(
            title: "編集",
            image: UIImage.SystemImages.squareAndPencil
        ) { [weak self] _ in

            guard let self = self else { return }

            let vm = RegisterClimbRecordViewModel(registerType: .edit(cellData.climbed))
            let vc = RegisterClimbRecordBottomSheetViewController.createInstance(viewModel: vm)
            vc.delegate = self
            self.present(vc, animated: true)
        }
    }

    private func makeDeleteAction(
        to cellData: ClimbedUserListViewModel.ClimbedCellData
    ) -> UIAction {

        return .init(
            title: "削除",
            image: UIImage.SystemImages.trash,
            attributes: .destructive
        ) { [weak self] _ in

            guard let self = self else { return }

            let deleteAction = UIAlertAction(
                title: "削除",
                style: .destructive
            ) { [weak self] _ in

                guard let self = self else { return }

                self.showIndicatorView()

                self.viewModel.deleteClimbRecord(
                    climbRecord: cellData.climbed
                ) { [weak self] result in

                    guard let self = self else { return }

                    self.hideIndicatorView()

                    switch result {
                        case .success:
                            self.snapShot.deleteItems([cellData])
                            self.datasource.apply(self.snapShot)

                        case .failure(let error):
                            self.showOKAlert(
                                title: "削除に失敗しました。",
                                message: error.localizedDescription
                            )
                    }
                }
            }

            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)

            self.showAlert(
                title: "記録を削除します。",
                message: "削除した記録は復元できません。\n削除してもよろしいですか？",
                actions: [
                    deleteAction,
                    cancelAction
                ],
                style: .actionSheet
            )
        }
    }
}

extension ClimbedUserListViewController {

    enum SectionKind: Hashable, CaseIterable {
        case owned
        case others

        var headerTitle: String {
            switch self {
                case .owned:
                    return "自分の記録"

                case .others:
                    return "自分以外の記録"
            }
        }
    }

}

extension ClimbedUserListViewController: UITableViewDelegate {

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(
        _ tableView: UITableView,
        contextMenuConfigurationForRowAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {

        guard
            let cellData = self.datasource.itemIdentifier(for: indexPath),
            cellData.isOwned
        else {
            return nil
        }

        let actionProvider: ([UIMenuElement]) -> UIMenu? = { [weak self] _ in

            guard let self = self else { return nil }

            return UIMenu(
                title: "",
                children: [
                    self.makeEditAction(to: cellData),
                    self.makeDeleteAction(to: cellData)
                ]
            )
        }

        return .init(identifier: nil, previewProvider: nil, actionProvider: actionProvider)

    }

    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        let header = UITableViewHeaderFooterView()
        header.textLabel?.text = SectionKind.allCases[section].headerTitle
        return header
    }

}

extension ClimbedUserListViewController: RegisterClimbRecordDetectableDelegate {

    func finishedRegisterClimbed(
        id: String,
        date: Date,
        type: FIDocument.ClimbRecord.ClimbedRecordType
    ) {
        viewModel.updateClimbedData(
            id: id,
            date: date,
            type: type
        )
    }

}
