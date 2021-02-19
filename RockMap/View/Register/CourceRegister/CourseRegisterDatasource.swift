//
//  CourseRegisterDatasource.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/02/11.
//

import UIKit

extension CourceRegisterViewController {
    
    func configureDatasource() -> UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind> {
        
        let datasource = UICollectionViewDiffableDataSource<SectionLayoutKind, ItemKind>(
            collectionView: collectionView,
            cellProvider: { [weak self] collectionView, indexPath, item in
                
                guard let self = self else { return UICollectionViewCell() }
                
                switch item {
                case let .rock(rock):
                    return collectionView.dequeueConfiguredReusableCell(
                        using: self.configureRockCell(),
                        for: indexPath,
                        item: rock
                    )
                
                case .courceName:
                    return collectionView.dequeueConfiguredReusableCell(
                        using: self.configureCourceNameCell(),
                        for: indexPath,
                        item: Dummy()
                    )
                
                case let .grade(grade):
                    return collectionView.dequeueConfiguredReusableCell(
                        using: self.configureGradeSelectingCell(),
                        for: indexPath,
                        item: grade
                    )
                case let .desc:
                    return collectionView.dequeueConfiguredReusableCell(
                        using: self.configureCourceDescCell(),
                        for: indexPath,
                        item: Dummy()
                    )
                    
                case .noImage:
                    return collectionView.dequeueConfiguredReusableCell(
                        using: self.configureImageSelectCell(),
                        for: indexPath,
                        item: Dummy()
                    )
                    
                default:
                    return UICollectionViewCell()
                    
                }
            }
        )
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<TitleSupplementaryView>(
            elementKind: TitleSupplementaryView.className
        ) { [weak self] supplementaryView, _, indexPath in
            
            guard let self = self else { return }
            
            supplementaryView.setSideInset(16)
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
        CourceRegisterViewModel.RockHeaderStructure
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
    
    private func configureCourceNameCell() -> UICollectionView.CellRegistration<
        TextFieldColletionViewCell,
        Dummy
    > {
        .init { [weak self] cell, _, _ in
            
            guard let self = self else { return }
            
            cell.textField.textDidChangedPublisher.assign(to: &self.viewModel.$courseName)
            cell.textField.delegate = self
        }
    }
    
    private func configureGradeSelectingCell() -> UICollectionView.CellRegistration<
        GradeSelectingCollectionViewCell,
        FIDocument.Cource.Grade
    > {
        .init(
            cellNib: .init(
                nibName: GradeSelectingCollectionViewCell.className,
                bundle: nil
            )
        ) { cell, _, grade in
            cell.configure(grade: grade)
        }
    }
    
    private func configureCourceDescCell() -> UICollectionView.CellRegistration<
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
            
            cell.textView.textDidChangedPublisher.assign(to: &self.viewModel.$desc)
            cell.textView.delegate = self
        }
    }
    
    private func configureImageSelectCell() -> UICollectionView.CellRegistration<
        ImageSelactCollectionViewCell,
        Dummy
    > {
        .init(
            cellNib: .init(
                nibName: ImageSelactCollectionViewCell.className,
                bundle: nil
            )
        ) { [weak self] cell, _, _ in
            
            guard let self = self else { return }
            
            self.setupImageUploadButtonActions(button: cell.uploadButton)
        }
    }
    
    private func setupImageUploadButtonActions(button: UIButton) {
        let photoLibraryAction = UIAction(
            title: "フォトライブラリ",
            image: UIImage.SystemImages.folderFill
        ) { [weak self] _ in
            
            guard let self = self else { return }

            self.present(self.phPickerViewController, animated: true)
        }
        
        let cameraAction = UIAction(
            title: "写真を撮る",
            image: UIImage.SystemImages.cameraFill
        ) { [weak self] _ in
            
            guard let self = self else { return }
            
            let vc = UIImagePickerController()
            vc.delegate = self
            vc.sourceType = .camera
            self.present(vc, animated: true)
        }
        
        let menu = UIMenu(title: "", children: [photoLibraryAction, cameraAction])
        button.menu = menu
        button.showsMenuAsPrimaryAction = true
    }
}

struct Dummy {}
