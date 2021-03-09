//
//  MFileManager.swift
//  MagicCube
//
//  Created by lynx on 19/2/2021.
//  Copyright © 2021 Lynx. All rights reserved.
//

import UIKit

///File storage type.
enum MFilePathType: Int {
    case bundle
    case sandbox
}

class MFileManager: NSObject {
    ///The main path of the project directory which ends with /.
    static let bundlePath = Bundle.main.resourcePath! + "/"
    ///The main path of the sandbox which ends with /.
    static let sandboxPath = NSHomeDirectory().appending("/Documents/")
    
    //MARK: - File List Method
    
    ///The list of files in the project directory.
    static func bundleFileList(path: String = bundlePath) -> [String]? {
        let fileManager = FileManager.default
        let bundleFileArray = try?fileManager.contentsOfDirectory(atPath: path)
        return bundleFileArray
    }
    
    ///The list of files in the project directory.
    static func bundleFileList(fileExtension: String, path: String = bundlePath) -> [String]? {
        let fileManager = FileManager.default
        let bundleFileArray = try?fileManager.contentsOfDirectory(atPath: path)
        let bPredicate = NSPredicate(format: "pathExtension == %@", fileExtension)
        if let bundleFileArray = bundleFileArray {
            let bundleNameArray:[String] = (bundleFileArray as NSArray).filtered(using: bPredicate) as! [String]
            return bundleNameArray
        } else {
            return nil
        }
    }
    
    //When a file is brought in by sharing, it is saved in both the Documents main folder and the `Inbox` folder under Documents.
    //When the file name is unrecognizable, such as Chinese, the file only appears in the Documents Inbox folder.
    ///The list of files in the sandbox.
    static func sandboxFileList(path: String = sandboxPath) -> [String]? {
        let fileManager = FileManager.default
        let sandboxFileArray = try?fileManager.contentsOfDirectory(atPath: path)
        return sandboxFileArray
    }
    
    ///The list of files in the sandbox.
    static func sandboxFileList(fileExtension: String, path: String = sandboxPath) -> [String]? {
        let fileManager = FileManager.default
        let sandboxFileArray = try?fileManager.contentsOfDirectory(atPath: path)
        let sbPredicate = NSPredicate(format: "pathExtension == %@", fileExtension)
        if let sandboxFileArray = sandboxFileArray {
            let sandboxNameArray: [String] = (sandboxFileArray as NSArray).filtered(using: sbPredicate) as! [String]
            return sandboxNameArray
        } else {
            return nil
        }
    }
    
    ///Get the file data by file name.
    static func getFileData(type: MFilePathType, fileName:String) -> Data? {
        var path:String?
        switch type {
        case .bundle:
            path = MFileManager.bundlePath.appending(fileName)
        //Bundle.main.path(forResource: fileName, ofType: "")//方法2
        case .sandbox:
            path = MFileManager.sandboxPath.appending(fileName)
        }
        let fileData = try? Data(contentsOf: URL(fileURLWithPath: path ?? ""))
        return fileData
    }
    
    //MARK: - Data Save&Fetch Method
    
    ///Save data in the sandbox.
    static func saveData(data: Data, fileName: String) -> Bool {
        let path = sandboxPath.appending(fileName)
        try?data.write(to: URL(fileURLWithPath: path), options: Data.WritingOptions.atomic)
        return FileManager.default.fileExists(atPath: path)
    }
    
    ///Fetch data.
    static func fetchData(fileName: String) -> Data? {
        let path = sandboxPath.appending(fileName)
        let data = try? Data(contentsOf: URL(fileURLWithPath: path))
        return data
    }
    
    ///Save dictionary information in sandbox.
    static func saveDictionary(dict: [String: Any], fileName: String) -> Bool {
        let path = sandboxPath.appending(fileName)
        NSDictionary(dictionary: dict).write(to: URL(fileURLWithPath: path), atomically: true)
        return FileManager.default.fileExists(atPath: path)
    }
    
    ///Fetch dictionary information.
    static func fetchDictionary(fileName: String) -> [String: Any]? {
        let path = sandboxPath.appending(fileName)
        let dict = NSDictionary(contentsOfFile: path) ?? [:]
        return dict as? [String: Any]
    }
    
    ///Save array information in the sandbox.
    static func saveArray(array: Array<Any>, fileName: String) -> Bool {
        let path = sandboxPath.appending(fileName)
        NSArray(array: array).write(to: URL(fileURLWithPath: path), atomically: true)
        return FileManager.default.fileExists(atPath: path)
    }
    
    //Fetch array information.
    static func fetchArray(fileName: String) -> Array<Any>? {
        let path = sandboxPath.appending(fileName)
        let array = NSArray(contentsOfFile: path) ?? []
        return array as? Array
    }
    
    ///Save image information in the sandbox.
    static func saveImage(image: UIImage, fileName: String) -> Bool {
        let path = sandboxPath.appending(fileName)
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            try?imageData.write(to: URL(fileURLWithPath: path), options: Data.WritingOptions.atomic)
            return FileManager.default.fileExists(atPath: path)
        }
        return false
    }
    
    ///Fetch image information.
    static func fetchImage(fileName: String) -> UIImage? {
        let path = sandboxPath.appending(fileName)
        let image = UIImage(contentsOfFile: path)
        return image
    }
    
    //MARK: - Remove Method
    
    ///Remove the file in the main path of the sandbox.
    static func deleteFile(fileName: String) {
        let filePath = sandboxPath + fileName
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: filePath) {
            try? fileManager.removeItem(atPath: filePath)
        }
    }
    
    ///Remove the file in the main path of the sandbox.
    static func deleteFile(fullPath: String) {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: fullPath) {
            try? fileManager.removeItem(atPath: fullPath)
        }
    }
    
    //MARK: - File Existence
    
    ///Check if the file exists.
    static func fileExists(type: MFilePathType = .sandbox, fileName: String) -> Bool {
        let fileManager = FileManager.default
        var result = false
        if type == .sandbox {
            let filePath = sandboxPath + fileName
            result = fileManager.fileExists(atPath: filePath)
        } else {
            let filePath = bundlePath + fileName
            result = fileManager.fileExists(atPath: filePath)
        }
        return result
    }
    
    ///Check if the file exists.
    static func fileExists(fullPath: String) -> Bool {
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: fullPath)
    }
}
