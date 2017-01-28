//
//  EditViewController.swift
//  ImagePickerExperiment
//
//  Created by iamqjin on 2017. 1. 27..
//  Copyright © 2017년 Udacity. All rights reserved.
//

import UIKit

class EditViewController: UIViewController, UITextFieldDelegate ,UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    
    var meme:Meme?
    var memes:[Meme]!
    var indexNumber: Int? //선택된 테이블 인덱스넘버
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let memeTextAttributes:[String:Any] = [
        NSStrokeColorAttributeName: UIColor.black,
        NSForegroundColorAttributeName: UIColor.white,
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName: -2.0]
    
    //MARK: 아울렛 선언
    @IBOutlet weak var originalImage: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!


    
    
    //카메라 사용
    @IBAction func usingCameraAction(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    //앨범 사용
    @IBAction func usingAlbumAction(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    //편집 취소 액션
    @IBAction func editCancel(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    //편집 완료 액션
    @IBAction func editSave(_ sender: Any) {
        save() //미미 구조체 저장
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //이미지 저장 후 저장버튼 활성화
        self.saveButton.isEnabled = false
        
        //텍스트 필드 델리게이트 설정
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        self.memes = appDelegate.memes
        
        topTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment = NSTextAlignment.center
        
        bottomTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.textAlignment = NSTextAlignment.center
        
        //선택된 테이블 데이터 삽입
        if let number = indexNumber  {
            
            originalImage.image = self.memes?[number].originalImage
            topTextField.text  = self.memes?[number].topText
            bottomTextField.text = self.memes?[number].bottomText

        }

    }
    
    //화면 나타날때
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications() //노티 얻는거 연결
    }
    
    //화면 사라질때
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications() //노티 얻는거 끊기
    }
    
    
    
    //배터리 부분 안보이게 감추는 프로퍼티
    override var prefersStatusBarHidden: Bool {
        return true
    }

    //텍스트 부분이 수정되었는지 파악한뒤 세이브버튼 활성화
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("나호출")
        if topTextField.text != self.memes?[indexNumber!].topText || bottomTextField.text != self.memes?[indexNumber!].bottomText{
            self.saveButton.isEnabled = true
        }
        
    }
    
    
    //return 키 눌렀을 때 키보드 사라짐
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    //키보드 설정
    func keyboardWillShow(_ notification:Notification) {
        
        if bottomTextField.isFirstResponder {
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
    
    //노티 옵저버 추가
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    //노티 옵저버 해제
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }

    //이미지 선택 취소시
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: false) { () in
            
            let alert = UIAlertController(title: "", message: "이미지 선택이 취소되었습니다.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    //이미지 선택 시
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true) { () in
            
            if let img = info[UIImagePickerControllerOriginalImage] as? UIImage{
                self.originalImage.image = img
            }
            
        }
        
        //이미지 저장 후 저장버튼 활성화
        self.saveButton.isEnabled = true
        
    }
    

    //기존 미미 구조체 새로 저장 부분
    func save() {
        print("저장부분")
        //미미 사진 저장
        let memedImage = generateMemedImage()
        meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: originalImage.image!, memedImage: memedImage)
        
        //appDelegate에 있는 기존에 저장되있는 곳에 통채로 새로운 구조체로 교체
        appDelegate.memes[indexNumber!] = self.meme!

    }
    
    //미미 수정된 이미지 생성 부분
    func generateMemedImage() -> UIImage {
        
        // 툴바 숨기기
        self.topToolbar.isHidden = true
        self.bottomToolbar.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // 툴바 다시 보이기
        self.topToolbar.isHidden = false
        self.bottomToolbar.isHidden = false
        
        return memedImage
    }


}
