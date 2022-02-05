//
//  ViewController.swift
//  HealthKitDemo
//
//  Created by Insu Byeon on 2022/02/05.
//

import UIKit
import HealthKit

class ViewController: UIViewController {

  @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
  @IBOutlet weak var tableView: UITableView!

  private var data: [HKQuantitySample] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    activityIndicatorView.startAnimating()
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    tableView.dataSource = self
    tableView.estimatedRowHeight = UITableView.automaticDimension

    Task {
      let isSuccess = try await HealthKitStorage.shared.requestAuthorizationIfNeeded()
      // 권한을 허용했다는 여부는 아니다!
      print("성공 여부", isSuccess)
      
      let currentDate = Date()
      let startDate = Calendar.current.date(byAdding: .year,
                                            value: -1,
                                            to: currentDate)
      
      let (_, samples) = try await HealthKitStorage.shared.retrieveStepCount(withStart: startDate,
                                                                             end: currentDate,
                                                                             options: [])
      
      data = (samples as? [HKQuantitySample]) ?? []
      
      tableView.reloadData()
      
      activityIndicatorView.stopAnimating()
    }
    
  }

}

extension ViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return data.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    let sample = data[indexPath.row]
    cell.textLabel?.text = "[\(sample.startDate) - \(sample.endDate)] \(sample.sourceRevision.source.name) : \(sample.quantity)"
    cell.textLabel?.numberOfLines = 0
    return cell
  }
}

