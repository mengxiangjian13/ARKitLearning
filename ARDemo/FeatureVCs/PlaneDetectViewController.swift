//
//  PlaneDetectViewController.swift
//  ARDemo
//
//  Created by mengxiangjian on 2022/10/25.
//

import UIKit
import ARKit

class PlaneDetectViewController: FeatureBaseViewController {
    
    lazy var arSceneView: ARSCNView = {
        let sceneView = ARSCNView(frame: CGRectZero)
        sceneView.delegate = self
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        sceneView.showsStatistics = true
        return sceneView
    }()
    
    lazy var arConfig: ARWorldTrackingConfiguration = {
        let config = ARWorldTrackingConfiguration()
        /// 开启平面检测
        config.planeDetection = .horizontal
        return config
    }()
    
    /// key是anchor的id，node是对应的带颜色的平面
    private var planeNodeDict = [UUID: SCNNode]()

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
        
        arSceneView.session.delegate = self
        arSceneView.session.run(arConfig)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        arSceneView.session.pause()
    }
    
    private var randomColor: UIColor {
        let colors: [UIColor] = [.red, .yellow, .blue, .green, .gray]
        let i = arc4random_uniform(5)
        return colors[Int(i)]
    }

}

extension PlaneDetectViewController: ARSCNViewDelegate, ARSessionDelegate {
    
    /// 发现了新anchor，并且为anchor创建了node。但是这个node并不能显示出来，需要添加子node，用于显示，使平面可见。
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let anchor = anchor as? ARPlaneAnchor {
            print("anchor render added: \(anchor.identifier)")
            // 为新发现的平面node添加可见的平面
            // 先创建可见平面geometry，用SCNBox实现，高度是0的box就是平面。geometry设置大小
            let plane = SCNBox(width: CGFloat(anchor.extent.x), height: 0, length: CGFloat(anchor.extent.z), chamferRadius: 0)
            // 平面geometry设置颜色是红色
            plane.firstMaterial?.diffuse.contents = randomColor
            // 用geometry创建node
            let planeNode = SCNNode(geometry: plane)
            // node设置position
            planeNode.position = SCNVector3(x: anchor.center.x, y: 0, z: anchor.center.z)
            node.addChildNode(planeNode)
            
            planeNodeDict[anchor.identifier] = planeNode
        }
    }
    
    /// node和anchor发生了变化
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let anchor = anchor as? ARPlaneAnchor {
            // anchor extend表示长宽高。ARPlaneAnchor的extend，x和z表示长宽，y始终为0。
            print("anchor render updated: \(anchor.identifier), width: \(anchor.extent.x), height: \(anchor.extent.z)")
            if let planeNode = planeNodeDict[anchor.identifier], let plane = planeNode.geometry as? SCNBox {
                // 平面大小有变化，重新设置平面node的geometry的大小
                if #available(iOS 16.0, *) {
                    plane.width = CGFloat(anchor.planeExtent.width)
                    plane.length = CGFloat(anchor.planeExtent.height)
                    // iOS15及其以前的版本，平面旋转了，anchor自己会旋转，只需要适配平面的width，和length就可以了。iOS16，anchor自己自动转，但围绕这y轴旋转的角度是有的，需要自己旋转。
                    planeNode.rotation = SCNVector4(x: 0, y: 1, z: 0, w: anchor.planeExtent.rotationOnYAxis)
                } else {
                    // Fallback on earlier versions
                    plane.width = CGFloat(anchor.extent.x)
                    plane.length = CGFloat(anchor.extent.z)
                }
                planeNode.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        if let planeNode = planeNodeDict[anchor.identifier] {
            planeNode.removeFromParentNode()
            planeNodeDict.removeValue(forKey: anchor.identifier)
        }
    }
}
