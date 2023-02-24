//
//  TodoDetaileViewController.swift
//  ToDoList
//
//  Created by 김정운 on 2023/01/31.
//

import UIKit
import CoreData
import PhotosUI

protocol TodoListRelode :AnyObject{
    /**
     TodoList의 추가, 수정, 삭제 시 ViewRelode를 위한 함수
     */
    func relode()
}

class TodoDetaileViewController: UIViewController {

    /* save기능을 사용하기 위한 인스턴스 */
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    weak var todoListRelode: TodoListRelode?
    private var selection = [String: PHPickerResult]()
    private var selectedAssetIdentifiers = [String]()
    var fetchResults: PHFetchResult<PHAsset>?
    
    @IBOutlet weak var imageView: UIView!
    
    @IBOutlet weak var titleLableSpace: UITextField!
    
    @IBOutlet weak var lowBtn: UIButton!
    @IBOutlet weak var normalBtn: UIButton!
    @IBOutlet weak var highBtn: UIButton!
    
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    
    var selectdeTodoList: ToDoList?
    var priority: PrioirtyLevel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let imageViewAction = UITapGestureRecognizer(target: self, action: #selector(addImage))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(imageViewAction)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let hasData = selectdeTodoList
        {
            titleLableSpace.text = hasData.title
            
            priority = PrioirtyLevel(rawValue: hasData.prioirty)
            
            makePriorityButtonDesign()
            
            deleteBtn.isHidden = false
            saveBtn.setTitle("업데이트", for: .normal)
            print("업데이트")
        }
        else
        {
            deleteBtn.isHidden = true
            saveBtn.setTitle("저장", for: .normal)
            print("저장")
        }
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        lowBtn.layer.cornerRadius = lowBtn.bounds.height / 2
        normalBtn.layer.cornerRadius = normalBtn.bounds.height / 2
        highBtn.layer.cornerRadius = highBtn.bounds.height / 2
    }
    
    
    @IBOutlet weak var photoImageView: UIImageView!
    {
        didSet
        {
            photoImageView.contentMode = .scaleAspectFit
        }
    }
    
    @objc func addImage()
    {
        self.checkPermission()
        
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
    }
    
    /**
        접근 권한을 확인하는 함수
     */
    func checkPermission()
    {
        // PHPhotoLibrary의 권한 부여 상태
        switch PHPhotoLibrary.authorizationStatus()
        {
            // 접근권한이 있거나 제한적으로 접권한이 있을 경우
            case .authorized, .limited : DispatchQueue.main.async
            {
                self.fetchImage()
            }
            
            // 제한이 거부되어 있을 경우
            case .denied : DispatchQueue.main.async
            {
                self.showAutorizationDeniedAlert()
            }
            
            // 아직 접근권한이 설정되어 있지 않은 경우
            case .notDetermined : self.notDeterminedMesage()
                
            default : break
        }
    }
    
    /**
        Gallery에 접근 하기 위한 함수
     */
    func fetchImage()
    {
        var configuration = PHPickerConfiguration(photoLibrary: .shared()) // PhotoLibrary 옵션 설정
                
        configuration.selectionLimit = 1    // 가져올 수 있는 사진의 개수
        
        let picker = PHPickerViewController(configuration: configuration) // PHPickerViewController 인스턴스화
        picker.delegate = self // 데이터를 전달 할 delegate
        present(picker, animated: true) // PHPickerViewController 화면 열기
    }
    
