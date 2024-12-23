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
        if let fieldsCell = visibleFieldsCell() {
            viewModel.name = fieldsCell.nameTextField.text ?? ""
            viewModel.email = fieldsCell.emailTextField.text ?? ""
            viewModel.location = fieldsCell.locationTextField.text ?? ""
            viewModel.country = fieldsCell.countryTextField.text ?? ""
            viewModel.bio = fieldsCell.bioTextField.text ?? ""
        }
        
        print("Name: \(viewModel.name)")
        print("Email: \(viewModel.email)")
        print("Location: \(viewModel.location)")
        print("Country: \(viewModel.country)")
        print("Bio: \(viewModel.bio)")
        
        view.endEditing(true)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
            
            // 1) If user picked a new image, display it
            if let selectedImage = selectedProfileImage {
                cell.profileImageView.image = selectedImage
                
            // 2) If no new image but we have a URL from Firebase, load it
            } else if !viewModel.profileImageLink.isEmpty {
                // Naive approach: load image synchronously.
                // For production, consider using URLSession or an image loading library (e.g. SDWebImage)
                if let url = URL(string: viewModel.profileImageLink) {
                    DispatchQueue.global().async {
                        if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                // Only update if no user-selected image arrived in the meantime
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
                
            // 3) Otherwise, use the fallback image
            } else {
                cell.profileImageView.image = UIImage(named: "dummyProfile")
            }
            
            // Handle edit button tap
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
            
            cell.selectionStyle = .none
            return cell
        }
    }
    
    @objc private func editProfileImageTapped() {
        presentImagePicker()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Handle cell selection if needed
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 200 : UITableView.automaticDimension
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
            // Reload only the profile image cell
            profileTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
        
        dismiss(animated: true, completion: nil)
    }
}



