//
//  ViewController.swift
//  Task_12
//
//  Created by DREAMWORLD on 02/05/24.
//

import UIKit
import SDWebImage
import MultiSlider
import NVActivityIndicatorView

class ViewController: UIViewController {

    @IBOutlet weak var sliderBackView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var userDetails: [UserDetails] = []
    
    let slider = MultiSlider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let frame = CGRect(x: view.bounds.width / 2 - 25, y: view.bounds.height / 2 - 150, width: 50, height: 50)
        let loader = NVActivityIndicatorView(frame: frame, type: .ballScaleMultiple, color: .gray, padding: 0.0)
        loader.startAnimating()
        self.view.addSubview(loader)
        
        fetchUserData()

        slider.value = [0,0.2,0.5,0.8,1]
        slider.tintColor = .black
        slider.thumbTintColor = .clear
        slider.orientation = .horizontal
        
        self.sliderBackView.addSubview(slider)
        slider.frame = sliderBackView.bounds
        slider.trackWidth = 5
        slider.centerThumbOnTrackEnd = true
        
        // Set custom UIImageViews for thumb views
        let thumbViewSize = CGSize(width: 35, height: 35)

        for i in 0..<5 {
            if let url = URL(string: userDetails[i].imageUrl) {
                let thumbView = UIImageView()
                thumbView.sd_setImage(with: url, completed: nil)
                thumbView.frame.size = thumbViewSize
                thumbView.contentMode = .scaleAspectFill
                thumbView.layer.cornerRadius = thumbViewSize.width / 2
                thumbView.clipsToBounds = true
                thumbView.isUserInteractionEnabled = true
                slider.thumbViews[i].addSubview(thumbView)
                thumbView.bringSubviewToFront(slider.thumbViews[i])
                thumbView.center = CGPoint(x: slider.thumbViews[i].bounds.width / 2, y: slider.thumbViews[i].bounds.height / 2)
                thumbView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(thumbViewTapped(_:))))
                
                
//                let line = UIView()
//                line.backgroundColor = .black
//                line.frame = CGRect(x: slider.thumbViews[i].bounds.width / 2 - 1, y: slider.thumbViews[i].bounds.height / 2, width: 2, height: 30)
//                slider.thumbViews[i].addSubview(line)
//                line.isUserInteractionEnabled = true
//                line.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped)))
            }
        }
        
        collectionView.collectionViewLayout = StoryProfileCollectionViewLayout()
    }
    
    @objc func thumbViewTapped(_ sender: UITapGestureRecognizer) {
        print("tap")
    }
    
    @objc func viewTapped() {
        print("view")
    }
    
    private func fetchUserData() {
        let path = Bundle.main.path(forResource: "user-details", ofType: "json")
        let data = NSData(contentsOfFile: path ?? "") as Data?
        do {
            let json = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
            if let aUserDetails = json["userDetails"] as? [[String : Any]] {
                for element in aUserDetails {
                    userDetails += [UserDetails(userDetails: element)]
                }
            }
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
        }
    }
    
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userDetails.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryCollectionCell", for: indexPath) as! StoryCollectionCell
        cell.nameLabel.text = userDetails[indexPath.row].name
        cell.profileImage.sd_setImage(with: URL(string: userDetails[indexPath.row].imageUrl)!, placeholderImage: UIImage(systemName: "person"))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "StoryPageViewController") as! StoryPageViewController
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        
        vc.userDetails = self.userDetails
        vc.userIndex = indexPath.row
        present(vc, animated: true, completion: nil)
    }
    
}

class StoryProfileCollectionViewLayout: UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        
        if let collectionView = collectionView {
            
            let itemHeight = collectionView.bounds.height
            let itemWidth = itemHeight - 35
            
            itemSize = CGSize(width: itemWidth, height: itemHeight)
            minimumLineSpacing = 0
            minimumInteritemSpacing = 0
            scrollDirection = .horizontal
        }
    }
}