    /**
        권한이 거부되어 있을 경우의 알림 함수
     */
    func showAutorizationDeniedAlert()
    {
        // UIAlertController를 이용한 메세지 객체 생성
        let alert = UIAlertController(title: "포토라이브러리의 접근 권한을 활성화 해주세요.", message: nil, preferredStyle: .alert)
        
        // 버튼 생성 객체
        alert.addAction(UIAlertAction(title: "닫기", style: .cancel))
        alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default, handler:
        {
            // 버튼의 액션 수행 이벤트 설정
            action in
            // url 객체 생성
            guard let url = URL(string: UIApplication.openSettingsURLString) else {return}
            
            if UIApplication.shared.canOpenURL(url) // 앱이 처리 할수 있는 URL 확인
            {
                UIApplication.shared.open(url)      // URL 열기
            }
        }))
        
        self.present(alert, animated: true) // UIAlertController 화면 열기
    }
    
    /**
        아직 접근권한이 설정되어 있지 않은 경우 알림 함수
     */
    func notDeterminedMesage()
    {
        PHPhotoLibrary.requestAuthorization
        {
            staus in self.checkPermission()
        }
    }
    
    @IBAction func buttenEventSpace(_ sender: UIButton) {
        
        switch sender.tag
        {
        case 1 :
            priority = .Level1
        case 2 :
            priority = .Level2
        case 3 :
            priority = .Level3
            
        default : break
        }
        
        makePriorityButtonDesign()
    }
    
    func makePriorityButtonDesign()
    {
        lowBtn.backgroundColor = .clear
        normalBtn.backgroundColor = .clear
        highBtn.backgroundColor = .clear
        
        switch self.priority
        {
            case .Level1:
                lowBtn.backgroundColor = priority?.Color
            case .Level2:
                normalBtn.backgroundColor = priority?.Color
            case .Level3:
                highBtn.backgroundColor = priority?.Color
            default:
                break
        }
    }
    
    @IBAction func saveEventSpace(_ sender: Any) {
        
        if selectdeTodoList != nil
        {
            updateTodo()
        }
        else
        {
            saveTodo()
        }
        
        appDelegate.saveContext()
        todoListRelode?.relode()
        self.dismiss(animated: true)
    }
    
    /**
     신규 데이터 저장
     */
    func saveTodo()
    {
        
        /* 생성한 Entity를 반환해주는 인스턴스 -> (NSEntityDescription) */
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "ToDoList", in: context) else { return }
        
        /* 생성한 Entity를 사용할 수 있게 만들어주는 인스턴스 */
        guard let object = NSManagedObject(entity: entityDescription, insertInto: context) as? ToDoList else { return }
        
        object.title = titleLableSpace.text
        object.date = Date()
        object.uuid = UUID()
        
        object.prioirty = priority?.rawValue ?? PrioirtyLevel.Level1.rawValue
    }
    
    /**
     기존 데이터 수정
     */
    func updateTodo()
    {
        
        guard let hasData = selectdeTodoList else {return}
        
        guard let hasUUID = hasData.uuid else {return}
        
        // 데이터를 불러 올 준비
        let fatchRequest: NSFetchRequest<ToDoList> = ToDoList.fetchRequest()
        
        fatchRequest.predicate = NSPredicate(format: "uuid = %@", hasUUID as CVarArg)
        
        do
        {
            let fetchData = try context.fetch(fatchRequest)
            
            fetchData.first?.title = titleLableSpace.text
            fetchData.first?.date = Date()
            fetchData.first?.prioirty = self.priority?.rawValue ?? PrioirtyLevel.Level1.rawValue
        }
        catch
        {
            print(error)
        }
    }
    
    
    @IBAction func deleteTodoBtn(_ sender: Any)
    {
        deleteTodo()
    }
    
    /**
     데이터 삭제
     */
    func deleteTodo()
    {
        
        guard let hasDate = selectdeTodoList else {return}
        
        guard let hasUUID = hasDate.uuid else {return}
        
        let fetchRequest: NSFetchRequest<ToDoList> = ToDoList.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "uuid = %@", hasUUID as CVarArg)
        
        do
        {
            let fetchData = try context.fetch(fetchRequest)
            
            if let hasObject = fetchData.first
            {
                context.delete(hasObject)
                appDelegate.saveContext()
            }
            
            todoListRelode?.relode()
            self.dismiss(animated: true)
        }
        catch
        {
            print(error)
        }
    }
}

extension TodoDetaileViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult])
    {
        let identifiers = results.map
        {
            $0.assetIdentifier ?? ""
        }
        
        self.fetchResults = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
        
        if let asset = self.fetchResults?.firstObject
        {
            self.loadImage(asset: asset)
        }
        
        self.dismiss(animated: true)
    }
}

extension TodoDetaileViewController {
    
    func loadImage(asset: PHAsset)
    {
        let imageManeger = PHImageManager()
//        let scale = UIScreen.main.scale
        let imageSize = CGSize(width: 150, height: 150)
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        
        imageManeger.requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFill, options: options)
        {
            image, info in
            self.photoImageView.image = image
        }
    }
}
