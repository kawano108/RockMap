//
//  CourseRegisterDatasource.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/11.
//

import UIKit

extension CourseRegisterViewController {
    
    func configureDatasource() -> UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind> {
        
        let datasource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, item in
            
            guard let self = self else { return UICollectionViewCell() }
            
            switch item {
            case let .rock(rock):
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.configureRockCell(),
                    for: indexPath,
                    item: rock
                )
                
            case .courseName:
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.configureCourseNameCell(),
                    for: indexPath,
                    item: Dummy()
                )
                
            case let .grade(grade):
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.configureGradeSelectingCell(),
                    for: indexPath,
                    item: grade
                )
                
            case .desc:
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.configurecourseDescCell(),
                    for: indexPath,
                    item: Dummy()
                )
                
            case let .shape(shape, isSelecting):
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.configureShapeCell(),
                    for: indexPath,
                    item: (shape, isSelecting)
                )
                
            case let .noImage(imageType):
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.configureImageSelectCell(),
                    for: indexPath,
                    item: imageType
                )

            case let .header(data):
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.configureDeletabelImageCell(),
                    for: indexPath,
                    item: data
                )
                
            case let .images(data):
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.configureDeletabelImageCell(),
                    for: indexPath,
                    item: data
                )
                
            case .confirmation:
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.configureConfirmationButtonCell(),
                    for: indexPath,
                    item: Dummy()
                )
                
            case let .error(error):
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.configureErrorLabelCell(),
                    for: indexPath,
                    item: error
                )
            }
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<TitleSupplementaryView>(
            elementKind: TitleSupplementaryView.className
        ) { [weak self] supplementaryView, _, indexPath in
            
            guard let self = self else { return }
            
            supplementaryView.setSideInset(0)
            supplementaryView.backgroundColor = .white
            supplementaryView.label.text = self.snapShot.sectionIdentifiers[indexPath.section].headerTitle
        }
        
        datasource.supplementaryViewProvider = { [weak self] collectionView, _, index in
            
            guard let self = self else { return nil }
            
            return self.collectionView.dequeueConfiguredReusableSupplementary(
                using: headerRegistration,
                for: index
            )
        }
        return datasource
    }
    
    private func configureRockCell() -> UICollectionView.CellRegistration<
        RockHeaderCollectionViewCell,
        CourseRegisterViewModel.RockHeaderStructure
    > {
        .init(
            cellNib: .init(
                nibName: RockHeaderCollectionViewCell.className,
                bundle: nil
            )
        ) { cell, _, rockHeaderStructure in
            cell.configure(rockHeaderStructure: rockHeaderStructure)
        }
    }
    
    private func configureCourseNameCell() -> UICollectionView.CellRegistration<
        TextFieldColletionViewCell,
        Dummy
    > {
        .init { [weak self] cell, _, _ in
            
            guard let self = self else { return }

            cell.textField.text = self.viewModel.courseName
            cell.configurePlaceholder("課題名を入力して下さい。")
            cell.textField.textDidChangedPublisher.assign(to: &self.viewModel.$courseName)
            cell.textField.delegate = self
        }
    }
    
    private func configureGradeSelectingCell() -> UICollectionView.CellRegistration<
        GradeSelectingCollectionViewCell,
        FIDocument.Course.Grade
    > {
        .init(
            cellNib: .init(
                nibName: GradeSelectingCollectionViewCell.className,
                bundle: nil
            )
        ) { [weak self] cell, _, grade in
            
            guard let self = self else { return }
            
            cell.configure(grade: grade)
            self.setupGradeSelectingButtonActions(button: cell.gradeSelectButton)
        }
    }
    
    private func configureShapeCell() -> UICollectionView.CellRegistration<
        IconCollectionViewCell,
        (shape: FIDocument.Course.Shape, isSelecting: Bool)
    > {
        .init { cell, _, shape in
            cell.configure(title: shape.shape.name)
            cell.isSelecting = shape.isSelecting
        }
    }
    
    private func configurecourseDescCell() -> UICollectionView.CellRegistration<
        TextViewCollectionViewCell,
        Dummy
    > {
        .init(
            cellNib: .init(
                nibName: TextViewCollectionViewCell.className,
                bundle: nil
            )
        ) { [weak self] cell, _, _ in
            
            guard let self = self else { return }

            cell.textView.text = self.viewModel.desc
            cell.configurePlaceholder("課題の説明を入力して下さい。")
            cell.textView.textDidChangedPublisher.assign(to: &self.viewModel.$desc)
        }
    }
    
    private func configureImageSelectCell() -> UICollectionView.CellRegistration<
        ImageSelactCollectionViewCell,
        ImageType
    > {
        .init(
            cellNib: .init(
                nibName: ImageSelactCollectionViewCell.className,
                bundle: nil
            )
        ) { [weak self] cell, _, imageType in
            
            guard let self = self else { return }
            
            self.setupImageUploadButtonActions(
                button: cell.uploadButton,
                imageType: imageType
            )
        }
    }
    
    private func configureDeletabelImageCell() -> UICollectionView.CellRegistration<
        DeletableImageCollectionViewCell,
        IdentifiableData
    > {
        .init { cell, _, identifiableData in
            
            cell.configure(data: identifiableData.data) { [weak self] in
                
                guard
                    let self = self,
                    let index = self.viewModel.images.firstIndex(of: identifiableData)
                else {
                    return
                }
                
                self.viewModel.images.remove(at: index)
            }
        }
    }
    
    private func configureConfirmationButtonCell() -> UICollectionView.CellRegistration<
        ConfirmationButtonCollectionViewCell,
        Dummy
    > {
        .init { cell, _, _ in
            cell.configure(title: "　登録内容を確認する　")
            cell.configure { [weak self] in
                
                guard let self = self else { return }

                guard
                    self.viewModel.callValidations(),
                    let header = self.viewModel.header
                else {
                    self.showOKAlert(title: "入力内容に不備があります。", message: "入力内容を見直してください。")
                    return
                }

                let viewModel = CourseConfirmViewModel(
                    rock: self.viewModel.rockHeaderStructure,
                    courseName: self.viewModel.courseName,
                    grade: self.viewModel.grade,
                    shape: self.viewModel.shape,
                    header: header,
                    images: self.viewModel.images,
                    desc: self.viewModel.desc
                )

                self.navigationController?.pushViewController(
                    CourseConfirmViewController.createInstance(viewModel: viewModel),
                    animated: true
                )
            }
        }
    }
    
    private func configureErrorLabelCell() -> UICollectionView.CellRegistration<
        ErrorLabelCollectionViewCell,
        ValidationError
    > {
        .init { cell, _, error in
            cell.configure(message: error.description)
        }
    }
    
    private func setupImageUploadButtonActions(
        button: UIButton,
        imageType: ImageType
    ) {
        let photoLibraryAction = UIAction(
            title: "フォトライブラリ",
            image: UIImage.SystemImages.folderFill
        ) { [weak self] _ in
            
            guard let self = self else { return }

            self.pickerManager.presentPhPicker(imageType: imageType)
        }
        
        let cameraAction = UIAction(
            title: "写真を撮る",
            image: UIImage.SystemImages.cameraFill
        ) { [weak self] _ in
            
            guard let self = self else { return }
            
            self.pickerManager.presentImagePicker(
                sourceType: .camera,
                imageType: imageType
            )
        }
        
        let menu = UIMenu(title: "", children: [photoLibraryAction, cameraAction])
        button.menu = menu
        button.showsMenuAsPrimaryAction = true
    }
    
    private func setupGradeSelectingButtonActions(button: UIButton) {
        
        let gradeSelectActions = FIDocument.Course.Grade.allCases.map { (grade) -> UIAction in
            .init(
                title: grade.name,
                state: viewModel.grade == grade ? .on : .off
            ) { [weak self] _ in
                
                guard let self = self else { return }
                
                self.viewModel.grade = grade
            }
        }
        
        let menu = UIMenu(title: "グレード選択", children: gradeSelectActions)
        button.menu = menu
        button.showsMenuAsPrimaryAction = true
    }
}

struct Dummy {}
