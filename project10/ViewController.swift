//
//  ViewController.swift
//  project10
//
//  Created by Madiapps on 21/07/2022.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var peoples = [Person]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard

        if let savedPeople = defaults.object(forKey: "people") as? Data {
            if let decodedPeople = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPeople) as? [Person] {
                peoples = decodedPeople
            }
        }
        
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = UIColor.lightGray
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance =
            navigationController?.navigationBar.standardAppearance
        }else{
            navigationController?.navigationBar.backgroundColor = UIColor.lightGray
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
    }

    @objc func addNewPerson() {
        let picker = UIImagePickerController()
        let ac = UIAlertController(title: "Use camera or gallery", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Camera", style: .default) {
            [weak self] action in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                picker.sourceType = .camera
            } else {
                let acError = UIAlertController(title: "Your phone don't have camera, use gallery instead", message: nil, preferredStyle: .alert)
                acError.addAction(UIAlertAction(title: "Use gallery", style: .cancel))
                self?.present(acError, animated: true)
            }
            picker.allowsEditing = true
            picker.delegate = self
            self?.present(picker, animated: true)
        })
        ac.addAction(UIAlertAction(title: "Gallery", style: .default) {
            [weak self] action in
                picker.allowsEditing = true
                picker.delegate = self
                self?.present(picker, animated: true)
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return peoples.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as! PersonCell

        let person = peoples[indexPath.item]

        cell.name.text = person.name

        let path = getDocumentsDirectory().appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)

        cell.imageView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7

        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let person = peoples[indexPath.item]
        
        let acChoice = UIAlertController(title: "Rename or delete person", message: nil, preferredStyle: .actionSheet)
        acChoice.addAction(UIAlertAction(title: "Rename", style: .default) {
            [weak self] action in
            let ac = UIAlertController(title: "Rename person", message: nil, preferredStyle: .alert)
            ac.addTextField()
            ac.addAction(UIAlertAction(title: "cancel", style: .cancel))
            ac.addAction(UIAlertAction(title: "ok", style: .default) {
                [weak self, weak ac] _ in
                guard let newName = ac?.textFields?[0].text else {return}
                person.name = newName
                self?.save()
                self?.collectionView.reloadData()
            })
            
            self?.present(ac, animated: true)
        })
        acChoice.addAction(UIAlertAction(title: "Delete", style: .default) {
            [weak self] action in
            self?.peoples.remove(at: indexPath.item)
            self?.collectionView.deleteItems(at: [indexPath])
            self?.save()
            self?.collectionView.reloadData()
        })
        acChoice.addAction(UIAlertAction(title: "Cancel", style: .default))
        present(acChoice, animated: true)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {return }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        let person = Person(name: "Unknown", image: imageName)
        peoples.append(person)
        self.save()
        collectionView.reloadData()
        
        dismiss(animated: true)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func save() {
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: peoples, requiringSecureCoding: false) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "people")
        }
    }
}

