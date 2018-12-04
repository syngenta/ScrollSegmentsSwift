//
//  ScrollSegmentsSwift.swift
//  Pods-ScrollSegment_Example
//
//  Created by Ievgen Iefimenko on 5/4/18.
//

import UIKit
import Foundation
import CoreFoundation

public struct ScrollSegmentStyle {
    
    public var indicatorColor = UIColor(white: 0.95, alpha: 1)
    public var titleMargin: CGFloat = 16
    public var titlePendingHorizontal: CGFloat = 15
    public var titlePendingVertical: CGFloat = 14
    public var titleFont = UIFont.boldSystemFont(ofSize: 14)
    public var normalTitleColor = UIColor.lightGray
    public var selectedTitleColor = UIColor.darkGray
    public var isScrollable = true
    public init() {}
}

public protocol ScrollSegmentDelegate: class {
    func segmentSelected(index: Int)
    func dataLoaded()
}

public class ScrollSegmentsSwift: UIControl {
    
    public weak var delegate: ScrollSegmentDelegate?
    public var style: ScrollSegmentStyle
    public var titles: [String]? {
        didSet {
            reloadData(selectedIndex: 0)
        }
    }
    private var titleLabels: [UILabel] = []
    private var constraintIndWidth = NSLayoutConstraint()
    private var constraintIndLeft = NSLayoutConstraint()
    private let segmentsStack = UIStackView()
    public private(set) var selectIndex = 0
    
