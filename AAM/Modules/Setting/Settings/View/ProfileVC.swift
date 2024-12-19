//
//  ProfileVC.swift
//  AAM
//
//  Created by Arif on 17/12/2024.
//

import UIKit

class ProfileVC: UIViewController, Storyboarded {

    // MARK: - Outlets
    @IBOutlet weak var profileTableView: UITableView!
    
    // MARK: - Properties
    private let viewModel = ProfileViewModel()
    private var selectedProfileImage: UIImage?
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        setupTapGestureToEndEditing()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        // Example: Add a save button on the navigation bar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(saveButtonTapped))
    }
    
    private func setupTableView() {
        profileTableView.delegate = self
        profileTableView.dataSource = self
        
        profileTableView.register(UINib(nibName: ProfileImageTblCell.identifier, bundle: nil),
                                  forCellReuseIdentifier: ProfileImageTblCell.identifier)
        profileTableView.register(UINib(nibName: ProfileFieldsTblCell.identifier, bundle: nil),
                                  forCellReuseIdentifier: ProfileFieldsTblCell.identifier)
        
        // Optional: Remove extra separators
        profileTableView.tableFooterView = UIView()
    }
    
    private func setupTapGestureToEndEditing() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(endEditingOnTap))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    
    @IBAction func backBtnAction() {
        Router.pop(from: self)
    }
    
    // MARK: - Actions
    @IBAction func saveButtonTapped() {
        // Fetch values from fields cell (if currently visible and loaded)
        if let fieldsCell = visibleFieldsCell() {
            viewModel.name = fieldsCell.nameTextField.text ?? ""
            viewModel.email = fieldsCell.emailTextField.text ?? ""
            viewModel.location = fieldsCell.locationTextField.text ?? ""
            viewModel.country = fieldsCell.countryTextField.text ?? ""
            viewModel.bio = fieldsCell.bioTextField.text ?? ""
        }
        
        // Print all fields texts
        print("Name: \(viewModel.name)")
        print("Email: \(viewModel.email)")
        print("Location: \(viewModel.location)")
        print("Country: \(viewModel.country)")
        print("Bio: \(viewModel.bio)")
        
        // End editing
        view.endEditing(true)
    }
    
    @objc private func endEditingOnTap() {
        view.endEditing(true)
    }
    
    private func visibleFieldsCell() -> ProfileFieldsTblCell? {
        // Assuming the fields cell is always at indexPath.row = 1
        let indexPath = IndexPath(row: 1, section: 0)
        if let cell = profileTableView.cellForRow(at: indexPath) as? ProfileFieldsTblCell {
            return cell
        }
        return nil
    }
    
    private func presentImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension ProfileVC: UITableViewDelegate, UITableViewDataSource {
    // Two cells: 0 for profile image cell, 1 for fields cell
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ProfileImageTblCell.identifier, for: indexPath) as? ProfileImageTblCell else {
                return UITableViewCell()
            }
            
            // Configure cell if needed
            // If an image is already selected, display it
            if let selectedImage = selectedProfileImage {
                cell.profileImageView.image = selectedImage
            } else {
                cell.profileImageView.image = UIImage(named: "dummyProfile")
            }
            
            // Handle edit button tap
            cell.editButton.addTarget(self, action: #selector(editProfileImageTapped), for: .touchUpInside)
            
            cell.selectionStyle = .none
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ProfileFieldsTblCell.identifier, for: indexPath) as? ProfileFieldsTblCell else {
                return UITableViewCell()
            }
            
            // If viewModel already has some data (just an example)
            cell.nameTextField.text = viewModel.name
            cell.emailTextField.text = viewModel.email
            cell.locationTextField.text = viewModel.location
            cell.countryTextField.text = viewModel.country
            cell.bioTextField.text = viewModel.bio
            
            cell.selectionStyle = .none
            return cell
        }
    }
    
    @objc private func editProfileImageTapped() {
        presentImagePicker()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // If needed, handle cell selection. Currently, no action required.
    }
    
    // Set row heights if you want
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 200 // height for profile image cell
        } else {
            return UITableView.automaticDimension // Let it size automatically or set a fixed size
        }
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension ProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Handle the picked image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            self.selectedProfileImage = selectedImage
            // Reload the first cell to show updated image
            profileTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
        
        dismiss(animated: true, completion: nil)
    }
}

