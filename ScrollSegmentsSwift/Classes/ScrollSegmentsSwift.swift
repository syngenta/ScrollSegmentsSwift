//
//  ScrollSegmentsSwift.swift
//  Pods-ScrollSegment_Example
//
//  Created by Ievgen Iefimenko on 5/4/18.
//

import UIKit
import Foundation
import CoreFoundation
import SwiftUI

public struct ScrollSegmentStyle {
    
    public var indicatorColor = UIColor.blue
    public var indicatorInactiveColor = UIColor.lightGray
    public var titlePendingHorizontal: CGFloat = 8
    public var titlePendingVertical: CGFloat = 14
    public var titleFont = UIFont.boldSystemFont(ofSize: 16)
    public var normalTitleColor = UIColor.black
    public var selectedTitleColor = UIColor.white
    public var isScrollable = true
    public init() {}
}

public protocol ScrollSegmentDelegate: class {
    func segmentSelected(index: Int)
    func scrollSegmentsLoaded()
}

public extension ScrollSegmentDelegate {
    func scrollSegmentsLoaded() { }
}

public class ScrollSegmentsSwift: UIControl {
    
    
    public weak var delegate: ScrollSegmentDelegate?
    public var style: ScrollSegmentStyle
    @IBInspectable public var titles: [String] {
        didSet {
            reloadData(selectedIndex: 0)
            self.layoutSubviews()
        }
    }
    private var titleLabels: [UILabel] = []
    private var titleLabelContainers: [UIView] = []
    private var titleIndicators: [UIView] = []
    private var constraintIndWidth = NSLayoutConstraint()
    private var constraintIndLeft = NSLayoutConstraint()
    
    public private(set) var selectedIndex = 0
    
    let scrollView: UIScrollView = {
        let view = UIScrollView()
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

    public override func layoutSubviews() {
        super.layoutSubviews()
        self.updateViewLayouts()
    }

    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
    }
    
    //MARK:- life cycle
    required public init?(coder aDecoder: NSCoder) {
        self.style = ScrollSegmentStyle()
        self.titles = []
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
    }

    public init(titles: [String], style: ScrollSegmentStyle = ScrollSegmentStyle()) {
        self.style = style
        self.titles = titles
        super.init(frame: .zero)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
    }
    
    @objc private func rotated() {
        self.updateViewLayouts()
    }
    
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        let x = gesture.location(in: self).x + scrollView.contentOffset.x

