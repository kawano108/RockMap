//
//  PickerManager.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/03/29.
//

import Foundation
import PhotosUI

protocol PickerManagerDelegate: AnyObject {
    func beganResultHandling()
    func didReceivePicking(data: Data, imageType: ImageType)
}

class PickerManager: NSObject {

    weak var delegate: PickerManagerDelegate?

    private var imageType: ImageType = .normal
    private let from: UIViewController
    private var configuration: PHPickerConfiguration

    init(
        from: UIViewController,
        configuration: PHPickerConfiguration
    ) {
        self.from = from
        self.configuration = configuration
    }

    func presentPhPicker(imageType: ImageType) {
        self.imageType = imageType
        configuration.selectionLimit = imageType.limit
        let vc = PHPickerViewController(configuration: configuration)
        vc.delegate = self
        from.present(vc, animated: true)
    }

    func presentImagePicker(
        sourceType: UIImagePickerController.SourceType,
        imageType: ImageType
    ) {
        self.imageType = imageType
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.sourceType = sourceType
        from.present(vc, animated: true)
    }
}

extension PickerManager: PHPickerViewControllerDelegate {

    func picker(
        _ picker: PHPickerViewController,
        didFinishPicking results: [PHPickerResult]
    ) {

        picker.dismiss(animated: true)

        if results.isEmpty { return }

        delegate?.beganResultHandling()

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

                self.delegate?.didReceivePicking(
                    data: data,
                    imageType: self.imageType
                )
            }
        }
    }
}

extension PickerManager: UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {

        picker.dismiss(animated: true)

        guard
            let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
            let data = image.jpegData(compressionQuality: 1)
        else {
            return
        }

        delegate?.beganResultHandling()

        delegate?.didReceivePicking(data: data, imageType: imageType)
    }

}