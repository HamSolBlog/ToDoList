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
    
    @IBOutlet weak var imageView: UIImageView!
    
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
        }
        else
        {
            deleteBtn.isHidden = true
            saveBtn.setTitle("저장", for: .normal)
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        lowBtn.layer.cornerRadius = lowBtn.bounds.height / 2
        normalBtn.layer.cornerRadius = normalBtn.bounds.height / 2
        highBtn.layer.cornerRadius = highBtn.bounds.height / 2
    }
    
    @objc func addImage(){
        print("image")
        fetchImage(filter: PHPickerFilter.images)
    }
    
    func fetchImage(filter: PHPickerFilter?){
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        
        configuration.filter = filter
        
        let picker = PHPickerViewController(configuration: configuration)
        present(picker, animated: true)
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
