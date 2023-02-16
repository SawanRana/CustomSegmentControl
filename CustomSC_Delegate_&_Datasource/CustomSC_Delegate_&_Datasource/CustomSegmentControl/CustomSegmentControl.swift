//
//  CustomSegmentControl.swift
//  CutomSCWithDataSourceAndDelegate
//
//  Created by Sawan Rana on 04/02/23.
//

import UIKit

//MARK: Custom segment control
public class CustomSegmentControl: UIView {
    
    @IBOutlet weak var containerView: UIView!
    
    weak var datasource: CustomSCDatasource?
    weak var delegate: CustomSCDelegate?
    
    private var selectorView: UIView!
    private var segmentButtons: [UIButton] = [UIButton]()
    private var boundsWidth: CGFloat? = nil
    
    private var selectedSegmentIndex: Int = 0
    
    public override func draw(_ rect: CGRect) {
        layer.masksToBounds = true
        layer.cornerRadius = frame.height/2
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        layer.borderColor = datasource?.borderColor(in: self).cgColor
        layer.borderWidth = datasource?.borderWidth(in: self) ?? 0.0
        backgroundColor = datasource?.backgroundColor(of: self) ?? .clear
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("CustomSegmentControl", owner: self, options: nil)
        addSubview(containerView)
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.frame = self.bounds
        
        configureSegmentControl()
    }
    
    private func configureSegmentControl() {
        guard let datasource = datasource else {
            return
        }
        
        // Since many view get added multiple time, so we need to remove them everytime we add new views
        segmentButtons.removeAll()
        subviews.forEach { $0.removeFromSuperview() }
        
        let numberOfSegments = datasource.numberOfSegments(in: self)
        if numberOfSegments > 0 {
            
            for segment in 0..<numberOfSegments {
                let button = UIButton(type: .custom)
                let buttonTitle = datasource.titleOfSegment(at: segment, segmentControl: self)
                button.setAttributedTitle(attributedStringForTextColor(buttonTitle: buttonTitle), for: .normal)
                button.addTarget(self, action: #selector(segmentButtonTapped(sender:)), for: .touchUpInside)
                segmentButtons.append(button)
            }
            
            
            // MARK: Setting up selected segment
            if datasource.defaultSegmentIndex(in: self) < numberOfSegments && datasource.defaultSegmentIndex(in: self) > -1 {
                selectedSegmentIndex = datasource.defaultSegmentIndex(in: self)
            }
            let selectedButton = segmentButtons[selectedSegmentIndex]
            selectedButton.setAttributedTitle(attributedStringForTextColor(buttonTitle: selectedButton.titleLabel?.text ?? "", nonSelectedSegmentTextColor: false), for: .normal)
            
            // MARK: Selector view on segment
            layoutIfNeeded()
            self.boundsWidth = self.bounds.width
            let selectorViewWidth = self.boundsWidth! / CGFloat(segmentButtons.count)
            let selectorViewXPosition = (selectorViewWidth * CGFloat(selectedSegmentIndex))
            selectorView = UIView(frame: CGRect(x: selectorViewXPosition, y: 0, width: selectorViewWidth, height: self.frame.height))
            selectorView.bounds = selectorView.bounds.insetBy(dx: datasource.minInset(in: self).inset, dy: datasource.minInset(in: self).inset)
            selectorView.layer.cornerRadius = selectorView.bounds.height * 0.5
            selectorView.backgroundColor = datasource.colorOfSelectedSegment(in: self)
            addSubview(selectorView)
            
            let horizontalStackView = UIStackView(arrangedSubviews: segmentButtons)
            horizontalStackView.axis = .horizontal
            horizontalStackView.alignment = .fill
            horizontalStackView.distribution = .fillEqually
            horizontalStackView.spacing = datasource.minInterSegmentSpacing(in: self)
            addSubview(horizontalStackView)
            horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
            horizontalStackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            horizontalStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            horizontalStackView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
            horizontalStackView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        }
    }
    
    @objc
    private func segmentButtonTapped(sender: UIButton) {
        updateSegmentPosition(sender, animation: datasource?.showAnimation(in: self) ?? true)
    }
    
    private func selectSegment(at index: Int, in segmentControl: CustomSegmentControl) {
        let sender = segmentButtons[index]
        updateSegmentPosition(sender, animation: datasource?.showAnimation(in: self) ?? true)
        
    }
    
    private func updateSegmentPosition(_ sender: UIButton, animation: Bool = true) {
        guard let delegate = delegate, let datasource = datasource else {
            return
        }
        
        
        segmentButtons.enumerated().forEach { (buttonIndex, button) in
            
            if sender == button {
                if selectedSegmentIndex != buttonIndex {
                    selectedSegmentIndex = buttonIndex
                    let selectorViewXPosition = (self.boundsWidth! / CGFloat(segmentButtons.count) * CGFloat(buttonIndex)) + datasource.minInset(in: self).inset
                    
                    if animation {
                        UIView.animate(withDuration: 0.3) { [weak self] in
                            guard let self = self else {
                                return
                            }
                            self.selectorView.frame.origin.x = selectorViewXPosition
                        } completion: { [weak self] success in
                            guard let self = self else {
                                return
                            }
                            if success {
                                button.setAttributedTitle(self.attributedStringForTextColor(buttonTitle: button.titleLabel?.text ?? "", nonSelectedSegmentTextColor: false), for: .normal)
                                delegate.didSelectSegment(at: self.selectedSegmentIndex, in: self)
                            }
                        }
                    } else {
                        self.selectorView.frame.origin.x = selectorViewXPosition
                        button.setAttributedTitle(self.attributedStringForTextColor(buttonTitle: button.titleLabel?.text ?? "", nonSelectedSegmentTextColor: false), for: .normal)
                        delegate.didSelectSegment(at: self.selectedSegmentIndex, in: self)
                    }
                } else {
                    if datasource.showLogInfo(in: self) {
                        print("Index \(selectedSegmentIndex) is already selected")
                    }
                }
            } else {
                button.setAttributedTitle(attributedStringForTextColor(buttonTitle: button.titleLabel?.text ?? ""), for: .normal)
            }
        }
    }

    private func attributedStringForTextColor(buttonTitle: String, nonSelectedSegmentTextColor: Bool = true) -> NSAttributedString {
        let combinedAttributedString = NSMutableAttributedString()
        if let datasource = datasource {
            var attributes = [NSAttributedString.Key.font: datasource.titleFontOfNonSelectedSegment(in: self).font, NSAttributedString.Key.foregroundColor: datasource.titleColorOfNonSelectedSegment(in: self)]
            if !nonSelectedSegmentTextColor {
                attributes = [NSAttributedString.Key.font: datasource.titleFontOfSelectedSegment(in: self).font, NSAttributedString.Key.foregroundColor:  datasource.titleColorOfSelectedSegment(in: self)]
            }
            let attributedString = NSAttributedString(string: buttonTitle, attributes: attributes as [NSAttributedString.Key : Any])
            combinedAttributedString.append(attributedString)
        }
        return combinedAttributedString
    }

}

public extension CustomSegmentControl {
    func reloadData() {
        self.configureSegmentControl()
    }
    