        for (i, container) in titleLabelContainers.enumerated() {
            if x >= container.frame.minX && x <= container.frame.maxX {
                if self.selectedIndex != i {
                    self.delegate?.segmentSelected(index: i)
                }
                setSelectIndex(index: i, animated: true)
                sendActions(for: UIControl.Event.valueChanged)
                break
            }
        }
    }
    
    public func setSelectIndex(index: Int, animated: Bool = true) {
        
        guard index >= 0 , index < titleLabels.count else { return }
        self.selectedIndex = index
        if animated {
            UIView.animate(withDuration: 0.2, animations: {
                self.setIndicatorFrame(indexLabel: index)
                self.layoutIfNeeded()
            })
        } else {
            self.setIndicatorFrame(indexLabel: index)
            self.layoutIfNeeded()
        }
        
        guard style.isScrollable else {
            self.scrollView.frame = self.bounds
            return
        }
        
        guard self.titleLabels.count > index else {
            return
        }
        
        let selectedLabel = titleLabelContainers[index]
        let sideOffset = self.style.titlePendingHorizontal * 2

        self.scrollView.contentInset.left = sideOffset
        self.scrollView.contentInset.right = sideOffset
        self.scrollView.scrollRectToVisible(selectedLabel.frame, animated: true)
    }
    
    private func setIndicatorFrame( indexLabel: Int) {
        
        let currentLabel = titleLabelContainers[indexLabel]
        var width = CGFloat()
        var leftInset = CGFloat()
        
        if !style.isScrollable {
            width = currentLabel.frame.size.width + 10
            leftInset = currentLabel.frame.origin.x - 5
        } else {
            width = currentLabel.frame.size.width
            leftInset = currentLabel.frame.origin.x
        }
        
        self.constraintIndWidth.constant = width
        self.constraintIndLeft.constant = leftInset
        self.indicator.center.y = currentLabel.center.y
        for (index, label) in self.titleLabels.enumerated() {
            label.textColor = index == indexLabel ? style.selectedTitleColor : style.normalTitleColor
        }
        for (index, container) in self.titleIndicators.enumerated() {
            container.backgroundColor = index == indexLabel ? .clear : self.style.indicatorInactiveColor
        }
    }
    
    private func reloadData(orientationChanged: Bool? = false, selectedIndex: Int) {

        let paddingsOnTheSide: CGFloat = self.style.isScrollable ? 0 : 20
        let segmentsStack = UIStackView()
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

        NSLayoutConstraint.activate([
            topConstraint,
            leftConstraint,
            rightConstraint,
            bottomConstraint,
            topConstraint1,
            leftConstraint1,
            rightConstraint1,
            bottomConstraint1,
            h,
            centerY
        ])

        guard self.titles.count > 0  else {
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
            segmentsStack.spacing = self.style.titlePendingHorizontal // + 20
            self.scrollView.isScrollEnabled = true
        }
        self.indicator.backgroundColor = self.style.indicatorColor
        for (index, title) in self.titles.enumerated() {
            let backLabel = UILabel()
            backLabel.text = title
            backLabel.tag = index
            backLabel.text = title
            backLabel.textColor = self.style.normalTitleColor
            backLabel.font = self.style.titleFont
            backLabel.textAlignment = .center

            let indicatorView = UIView(frame: .zero)
            indicatorView.backgroundColor = self.style.indicatorInactiveColor
            indicatorView.addFullFillLayoutedSubview(view: backLabel,
                                                     minWidth: coverH,
                                                     edgeInsets: UIEdgeInsets(top: 0,
                                                                              left: 12,
                                                                              bottom: 0,
                                                                              right: -12))
            indicatorView.layer.cornerRadius = coverH/2

            let container = UIView(frame: .zero)
            container.backgroundColor = .clear
            container.addCenteredVerticalLayoutedSubview(view: indicatorView, height: coverH)

            segmentsStack.addArrangedSubview(container)

            self.titleLabels.append(backLabel)
            self.titleIndicators.append(indicatorView)
            self.titleLabelContainers.append(container)
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
        
        self.setSelectIndex(index: selectedIndex, animated: false)
        self.delegate?.scrollSegmentsLoaded()
    }

    private func updateViewLayouts() {
        self.setIndicatorFrame(indexLabel: self.selectedIndex)

        guard self.style.isScrollable else {
            return
        }

        guard self.titleLabels.count > self.selectedIndex else {
            return
        }

        let sideOffset = self.style.titlePendingHorizontal * 2

        self.scrollView.contentInset.left = sideOffset
        self.scrollView.contentInset.right = sideOffset
        self.scrollView.setContentOffset(CGPoint(x: sideOffset * -1, y: 0), animated: true)
    }
}

private extension UIView {

    func addFullFillLayoutedSubview(view: UIView, minWidth: CGFloat, edgeInsets: UIEdgeInsets = .zero) {
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false

        let constraints = [
            view.topAnchor.constraint(equalTo: topAnchor, constant: edgeInsets.top),
            view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: edgeInsets.bottom),
            view.leftAnchor.constraint(equalTo: leftAnchor, constant: edgeInsets.left),
            view.rightAnchor.constraint(equalTo: rightAnchor, constant: edgeInsets.right),
            view.widthAnchor.constraint(greaterThanOrEqualToConstant: minWidth),
        ]

        NSLayoutConstraint.activate(constraints)
        view.layoutSubviews()
    }

    func addCenteredVerticalLayoutedSubview(view: UIView, height: CGFloat) {
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false

        let constraints = [
            view.heightAnchor.constraint(equalToConstant: height),
            view.centerYAnchor.constraint(equalTo: centerYAnchor),
            view.leftAnchor.constraint(equalTo: leftAnchor),
            view.rightAnchor.constraint(equalTo: rightAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
        view.layoutSubviews()
    }
}
