//
//  ProfileViewController.swift
//  Pessanger
//
//  Created by 강민성 on 2021/05/15.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
<<<<<<< HEAD
    
    
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private var sections = [Section]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        configureModels()
        title = "설정"
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: Setup
    fileprivate func setupNavigation() {
        navigationController?.navigationBar.tintColor = .label

    }
    
    private func configureModels() {
        sections.append(Section(title: "프로필", options: [Option(title: "프로필 보기", handler: { [weak self] in
            DispatchQueue.main.async {
                self?.viewProfile()
            }
        })]))
        
        
        sections.append(Section(title: "계정", options: [Option(title: "로그아웃", handler: { [weak self] in
            DispatchQueue.main.async {
                self?.signOutTapped()
            }
        })]))
        
        
    }
    
    private func viewProfile() {
        let vc = ProfileViewController()
        vc.title = "프로필"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    private func signOutTapped() {
        let alert = UIAlertController(title: "로그아웃", message: "로그아웃 하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "로그아웃", style: .destructive, handler: { _ in
            
        } ))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        
    }
    
    // MARK: -TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = sections[indexPath.section].options[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = sections[indexPath.section].options[indexPath.row]
        model.handler()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let model = sections[section]
        return model.title
    }
 
    
=======
  private let tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .grouped)
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    return tableView
  }()
  
  private var sections = [Section]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavigation()
    configureModels()
    title = "설정"
    view.addSubview(tableView)
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  // MARK: Setup
  fileprivate func setupNavigation() {
    navigationController?.navigationBar.tintColor = .label
  }
  
  private func configureModels() {
    sections.append(Section(title: "프로필", options: [Option(title: "프로필 보기", handler: { [weak self] in
      DispatchQueue.main.async {
        self?.viewProfile()
      }
    })]))
    
    sections.append(Section(title: "계정", options: [Option(title: "로그아웃", handler: { [weak self] in
      DispatchQueue.main.async {
        self?.signOutTapped()
      }
    })]))
  }
  
  private func viewProfile() {
    let vc = ProfileViewController()
    vc.title = "프로필"
    vc.navigationItem.largeTitleDisplayMode = .never
    navigationController?.pushViewController(vc, animated: true)
  }
  
  private func signOutTapped() {
    let alert = UIAlertController(title: "로그아웃", message: "로그아웃 하시겠습니까?", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
    alert.addAction(UIAlertAction(title: "로그아웃", style: .destructive, handler: { _ in
      
    } ))
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    tableView.frame = view.bounds
  }
  
  // MARK: -TableView
  func numberOfSections(in tableView: UITableView) -> Int {
    return sections.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sections[section].options.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let model = sections[indexPath.section].options[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    cell.textLabel?.text = model.title
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    let model = sections[indexPath.section].options[indexPath.row]
    model.handler()
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    let model = sections[section]
    return model.title
  }
>>>>>>> 3ac318330d3addcd6d25c67d5df7818a5118d3c0
}
