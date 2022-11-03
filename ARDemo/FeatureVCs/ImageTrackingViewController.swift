//
//  ImageTrackingViewController.swift
//  ARDemo
//
//  Created by mengxiangjian on 2022/11/1.
//

import UIKit
import ARKit
import SpriteKit
import AVFoundation

class ImageTrackingViewController: FeatureBaseViewController {
    
    var videoNode: SKVideoNode?
    
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
        if imageAnchor.name == "unity" {
            print("detect unity logo")
            let videoSize = CGSize(width: 1280, height: 720)
            let videoURL = Bundle.main.url(forResource: "Unitylogo", withExtension: ".mp4")
            let avPlayer = AVPlayer(url: videoURL!)
            // playerScene宽度应该与视频宽度相同，宽高比例应该与检测出来的图片的宽高比例相同，这样可以保证视频node的宽高比例正确
            let playerScene = SKScene(size: CGSize(width: videoSize.width, height: videoSize.width / imageAnchor.referenceImage.physicalSize.width * imageAnchor.referenceImage.physicalSize.height))
            // 可以根据宽高比例缩放
            playerScene.scaleMode = .aspectFit
            videoNode = SKVideoNode(avPlayer: avPlayer)
            videoNode!.position = CGPoint(x: playerScene.size.width / 2, y: playerScene.size.height / 2)
            // 视频是什么比例，就配置这个比例
            videoNode!.size = videoSize
            // yScale需要设置-1，不然视频是倒着的
            videoNode!.yScale = -1
            videoNode!.play()
            playerScene.addChild(videoNode!)
            plane.firstMaterial?.diffuse.contents = playerScene
        } else {
            plane.firstMaterial?.diffuse.contents = UIColor.red.withAlphaComponent(0.9)
        }
        let planeNode = SCNNode(geometry: plane)
        // SCNPlane是2D的控件，坐标系在3D空间中是竖直的，和3D空间的坐标系不同。所以需要旋转90度
        planeNode.eulerAngles.x = -.pi/2
        node.addChildNode(planeNode)
        
        boxsDict[anchor.identifier] = planeNode
        
        // 设置动画
        planeNode.opacity = 0.1
        planeNode.scale = SCNVector3(x: 0.1, y: 0.1, z: 0.1)
        planeNode.runAction(SCNAction.group([
            .fadeIn(duration: 1),
            .scale(to: 1, duration: 1)
        ]))
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeNode = boxsDict[anchor.identifier] else { return }
//        planeNode.transform = SCNMatrix4(anchor.transform)
    }
}
