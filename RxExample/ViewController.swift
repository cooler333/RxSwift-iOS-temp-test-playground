//
//  ViewController.swift
//  RxExample
//
//  Created by Dmitriy Utmanov on 05/01/2018.
//  Copyright © 2018 Dmitry Utmanov. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit

class ViewController: UIViewController {

    private weak var textField: UITextField!
    private let delay: RxTimeInterval = 3
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTextField()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4) {
            self.textField.text = "sooooome vaaalid text"
        }
    }
    
    private func setupTextField() {
        let _textField = getTextField()
        
        view.addSubview(_textField)
        _textField.snp.makeConstraints { (maker) in
            maker.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin).offset(10)
            maker.left.equalToSuperview().offset(10)
            maker.right.equalToSuperview().offset(-10)
            maker.height.equalTo(44)
        }
    
        self.textField.text = "Some valid text"

        observeText(for: _textField)
        
        _textField.text = "..."
        
        textField = _textField
        
        print("textField did configured")
    }
    
    private func observeText(for textField: UITextField) {
        let observableText = textField
            .rx
            .text
            .orEmpty
            .asObservable()
        
        let observableStartText = observableText
            .map { (text) -> Bool in
                return text.count > 10
            }
        
        let obserDelayedText = observableText
            .debounce(delay, scheduler: MainScheduler.instance)
            .map { (text) -> Bool in
                return text.count > 10
            }
        
        observableStartText.subscribe(onNext: { (isValid) in
            let isValidString = isValid ? "Valid" : "Not valid"
            print("isValid: \(isValidString) (\(textField.text ?? ""))")
        }, onError: { (error) in
            print("Error: \(error)")
        }, onCompleted: {
            print("Completed")
        }, onDisposed: {
            print("Disposed")
        }).dispose()

        obserDelayedText.subscribe(onNext: { (isValid) in
            let isValidString = isValid ? "Valid" : "Not valid"
            print("isValid: \(isValidString) (\(textField.text ?? ""))")
        }, onError: { (error) in
            print("Error: \(error)")
        }, onCompleted: {
            print("Completed")
        }, onDisposed: {
            print("Disposed")
        }).disposed(by: disposeBag)
    }
    
    private func getTextField() -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.backgroundColor = .lightGray
        return textField
    }
}
