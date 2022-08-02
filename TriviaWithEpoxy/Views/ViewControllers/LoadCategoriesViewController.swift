//
//  LoadCategoriesViewController.swift
//  TriviaWithEpoxy
//
//  Created by Enrique Nieloud on 30/07/2022.
//

import UIKit

class LoadCategoriesViewController: UIViewController {
    let spinner = UIActivityIndicatorView(style: .large)

    init() {
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        startSpinnerView()
        readTriviaCategories() { [weak self] categs in
            self?.stopSpinnerView()
            if let self = self, let categs = categs {
                DispatchQueue.main.async {
                    let vc = InitialViewController(categories: categs)
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                }
            }
        }
    }
    
    func startSpinnerView() {
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
        spinner.center = view.center
        spinner.startAnimating()
    }
    
    func stopSpinnerView() {
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
