//
//  BriefViewController.swift
//  ARDemo
//
//  Created by mengxiangjian on 2022/10/25.
//

import UIKit
import ARKit

class BriefViewController: FeatureBaseViewController {
    
    lazy var arView: ARSCNView = {
        let arview = ARSCNView()
        arview.delegate = self
        arview.backgroundColor = .yellow
        arview.translatesAutoresizingMaskIntoConstraints = false
        arview.showsStatistics = true
        return arview
    }()
    
    lazy var arScene: SCNScene? = {
        let scene = SCNScene(named: "art.scnassets/ship.scn")
        return scene
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(arView)
        NSLayoutConstraint.activate([
            arView.leftAnchor.constraint(equalTo: view.leftAnchor),
            arView.rightAnchor.constraint(equalTo: view.rightAnchor),
            arView.topAnchor.constraint(equalTo: view.topAnchor),
            arView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // 加入场景
        arView.scene = arScene!
        
        // 手动控制摄像机，并不是AR通过手机移动控制摄像机。
//        arView.allowsCameraControl = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 在will appear中启动session
        let config = ARWorldTrackingConfiguration()
        arView.session.run(config)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // 在will disappear中暂停session
        arView.session.pause()
    }

}

extension BriefViewController: ARSCNViewDelegate {
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        print("AR session failed with error: \(error)")
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        print("AR session did change camera tracking state: \(camera.trackingState)")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        print("AR session was interrupted")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        print("AR session was end interrupted")
    }
}
