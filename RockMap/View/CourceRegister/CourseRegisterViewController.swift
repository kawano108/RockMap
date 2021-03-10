//
//  CourseRegisterViewController.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/11.
//

import UIKit
import Combine
import PhotosUI

class CourseRegisterViewController: UIViewController, CollectionViewControllerProtocol {
    
    var collectionView: TouchableColletionView!
    var viewModel: CourseRegisterViewModel!
    var snapShot = NSDiffableDataSourceSnapshot<SectionLayoutKind, ItemKind>()
    var datasource: UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>!
    let indicator = UIActivityIndicatorView()
    
    private var bindings = Set<AnyCancellable>()
    
    let phPickerViewController: PHPickerViewController = {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 0
        configuration.filter = .images

        return PHPickerViewController(configuration: configuration)
    }()
    
    static func createInstance(
        viewModel: CourseRegisterViewModel
    ) -> CourseRegisterViewController {
        let instance = CourseRegisterViewController()
        instance.viewModel = viewModel
        return instance
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupColletionView()
        setupIndicator()
        setupNavigationBar()
        bindViewModelToView()
        datasource = configureDatasource()
        configureSections()
        phPickerViewController.delegate = self
    }
    
    private func setupColletionView() {
        setupCollectionView(layout: createLayout())
        collectionView.delegate = self
        collectionView.layoutMargins = .init(top: 8, left: 16, bottom: 8, right: 16)
        collectionView.contentInset = .init(top: 16, left: 0, bottom: 8, right: 0)
    }
    
    private func setupIndicator() {
        indicator.hidesWhenStopped = true
        indicator.backgroundColor = UIColor.Pallete.transparentBlack
        indicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            indicator.rightAnchor.constraint(equalTo: view.rightAnchor),
            indicator.topAnchor.constraint(equalTo: view.topAnchor),
            indicator.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        indicator.bringSubviewToFront(collectionView)
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "課題を登録する"

        navigationItem.setLeftBarButton(
            .init(
                systemItem: .cancel,
                primaryAction: .init {  [weak self] _ in
                    
                    guard let self = self else { return }
                    
                    self.dismiss(animated: true)
                }
            ),
            animated: false
        )
    }
    
    private func bindViewModelToView() {
        viewModel.$rockHeaderStructure
            .drop { $0.rockName.isEmpty }
            .receive(on: RunLoop.main)
            .sink { [weak self] rock in
                
                guard let self = self else { return }
                
                self.snapShot.appendItems([.rock(rock)], toSection: .rock)
                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)
        
        viewModel.$images
            .drop { $0.isEmpty }
            .receive(on: RunLoop.main)
            .sink { [weak self] images in
                
                defer {
                    self?.indicator.stopAnimating()
                }
                
                guard let self = self else { return }
                
                self.snapShot.deleteItems(self.snapShot.itemIdentifiers(inSection: .images))
                
                self.snapShot.appendItems([.noImage], toSection: .images)
                
                let items = images.map { ItemKind.images($0) }
                self.snapShot.appendItems(items, toSection: .images)
                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)
        
        viewModel.$courseNameValidationResult
            .receive(on: RunLoop.main)
            .sink { [weak self] result in
                
                guard let self = self else { return }
                
                switch result {
                case .valid, .none:
                    let items = self.snapShot.itemIdentifiers(inSection: .courseName)
                    
                    guard
                        let item = items.first(where: { $0.isErrorItem })
                    else {
                        return
                    }
                    
                    self.snapShot.deleteItems([item])
                    
                case let .invalid(error):
                    let items = self.snapShot.itemIdentifiers(inSection: .courseName)
                    
                    if let item = items.first(where: { $0.isErrorItem }) {
                        self.snapShot.deleteItems([item])
                    }

                    self.snapShot.appendItems([.error(error.description)], toSection: .courseName)
                }
                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)
        
        viewModel.$grade
            .receive(on: RunLoop.main)
            .sink { [weak self] grade in
            
                guard let self = self else { return }
                
                self.snapShot.deleteItems(self.snapShot.itemIdentifiers(inSection: .grade))
                
                self.snapShot.appendItems([.grade(grade)], toSection: .grade)
                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)
        
        viewModel.$courseImageValidationResult
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] isValid in
                
                guard let self = self else { return }
                
                if isValid {
                    let items = self.snapShot.itemIdentifiers(inSection: .confirmation)
                    
                    guard
                        let item = items.first(where: { $0.isErrorItem })
                    else {
                        return
                    }
                    self.snapShot.deleteItems([item])

                } else {
                    let items = self.snapShot.itemIdentifiers(inSection: .confirmation)
                    
                    if let item = items.first(where: { $0.isErrorItem }) {
                        self.snapShot.deleteItems([item])
                    }

                    self.snapShot.appendItems([.error("課題の画像は必須です。")], toSection: .confirmation)
                }
                
                self.datasource.apply(self.snapShot)
            }
            .store(in: &bindings)
    }
    
    private func configureSections() {
        snapShot.appendSections(SectionLayoutKind.allCases)
        SectionLayoutKind.allCases.forEach {
            snapShot.appendItems($0.initalItems, toSection: $0)
        }
        datasource.apply(snapShot)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension CourseRegisterViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        guard
            let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
            let data = image.jpegData(compressionQuality: 1)
        else {
            return
        }
        
        indicator.startAnimating()
        viewModel.images.append(.init(data: data))
        picker.dismiss(animated: true)
    }
}

extension CourseRegisterViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true)
        
        if results.isEmpty { return }
        
        indicator.startAnimating()
        
        results.map(\.itemProvider).forEach {
            
            guard $0.canLoadObject(ofClass: UIImage.self) else { return }
            
            $0.loadObject(ofClass: UIImage.self) { [weak self] providerReading, error in
                guard
                    case .none = error,
                    let self = self,
                    let image = providerReading as? UIImage,
                    let data = image.jpegData(compressionQuality: 1)
                else {
                    return
                }
                
                self.viewModel.images.append(.init(data: data))
            }
        }
    }
}

extension CourseRegisterViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}
