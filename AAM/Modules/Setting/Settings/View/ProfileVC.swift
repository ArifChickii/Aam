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
    
    // NEW: Track whether any field or image changed
    private var profileHasChanges = false
    
    // NEW: A loader (activity indicator) to show while updating
    private var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .systemGray
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        setupTapGestureToEndEditing()
        setupActivityIndicator()
        
        // Disable the Save button initially
        setSaveButtonEnabled(false)
        
        // Fetch user profile from Firebase
        viewModel.fetchUserProfile { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success():
                // Successfully fetched user data, reload the table
                DispatchQueue.main.async {
                    self.profileTableView.reloadData()
                }
            case .failure(let error):
                print("Error fetching user profile: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Save",
            style: .done,
            target: self,
            action: #selector(saveButtonTapped)
        )
    }
    
    private func setupTableView() {
        profileTableView.delegate = self
        profileTableView.dataSource = self
        
        profileTableView.register(UINib(nibName: ProfileImageTblCell.identifier, bundle: nil),
                                  forCellReuseIdentifier: ProfileImageTblCell.identifier)
        profileTableView.register(UINib(nibName: ProfileFieldsTblCell.identifier, bundle: nil),
                                  forCellReuseIdentifier: ProfileFieldsTblCell.identifier)
        
        profileTableView.tableFooterView = UIView()
    }
    
    private func setupTapGestureToEndEditing() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(endEditingOnTap))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // NEW:
    private func setupActivityIndicator() {
        // Place in center of view
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @IBAction func backBtnAction() {
        Router.pop(from: self)
    }
    
    // MARK: - Actions
    
    /// Toggles the Save button (enabled/disabled) and adjusts tint color for visual feedback
    private func setSaveButtonEnabled(_ isEnabled: Bool) {
        navigationItem.rightBarButtonItem?.isEnabled = isEnabled
        navigationItem.rightBarButtonItem?.tintColor = isEnabled ? view.tintColor : .lightGray
    }
    
    @objc private func saveButtonTapped() {
        // Start loader
        activityIndicator.startAnimating()
        setSaveButtonEnabled(false)
        
        // Update fields from text fields
        if let fieldsCell = visibleFieldsCell() {
            viewModel.name = fieldsCell.nameTextField.text ?? ""
            viewModel.location = fieldsCell.locationTextField.text ?? ""
            viewModel.country = fieldsCell.countryTextField.text ?? ""
            viewModel.bio = fieldsCell.bioTextField.text ?? ""
        }
        
        // 1) If user selected a new image, upload it to Firebase Storage
        if let newImage = selectedProfileImage {
            
            // Generate a unique filename
            let imageName = "profileImage_\(UUID().uuidString)"
            viewModel.firebaseService.uploadImage(image: newImage, imageName: imageName) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let urlString):
                    // 2) Update the user profile with new image URL
                    self.viewModel.updateUserProfile(newImageURL: urlString) { updateResult in
                        self.handleProfileUpdateResult(updateResult)
                    }
                case .failure(let error):
                    self.handleProfileUpdateResult(.failure(error))
                }
            }
            
        } else {
            // If image not changed, just update data with nil for newImageURL
            viewModel.updateUserProfile(newImageURL: nil) { [weak self] updateResult in
                self?.handleProfileUpdateResult(updateResult)
            }
        }
    }
    
    // NEW:
    /// Handles result of the profile update, stops loader, and shows alert
    private func handleProfileUpdateResult(_ result: Result<Void, Error>) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            
            switch result {
            case .success:
                self.showAlert(title: "Success",
                               message: "Profile updated successfully.")
                
                // Reset change tracking
                self.profileHasChanges = false
                self.setSaveButtonEnabled(false)
                
            case .failure(let error):
                self.showAlert(title: "Error",
                               message: "Failed to update profile: \(error.localizedDescription)")
                // Re-enable save button to allow retry
                self.setSaveButtonEnabled(true)
            }
        }
    }
    
    // NEW:
    private func showAlert(title: String, message: String) {
        let alertVC = UIAlertController(title: title,
                                        message: message,
                                        preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    @objc private func endEditingOnTap() {
        view.endEditing(true)
    }
    
    private func visibleFieldsCell() -> ProfileFieldsTblCell? {
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
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ProfileImageTblCell.identifier,
                for: indexPath
            ) as? ProfileImageTblCell else {
                return UITableViewCell()
            }
            
            // Show user-selected image if available
            if let selectedImage = selectedProfileImage {
                cell.profileImageView.image = selectedImage
            }
            // Otherwise, load from Firestore if available
            else if !viewModel.profileImageLink.isEmpty {
                if let url = URL(string: viewModel.profileImageLink) {
                    DispatchQueue.global().async {
                        if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                // Only set if user hasn't picked a new image in the meantime
                                if self.selectedProfileImage == nil {
                                    cell.profileImageView.image = image
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                cell.profileImageView.image = UIImage(named: "dummyProfile")
                            }
                        }
                    }
                } else {
                    cell.profileImageView.image = UIImage(named: "dummyProfile")
                }
            }
            // Fallback
            else {
                cell.profileImageView.image = UIImage(named: "dummyProfile")
            }
            
            cell.editButton.addTarget(self,
                                      action: #selector(editProfileImageTapped),
                                      for: .touchUpInside)
            
            cell.selectionStyle = .none
            return cell
            
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ProfileFieldsTblCell.identifier,
                for: indexPath
            ) as? ProfileFieldsTblCell else {
                return UITableViewCell()
            }
            
            // Populate text fields from the ViewModel
            cell.nameTextField.text = viewModel.name
            cell.emailTextField.text = viewModel.email
            cell.locationTextField.text = viewModel.location
            cell.countryTextField.text = viewModel.country
            cell.bioTextField.text = viewModel.bio
            
            // NEW: Make email textfield non-editable (disabled + gray color)
            cell.emailTextField.isUserInteractionEnabled = false
            cell.emailTextField.textColor = .gray
            
            // NEW: Add target to text fields to track changes
            cell.nameTextField.addTarget(self,
                                         action: #selector(textFieldDidChange(_:)),
                                         for: .editingChanged)
            cell.locationTextField.addTarget(self,
                                         action: #selector(textFieldDidChange(_:)),
                                         for: .editingChanged)
            cell.countryTextField.addTarget(self,
                                         action: #selector(textFieldDidChange(_:)),
                                         for: .editingChanged)
            cell.bioTextField.addTarget(self,
                                         action: #selector(textFieldDidChange(_:)),
                                         for: .editingChanged)
            
            cell.selectionStyle = .none
            return cell
        }
    }
    
    @objc private func editProfileImageTapped() {
        presentImagePicker()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Handle selection if needed
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (indexPath.row == 0) ? 200 : UITableView.automaticDimension
    }
}

// MARK: - Track Text Field Changes
extension ProfileVC {
    @objc private func textFieldDidChange(_ textField: UITextField) {
        // If user modifies any text field, mark profile as changed
        profileHasChanges = true
        setSaveButtonEnabled(true)
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension ProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            self.selectedProfileImage = selectedImage
            // Mark changes and enable Save button
            profileHasChanges = true
            setSaveButtonEnabled(true)
            
            // Reload only the profile image cell
            profileTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
        
        dismiss(animated: true, completion: nil)
    }
}














