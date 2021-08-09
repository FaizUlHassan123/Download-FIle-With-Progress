//
//  ViewController.swift
//  Download
//
//  Created by Faiz Ul Hassan on 8/9/21.
//

import UIKit

class ViewController: UIViewController {
    
    let urlString = "https://firebasestorage.googleapis.com/v0/b/firestorechat-e64ac.appspot.com/o/intermediate_training_rec.mp4?alt=media&token=e20261d0-7219-49d2-b32d-367e1606500c"

    let shapeLayer = CAShapeLayer()
    
    let percentageLabel: UILabel = {
        let label = UILabel()
        label.text = "0%"
        label.textColor = UIColor.init(named: "Splash")
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize:12)
        return label
    }()
    
    
    @IBOutlet weak var downloadView:UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.bringSubviewToFront(downloadView)
        beginDownloadingFile()
    }
    
    func addPercentageLAbel(){
        self.downloadView.isHidden = false
        downloadView.layer.cornerRadius = downloadView.frame.size.width/2
        downloadView.backgroundColor = .white
        downloadView.addSubview(percentageLabel)
        percentageLabel.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        percentageLabel.center = CGPoint(x: downloadView.frame.size.width/2, y: downloadView.frame.size.height/2)
        
        // let's start by drawing a circle somehow
        
        // create my track layer
        let trackLayer = CAShapeLayer()
        
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 40, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        trackLayer.path = circularPath.cgPath
        
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = 7
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = CAShapeLayerLineCap.round
        //        trackLayer.position = view.center
        trackLayer.position = CGPoint(x: downloadView.frame.size.width/2, y: downloadView.frame.size.height/2)
        trackLayer.name = "trackingLayer"
        
        downloadView.layer.addSublayer(trackLayer)
        
        shapeLayer.path = circularPath.cgPath
        
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 7
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        //        shapeLayer.position = view.center
        shapeLayer.position = CGPoint(x: downloadView.frame.size.width/2, y: downloadView.frame.size.height/2)
        shapeLayer.name = "shapeLayer"
        shapeLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        
        shapeLayer.strokeEnd = 0
        
        downloadView.layer.addSublayer(shapeLayer)
    }
    
    private func beginDownloadingFile() {
        print("Attempting to download file")
        self.addPercentageLAbel()
        
        shapeLayer.strokeEnd = 0
        guard let url = URL(string: urlString) else {
            return
        }
        let configuration = URLSessionConfiguration.default
        let operationQueue = OperationQueue()
        let urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: operationQueue)
        
        let downloadTask = urlSession.downloadTask(with: url)
        downloadTask.resume()
    }
    
    
    fileprivate func animateCircle() {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        
        basicAnimation.toValue = 1
        
        basicAnimation.duration = 2
        
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = false
        
        shapeLayer.add(basicAnimation, forKey: "urSoBasic")
    }
    

}

extension ViewController:URLSessionDownloadDelegate{
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let percentage = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
        
        DispatchQueue.main.async {
            self.percentageLabel.text = "\(Int(percentage * 100))%"
            self.shapeLayer.strokeEnd = percentage
        }
        
        print(percentage)
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        if let error = error{
            print(error.localizedDescription)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error{
            print(error.localizedDescription)
        }
    }
    
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let url = downloadTask.originalRequest?.url else {
            return
        }
        guard let mimeType = downloadTask.response?.mimeType else {
            return
        }
        print(mimeType)
        let a = mimeType.split(separator: "/")
        let extesion  = a[1]
        // Create destination URL
        let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "\(url.deletingPathExtension().lastPathComponent)" + "." + "\(extesion)"
        print("FileName is \(fileName)")
        let destinationFileUrl = documentsUrl.appendingPathComponent("\(fileName)")
        
        try? FileManager.default.removeItem(at: destinationFileUrl)
        do {
            try FileManager.default.moveItem(at: location, to: destinationFileUrl)
            do {
                
                //Show UIActivityViewController to save the downloaded file
                let contents  = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                for indexx in 0..<contents.count {
                    if contents[indexx].lastPathComponent == destinationFileUrl.lastPathComponent {
                        let activityViewController = UIActivityViewController(activityItems: [contents[indexx]], applicationActivities: nil)
                        DispatchQueue.main.async {
                            self.present(activityViewController, animated: true, completion: nil)
                        }
                    }
                }
            }
            catch (let err) {
                print("error saving file: \(err)")
            }
        }
        catch (let writeError) {
            print("Error creating a file \(destinationFileUrl) : \(writeError)")
        }
        
        
        print("Downloading finished")
    }
}
