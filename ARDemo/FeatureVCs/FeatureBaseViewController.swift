//
//  FeatureBaseViewController.swift
//  ARDemo
//
//  Created by mengxiangjian on 2022/10/25.
//

import UIKit

class FeatureBaseViewController: UIViewController {
    
    lazy var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: view.bounds.width - 60, y: 44, width: 44, height: 44)
        button.backgroundColor = .red
        button.setTitle("关闭", for: .normal)
        button.addTarget(self, action: #selector(_close), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = .black
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        view.addSubview(closeButton)
        view.bringSubviewToFront(closeButton)
    }
    
    
    @objc private func _close() {
        self.dismiss(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
