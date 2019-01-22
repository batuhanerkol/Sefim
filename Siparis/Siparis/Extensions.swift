//
//  Extensions.swift
//  Siparis
//
//  Created by Atakan Kartal on 17.01.2019.
//  Copyright © 2019 Batuhan Erkol. All rights reserved.
//

import UIKit

extension UIView {
    func addConstraints(format: String, views: UIView...){
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key: String = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}

extension UIView {
    func addAnchor(topView: NSLayoutAnchor<NSLayoutYAxisAnchor>, topConstant: CGFloat, bottomView: NSLayoutAnchor<NSLayoutYAxisAnchor>, bottomConstant: CGFloat, rightView: NSLayoutAnchor<NSLayoutXAxisAnchor>, rightConstant: CGFloat, leftView: NSLayoutAnchor<NSLayoutXAxisAnchor>, leftConstant: CGFloat ) {
        
        self.topAnchor.constraint(equalTo: topView, constant: topConstant).isActive = true
        self.bottomAnchor.constraint(equalTo: bottomView, constant: bottomConstant).isActive = true
        self.rightAnchor.constraint(equalTo: rightView, constant: rightConstant).isActive = true
        self.leftAnchor.constraint(equalTo: rightView, constant: rightConstant).isActive = true
    }
    
}

extension UIViewController {
    func alertMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Tamam", style: .cancel, handler: nil)
        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)
        
    }
}

extension UIButton{
    func addPlusButton() -> UIButton{
        let button = UIButton()
        button.backgroundColor = UIColor.red
        button.setTitle("+", for: UIControlState.normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont(descriptor: UIFontDescriptor(), size: 30)
        button.layer.cornerRadius = 30
        button.layer.masksToBounds = true
        
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 0)
        button.layer.shadowOpacity = 1
        button.layer.shadowRadius = 3
        
        return button
    }
    
}

//extension UIViewController {
//    func hideKeyboardWhenTappedAround() {
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
//        tap.cancelsTouchesInView = false
//        view.addGestureRecognizer(tap)
//    }
//    
//    @objc func dismissKeyboard() {
//        view.endEditing(true)
//    }
//}

extension UIImageView {
    func loadImage(with urlString: String) {
        guard let url = URL(string: urlString) else{ return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            guard let imageData = data else{ return }
            let photoImage = UIImage(data: imageData)
            
            DispatchQueue.main.async {
                self.image = photoImage
            }
            }.resume()
    }
}


extension UIViewController {
    func showLoadingView(){
        
        let v = UIView()
        v.backgroundColor = #colorLiteral(red: 0.9390663505, green: 0.7354334585, blue: 0.573834057, alpha: 1)
        v.frame = CGRect(origin: view.center, size: CGSize(width: 40, height: 40))
        v.center = view.center
        v.layer.cornerRadius = 5
        view.addSubview(v)
        
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
}
