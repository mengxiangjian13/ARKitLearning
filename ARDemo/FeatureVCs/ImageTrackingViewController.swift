//
//  ImageTrackingViewController.swift
//  ARDemo
//
//  Created by mengxiangjian on 2022/11/1.
//

import UIKit
import ARKit

class ImageTrackingViewController: FeatureBaseViewController {
    
    lazy var arSceneView: ARSCNView = {
        let sceneView = ARSCNView(frame: CGRectZero)
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        return sceneView
    }()
    
    lazy var config: ARImageTrackingConfiguration = {
        // ARImageTrackingConfiguration 专门用于图片探查和追踪。没有world track。
        let config = ARImageTrackingConfiguration()
        config.maximumNumberOfTrackedImages = 2
        config.trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "TrackImages", bundle: nil)!
        return config
    }()
    
    var boxsDict = [UUID: SCNNode]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(arSceneView)
        
        NSLayoutConstraint.activate([
            arSceneView.leftAnchor.constraint(equalTo: view.leftAnchor),
            arSceneView.rightAnchor.constraint(equalTo: view.rightAnchor),
            arSceneView.topAnchor.constraint(equalTo: view.topAnchor),
            arSceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        arSceneView.session.run(config)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        arSceneView.session.pause()
    }

}

extension ImageTrackingViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        
        print("add image anchor name: \(String(describing: imageAnchor.name))")
        // 使用图片真实大小初始化，当加入到node当中，会进行缩放，适应场景中的图片大小。
        let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
        plane.firstMaterial?.diffuse.contents = UIColor.red.withAlphaComponent(0.9)
        let planeNode = SCNNode(geometry: plane)
        // SCNPlane是2D的控件，坐标系在3D空间中是竖直的，和3D空间的坐标系不同。所以需要旋转90度
        planeNode.eulerAngles.x = -.pi/2
        node.addChildNode(planeNode)
                
        boxsDict[anchor.identifier] = planeNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeNode = boxsDict[anchor.identifier] else { return }
//        planeNode.transform = SCNMatrix4(anchor.transform)
    }
}
