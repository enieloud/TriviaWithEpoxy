//
//  InitialViewController.swift
//  TriviaWithEpoxy
//
//  Created by Enrique Nieloud on 27/07/2022.
//

import UIKit
import Epoxy

//class InitialViewController: UIViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//    }
//
//}

class InitialViewController: CollectionViewController {
  init() {
    let layout = UICollectionViewCompositionalLayout
      .list(using: .init(appearance: .plain))
    super.init(layout: layout)
    setItems(items, animated: false)
  }

  enum DataID {
    case row
  }

  var count = 0 {
    didSet {
      setItems(items, animated: true)
    }
  }

  @ItemModelBuilder
  var items: [ItemModeling] {
    TextRow.itemModel(
      dataID: DataID.row,
      content: .init(
        title: "Count \(count)",
        body: "Tap to increment"),
      style: .large)
      .didSelect { [weak self] _ in
        self?.count += 1
      }
  }
}
