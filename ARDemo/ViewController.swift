//
//  ViewController.swift
//  ARDemo
//
//  Created by mengxiangjian on 2022/10/24.
//

import UIKit
import SceneKit
import ARKit

enum ARFeature: String {
case firstGlance = "ARKit First Glance",
     planeDetection = "AR Plane Detection",
     raycast = "AR Raycast"
}

class ViewController: UIViewController {
    
    let allFeatures: [ARFeature] = [.firstGlance, .planeDetection, .raycast]
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        view.addSubview(tableView)
    }
    
    lazy var tableView: UITableView = {
        let table = UITableView(frame: view.bounds, style: .plain)
        table.delegate = self
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if indexPath.row < allFeatures.count {
            let feature = allFeatures[indexPath.row]
            cell.textLabel?.text = "\(indexPath.row + 1). \(feature.rawValue)"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allFeatures.count;
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "ARKit"
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        88
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row < allFeatures.count {
            let feature = allFeatures[indexPath.row]
            switch feature {
            case .firstGlance:
                let vc = BriefViewController()
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
            case .planeDetection:
                let vc = PlaneDetectViewController()
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
            case .raycast:
                let vc = RaycastViewController()
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true)
            }
        }
    }
}
