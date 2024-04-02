//
//  DynamicAdsViewController.swift
//  Ads Example App
//

import RichieSDK
import UIKit

final class DynamicAdsViewController: UIViewController {
    private let richieAdsController: RichieAdsController

    private var currentPageIndex: Int = -1
    private var items: [DynamicItem] = []
    private var itemViews: [UIView] = []

    init(richieAdsController: RichieAdsController) {
        self.richieAdsController = richieAdsController

        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = DynamicAdsView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dynamicAdsView.scrollView.delegate = self

        self.insert(.color(UIColor(red: 52.0/255.0, green: 181.0/255.0, blue: 208.0/255.0, alpha: 1.0)), at: 0)
        self.insert(.color(UIColor(red: 181.0/255.0, green: 52.0/255.0, blue: 138.0/255.0, alpha: 1.0)), at: 1)
        self.insert(.color(UIColor(red: 52.0/255.0, green: 182.0/255.0, blue: 138.0/255.0, alpha: 1.0)), at: 2)
        self.updateItemViewFrames()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updateItemViewFrames()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in self.updateScrollViewOffset() })
    }
}

// MARK: Ads calls

// This extension contains all the calls we do to RichieAdsController.

extension DynamicAdsViewController {
    func nextFlight() -> RichieAdsSlotAdFlight? {
        self.richieAdsController.nextFlightForSlots(slotIdentifiers: "Page")
    }

    func adView(at index: Int, flight: RichieAdsSlotAdFlight) -> RichieAdsView? {
        self.richieAdsController.view(
            frame: self.frameForView(at: index),
            adFlight: flight,
            delegate: self
        )
    }
}

// MARK: RichieAdsViewDelegate

extension DynamicAdsViewController: RichieAdsViewDelegate {
    func viewControllerForPresenting(from view: RichieAdsView) -> UIViewController {
        self
    }
}

// MARK: UIScrollViewDelegate

extension DynamicAdsViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
        self.currentPageDidChange()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.currentPageDidChange()
    }
}

// MARK: Private

private extension DynamicAdsViewController {
    private func checkForSlotAd() {
        guard let adFlight = self.nextFlight() else {
            return
        }

        self.insert(.ad(adFlight), at: self.currentPageIndex + 1)
        self.updateItemViewFrames()
    }

    private func currentPageDidChange() {
        let newPageIndex = self.pageIndexForCurrentScrollOffset
        guard newPageIndex != self.currentPageIndex else { return }
        let previousPageIndex = self.currentPageIndex

        let previousView = previousPageIndex >= self.itemViews.startIndex ? self.itemViews[previousPageIndex] : nil

        self.currentPageIndex = newPageIndex

        let view = self.itemViews[newPageIndex]

        if !(view is RichieAdsView) {
            // Try adding an ad if the user is not currently viewing an ad
            self.checkForSlotAd()
        }

        if let adView = self.itemViews[newPageIndex] as? RichieAdsView {
            adView.didAppear()
        }

        if let previousAdView = previousView as? RichieAdsView {
            previousAdView.didDisappear()
        }
    }

    private func frameForView(at index: Int) -> CGRect {
        let scrollView = self.dynamicAdsView.scrollView
        return CGRect(
            x: CGFloat(index) * scrollView.bounds.width,
            y: scrollView.bounds.minY,
            width: scrollView.bounds.width,
            height: scrollView.bounds.height
        )
    }

    private var dynamicAdsView: DynamicAdsView {
        self.view as! DynamicAdsView
    }

    private func insert(_ item: DynamicItem, at index: Int) {
        switch item {
        case let .ad(flight):
            guard let adView = self.adView(at: index, flight: flight) else {
                print("Ad view failed to load")
                return
            }
            adView.preloadAdContent()
            self.items.insert(item, at: index)
            self.itemViews.insert(adView, at: index)
            self.dynamicAdsView.scrollView.addSubview(adView)

        case let .color(color):
            let colorView = UILabel(frame: self.frameForView(at: index))
            colorView.backgroundColor = color
            colorView.text = "Swipe"
            colorView.textAlignment = .center
            colorView.font = .boldSystemFont(ofSize: 38.0)

            self.items.insert(item, at: index)
            self.itemViews.insert(colorView, at: index)

            self.dynamicAdsView.scrollView.addSubview(colorView)
        }
    }

    private var pageIndexForCurrentScrollOffset: Int {
        let scrollView = dynamicAdsView.scrollView
        var currentPageIndex = Int((scrollView.contentOffset.x / scrollView.bounds.width).rounded())
        if currentPageIndex < 0 {
            currentPageIndex = 0
        } else if currentPageIndex >= self.items.endIndex {
            currentPageIndex = self.items.endIndex - 1
        }

        return currentPageIndex
    }

    private func updateItemViewFrames() {
        let scrollView = dynamicAdsView.scrollView
        self.dynamicAdsView.scrollView.contentSize = CGSize(
            width: CGFloat(self.items.count) * scrollView.bounds.width,
            height: scrollView.bounds.width
        )

        for (index, itemView) in self.itemViews.enumerated() {
            itemView.frame = self.frameForView(at: index)
        }
    }

    private func updateScrollViewOffset() {
        guard self.currentPageIndex >= 0 else { return }
        self.dynamicAdsView.scrollView.contentOffset = CGPoint(
            x: CGFloat(self.currentPageIndex) * self.dynamicAdsView.scrollView.bounds.width,
            y: 0
        )
    }
}

// MARK: - View

private final class DynamicAdsView: UIView {
    let scrollView: UIScrollView

    override init(frame: CGRect) {
        let scrollView = UIScrollView()
        self.scrollView = scrollView

        super.init(frame: frame)

        scrollView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.alwaysBounceHorizontal = true
        scrollView.alwaysBounceVertical = false
        scrollView.scrollsToTop = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.isPagingEnabled = true

        self.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - DynamicItem

private enum DynamicItem {
    case ad(RichieAdsSlotAdFlight)
    case color(UIColor)
}
