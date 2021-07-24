//
//  ViewController.swift
//  NamesToFaces
//
//  Created by Atin Agnihotri on 22/07/21.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var pickerType: UIImagePickerController.SourceType?
    var people = [Person]() {
        didSet {
            save()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNewImageButton()
        print("Reached the end of viewDidLoad")
        performSelector(inBackground: #selector(loadSavedPeoples), with: nil)
    }
    
    @objc func loadSavedPeoples() {
        /*
        if let savedPeople = UserDefaults.standard.object(forKey: "people") as? Data {
            if let decodedPeople = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPeople) as? [Person] {
                DispatchQueue.main.async { [weak self] in
                    self?.people = decodedPeople
                    self?.collectionView.reloadData()
                }
            }
        }
        */
        if let savedPeople = UserDefaults.standard.data(forKey: "people") {
            let decoder = JSONDecoder()
            if let decodedData = try? decoder.decode([Person].self, from: savedPeople) {
                DispatchQueue.main.async { [weak self] in
                    self?.people = decodedData
                    self?.collectionView.reloadData()
                }
            }
        }
    }
    
    func save() {
        /*
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: people, requiringSecureCoding: false) {
            UserDefaults.standard.set(data, forKey: "people")
        }
        */
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(people) {
            UserDefaults.standard.set(encodedData, forKey: "people")
        }
    }
    
    func addNewImageButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newPersonChoice))
    }
    
    
    
    @objc func newPersonChoice() {
        let ac = UIAlertController(title: "Select Image", message: nil, preferredStyle: .actionSheet)
        
        let library = UIAlertAction(title: "Photos Library", style: .default) { [weak self] _ in
            self?.addNewPerson(with: .photoLibrary)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let camera = UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
                self?.addNewPerson(with: .camera)
            }
            ac.addAction(camera)
        }
        ac.addAction(library)
        ac.addAction(cancel)
        present(ac, animated: true)
    }
    
    func addNewPerson(with sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        picker.sourceType = sourceType
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
        let index = indexPath.item
        promptPersonChoice(for: index)
    }
    
    func promptPersonChoice(for index: Int) {
        let ac = UIAlertController(title: "Do you want to . . .", message: nil, preferredStyle: .actionSheet)
        let rename = UIAlertAction(title: "Rename", style: .default) {
            [weak self] _ in
            self?.promptPersonName(for: index)
        }
        let delete = UIAlertAction(title: "Delete", style: .destructive) {
            [weak self] _ in
            self?.deletePerson(at: index)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        ac.addAction(rename)
        ac.addAction(delete)
        ac.addAction(cancel)
        present(ac, animated: true)
    }
    
    func promptPersonName(for index: Int) {
        let ac = UIAlertController(title: "Enter Person's Name", message: nil, preferredStyle: .alert)
        ac.addTextField()
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        let submit = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] _ in
            guard let name = ac?.textFields?[0].text else {
                return
            }
            guard let person = self?.people[index] else {
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
        save()
    }
    
    func deletePerson(at index: Int) {
        people.remove(at: index)
        collectionView.reloadData()
    }
    
    func getDocumentsDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0]
    }

}

