//
//  NotesTableViewCell.swift
//  VeeHomeTest
//
//  Created by Idan Moshe on 03/09/2020.
//  Copyright © 2020 Idan Moshe. All rights reserved.
//

import UIKit

class NotesTableViewCell: UITableViewCell {
    
    // MARK: - Properties(public)
    
    static let identifier: String = "NotesTableViewCell"
        
    // MARK: - Properties(private)
    
    @IBOutlet private weak var noteTitleLabel: UILabel!
    @IBOutlet private weak var notePreviewLabel: UILabel!
    @IBOutlet private weak var lastEditDateLabel: UILabel!
    
    // MARK: - Class Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.noteTitleLabel.text = nil
        self.notePreviewLabel.text = nil
    }
    
    // MARK: - Methods(public)
    
    func updateData(note: Note) {
        self.noteTitleLabel.text = note.title
        self.notePreviewLabel.text = note.content
        
        if let lastEdit: Date = note.lastEditDate {
            self.lastEditDateLabel.isHidden = false
            let lastEditFormatted: String = AppDelegate.sharedDelegate().dateFormatter.string(from: lastEdit)
            self.lastEditDateLabel.text = "Last edit: \(lastEditFormatted)"
        } else {
            self.lastEditDateLabel.isHidden = true
        }
    }
    
}
