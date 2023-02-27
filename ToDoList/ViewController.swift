//
//  ViewController.swift
//  ToDoList
//
//  Created by 김정운 on 2023/01/19.
//

import UIKit
import CoreData
/**
        중요도에 따라서 rowValue를 반환한다
 
    case에 따라 색상 리턴
     1. Level1 .green
     2. Level2 .orange
     3. Level3 .red
 */
enum PrioirtyLevel: Int64 {
    case Level1 //rowValue 0
    case Level2 //rowValue 1
    case Level3 //rowValue 2
}

extension PrioirtyLevel{
    
    var Color: UIColor
    {
        switch self
        {
            case.Level1:
                return .green
            case.Level2:
                return .orange
            case.Level3:
                return .red
        }
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var todoTabelView: UITableView!
    
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    
    var todoList = [ToDoList]()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
//      타이틀 이름
        self.title = "To Do List"
        
//      NavigationBar Controller 함수
        self.makeNavigationBar()
        
        todoTabelView.delegate = self
        
//      보여 줄 셀의 영역
        todoTabelView.dataSource = self
        
        self.fetcData()
        self.relode()
    }
    
    /**
         로컬DB에 접근해서
         저장된 데이터를 가져오는 함수
     */
    func fetcData()
    {
        // CoreData를 통해서 ToDoList타입의 객체를 반환 받음
        let fetcReqeust: NSFetchRequest<ToDoList> = ToDoList.fetchRequest()
        // CoreData의 Container에 접근해서 데이터를 반환 받을 객체
        let context = appdelegate.persistentContainer.viewContext
        do
        {
            // Container의 viewContext를 이용해서 ToDoList타입의 데이터를 받아서 todoList에 적재
            self.todoList = try context.fetch(fetcReqeust)
        }
        catch
        {
            print(error)
        }
    }

    /**
            NavigationBarController 함수
     
        이함수 에서는 네이게션 바의 이벤트를 관리 한다
     1. 리스트 추가 버튼
     2. 타이틀 Background영역
     */
    func makeNavigationBar()
    {
//      리스트 추가 버튼
        let item = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewTodo))
        
        self.navigationItem.rightBarButtonItem = item
        
        
//      타이틀 backgroundColor
        let barAppearnce = UINavigationBarAppearance()
        barAppearnce.backgroundColor = .blue.withAlphaComponent(0.2)
        
        self.navigationController?.navigationBar
            .scrollEdgeAppearance = barAppearnce
    }

    
    /**
     NavigationBar의 + 버튼 이벤트
     */
    @objc func addNewTodo()
    {
        let detaileVC = TodoDetaileViewController(nibName: "TodoDetaileViewController", bundle: nil)
        
        detaileVC.todoListRelode = self
        
        self.present(detaileVC, animated: true)
    }

}

// Cell 데이터 추가 확장기능
extension ViewController: UITableViewDelegate,UITableViewDataSource{
    
    // 리스트 행의 개수 리턴
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.todoList.count
    }
    
    // 조회된 데이터를 셀에 알맞게 출력
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // 지정된 사용 식별자에 대한 사용 가능한 테이블 뷰 셀 객체를 반환하고 테이블에 추가합니다.
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCell", for: indexPath) as! ToDoCell
        
        // topTitleLabel.text 프로퍼티에 값을 할당한다.
        cell.topTitleLabel.text = todoList[indexPath.row].title
        
        // Data타입을 String타입으로 변환한다.
        if let hasDate = todoList[indexPath.row].date
        {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd HH:mm:ss"
            let dateString = formatter.string(from: hasDate)
            
            cell.dateLabel.text = dateString
        }
        else
        {
            cell.dateLabel.text = ""
        }
        
        // Data타입을 UIImage타입으로 반환한다.
        if let image = UIImage(data:todoList[indexPath.row].photo!)
        {
            cell.photoView.image = image
            print(image)
        }
        
        // priority의 인덱스에 따라 색상을 반환한다.
        let priority = todoList[indexPath.row].prioirty
        let priorityColor = PrioirtyLevel(rawValue: priority)?.Color
        
        // 받아온 색상을 Cell 프로퍼티에 할당
        cell.prioirtyView.backgroundColor = priorityColor
        // 표시 모양을 원형으로 만들어 준다.
        cell.prioirtyView.layer.cornerRadius = cell.prioirtyView.bounds.height / 2
        
        
        return cell
    }
    
    // 상세조회
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        // TodoDetaileViewController를 인스턴스화 한다.
        let detaileVC = TodoDetaileViewController(nibName: "TodoDetaileViewController", bundle: nil)
        
        // TodoDetaileViewController에 데이터 넘겨주거나 받아 오기위해
        // ViewController의 인스턴스를 넘겨준다
        detaileVC.todoListRelode = self
        detaileVC.selectdeTodoList = todoList[indexPath.row]
        
        self.present(detaileVC, animated: true)
    }
    
}

extension ViewController: TodoListRelode
{
    func relode()
    {
        self.fetcData()
        self.todoTabelView.reloadData()
    }
}

