//
//  ViewController.swift
//  ImagePickerExperiment
//
//  Created by iamqjin on 2017. 1. 20..
//  Copyright © 2017년 Udacity. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate ,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //미미 구조체 선언
    var meme:Meme?
    let memeTextAttributes:[String:Any] = [
        NSStrokeColorAttributeName: UIColor.black,
        NSForegroundColorAttributeName: UIColor.white,
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName: -2.0]
    
    
    //MARK: 아울렛 선언
    @IBOutlet weak var imagePickView: UIImageView!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var firstTextField: UITextField!
    @IBOutlet weak var secondTextField: UITextField!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    //meme 구조체 공유버튼
    @IBAction func shareImage(_ sender: Any) {
        
        let memedImage = generateMemedImage()

        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        self.present(activityViewController, animated: true, completion: nil)
        
        //액티비티뷰 설정
        activityViewController.completionWithItemsHandler = {
            (activityType: UIActivityType?, shared: Bool, items: [Any]?, error: Error?) in
            
                //사진 저장이 아닌 버튼(공유)일 시 저장하지 않고 공유만 한다.
                if (shared == true && activityType != UIActivityType.saveToCameraRoll) {
                        self.save() // meme구조체 저장
                        let ok = UIAlertAction(title: "확인", style: .cancel, handler:nil)
                    
                        let alert = UIAlertController(title: "", message: "공유가 완료되었습니다.", preferredStyle: .alert)
                        alert.addAction(ok)
                        
                        self.present(alert, animated: true, completion: nil)
                    
                //사진 저장 버튼일 시 사진을 저장한다.
                } else if (shared == true && activityType == UIActivityType.saveToCameraRoll){
                   
                    self.save() // meme구조체 저장
                    
                    let ok = UIAlertAction(title: "확인", style: .cancel, handler:nil)
                    
                    
                    let alert = UIAlertController(title: "", message: "이미지 저장이 완료되었습니다.", preferredStyle: .alert)
                    alert.addAction(ok)
                    
                    self.present(alert, animated: true, completion: nil)
                    
                //그 무엇도 아닐 시 공유취소
                } else {
                    let alert = UIAlertController(title: "", message: "공유가 취소되었습니다.", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)

                }
        }
    }
    
    
    //앨범 버튼을 통한 이미지 선택 액션
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)

    }
    
    //카메라 버튼을 통한 이미지 선택 액션
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }

    
    //미미 사진 추가 취소 액션
    @IBAction func cancelButtonClicked(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true) { () in
            
            let alert = UIAlertController(title: "", message: "이미지 확인창", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
           
            
        }

    }
    
    //배터리 부분 안보이게 감추는 프로퍼티
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //화면이 새롭게 보일때
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications() //노티 얻는거 연결
    }
    
    //화면이 사라질때
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications() //노티 얻는거 끊기
    }
    
    //화면이 로드되기 전에 하는 작업
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shareButton.isEnabled = false
        
        //텍스트 필드 델리게이트 설정
        firstTextField.delegate = self
        secondTextField.delegate = self
        
        //텍스트 필드 설정
        firstTextField.text = "TOP"
        secondTextField.text = "BOTTOM"
        firstTextField.defaultTextAttributes = memeTextAttributes
        firstTextField.textAlignment = NSTextAlignment.center
        secondTextField.defaultTextAttributes = memeTextAttributes
        secondTextField.textAlignment = NSTextAlignment.center
    }

    
    //MARK: 메소드 선언
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: false) { () in
        
        let alert = UIAlertController(title: "", message: "이미지 선택이 취소되었습니다.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true) { () in
            
            if let img = info[UIImagePickerControllerOriginalImage] as? UIImage{
                self.imagePickView.image = img
            }
            
        }
        
        //이미지 저장 후 공유버튼 활성화
        self.shareButton.isEnabled = true
        
    }
    
    
    //텍스트 필드 델리게이트 메소드 선언부
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "TOP" {
            firstTextField.text = ""
        }
        if textField.text == "BOTTOM" {
            secondTextField.text = ""
        }
        
    }
    
    //텍스트 필드 작성시 아무것도 입력안했을 때 얼럿창 띄우기
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" {
            
            let ok = UIAlertAction(title: "확인", style: .default, handler: nil)
            let cancel = UIAlertAction(title: "취소", style: .cancel) {
                (_) in textField.becomeFirstResponder() //취소버튼시 포커싱
            }
            
            let alert = UIAlertController(title: "", message: "입력하지 않으시겠습니까?", preferredStyle: .alert)
            
            alert.addAction(ok)
            alert.addAction(cancel)
            
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    //return 입력시 키보드 사라짐
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func keyboardWillShow(_ notification:Notification) {
        
        if secondTextField.isFirstResponder {
            view.frame.origin.y = 0 - getKeyboardHeight(notification)
        }
        
    }
    
    func keyboardWillHide(_ notification:Notification){
        
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        //노티 설정에 옵저버 추가
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
        
    }

    //미미 구조체에 저장 부분
    func save() {
        
        let memedImage = generateMemedImage()
        meme = Meme(topText: firstTextField.text!, bottomText: secondTextField.text!, originalImage: imagePickView.image!, memedImage: memedImage)
        
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(self.meme!)
        
    }
    
    //미미 수정된 이미지 생성 부분
    func generateMemedImage() -> UIImage {
        
        // 위아래 툴바 숨기기
        self.topToolbar.isHidden = true
        self.bottomToolbar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // 위아래 툴바 다시 보이기
        self.topToolbar.isHidden = false
        self.bottomToolbar.isHidden = false
        
        return memedImage
    }

}

