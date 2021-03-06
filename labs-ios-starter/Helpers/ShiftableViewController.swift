//
//  ShiftableViewController.swift
//  labs-ios-starter
//
//  Created by Tobi Kuyoro on 15/10/2020.
//  Copyright © 2020 Spencer Curtis. All rights reserved.
//

import UIKit

class ShiftableViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate {

    var currentYShiftForKeyboard: CGFloat = 0
    var textFieldBeingEdited: UITextField?
    var textViewBeingEdited: UITextView?
    var keyboardDismissTapGestureRecognizer: UITapGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardDismissTapGestureRecognizer()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    @objc func stopEditingTextInput() {
        if let textField = self.textFieldBeingEdited {
            textField.resignFirstResponder()
            self.textFieldBeingEdited = nil
            self.textViewBeingEdited = nil
        } else if let textView = self.textViewBeingEdited {
            textView.resignFirstResponder()
            self.textFieldBeingEdited = nil
            self.textViewBeingEdited = nil
        }

        guard keyboardDismissTapGestureRecognizer.isEnabled else { return }
        keyboardDismissTapGestureRecognizer.isEnabled = false
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textFieldBeingEdited = textField
    }

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        textViewBeingEdited = textView
        return true
    }

    @objc func keyboardWillShow(notification: Notification) {
        keyboardDismissTapGestureRecognizer.isEnabled = true
        var keyboardSize: CGRect = .zero

        if let keyboardRect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            keyboardRect.height != 0 {
            keyboardSize = keyboardRect
        } else if let keyboardRect = notification.userInfo?["UIKeyboardBoundsUserInfoKey"] as? CGRect {
            keyboardSize = keyboardRect
        }

        if let textField = textFieldBeingEdited {
            if self.view.frame.origin.y == 0 {
                let yShift = yShiftWhenKeyboardAppearsFor(textInput: textField, keyboardSize: keyboardSize, nextY: keyboardSize.height)
                self.currentYShiftForKeyboard = yShift
                self.view.frame.origin.y -= yShift
            }

        } else if let textView = textViewBeingEdited {
            if self.view.frame.origin.y == 0 {
                let yShift = yShiftWhenKeyboardAppearsFor(textInput: textView, keyboardSize: keyboardSize, nextY: keyboardSize.height)
                self.currentYShiftForKeyboard = yShift
                self.view.frame.origin.y -= yShift
            }
        }
    }

    @objc func yShiftWhenKeyboardAppearsFor(textInput: UIView, keyboardSize: CGRect, nextY: CGFloat) -> CGFloat {
        let textFieldOrigin = self.view.convert(textInput.frame, from: textInput.superview!).origin.y
        let textFieldBottomY = textFieldOrigin + textInput.frame.size.height
        let maximumY = self.view.frame.height - (keyboardSize.height + view.safeAreaInsets.bottom)
        if textFieldBottomY > maximumY {
            return textFieldBottomY - maximumY
        } else {
            return 0
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y += currentYShiftForKeyboard
        }
        
        stopEditingTextInput()
    }

    @objc func setupKeyboardDismissTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(stopEditingTextInput))
        tapGestureRecognizer.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGestureRecognizer)
        keyboardDismissTapGestureRecognizer = tapGestureRecognizer
    }
}
