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
        startSpinnerView()
    }
    
    override func viewDidDisappear(_ : Bool) {
        stopSpinnerView()
    }
    
    func startSpinnerView() {
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
        spinner.center = view.center
        spinner.startAnimating()
    }
    
    func stopSpinnerView() {
        self.spinner.stopAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
