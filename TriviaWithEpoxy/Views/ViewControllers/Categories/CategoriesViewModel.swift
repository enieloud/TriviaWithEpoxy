//
//  TriviaViewModel.swift
//  TriviaWithEpoxy
//
//  Created by Enrique Nieloud on 03/08/2022.
//

import Foundation
import RxSwift
import RxCocoa

final class CategoriesViewModel {
    private let disposeBag = DisposeBag()
    var gameInfo: GameInfo?
    var categories: TriviaCategories? {
        get {
            gameInfo?.categories
        }
    }
    
// MARK: - Categories
    private var categoriesIsLoadingSubject = PublishSubject<Bool>()
    lazy var categoriesIsLoadingPublisher = categoriesIsLoadingSubject.asDriver(onErrorJustReturn: false)

    func fetchCategories() {
        self.categoriesIsLoadingSubject.onNext(true)
        TriviaAPIClient.fetchCategories()
            .subscribe(onNext: { categories in
                self.gameInfo = GameInfo(categories: categories)
                self.categoriesIsLoadingSubject.onNext(false)
            },
        onError: { error in
            })
        .disposed(by: disposeBag)
    }
}
