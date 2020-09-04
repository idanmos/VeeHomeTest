//
//  ArchivedTableViewController.swift
//  VeeHomeTest
//
//  Created by Idan Moshe on 04/09/2020.
//  Copyright © 2020 Idan Moshe. All rights reserved.
//

import UIKit

class ArchivedTableViewController: UITableViewController {
    
    let ArchivedNotesToNoteSegue: String = "ArchivedNotesToNoteSegue"
    
    private var notes: [Note] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView(frame: .zero)
        
        self.tableView.register(UINib(nibName: NotesTableViewCell.identifier, bundle: nil),
                                forCellReuseIdentifier: NotesTableViewCell.identifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.notes = CoreDataManager.shared.getNotes(isArchived: true)
        
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NotesTableViewCell.identifier, for: indexPath) as! NotesTableViewCell
        cell.updateData(note: self.notes[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let noteViewController = self.storyboard?.instantiateViewController(identifier: "NoteViewController") as? NoteViewController {
            noteViewController.note = self.notes[indexPath.row]
            self.navigationController?.pushViewController(noteViewController, animated: true)
        }
    }
    
}
