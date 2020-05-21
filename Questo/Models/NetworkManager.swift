//
//  ImageUpload.swift
//  Questo
//
//  Created by Taichi Kato on 23/11/16.
//  Copyright © 2016 Taichi Kato. All rights reserved.
//
import Alamofire
import Foundation
import UIKit
import CoreGraphics
import SwiftyJSON
import FirebaseAuth
import Firebase

class NetworkManager{
    private let fullUrl = "https://\(UserDefaults.standard.string(forKey: "api") ?? "api.questo.ai")/"
    private let sessionManager = Alamofire.SessionManager.default
    private var token = ""
    init() {
        _ = Auth.auth().currentUser?.getIDTokenForcingRefresh(true, completion: { (idToken, _) in
            self.token = "Bearer " + (idToken ?? "")
        })
    }
    public func rateCard(endUrl: String, id: String, card: Card, onCompletion: ((JSON?) -> Void)? = nil, onError: ((Error?) -> Void)? = nil){
        let url = fullUrl + endUrl /* your API url */
        let headers: HTTPHeaders = [
            :]
        sessionManager.request(url, method: .post, parameters: ["question": card.prompt ?? "", "answer": card.answer ?? "", "rating": "bad", "id": id], headers: headers)
        .responseJSON { response in
            print(response.description)
            if let json = response.result.value as? Data {
                let jsonData = try? JSON(data: json)
                onCompletion?(jsonData)
            }
        }
    }
    public func requestWith(endUrl: String = "generate/image", imageData: [Data?], parameters: [String : Any], onCompletion: ((JSON?) -> Void)? = nil, onError: ((Error?) -> Void)? = nil){
        let url = fullUrl + endUrl /* your API url */
        let headers: HTTPHeaders = [
            "Authorization": token,
            "Content-type": "multipart/form-data"
        ]
        var new = parameters
        if parameters["title"] == nil {
            new["title"] = "Untitled Quiz"
        }
        sessionManager.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in new {
                multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
            }
            for (index, data) in imageData.enumerated(){
                if let data = data{
                    multipartFormData.append(data, withName: "image", fileName: "image\(index).png", mimeType: "application/octet-stream")
                }
            }
            print(multipartFormData)
        }, usingThreshold: UInt64.init(), to: url, method: .post, headers: headers) { (result) in
            switch result{
            case .success(let upload, _, _):
                upload.responseString { response in
                    if let err = response.error{
                        onError?(err)
                        return
                    }
                    if let data = response.data {
                        let json = try? JSON(data: data)
                        print(json?.debugDescription)
                        onCompletion?(json)
                    }else{
                        print(response.debugDescription)
                        onError?(nil)
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                onError?(error)
            }
        }
    }
    public func requestWith(endUrl: String = "generate/text", documentData: String, parameters: [String : Any], onCompletion: ((JSON) -> Void)? = nil, onError: ((Error?) -> Void)? = nil){
        let url = fullUrl + endUrl /* your API url */
        _ = Auth.auth().currentUser?.getIDTokenForcingRefresh(true, completion: { (idToken, error) in
            let headers: HTTPHeaders = [
                "Authorization": idToken ?? "",
                "Content-type": "multipart/form-data"
            ]
            var new = parameters
            if parameters["title"] == nil {
                new["title"] = "Untitled Quiz"
            }

            self.sessionManager.upload(multipartFormData: { (multipartFormData) in
                for (key, value) in new {
                    multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
                }
                multipartFormData.append("\(documentData)".data(using: String.Encoding.utf8)!, withName: "text")
                multipartFormData.append("false".data(using: String.Encoding.utf8)!, withName: "beta")
                
            }, usingThreshold: UInt64.init(), to: url, method: .post, headers: headers) { (result) in
                switch result{
                case .success(let upload, _, _):
                    upload.responseString { response in
                        if let err = response.error{
                            onError?(err)
                            return
                        }
                        if let data = response.data, let json = try? JSON(data: data){
                            print(json.debugDescription)
                            onCompletion?(json)
                        }else{
                            print(response.debugDescription)
                            onError?(nil)
                        }
                    }
                case .failure(let error):
                    print("Error in upload: \(error.localizedDescription)")
                    onError?(error)
                }
            }
        })
    }
}
