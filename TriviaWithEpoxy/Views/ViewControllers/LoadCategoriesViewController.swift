//
//  LoadCategoriesViewController.swift
//  TriviaWithEpoxy
//
//  Created by Enrique Nieloud on 30/07/2022.
//

import UIKit
import RxSwift

class LoadCategoriesViewController: UIViewController {
    let spinner = UIActivityIndicatorView(style: .large)
    let disposeBag = DisposeBag()

    init() {
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        startSpinnerView()
        TriviaAPIClient.fetchCategories().subscribe { [weak self] triviaCategories in
            DispatchQueue.main.async {
                self?.stopSpinnerView()
                if let self = self {
                    let vc = InitialViewController(categories: triviaCategories)
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true)
                }
            }
        } onError: { [weak self] error in
            DispatchQueue.main.async {
                self?.stopSpinnerView()
            }
        }
        .disposed(by: disposeBag)
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
