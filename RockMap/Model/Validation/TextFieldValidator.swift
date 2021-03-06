//
//  TextFieldValidator.swift
//  RockMap
//
//  Created by TOUYA KAWANO on 2020/10/30.
//

import Foundation
import MapKit
import Combine

protocol ValidatorProtocol {
    func validate(_ value: Any?) -> ValidationResult
}

protocol CompositeValidator: ValidatorProtocol {
    var validators: [ValidatorProtocol] { get }

    func validate(_ value: Any?) -> ValidationResult
}

extension CompositeValidator {

    func validateReturnAllReasons(_ value: Any?) -> [ValidationResult] {
        return validators.map { $0.validate(value) }
    }

    func validate(_ value: Any?) -> ValidationResult {
        let results = validators.map { $0.validate(value) }
        
        return results.first { result -> Bool in
            switch result {
            case .valid:
                return false
                
            case .invalid, .none:
                return true
                
            }
        } ?? .valid
    }
}

// MARK: - ValidationEnumeration

enum ValidationResult {
    case none
    case valid
    case invalid(ValidationError)
    
    var isValid: Bool {
        switch self {
        case .valid:
            return true
            
        case .invalid, .none:
            return false
        }
    }
    
    var error: ValidationError? {
        
        guard case .invalid(let error) = self else { return nil }
        
        return error
    }
}

enum ValidationError: Error, Hashable {
    case empty(formName: String)
    case quantity(formName: String, max: Int)
    case none(formName: String)
    case length(formName: String, min: Int?)
    case cannotConvertAddressToLocation
    case cannotConvertLocationToAddrress
    
    var description: String {
        switch self {
        case .empty(let formName):
            return "\(formName)を入力してください。"
            
        case .length(let formName, let min):
            var errorMessage = "\(formName)は"
            if let min = min { errorMessage += "\(min)文字以上" }
            return errorMessage + "で入力してください。"

        case .cannotConvertAddressToLocation:
            return "住所から位置情報の変換に失敗しました。"
            
        case .cannotConvertLocationToAddrress:
            return "位置情報から住所への変換に失敗しました。"
            
        case let .quantity(formName, max):
            return "\(formName)が\(max)個以上選択されています。\(formName)は\(max)個までしか選択できないため、お手数ですが再度\(max)個以下の個数を選択し直して下さい。"

        case let .none(formName):
            return "\(formName)が未選択になっています。\(formName)を選択して下さい。"

        }
    }
}

// MARK: - CompositeValidatorStruct

struct RockNameValidator: CompositeValidator {
    var validators: [ValidatorProtocol] = [
        EmptyValidator(formName: "岩の名前")
    ]
}

struct RockAddressValidator: CompositeValidator {
    var validators: [ValidatorProtocol] = [
        EmptyValidator(formName: "岩の住所")
    ]
}

struct RockImageValidator: CompositeValidator {
    var validators: [ValidatorProtocol] = [
        QuantityValidator(formName: "画像", max: 10)
    ]
}

struct HeaderImageValidator<D: FIDocumentProtocol>: CompositeValidator {
    var validators: [ValidatorProtocol] = [
        HeaderValidator<D>(formName: "ヘッダー画像")
    ]
}

struct CourseNameValidator: CompositeValidator {
    var validators: [ValidatorProtocol] = [
        EmptyValidator(formName: "課題名")
    ]
}

struct UserNameValidator: CompositeValidator {
    var validators: [ValidatorProtocol] = [
        EmptyValidator(formName: "ユーザー名")
    ]
}

// MARK: - ValidatorStruct

/// 未入力検証用バリデーター
private struct EmptyValidator: ValidatorProtocol {
    let formName: String
    
    func validate(_ value: Any?) -> ValidationResult {

        guard
            let strings = value as? String
        else {
            return .invalid(.empty(formName: formName))
        }

        return strings.isEmpty ? .invalid(.empty(formName: formName)) : .valid
    }
}

private struct HeaderValidator<D: FIDocumentProtocol>: ValidatorProtocol {

    let formName: String

    func validate(_ value: Any?) -> ValidationResult {

        guard
            let image = value as? CrudableImage<D>
        else {
            return .invalid(.none(formName: formName))
        }

        if image.storageReference == nil {
            return image.updateData == nil
                ? .invalid(.none(formName: formName))
                : .valid
        } else {
            return image.shouldDelete
                ? .invalid(.none(formName: formName))
                : .valid
        }
    }
}

/// nil検証用バリデーター
private struct NoneValidator: ValidatorProtocol {
    let formName: String

    func validate(_ value: Any?) -> ValidationResult {
        return value == nil ? .invalid(.none(formName: formName)) : .valid
    }
}

/// 個数検証用バリデーター
private struct QuantityValidator: ValidatorProtocol {
    let formName: String
    let max: Int

    func validate(_ value: Any?) -> ValidationResult {

        guard
            let array = value as? [Any]
        else {
            return .invalid(.quantity(formName: formName, max: max))
        }

        return array.count > max
            ? .invalid(.quantity(formName: formName, max: max))
            : .valid
    }
}

/// 文字の長さ検証用バリデーター
private struct LengthValidator: ValidatorProtocol {
    let formName: String
    let min: Int
    
    func validate(_ value: Any?) -> ValidationResult {

        guard
            let strings = value as? String
        else {
            return .invalid(.empty(formName: formName))
        }

        return min > strings.count
            ? .invalid(.length(formName: formName, min: min))
            : .valid
    }
}

