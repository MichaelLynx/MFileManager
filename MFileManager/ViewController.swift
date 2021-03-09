//
//  ViewController.swift
//  MFileManager
//
//  Created by lynx on 2021/3/8.
//  Copyright © 2021 Lynx. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    let cellIdentifier = "TableViewCellIdentifer"
    
    ///文件名列表，工程目录文件及沙盒文件
    var fileNameArray:[[String]] = [[],[]]
    var extraBundlePath = ""
    var extraSandboxPath = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupConfig()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupData()
    }
    
    func setupConfig() {
        title = "Me"
    }
    
    func setupUI() {
        view.addSubview(mTableView)
        mTableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    func setupData() {
        let bundleArray = MFileManager.bundleFileList(fileExtension: "", path: MFileManager.bundlePath + extraBundlePath) ?? []
        let sanboxArray = MFileManager.sandboxFileList(path: MFileManager.sandboxPath + extraSandboxPath) ?? []
        //let fileData = MFileManager.getFileData(type: .bundle, fileName: bundleArray[0])
        
        fileNameArray[0] = bundleArray
        fileNameArray[1] = sanboxArray
        mTableView.reloadData()
        
        let dataName = "myData"
        let mByte: [UInt8] = [0x0, 0x1, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0]
        let data = Data(bytes: mByte, count: mByte.count)
        if MFileManager.saveData(data: data, fileName: dataName) {
            let newData = MFileManager.fetchData(fileName: dataName)!
            print("data:\([UInt8](newData))")
        }
        
        if MFileManager.fileExists(fullPath: MFileManager.bundlePath + "_CodeSignature") {
            print("_CodeSignature file exists.")
        } else {
            print("_CodeSignature file no found.")
        }
    }
    
    //MARK: - Lazy Load
    
    lazy var mTableView: UITableView = {
        let tTableView = UITableView(frame: CGRect.zero, style: .plain)
        tTableView.delegate = self
        tTableView.dataSource = self
        tTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tTableView.separatorStyle = .none
        
        return tTableView
    }()
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return fileNameArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileNameArray[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "工程文件"
        } else {
            return "沙盒文件"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = fileNameArray[indexPath.section][indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let name = fileNameArray[indexPath.section][indexPath.row]
        if indexPath.section == 0 {
            //bundle
            let extraPath = extraBundlePath + "\(name)/"
            if let _ = MFileManager.bundleFileList(path: MFileManager.bundlePath + extraPath ) {
                let vc = ViewController()
                vc.extraBundlePath = extraPath
                vc.extraSandboxPath = extraSandboxPath
                navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            //sandbox
            let extraPath = extraSandboxPath + "\(name)/"
            if let _ = MFileManager.sandboxFileList(path: MFileManager.sandboxPath + extraPath) {
                let vc = ViewController()
                vc.extraSandboxPath = extraPath
                vc.extraBundlePath = extraBundlePath
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.section == 1 {
            return UITableViewCell.EditingStyle.delete
        } else {
            return UITableViewCell.EditingStyle.none
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            let name = fileNameArray[indexPath.section][indexPath.row]
            let path = MFileManager.sandboxPath + extraSandboxPath + "/\(name)"
            MFileManager.deleteFile(fullPath: path)
            setupData()
        }
    }
}
