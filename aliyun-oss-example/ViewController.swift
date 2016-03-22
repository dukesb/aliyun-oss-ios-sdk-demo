//
//  ViewController.swift
//  aliyun-oss-example
//
//  Created by Duc Do Ba on 3/23/16.
//  Copyright © 2016 ducky. All rights reserved.
//

import UIKit
import AliyunOSSiOS

let OSSBucketName = "oss-test-1-japan"
let OSSEndPoint = "http://oss-cn-hongkong.aliyuncs.com"
let OSSCredentialProvider = OSSPlainTextAKSKPairCredentialProvider(plainTextAccessKey: "k3wQpECoFXWnKNb8", secretKey: "lRIFubBHD1W3RGD2M5HMNOoTMJVwFi")
let client = OSSClient(endpoint: OSSEndPoint, credentialProvider: OSSCredentialProvider)
let OSSTestObjectKey = "test-object"


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    @IBAction func uploadTestFile(sender: AnyObject) {
        let putRequest = OSSPutObjectRequest()
        let textContent = "Hello OSS!"
        putRequest.bucketName = OSSBucketName
        putRequest.objectKey = OSSTestObjectKey
        putRequest.uploadingData = NSString(string: textContent).dataUsingEncoding(NSUTF8StringEncoding)
        
        putRequest.uploadProgress = { bytesSent, totalByteSent, totalBytesExpectedToSend in
            print("Bytes sent: \(bytesSent), Total bytes sent:\(totalByteSent), Expected total bytes sent: \(totalBytesExpectedToSend)")
        }
        
        let putTask = client.putObject(putRequest)
        putTask.continueWithBlock({ task in
            var result: String = ""
            if task.error == nil {
                result = "Completed uploading text: " + textContent
            } else {
                result = "Failed to upload object. Error: " + task.error.localizedDescription
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.displayAlert(result)
            })
            
            return nil
        })
    }

    @IBAction func downloadTestData(sender: AnyObject) {
        let getRequest = OSSGetObjectRequest()
        getRequest.bucketName = OSSBucketName
        getRequest.objectKey = OSSTestObjectKey
        
        getRequest.downloadProgress = {bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
            print("Bytes written: \(bytesWritten), Total bytes written: \(totalBytesWritten), Expected total bytes written: \(totalBytesExpectedToWrite)")
        }

        let getTask = client.getObject(getRequest)
        getTask.continueWithBlock { task in
            var result: String
            if task.error == nil {
                let getResult = task.result.downloadedData;
                if let str = String(data: getResult, encoding: NSUTF8StringEncoding) {
                    result = "Downloaded content: " + str
                } else {
                    result = "Failed to download object"
                }
            } else {
                result = "Failed to download object. Error: " + task.error.localizedDescription
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.displayAlert(result)
            })
            
            return nil
        }
    }
    
    @IBAction func destroyTestData(sender: AnyObject) {
        // Documentation is missing :-(
        let deleteRequest = OSSDeleteObjectRequest()
        deleteRequest.bucketName = OSSBucketName
        deleteRequest.objectKey = OSSTestObjectKey
        
        let deleteTask = client.deleteObject(deleteRequest)
        deleteTask.continueWithBlock { task in
            var result: String = ""
            if task.error == nil {
                result = "Finished deleting object"
            } else {
                result = "Failed to delete object. Error: " + task.error.localizedDescription
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.displayAlert(result)
            })
            
            
            return nil
        }
    }
    
    func displayAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

