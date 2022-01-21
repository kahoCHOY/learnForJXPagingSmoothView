//
//  SmoothListViewController.swift
//  JXPagingView
//
//  Created by jiaxin on 2019/11/20.
//  Copyright © 2019 jiaxin. All rights reserved.
//

import UIKit

@objc protocol SmoothListViewControllerDelegate {
    func startRefresh()
    func endRefresh()
}

class SmoothListViewController: UIViewController, JXPagingSmoothViewListViewDelegate, UITableViewDataSource {
    weak var delegate: SmoothListViewControllerDelegate?
    lazy var tableView: UITableView = {
        return UITableView(frame: CGRect.zero, style: .plain)
    }()
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        view.addSubview(tableView)

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableView.frame = view.bounds
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(title ?? ""):\(indexPath.row)"
        return cell
    }

    func listView() -> UIView {
        return view
    }

    func listScrollView() -> UIScrollView {
        return tableView
    }
}
