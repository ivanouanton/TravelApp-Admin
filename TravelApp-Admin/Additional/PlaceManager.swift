//
//  PlaceManager.swift
//  TravelApp-Admin
//
//  Created by Антон Иванов on 4/16/20.
//  Copyright © 2020 companyName. All rights reserved.
//

import Foundation
import CoreXLSX
import SwiftyDropbox
import UIKit
import FirebaseStorage

class PlaceManager {
    static let shared = PlaceManager()
    
    private init() {}
    
    let storage = Storage.storage()
    
    let arrDropboxImages = NSMutableArray()
    
    var startVC: StartViewController?
    
    func parseExel() {
        
        guard let path =  Bundle.main.path(forResource: "rome", ofType: "xlsx"),
            let file = XLSXFile(filepath: path) else {
                print("error")
                return
        }
        
        do{
            let sharedStrings = try file.parseSharedStrings()
            
            for path in try file.parseWorksheetPaths() {
                let worksheet = try file.parseWorksheet(at: path)
                for row in worksheet.data?.rows ?? [] {
                    var f: String = ""
                    for (index, c) in row.cells.enumerated() {
                        if (index == 2) {
                            getCoordinate(with: c.stringValue(sharedStrings) ?? "")
                        }
                        // print(index, c.stringValue(sharedStrings))
                        let v = c.stringValue(sharedStrings)
                        f += " " + (v ?? "nil")
                    }
                    print(f)
                }
            }
        } catch(let error) {
            print(error.localizedDescription)
        }
    }
    

    func getCoordinate(with address: String) {
        NetworkProvider.shared.getMoyaProvider().request(.geocode(address: address)) { result in
            switch result{
            case .success(let response):
                if let json : [String:Any] = try? JSONSerialization.jsonObject(with: response.data, options: .allowFragments) as? [String: Any]{
                    
                    guard
                        let results = json["results"] as? Array<Any>,
                        !results.isEmpty,
                        let result = results[0] as? [String: Any] else {
                            print("location not found")
                            return
                    }
                    
                    guard
                        let geometry = result["geometry"] as? [String: Any],
                        let location = geometry["location"] as? [String: Any],
                        let lat = location["lat"] as? Double,
                        let lng = location["lng"] as? Double else {
                            print("location not found")
                            return
                    }
                    
                    print("\(lat) \(lng)")
                    
                    
                }else{
                    print("location not found")
                }
                        
            case .failure(let error):
                print(error.localizedDescription)
                print("location not found")
            }
        }
    }
    
    func getDPImages(with vc: StartViewController) {
        self.startVC = vc
        
        if (DropboxClientsManager.authorizedClient != nil) {
            
            //User is already authorized
            //Fetch images from user's DropBox folder
            self.getImageFromDropbox()
            print("success auth")
        } else {
            
            //User not authorized
            //So we go for authorizing user first.
            DropboxClientsManager.authorizeFromController(UIApplication.shared, controller: vc, openURL: { (url) in
                UIApplication.shared.openURL(url)
                
                //Fetch images from user's DropBox folder
//                self.getImageFromDropbox()
                print("success auth")
            })
            
        }
    }
    