    func showDefaultSegment(at index: Int, in segmentControl: CustomSegmentControl) {
        if index != selectedSegmentIndex {
            self.selectSegment(at: index, in: self)
        }
    }
}


public protocol CustomSCDatasource: AnyObject {
    // MARK: - @required methods
    func numberOfSegments(in segmentControl: CustomSegmentControl) -> Int
    func titleOfSegment(at index: Int, segmentControl: CustomSegmentControl) -> String
    
    // MARK: - @optional methods
    func minInterSegmentSpacing(in segmentControl: CustomSegmentControl) -> CGFloat
    func minInset(in segmentControl: CustomSegmentControl) -> CustomSCInset
    func colorOfSelectedSegment(in segmentControl: CustomSegmentControl) -> UIColor
    func titleColorOfSelectedSegment(in segmentControl: CustomSegmentControl) -> UIColor
    func titleColorOfNonSelectedSegment(in segmentControl: CustomSegmentControl) -> UIColor
    func titleFontOfSelectedSegment(in segmentControl: CustomSegmentControl) -> CustomSCFont
    func titleFontOfNonSelectedSegment(in segmentControl: CustomSegmentControl) -> CustomSCFont
    func borderWidth(in segmentControl: CustomSegmentControl) -> CGFloat
    func borderColor(in segmentControl: CustomSegmentControl) -> UIColor
    func showAnimation(in segmentControl: CustomSegmentControl) -> Bool
    func backgroundColor(of segmentControl: CustomSegmentControl) -> UIColor
    func showLogInfo(in segmentControl: CustomSegmentControl) -> Bool
    func defaultSegmentIndex(in segmentControl: CustomSegmentControl) -> Int
}

public extension CustomSCDatasource {
    func minInterSegmentSpacing(in segmentControl: CustomSegmentControl) -> CGFloat {
        return 0.0
    }
    
    func minInset(in segmentControl: CustomSegmentControl) -> CustomSCInset {
        return CustomSCInset.zero
    }
    
    func colorOfSelectedSegment(in segmentControl: CustomSegmentControl) -> UIColor {
        return UIColor(red: 0, green: 184, blue: 82, alpha: 1)
    }
    
    func titleColorOfSelectedSegment(in segmentControl: CustomSegmentControl) -> UIColor {
        return UIColor(red: 255, green: 255, blue: 255, alpha: 1)
    }
    
    func titleColorOfNonSelectedSegment(in segmentControl: CustomSegmentControl) -> UIColor {
        return UIColor(red: 0, green: 184, blue: 82, alpha: 1)
    }
    
    func borderWidth(in segmentControl: CustomSegmentControl) -> CGFloat {
        return 1.0
    }
    
    func borderColor(in segmentControl: CustomSegmentControl) -> UIColor {
        return UIColor.systemBlue
    }
    
    func showAnimation(in segmentControl: CustomSegmentControl) -> Bool {
        return true
    }
    
    func backgroundColor(of segmentControl: CustomSegmentControl) -> UIColor {
        return UIColor.clear
    }
    
    func titleFontOfSelectedSegment(in segmentControl: CustomSegmentControl) -> CustomSCFont {
        return .defaultFont
    }
    
    func titleFontOfNonSelectedSegment(in segmentControl: CustomSegmentControl) -> CustomSCFont {
        return .defaultFont
    }
    
    func showLogInfo(in segmentControl: CustomSegmentControl) -> Bool {
        return true
    }
    
    func defaultSegmentIndex(in segmentControl: CustomSegmentControl) -> Int {
        return 0
    }
    
}

public protocol CustomSCDelegate: AnyObject {
    func didSelectSegment(at index: Int, in segmentControl: CustomSegmentControl)
}


//MARK: Struct helpers
public struct CustomSCInset {
    var inset: CGFloat
    static var zero = CustomSCInset(inset: 0.0)
}

public struct CustomSCFont {
    var font: UIFont
    
    static var defaultFont = CustomSCFont(font: UIFont(name: "Helvetica Neue", size: 12)!)
}
