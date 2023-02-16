//
//  ViewController.swift
//  CustomSC_Delegate_&_Datasource
//
//  Created by Sawan Rana on 08/02/23.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var customSC_1: CustomSegmentControl!
    @IBOutlet weak var customSC_2: CustomSegmentControl!
    @IBOutlet weak var customSC: CustomSegmentControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customSC.datasource = self
        customSC.delegate = self
        // Do any additional setup after loading the view.
        customSC.reloadData()
        
        customSC_1.datasource = self
        customSC_1.delegate = self
        customSC_1.reloadData()
        
        customSC_2.datasource = self
        customSC_2.delegate = self
        customSC_2.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let _ = self else {
                return
            }
//            self.customSC.showDefaultSegment(at: 1, in: self.customSC)
        }
    }
}

extension ViewController: CustomSCDatasource {
    
    func titleOfSegment(at index: Int, segmentControl: CustomSegmentControl) -> String {
        
        if index == 0 {
            return "Seg 0"
        } else if index == 1 {
            return "Seg 1"
        } else if index == 2 {
            return "Seg 2"
        }
        
        return "Seg ?"
    }
    
    func numberOfSegments(in segmentControl: CustomSegmentControl) -> Int {
        return 4
    }
    
    func minInset(in segmentControl: CustomSegmentControl) -> CustomSCInset {
        return CustomSCInset(inset: 5)
    }
    
    func backgroundColor(of segmentControl: CustomSegmentControl) -> UIColor {
        if segmentControl ==  customSC_1 {
            return UIColor.systemTeal
        }
        if segmentControl == customSC_2 {
            return UIColor.systemMint
        }
        return UIColor.systemCyan
    }
    
    func borderWidth(in segmentControl: CustomSegmentControl) -> CGFloat {
        return 2.0
    }
    
    func borderColor(in segmentControl: CustomSegmentControl) -> UIColor {
        return UIColor.systemOrange
    }
    
    func defaultSegmentIndex(in segmentControl: CustomSegmentControl) -> Int {
        if segmentControl == customSC {
            return 0
        } else if segmentControl == customSC_1 {
            return 1
        } else if segmentControl == customSC_2 {
            return 2
        }
        
        return 0
    }
    
}

extension ViewController: CustomSCDelegate {
    func didSelectSegment(at index: Int, in segmentControl: CustomSegmentControl) {
        print("index: \(index)")
    }
    
    
}


