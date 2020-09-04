//
//  NoteViewController.swift
//  VeeHomeTest
//
//  Created by Idan Moshe on 03/09/2020.
//  Copyright © 2020 Idan Moshe. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController {
        
    var note: Note?
    var isNewNote: Bool = false
    
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var contentTextView: UITextView!
    
    private lazy var saveButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.onPressSaveNote(_:)))
    }()
    
    private lazy var editButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.onPressEditNote(_:)))
    }()
    
    private lazy var deleteButton: UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(self.onPressDeleteNote(_:)))
    }()
    
    private lazy var restoreButton: UIBarButtonItem = {
        return UIBarButtonItem(title: "Restore", style: .plain, target: self, action: #selector(self.onPressRecoverNote(_:)))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleTextField.placeholder = "Title here..."
        self.titleTextField.returnKeyType = .done
        
        self.contentTextView.layer.borderColor = UIColor.lightGray.cgColor
        self.contentTextView.layer.borderWidth = 1.0
        
        if self.isNewNote {
            self.title = "New note"
            
            self.titleTextField.delegate = self
            self.titleTextField.text = ""
            self.titleTextField.isUserInteractionEnabled = true
            
            self.contentTextView.delegate = self
            self.contentTextView.text = ""
            self.contentTextView.isEditable = true
            
            self.navigationItem.rightBarButtonItems = nil
        } else {
            self.titleTextField.isUserInteractionEnabled = false
            self.contentTextView.isEditable = false
            
            if let note: Note = self.note {
                self.titleTextField.text = note.title
                self.contentTextView.text = note.content
                
                if note.isArchived {
                    self.navigationItem.rightBarButtonItems = [self.restoreButton, self.editButton, self.deleteButton]
                } else {
                    self.navigationItem.rightBarButtonItems = [self.editButton, self.deleteButton]
                }
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onPressEditNote(_ sender: Any) {
        self.titleTextField.isUserInteractionEnabled = true
        self.contentTextView.isEditable = true
        
        if let _ = self.note {
            self.navigationItem.rightBarButtonItems = [self.saveButton, self.deleteButton]
        }
        
        self.titleTextField.becomeFirstResponder()
    }
    
    @IBAction func onPressDeleteNote(_ sender: Any) {
        let alertController = UIAlertController(title: "Delete note", message: "Are you sure you want to delete this note?", preferredStyle: .alert)
        let actionOK = UIAlertAction(title: "OK", style: .destructive) { (action: UIAlertAction) in
            if let note: Note = self.note {
                if note.isArchived {
                    CoreDataManager.shared.deleteNote(note) { [weak self] in
                        guard let self = self else { return }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.4) {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                } else {
                    guard let createDate: Date = note.createDate else { return }
                    CoreDataManager.shared.updateExistingObject(createDate: createDate, title: self.titleTextField.text, content: self.contentTextView.text, isArchive: true) { [weak self] (success: Bool, error: Error?) in
                        guard let self = self else { return }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.4) {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(actionOK)
        alertController.addAction(actionCancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func onPressRecoverNote(_ sender: Any) {
        if let note: Note = self.note {
            note.isArchived = false
            CoreDataManager.shared.saveContext()
            
            DispatchQueue.main.asyncAfter(deadline: .now()+0.4) { [weak self] in
                guard let self = self else { return }
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func onPressSaveNote(_ sender: Any) {
        if self.isNewNote {
            CoreDataManager.shared.insertNewObject(title: self.titleTextField.text, content: self.contentTextView.text) { [weak self] (success: Bool, error: Error?) in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            guard let note = note else { return }
            guard let createDate = note.createDate else { return }
            
            CoreDataManager.shared.updateExistingObject(createDate: createDate, title: self.titleTextField.text, content: self.contentTextView.text, isArchive: false) { [weak self] (success: Bool, error: Error?) in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }

}

// MARK: - UITextFieldDelegate

extension NoteViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let range = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: range, with: string)
            if updatedText.count > 0 || self.contentTextView.text.count > 0 {
                self.navigationItem.rightBarButtonItems = [self.saveButton]
            } else {
                self.navigationItem.rightBarButtonItems = nil
            }
        }
        
        return true
    }
    
}

// MARK: - UITextViewDelegate

extension NoteViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let string = textView.text, let range = Range(range, in: string) {
            let updatedText = string.replacingCharacters(in: range, with: text)
            if updatedText.count > 0 || self.titleTextField.text?.count ?? 0 > 0 {
                self.navigationItem.rightBarButtonItems = [self.saveButton]
            } else {
                self.navigationItem.rightBarButtonItems = nil
            }
        }
        
        return true
    }
    
}
