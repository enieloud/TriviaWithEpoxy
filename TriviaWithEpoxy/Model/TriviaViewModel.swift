//
//  TriviaViewModel.swift
//  TriviaWithEpoxy
//
//  Created by Enrique Nieloud on 03/08/2022.
//

import Foundation
import RxSwift
import RxCocoa

final class TriviaViewModel {
    private let disposeBag = DisposeBag()
    
    private var categoriesSubject = PublishSubject<TriviaCategories>()
    private var loadingSubject = PublishSubject<Bool>()

    lazy var categories = categoriesSubject.asDriver(onErrorJustReturn: TriviaCategories.empty())
    lazy var loading = loadingSubject.asDriver(onErrorJustReturn: false)

    func fetchCategories() {
        loadingSubject.onNext(true)
        TriviaAPIClient.fetchCategories().subscribe { [weak self] categories in
            self?.loadingSubject.onNext(false)
            self?.categoriesSubject.onNext(categories)
        } onError: { [weak self] error in
            self?.loadingSubject.onNext(false)
        }
        .disposed(by: disposeBag)
    }
}
