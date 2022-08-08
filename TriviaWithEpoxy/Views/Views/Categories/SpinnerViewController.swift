//
//  SpinnerViewController.swift
//  TriviaWithEpoxy
//
//  Created by Enrique Nieloud on 30/07/2022.
//

import UIKit

class SpinnerViewController: UIViewController {
  let spinner = UIActivityIndicatorView(style: .large)

  init() {
    super.init(nibName: nil, bundle: nil)
    view.backgroundColor = .white
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.startSpinnerView()
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    self.stopSpinnerView()
  }

  func startSpinnerView() {
    self.spinner.hidesWhenStopped = true
    view.addSubview(self.spinner)
    self.spinner.center = view.center
    self.spinner.startAnimating()
  }

  func stopSpinnerView() {
    self.spinner.stopAnimating()
  }

  @available(*, unavailable)
  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