    let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.canCancelContentTouches = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsHorizontalScrollIndicator = false
        view.bounces = true
        view.isPagingEnabled = false
        view.scrollsToTop = false
        view.contentInset = UIEdgeInsets.zero
        view.contentOffset = CGPoint.zero
        view.scrollsToTop = false
        return view
    }()
    
    private var indicator: UIView = {
        let ind = UIView()
        ind.translatesAutoresizingMaskIntoConstraints = false
        ind.layer.masksToBounds = true
        return ind
    }()
    
    
    //MARK:- life cycle
    required public init?(coder aDecoder: NSCoder) {
        self.style = ScrollSegmentStyle()
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
    }
    
    @objc func rotated() {
        self.updateViewRotation()
    }
    
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        let x = gesture.location(in: self).x + scrollView.contentOffset.x
        for (i, label) in titleLabels.enumerated() {
            if x >= label.frame.minX && x <= label.frame.maxX {
                setSelectIndex(index: i, animated: true)
                break
            }
        }
    }
    
    public func setSelectIndex(index: Int, animated: Bool = true) {
                    
        guard index >= 0 , index < titleLabels.count else { return }
        
        if style.isScrollable {
            let offSetX = -((scrollView.frame.width/2) - titleLabels[index].frame.origin.x - (titleLabels[index].frame.size.width/2) )
            self.scrollView.contentInset.left = self.bounds.width/2 - ((titleLabels.first?.frame.size.width)!/2)
            self.scrollView.contentInset.right = self.bounds.width/2 - ((titleLabels.last?.frame.size.width)!/2)
            self.scrollView.setContentOffset(CGPoint(x:offSetX, y: 0), animated: animated)
        } else {
            self.scrollView.frame = self.bounds
        }
        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                self.setIndicatorFrame(indexLabel: index)
                self.layoutIfNeeded()
            })
        } else {
            self.setIndicatorFrame(indexLabel: index)
            self.layoutIfNeeded()
        }


        if self.selectIndex != index {
            self.delegate?.segmentSelected(index: index)
        }
        selectIndex = index
        sendActions(for: UIControl.Event.valueChanged)
    }
    
    private func setIndicatorFrame(indexLabel: Int) {
        
        let currentLabel = titleLabels[indexLabel]
        let coverH: CGFloat = style.titleFont.lineHeight + style.titlePendingVertical
        var width = CGFloat()
        var leftInset = CGFloat()
        
        if !style.isScrollable {
            width = currentLabel.frame.size.width
            leftInset = currentLabel.frame.origin.x
        } else {
            width = currentLabel.frame.size.width + coverH/1.3
            leftInset = currentLabel.frame.origin.x - coverH/2.6
        }
        
        self.constraintIndWidth.constant = width
        self.constraintIndLeft.constant = leftInset
        self.indicator.center.y = currentLabel.center.y
        for (index, label) in self.titleLabels.enumerated() {
            label.textColor = index == indexLabel ? style.selectedTitleColor : style.normalTitleColor
        }
    }
    
        private func reloadData(orientationChanged: Bool? = false, selectedIndex: Int) {

        let paddingsOnTheSide: CGFloat = self.style.isScrollable ? 0 : 20
        segmentsStack.translatesAutoresizingMaskIntoConstraints = false
        segmentsStack.translatesAutoresizingMaskIntoConstraints = false
        segmentsStack.layoutMargins = UIEdgeInsets(top: 0, left: paddingsOnTheSide, bottom: 0, right: paddingsOnTheSide)
        segmentsStack.isLayoutMarginsRelativeArrangement = true
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.scrollView)
        let topConstraint =  self.scrollView.topAnchor.constraint(equalTo: self.topAnchor)
        let leftConstraint =  self.scrollView.leftAnchor.constraint(equalTo: self.leftAnchor)
        let rightConstraint =  self.scrollView.rightAnchor.constraint(equalTo: self.rightAnchor)
        let bottomConstraint =  self.scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor)

        self.scrollView.addSubview(self.indicator)
        self.scrollView.addSubview(segmentsStack)
        let h = segmentsStack.heightAnchor.constraint(equalTo: self.scrollView.heightAnchor)
        let centerY = segmentsStack.centerYAnchor.constraint(equalTo: self.scrollView.centerYAnchor)
        let topConstraint1 = segmentsStack.topAnchor.constraint(equalTo: self.scrollView.topAnchor)
        let leftConstraint1 = segmentsStack.leftAnchor.constraint(equalTo: self.scrollView.leftAnchor)
        let rightConstraint1 = segmentsStack.rightAnchor.constraint(equalTo: self.scrollView.rightAnchor)
        let bottomConstraint1 = segmentsStack.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor)
        NSLayoutConstraint.activate([topConstraint, leftConstraint, rightConstraint, bottomConstraint, topConstraint1, leftConstraint1, rightConstraint1, bottomConstraint1, h, centerY])

        guard let titles = self.titles, titles.count > 0  else {
            return
        }
        // Set titles
        let font = self.style.titleFont

        let coverH: CGFloat = font.lineHeight + self.style.titlePendingVertical
        segmentsStack.axis = .horizontal
        segmentsStack.spacing = self.style.titlePendingHorizontal
        segmentsStack.alignment = .fill
        if !self.style.isScrollable {
            segmentsStack.distribution = .fillEqually
            segmentsStack.spacing = self.style.titlePendingHorizontal
            self.scrollView.isScrollEnabled = false
        } else {
            segmentsStack.distribution = .fill
            segmentsStack.spacing = self.style.titlePendingHorizontal + 20
            self.scrollView.isScrollEnabled = true
        }
        self.indicator.backgroundColor = self.style.indicatorColor
        for (index, title) in titles.enumerated() {
            let backLabel = UILabel()
            backLabel.text = title
            backLabel.tag = index
            backLabel.text = title
            backLabel.textColor = self.style.normalTitleColor
            backLabel.font = self.style.titleFont
            backLabel.textAlignment = .center
            self.titleLabels.append(backLabel)
            segmentsStack.addArrangedSubview(backLabel)
        }

        let coverX = self.titleLabels[selectedIndex].frame.origin.x
        let coverW = self.titleLabels[selectedIndex].frame.size.width

        self.constraintIndWidth = NSLayoutConstraint(item: self.indicator,
                                                     attribute: .width,
                                                     relatedBy: .equal,
                                                     toItem: nil,
                                                     attribute: .notAnAttribute,
                                                     multiplier: 1,
                                                     constant: coverW)
        self.constraintIndLeft = NSLayoutConstraint(item: self.indicator,
                                                    attribute: .leading,
                                                    relatedBy: .equal,
                                                    toItem: self.scrollView,
                                                    attribute: .leading,
                                                    multiplier: 1,
                                                    constant: coverX)
        NSLayoutConstraint(item: self.indicator,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: nil,
                           attribute: .notAnAttribute,
                           multiplier: 1,
                           constant: coverH).isActive = true
        self.indicator.centerYAnchor.constraint(equalTo: self.scrollView.centerYAnchor).isActive = true
        self.constraintIndWidth.isActive = true
        self.constraintIndLeft.isActive = true
        self.indicator.layer.cornerRadius = coverH/2
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ScrollSegmentsSwift.handleTapGesture(_:)))
        self.addGestureRecognizer(tapGesture)
        if !self.style.isScrollable {
            segmentsStack.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        }
        DispatchQueue.main.async {
            self.setSelectIndex(index: 0, animated: false)
            self.delegate?.dataLoaded()
        }
    }
    
    
private func updateViewRotation() {
        DispatchQueue.main.async { [weak self] in
            if let self_ = self {
                if self_.style.isScrollable {
                    let offSetX = -(self_.scrollView.frame.width/2 - self_.titleLabels[self_.selectIndex].frame.origin.x - self_.titleLabels[self_.selectIndex].frame.size.width/2)
                    if let firstSegment = self_.titleLabels.first, let lastSegment = self_.titleLabels.last {
                        self?.scrollView.contentInset.left = self_.bounds.width/2 - firstSegment.frame.size.width/2
                        self?.scrollView.contentInset.right = self_.bounds.width/2 - lastSegment.frame.size.width/2
                        self?.scrollView.setContentOffset(CGPoint(x:offSetX, y: 0), animated: true)
                    }
                } else {
                    self?.setIndicatorFrame(indexLabel: self_.selectIndex)
                }
            }
        }
    }
}

