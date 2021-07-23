//
//  ViewController.swift
//  NamesToFaces
//
//  Created by Atin Agnihotri on 22/07/21.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var people = [Person]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNewImageButton()
        print("Reached the end of viewDidLoad")
        
    }
    
    func addNewImageButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
    }
    
    @objc func addNewPerson() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            fatalError("Unable to dequeue cell")
        }
        
        let person = people[indexPath.item]
        let path = getDocumentsDirectory().appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        cell.nameLabel.text = person.name
        
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
    func loadImagesFromDisk() {
        
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        
        let person = Person(name: "Unknown Name", image: imageName)
        people.append(person)
        collectionView.reloadData()
        
        dismiss(animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let person = people[indexPath.item]
        promptPersonName(for: person)
    }
    
    func promptPersonName(for person: Person) {
        let ac = UIAlertController(title: "Enter Person's Name", message: nil, preferredStyle: .alert)
        ac.addTextField()
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let submit = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac, weak person] _ in
            guard let name = ac?.textFields?[0].text else {
                return
            }
            guard let person = person else {
                return
            }
            self?.savePerson(for: person, with: name)
        }
        ac.addAction(submit)
        ac.addAction(cancel)
        present(ac, animated: true)
    }
    
    func savePerson(for person: Person, with name: String) {
        person.name = name
        collectionView.reloadData()
    }
    
    func getDocumentsDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0]
    }

}

