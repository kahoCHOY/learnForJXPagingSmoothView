//
//  SmoothViewController.swift
//  JXPagingView
//
//  Created by jiaxin on 2019/11/20.
//  Copyright © 2019 jiaxin. All rights reserved.
//

import UIKit
import AVFoundation

class SmoothViewController: UIViewController {
    var headerType: Int = 0
    lazy var paging: JXPagingSmoothView = {
        return JXPagingSmoothView(dataSource: self)
    }()
    lazy var segmentedView: JXSegmentedView = {
        return JXSegmentedView()
    }()
    lazy var headerView: UIView = {
        
        guard headerType == 0 else {
            let view = UIView()
            //创建媒体资源管理对象
             let palyerItem = AVPlayerItem(url: URL(string: "http://mirror.aarnet.edu.au/pub/TED-talks/911Mothers_2010W-480p.mp4")!)
             //创建ACplayer：负责视频播放
             let player = AVPlayer.init(playerItem: palyerItem)
             player.rate = 1.0//播放速度 播放前设置
             //创建显示视频的图层
             let playerLayer = AVPlayerLayer.init(player: player)
            playerLayer.videoGravity = .resizeAspectFill
            playerLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 300)
             view.layer.addSublayer(playerLayer)
             //播放
             player.play()
            
            return view
        }
        
        let imageView = UIImageView(image: UIImage(named: "lufei.jpg"))
        imageView.isUserInteractionEnabled = true
        let button = UIButton(frame: CGRect(x: 10, y: 210, width: 200, height: 30))
        button.setTitle("按我呀 addTarget", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.addTarget(self, action: #selector(tapButton), for: .touchUpInside)
        imageView.addSubview(button)
        
        let label = UILabel(frame: CGRect(x: 10, y: 300, width: 200, height: 30))
        label.text = "按我呀 addGesture"
        label.textColor = .red
        label.font = .systemFont(ofSize: 20)
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapButton)))
        label.isUserInteractionEnabled = true
        imageView.addSubview(label)
        
        let horizontalScrollView = UIScrollView(frame: CGRect(x: 10, y: 360, width: 300, height: 30))
        horizontalScrollView.backgroundColor = .systemTeal
        horizontalScrollView.contentSize = CGSize(width: 500, height: 30)
        let horizontalLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 500, height: 30))
        horizontalLabel.text = "滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！滑动我啊！"
        horizontalLabel.textColor = .black
        horizontalLabel.font = .systemFont(ofSize: 20)
        horizontalScrollView.addSubview(horizontalLabel)
        imageView.addSubview(horizontalScrollView)
        
        return imageView
        
    }()
    
    
    @objc func tapButton() {
        print("kk=tap button")
    }
    
    
    let dataSource = JXSegmentedTitleDataSource()
    
    init(headerType: Int) {
        super.init(nibName: nil, bundle: nil)
        self.headerType = headerType
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = false
        
        view.addSubview(paging)

        dataSource.titles = ["能力", "爱好", "队友"]
        dataSource.titleSelectedColor = UIColor(red: 105/255, green: 144/255, blue: 239/255, alpha: 1)
        dataSource.titleNormalColor = UIColor.black
        dataSource.isTitleColorGradientEnabled = true
        dataSource.isTitleZoomEnabled = true

        segmentedView.backgroundColor = .white
        segmentedView.isContentScrollViewClickTransitionAnimationEnabled = false
        segmentedView.delegate = self
        segmentedView.dataSource = dataSource

        let line = JXSegmentedIndicatorLineView()
        line.indicatorColor = UIColor(red: 105/255, green: 144/255, blue: 239/255, alpha: 1)
        line.indicatorWidth = 30
        segmentedView.indicators = [line]

        headerView.clipsToBounds = true
        headerView.contentMode = .scaleAspectFill

        segmentedView.contentScrollView = paging.listCollectionView

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "reload", style: .plain, target: self, action: #selector(didNaviRightItemClick))
        paging.listCollectionView.panGestureRecognizer.require(toFail: navigationController!.interactivePopGestureRecognizer!)
    }

    @objc func didNaviRightItemClick() {
        
        dataSource.titles = ["第一", "第二", "第三"]
        dataSource.reloadData(selectedIndex: 1)
        segmentedView.defaultSelectedIndex = 1
        paging.defaultSelectedIndex = 1
        segmentedView.reloadData()
        paging.reloadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        paging.frame = view.bounds
    }
}

extension SmoothViewController: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = (index == 0)
    }
}

extension SmoothViewController: JXPagingSmoothViewDataSource {
    func heightForPagingHeader(in pagingView: JXPagingSmoothView) -> CGFloat {
        return headerType == 0 ? 500 : 300
    }

    func viewForPagingHeader(in pagingView: JXPagingSmoothView) -> UIView {
        return headerView
    }

    func heightForPinHeader(in pagingView: JXPagingSmoothView) -> CGFloat {
        return 50
    }

    func viewForPinHeader(in pagingView: JXPagingSmoothView) -> UIView {
        return segmentedView
    }

    func numberOfLists(in pagingView: JXPagingSmoothView) -> Int {
        return dataSource.titles.count
    }

    func pagingView(_ pagingView: JXPagingSmoothView, initListAtIndex index: Int) -> JXPagingSmoothViewListViewDelegate {
        let vc = SmoothListViewController()
        vc.title = dataSource.titles[index]
        return vc
    }
}
