//
//  StoryCollectionCell.swift
//  Task_12
//
//  Created by DREAMWORLD on 02/05/24.
//

import UIKit

class StoryCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var middleView: UIView!
    @IBOutlet weak var imageBackView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var backView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImage.layer.cornerRadius = 5
        middleView.layer.cornerRadius = 5
        //imageBackView.layer.cornerRadius = profileImage.bounds.height / 2
        
        self.addBorderGradient(to: imageBackView, startColor: UIColor.red, endColor: UIColor.blue, lineWidth: 5, startPoint: CGPoint.topLeft, endPoint: CGPoint.bottomRight)
        
    }
    
    func addBorderGradient(to view: UIView, startColor:UIColor, endColor: UIColor, lineWidth: CGFloat, startPoint: CGPoint, endPoint: CGPoint) {
    //This will make view border circular
    view.layer.cornerRadius = 10
    //This will hide the part outside of border, so that it would look like circle
    view.clipsToBounds = true
    //Create object of CAGradientLayer
    let gradient = CAGradientLayer()
    //Assign origin and size of gradient so that it will fit exactly over circular view
    gradient.frame = view.bounds
    //Pass the gredient colors list to gradient object
    gradient.colors = [startColor.cgColor, endColor.cgColor]
    //Point from where gradient should start
    gradient.startPoint = startPoint
    //Point where gradient should end
    gradient.endPoint = endPoint
    //Now we have to create a circular shape so that it can be added to view’s layer
    let shape = CAShapeLayer()
    //Width of circular line
    shape.lineWidth = lineWidth
    //Create circle with center same as of center of view, with radius equal to half height of view, startAngle is the angle from where circle should start, endAngle is the angle where circular path should end
//    shape.path = UIBezierPath(
//    arcCenter: CGPoint(x: view.bounds.height/2,
//    y: view.bounds.height/2),
//    radius: view.bounds.height/2,
//    startAngle: CGFloat(0),
//    endAngle:CGFloat(CGFloat.pi * 2),
//    clockwise: true).cgPath
    //the color to fill the path’s stroked outline
    shape.strokeColor = UIColor.black.cgColor
    //The color to fill the path
    shape.fillColor = UIColor.clear.cgColor
    //Apply shape to gradient layer, this will create gradient with circular border
    //gradient.mask = shape
    //Finally add the gradient layer to out View
    view.layer.addSublayer(gradient)
        view.bringSubviewToFront(middleView)
    }
    
}

extension CGPoint {
     static let topLeft = CGPoint(x: 0, y: 0)
     static let topCenter = CGPoint(x: 0.5, y: 0)
     static let topRight = CGPoint(x: 1, y: 0)
static let centerLeft = CGPoint(x: 0, y: 0.5)
     static let center = CGPoint(x: 0.5, y: 0.5)
     static let centerRight = CGPoint(x: 1, y: 0.5)
static let bottomLeft = CGPoint(x: 0, y: 1.0)
     static let bottomCenter = CGPoint(x: 0.5, y: 1.0)
     static let bottomRight = CGPoint(x: 1, y: 1)
}
