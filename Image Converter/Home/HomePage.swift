//
//  HomeTabPage.swift
//  AnimeFilters2
//
//  Created by TapUniverse Dev9 on 29/08/2023.
//

import UIKit

class HomePage: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    private let converter = HomeConverter.create()
    private lazy var pages: [() -> UIViewController] = [
        { self.converter },
        { Upscale.create() },
        { Compare.create() },
    ]
    
    private var didLoad = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        dataSource = self
        
        for view in view.subviews {
            if let view = view as? UIScrollView {
                view.isScrollEnabled = false
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(tabUpdate), name: CHome.tabUpdate, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if didLoad { return }
        didLoad = true
        
        setViewControllers([pages[0]()], direction: .forward, animated: false)
    }
    
    @objc func tabUpdate(_ noti: Notification) {
        let index = cHome.getTab().rawValue
        
        guard let currVC = viewControllers?.first,
              let currIndex = pages.firstIndex(where: { type(of: currVC) == type(of: $0()) })
        else { return }
        
        if pages.indices.contains(index) {
            setViewControllers([pages[index]()], direction: currIndex < index ? .forward : .reverse, animated: currIndex != index)
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(where: { type(of: viewController) == type(of: $0()) }) else { return pages[0]() }
        let nextIndex = (currentIndex - 1) < 0 ? -1 : (currentIndex - 1)
        
        return pages.indices.contains(nextIndex) ? pages[nextIndex]() : nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(where: { type(of: viewController) == type(of: $0()) }) else { return pages[0]() }
        let nextIndex = (currentIndex + 1) > (pages.count - 1) ? -1 : (currentIndex + 1)
        
        return pages.indices.contains(nextIndex) ? pages[nextIndex]() : nil
    }
}
