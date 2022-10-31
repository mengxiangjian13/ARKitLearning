//
//  RaycastViewController.swift
//  ARDemo
//
//  Created by mengxiangjian on 2022/10/27.
//

import UIKit
import ARKit

class RaycastViewController: FeatureBaseViewController {
    
    var planeNodeDict: [UUID: SCNNode] = [:]
    
    lazy var arSceneView: ARSCNView = {
        let sceneView = ARSCNView(frame: CGRectZero)
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        return sceneView
    }()
    
    lazy var config: ARWorldTrackingConfiguration = {
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        return config
    }()

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
        
        /// 添加自然光
        let natureLight = SCNLight()
        natureLight.type = .ambient
        let natureLightNode = SCNNode()
        natureLightNode.light = natureLight
        arSceneView.scene.rootNode.addChildNode(natureLightNode)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        arSceneView.session.run(config)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        arSceneView.session.pause()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 在touch end方法中，生成raycast query
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: arSceneView)
        // 根据点击location，判断是否与存在平面交叉，对齐方式（水平还是垂直），来发射raycast。
        guard let query = arSceneView.raycastQuery(
            from: location,
            allowing: .existingPlaneGeometry,
            alignment: .horizontal) else { return }
        
        // 看raycast是否可以检测到与平面相交。
        let results = arSceneView.session.raycast(query)
        for result in results {
            addPlaneNode(raycastResult: result)
        }
        
    }
    
    private func addPlaneNode(raycastResult: ARRaycastResult) {
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        guard let shipNode = scene.rootNode.childNodes.first else { return }
        // 将raycast的result transform传递给飞机，就可以在点击的位置上放置飞机
        shipNode.simdTransform = raycastResult.worldTransform
        arSceneView.scene.rootNode.addChildNode(shipNode)
    }
    
    private var randomColor: UIColor {
        let colors: [UIColor] = [.red, .yellow, .blue, .green, .gray]
        let i = arc4random_uniform(5)
        return colors[Int(i)]
    }

}

extension RaycastViewController: ARSCNViewDelegate {
    // 发现平面
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor else { return }
        let box = SCNBox(width: CGFloat(anchor.extent.x),
                         height: 0,
                         length: CGFloat(anchor.extent.z),
                         chamferRadius: 0)
        box.firstMaterial?.diffuse.contents = randomColor
        let planeNode = SCNNode(geometry: box)
        planeNode.position = SCNVector3(x: anchor.center.x,
                                        y: 0,
                                        z: anchor.center.z)
        planeNode.opacity = 0.8
        node.addChildNode(planeNode)
        planeNodeDict[anchor.identifier] = planeNode
    }
    // 平面变化
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor,
        let planeNode = planeNodeDict[anchor.identifier], let plane = planeNode.geometry as? SCNBox else { return }
        if #available(iOS 16.0, *) {
            plane.width = CGFloat(anchor.planeExtent.width)
            plane.length = CGFloat(anchor.planeExtent.height)
            planeNode.rotation = SCNVector4(x: 0, y: 1, z: 0, w: anchor.planeExtent.rotationOnYAxis)
        } else {
            // Fallback on earlier versions
            plane.width = CGFloat(anchor.extent.x)
            plane.length = CGFloat(anchor.extent.z)
        }
        planeNode.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
    }
    // 平面移除
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let planeNode = planeNodeDict[anchor.identifier] else { return }
        planeNode.removeFromParentNode()
        planeNodeDict.removeValue(forKey: anchor.identifier)
    }
}
