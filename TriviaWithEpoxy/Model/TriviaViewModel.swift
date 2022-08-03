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
    lazy var categories = categoriesSubject.asDriver(onErrorJustReturn: TriviaCategories.empty())

    func fetchCategories() {
        TriviaAPIClient.fetchCategories()
            .subscribe(onNext: { categories in
                self.categoriesSubject.onNext(categories)
            },
        onError: { error in
            })
        .disposed(by: disposeBag)
    }
}
