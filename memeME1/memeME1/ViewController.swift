import UIKit
class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate,
                      UINavigationControllerDelegate, UITextFieldDelegate   {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyBoardNotifications()
  
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unSubscribeToKeyBoardNotifications()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareTextField(textField: topTextField, defaultText:"TOP")
        prepareTextField(textField: bottomTextField, defaultText:"BOTTOM")
        topTextField.textAlignment = .center
        bottomTextField.textAlignment = .center
        shareButton.isEnabled = true
        #if targetEnvironment(simulator)
        camerButton.isEnabled = false
        #else
           cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera);
        #endif
    }
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var navbar: UINavigationBar!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var camerButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var AlbumButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var ToolBar: UIToolbar!
        
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        pickAnImage(UIImagePickerController.SourceType.photoLibrary)
    }
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
       
        pickAnImage(UIImagePickerController.SourceType.camera)
        }
    
    func prepareTextField(textField: UITextField, defaultText: String) {
        textField.delegate = self
        textField.textAlignment = .center
        textField.defaultTextAttributes = memeTextAttributes
        textField.text = defaultText
        textField.autocapitalizationType = .allCharacters

    }
    
    func pickAnImage(_ source: UIImagePickerController.SourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = source
        present(pickerController, animated: true, completion: nil)
    }
   
    
    @IBAction func shareAnImage(_ sender: Any) {
        
        let sharedImage = generateMemedImage()
        let controller = UIActivityViewController(activityItems: [sharedImage], applicationActivities: nil)
        controller.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if completed && error == nil {
                self.save()
            }
        }
        present(controller,animated: true, completion: nil)
    }
    @IBAction func cancelToShareMeme(_ sender: Any) {
        leaveMemeInBetween()
    }
    @IBAction func topTextField(_ sender: Any) {
        textFieldDidBeginEditing(topTextField)
        

    }
    
    @IBAction func bottomTextField(_ sender: Any) {
        textFieldDidBeginEditing(bottomTextField)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("Image selected")
        if let image = info[.originalImage] as? UIImage {
            imagePickerView.image = image
        }
        shareButton.isEnabled = true
        print("share button action is active")
        dismiss(animated: true, completion: nil)
       }
       func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
       {
          dismiss(animated: true, completion: nil)
       }
    @objc func textFieldDidBeginEditing(_ textField: UITextField){
           if (textField == topTextField && textField.text == "TOP") || (textField == bottomTextField && textField.text == "BOTTOM"){
               textField.text = " "
           }
       }
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool{
            textField.resignFirstResponder()
           return true
       }
       let memeTextAttributes: [NSAttributedString.Key: Any] = [
           NSAttributedString.Key.strokeColor: UIColor.black,
           NSAttributedString.Key.foregroundColor:UIColor.white,
           NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
           NSAttributedString.Key.strokeWidth: -3.5
       ]
       
       @objc func keyboardWillShow(_ notification:Notification){
           if bottomTextField.isFirstResponder{
               view.frame.origin.y = -getKeyboardHeight(notification)
           }
       }
        
    @objc func keyboardWillHide(_ notification:Notification){
        view.frame.origin.y = 0
        }
   
    func getKeyboardHeight(_ notification:Notification) -> CGFloat{
     
           let userInfo = notification.userInfo
           let keyBoardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
           return keyBoardSize.cgRectValue.height
       }
       
       func subscribeToKeyBoardNotifications() {
           NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
           NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
       }
       func unSubscribeToKeyBoardNotifications() {
           NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
           NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
       }
       
       func save() {
           _ = Meme(topText: topTextField.text!,
                           bottomText: bottomTextField.text!,
                           originalImage:imagePickerView.image!,
                           memedImage: generateMemedImage())
       }

    struct Meme {
           let topText:String
           let bottomText:String
           let originalImage:UIImage
           let memedImage:UIImage
       }
       
       func generateMemedImage() -> UIImage {
           self.navigationController?.navigationBar.isHidden = true;

           self.tabBarController?.tabBar.isHidden = true;
           UIGraphicsBeginImageContext(self.view.frame.size)
           view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
           let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
           UIGraphicsEndImageContext()
           self.navigationController?.navigationBar.isHidden = false;
           self.tabBarController?.tabBar.isHidden = false;

           return memedImage
       }
       func leaveMemeInBetween(){
           topTextField.text = "TOP"
           bottomTextField.text = "BOTTOM"
           imagePickerView.image = nil
           initialState()
       }
      
    func initialState(){
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        imagePickerView.image = nil
    }

   }
