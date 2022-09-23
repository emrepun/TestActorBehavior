//
//  ViewController.swift
//  TestActorBehaviour
//
//  Created by Emre Havan on 23.09.22.
//

import UIKit

final class Networking {
    @MainActor
    func fetch() async -> String {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                continuation.resume(returning: "Test")
            }
        }
    }
}

final class Service {
    
    private let networking = Networking()
    
    weak var delegate: ViewModel!
    
    func fetchValue() {
        Task {
            let result = await networking.fetch()
            // delegate will be notified on main thread on Xcode 13.3 & 13.4 because Networking method returns on @MainActor
            // but it will switch back to a background thread on Xcode 14.0 and will crash, after notifying the delegate.
            delegate.didCompleteFetching(value: result)
        }
    }
}

class ViewModel {
    weak var view: ViewController!
    
    let service: Service
    
    init() {
        service = Service()
        service.delegate = self
    }
    
    func fetchValue() {
        service.fetchValue()
    }
    
    func didCompleteFetching(value: String) {
        view.updateLabel(text: value)
    }
}

class ViewController: UIViewController {

    @IBOutlet private weak var testLabel: UILabel!
    
    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.view = self
        // Do any additional setup after loading the view.
        viewModel.fetchValue()
    }
    
    func updateLabel(text: String) {
        testLabel.text = text
    }


}

