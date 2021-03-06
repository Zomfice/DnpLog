//
//  DnpLogDetailController.swift
//  DnpLog
//
//  Created by Fice on 2021/5/21.
//

import UIKit

class DnpLogDetailController: DnpToolBaseController {

    lazy var textView: UITextView = {
        let m_textView = UITextView()
        m_textView.backgroundColor = UIColor.white
        m_textView.translatesAutoresizingMaskIntoConstraints = false
        m_textView.setContentOffset(CGPoint(x: 0, y: -navigationHeight), animated: false)
        m_textView.delegate = self
        return m_textView
    }()
    
    var content : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.layout()
        DispatchQueue.global().async {
            self.showTextviewContent(content: self.content)
        }
        
        let mock = UIBarButtonItem(title: "Mock", style: .plain, target: self, action: #selector(mockAction))
        let copy = UIBarButtonItem(title: "复制", style: .plain, target: self, action: #selector(copyAction))
        let airDrop = UIBarButtonItem(title: "分享", style: .plain, target: self, action: #selector(shareAction))
        self.navigationItem.rightBarButtonItems = [airDrop,copy,mock]
    }
    
    /// TextView显示
    func showTextviewContent(content: String) {
        let attribute = NSMutableAttributedString(string: content)
        let pattern0 = "((.*?)\\s=)|(\"(.*?)\"\\s:)"
        let contentRange0 = NSRange(location: 0, length: content.count)
        let express0 = try? NSRegularExpression.init(pattern: pattern0, options: .caseInsensitive)
        let expressResults0 = express0?.matches(in: content, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: contentRange0)
        if let result = expressResults0{
            for check in result {
                let range = NSRange(location: check.range.location, length: check.range.length > 1 ? check.range.length - 1 : check.range.length)
                let keycolor = UIColor(red: 58/255.0, green: 181/255.0, blue: 75/255.0, alpha: 1)
                attribute.addAttributes([NSAttributedString.Key.foregroundColor : keycolor], range: range)
            }
        }
        
        let pattern = "((https|http|ftp|rtsp|mms)?:\\/\\/)(.*?)(\"|\\s)"
        let contentRange = NSRange(location: 0, length: content.count)
        let express = try? NSRegularExpression.init(pattern: pattern, options: .caseInsensitive)
        let expressResults = express?.matches(in: content, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: contentRange)
        if let result = expressResults{
            for check in result {
                let range = NSRange(location: check.range.location, length: check.range.length > 1 ? check.range.length - 1 : check.range.length)
                let httpcolor = UIColor(red: 97/255.0, green: 210/255.0, blue: 214/255.0, alpha: 1)
                attribute.addAttributes([NSAttributedString.Key.foregroundColor : httpcolor], range: range)
            }
        }
        
        let keys = ["URL:","Method:","Headers:","RequestBody:","ResponseHeader:","Response:","Error:"]
        for m_key in keys {
            let keycolor = UIColor(red: 146/255.0, green: 38/255.0, blue: 143/255.0, alpha: 1)
            let range = NSString(string: content).range(of: m_key)
            attribute.addAttributes([NSAttributedString.Key.foregroundColor : keycolor], range: range)
        }
        DispatchQueue.main.async {
            self.textView.attributedText = attribute
        }
    }
    
    
    func layout() {
        self.view.addSubview(self.textView)
        NSLayoutConstraint(item: self.textView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self.textView, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self.textView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self.textView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
    
    @objc func mockAction() {
        let arr = content.components(separatedBy: "Response:")
        var dic = [String:Any]()
        if let str = arr.last{
            dic = String.stringToJson(string: str)
        }
        var mockDic = [String:Any]()
        mockDic["params"] = [String:Any]()
        mockDic["data"] = dic
        
        let mockstring = String.jsonToString(dic: mockDic)
        let activity = UIActivityViewController(activityItems: [mockstring], applicationActivities: nil)
        self.present(activity, animated: true, completion: nil)
    }

    @objc func copyAction() {
        let board = UIPasteboard.general
        board.string = self.textView.text
        //self.textView.selectAll(self.textView)
    }
    
    @objc func shareAction() {
        guard let contentText = self.textView.text else {
            return
        }
        let activity = UIActivityViewController(activityItems: [contentText], applicationActivities: nil)
        self.present(activity, animated: true, completion: nil)
    }
    
}

extension DnpLogDetailController: UITextViewDelegate{
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        self.textView.inputView = UIView()
        return true
    }
}
