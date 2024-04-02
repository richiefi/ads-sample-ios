//
//  RootViewController.swift
//  Ads Example App
//

import UIKit

// MARK: View controller

final class RootViewController: UIViewController {
    var dynamicAdsCallback: (() -> Void)?

    override func loadView() {
        let rootView = RootView()
        self.view = rootView

        rootView.dynamicAdsButton.addTarget(self, action: #selector(dynamicAdsAction), for: .primaryActionTriggered)
    }
}

// MARK: Action methods

extension RootViewController {
    @objc
    func dynamicAdsAction() {
        self.dynamicAdsCallback?()
    }
}

// MARK: - View

final class RootView: UIView {
    let dynamicAdsButton: UIButton

    override init(frame: CGRect) {
        self.dynamicAdsButton = UIButton(type: .system)

        super.init(frame: frame)

        self.backgroundColor = UIColor.systemBackground

        self.dynamicAdsButton.setTitle("Dynamic Ads", for: .normal)

        self.dynamicAdsButton.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(self.dynamicAdsButton)

        NSLayoutConstraint.activate([
            self.dynamicAdsButton.centerXAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerXAnchor),
            self.dynamicAdsButton.centerYAnchor.constraint(equalTo: self.safeAreaLayoutGuide.centerYAnchor),
        ])
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