    //Fetch all images from DropBox
    func getImageFromDropbox() {
        
        let client = DropboxClientsManager.authorizedClient
        
        //Get list of folder of dropbox by set (path: "/")
        //Or you can get folder inside a folder by set (path: "/Photos")
        
        
        
        client!.files.listFolder(path: "/new").response{ (objList, error) in
            if let resultList = objList {
                var entrycount = resultList.entries.count
                print(entrycount)
                var r = 0
                var t = 0
                
                let concurrentTasks = 4
                
                let queue = DispatchQueue.global(qos: .background)
                let sema = DispatchSemaphore(value: concurrentTasks)
                
                
                //Create a for loop for get all the entities individually
                for entry in resultList.entries {
   
//      
                    //Check if file have metadata or not
                    if let fileMetadata = entry as? Files.FileMetadata {
                        //                            print("METADATA-EXISTS")
                        
                        
                        //Check file type by extention .jpg/.png
                        //You can check this by your own added extention
                        if self.isFileImage(filename: fileMetadata.name) == true {
                            
                            //Get Path for save image in document directory
                            let destination : (NSURL, HTTPURLResponse) -> NSURL = { temporaryURL, response in
                                return self.getDocumentDirectoryPath(fileName: fileMetadata.name)
                            }
                            
                            //Download Image on destination path
                            queue.async {
                                
                            client!.files.download(path: fileMetadata.pathLower!).response(queue: queue) { response, error in
                                    r += 1
                                    print(r)
                                DispatchQueue.main.async {
                                    self.startVC?.downloadProgLbl.text = "Downloaded \(r)/\(r)"
                                }
                                
                                    sema.signal()
//                                    print(response?.0.name ?? "Error name")
                                    if let (_, url) = response {
                                        let data = response?.1
                                        
                                        if let name = response?.0.name,
                                            let data = data{
                                            let riversRef = self.storage.reference().child("rome_places/\(name)")
                                            print("Download \(name)")
                                            
                                            let uploadTask = riversRef.putData(data, metadata: nil) { (metadata, error) in
                                                guard let metadata = metadata else {
                                                    // Uh-oh, an error occurred!
                                                    return
                                                }
                                                t += 1
                                                DispatchQueue.main.async {
                                                    self.startVC?.uploadProgLbl.text = "Uploaded \(t)/\(r)"
                                                }
                                                // Metadata contains file metadata such as size, content-type.
                                                let size = metadata.size
                                                // You can also access to download URL after upload.
                                                riversRef.downloadURL { (url, error) in
                                                    guard let downloadURL = url else {
                                                        // Uh-oh, an error occurred!
                                                        return
                                                    }
                                                }
                                            }
                                        }
                                        
                                        
                                        
                                        
                                        
                                        //                                        let data = NSData(contentsOfURL: url)
                                        let img = UIImage(data: data!)
                                        
                                        if !self.arrDropboxImages.contains(img!) {
                                            self.arrDropboxImages.add(img!)
                                            //                                            self.collectionViewDropbox.hidden = false
                                            //                                            self.collectionViewDropbox.reloadData()
                                        }
                                        else {
                                            print("Image already added to array")
                                        }
                                    }
                                }
                        }
                                sema.wait()
                                
                            
                        } else {
                            //File is not an image
                        }
                    } else {
                        //If file have not metadata it mean it is a folder.
                    }
                    
                    
                    self.arrDropboxImages
                    //                    if (entrycount == 0 && self.arrDropboxImages.count > 0) {
                    //                        self.collectionViewDropbox.hidden = false
                    //                        self.collectionViewDropbox.reloadData()
                    //                    }
                    
                }
                
                
            } else {
                print(error)
            }
        }
    }
        
        //Logout
        func logoutFromDropBox() {
            //Check Dropbox is authorized or not
            if (DropboxClientsManager.authorizedClient != nil) {

                //If Authorized then unlink it.
                DropboxClientsManager.unlinkClients()
            }
        }
        
        //MARK: check for file type
        private func isFileImage(filename:String) -> Bool {
            let lastPathComponent = filename.pathExtension().lowercased()
            return lastPathComponent == "jpg" || lastPathComponent == "png"
        }
        
        //to get document directory path
        func getDocumentDirectoryPath(fileName:String) -> NSURL {
            let fileManager = FileManager.default
            let directoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let UUID = NSUUID().uuidString
            let pathComponent = "\(UUID)-\(fileName)"
            return directoryURL.appendingPathComponent(pathComponent) as NSURL
        }
 
}

extension String {
    public func lastPathComponent() -> String {
        return (self as NSString).lastPathComponent
    }
    
    public func pathExtension() -> String {
        return (self as NSString).pathExtension
    }
}
