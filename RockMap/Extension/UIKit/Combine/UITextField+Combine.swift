//
//  UITextField+Combine.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2021/04/16.
//

import UIKit
import Combine

extension UITextField {
    var textDidChangedPublisher: AnyPublisher<String, Never> {
        return NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: self)
            .compactMap { $0.object as? UITextField }
            .map { $0.text ?? "" }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func setText(text: String) {
        self.text = text
        NotificationCenter.default.post(name: UITextField.textDidChangeNotification, object: self)
    }
}

extension UIViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
