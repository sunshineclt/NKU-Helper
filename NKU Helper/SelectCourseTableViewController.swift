//
//  SelectCourseTableViewController.swift
//  NKU Helper
//
//  Created by 陈乐天 on 1/9/16.
//  Copyright © 2016 &#38472;&#20048;&#22825;. All rights reserved.
//

import UIKit

class SelectCourseTableViewController: UITableViewController, NKNetworkSearchCourseDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        courseSearchHelper = NKNetworkSearchCourse()
        courseSearchHelper?.delegate = self
        SVProgressHUD.show()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { () -> Void in
            let loginResult = NKNetworkIsLogin.isLoggedin()
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                SVProgressHUD.dismiss()
                switch loginResult {
                case .Loggedin:
                    break
                case .NotLoggedin:
                    NSNotificationCenter.defaultCenter().addObserver(self, selector: "loginComplete", name: "loginComplete", object: nil)
                    self.performSegueWithIdentifier(SegueIdentifier.Login, sender: "GradeShowerTableViewController")
                case .UnKnown:
                    self.presentViewController(ErrorHandler.alert(ErrorHandler.NetworkError()), animated: true, completion: nil)
                }
            })
        }
    }
    
    func loginComplete() {
    }

    var courseSearchHelper: NKNetworkSearchCourse!
    var searchResult: [CourseSelecting]?
    var whichButtonIsClicked: Int?
    
    func didFailToReceiveSearchResult(message: String) {
        self.presentViewController(ErrorHandler.alertWithAlertTitle("获取错误", message: message, cancelButtonTitle: "好"), animated: true, completion: nil)
    }
    
    func didReceiveSearchResult(result: [CourseSelecting]) {
        searchResult = result
        self.performSegueWithIdentifier(SegueIdentifier.showClassSearchDetail, sender: nil)
    }
    
    @IBAction func search(sender: UIButton) {
        switch sender.tag {
        case 1:
            whichButtonIsClicked = 1
            guard let classID = classIDTextField.text where (classID != "") else {
                self.presentViewController(ErrorHandler.alert(ErrorHandler.InputError()), animated: true, completion: nil)
                return
            }
            courseSearchHelper.searchCourseWithClassID(classID)
        case 2:
            whichButtonIsClicked = 2
            guard let classname = classnameTextField.text where (classname != "") else {
                self.presentViewController(ErrorHandler.alert(ErrorHandler.InputError()), animated: true, completion: nil)
                return
            }
            courseSearchHelper.searchCourseWithClassName(classname)
        case 3:
            whichButtonIsClicked = 3
            guard let teachername = teachernameTextField.text where (teachername != "") else {
                self.presentViewController(ErrorHandler.alert(ErrorHandler.InputError()), animated: true, completion: nil)
                return
            }
            courseSearchHelper.searchCourseWithTeachername(teachername)
        case 4:
            break
        default:break
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifier.showClassSearchDetail {
            if let vc = segue.destinationViewController as? SearchCourseTableViewController {
                vc.courseSearchResult = searchResult ?? []
                switch whichButtonIsClicked! {
                case 1:
                    vc.navigationController?.title = "ID" + classIDTextField.text! + "的搜索结果"
                case 2:
                    vc.navigationController?.title = classnameTextField.text! + "的搜索结果"
                case 3:
                    vc.navigationController?.title = teachernameTextField.text! + "的搜索结果"
                default:
                    break
                }
                searchResult = nil
                whichButtonIsClicked = nil
            }
        }
    }
    
    @IBOutlet var classIDTextField: UITextField!
    @IBOutlet var classnameTextField: UITextField!
    @IBOutlet var teachernameTextField: UITextField!
    @IBOutlet var departTextField: UITextField!
}

extension ErrorHandler {
    struct InputError:ErrorHandlerProtocol {
        static let title = "输入错误"
        static let message = "请检查输入"
        static let cancelButtonTitle = "好"
    }
}
