//
//  JXPagingSmoothView.swift
//  JXPagingView
//
//  Created by jiaxin on 2019/11/20.
//  Copyright © 2019 jiaxin. All rights reserved.
//

import UIKit

@objc public protocol JXPagingSmoothViewListViewDelegate {
    /// 返回listView。如果是vc包裹的就是vc.view；如果是自定义view包裹的，就是自定义view自己。
    func listView() -> UIView
    /// 返回JXPagerSmoothViewListViewDelegate内部持有的UIScrollView或UITableView或UICollectionView
    func listScrollView() -> UIScrollView
    @objc optional func listDidAppear()
    @objc optional func listDidDisappear()
}

@objc
public protocol JXPagingSmoothViewDataSource {
    /// 返回页面header的高度
    func heightForPagingHeader(in pagingView: JXPagingSmoothView) -> CGFloat
    /// 返回页面header视图
    func viewForPagingHeader(in pagingView: JXPagingSmoothView) -> UIView
    /// 返回悬浮视图的高度
    func heightForPinHeader(in pagingView: JXPagingSmoothView) -> CGFloat
    /// 返回悬浮视图
    func viewForPinHeader(in pagingView: JXPagingSmoothView) -> UIView
    /// 返回列表的数量
    func numberOfLists(in pagingView: JXPagingSmoothView) -> Int
    /// 根据index初始化一个对应列表实例，需要是遵从`JXPagingSmoothViewListViewDelegate`协议的对象。
    /// 如果列表是用自定义UIView封装的，就让自定义UIView遵从`JXPagingSmoothViewListViewDelegate`协议，该方法返回自定义UIView即可。
    /// 如果列表是用自定义UIViewController封装的，就让自定义UIViewController遵从`JXPagingSmoothViewListViewDelegate`协议，该方法返回自定义UIViewController即可。
    func pagingView(_ pagingView: JXPagingSmoothView, initListAtIndex index: Int) -> JXPagingSmoothViewListViewDelegate
}

@objc
public protocol JXPagingSmoothViewDelegate {
    @objc optional func pagingSmoothViewDidScroll(_ scrollView: UIScrollView)
}


open class JXPagingSmoothView: UIView {
    public private(set) var listDict = [Int : JXPagingSmoothViewListViewDelegate]()
    public let listCollectionView: JXPagingSmoothCollectionView
    public var defaultSelectedIndex: Int = 0
    public weak var delegate: JXPagingSmoothViewDelegate?

    weak var dataSource: JXPagingSmoothViewDataSource?
    var listHeaderDict = [Int : UIView]()
    var isSyncListContentOffsetEnabled: Bool = false
    public let pagingHeaderContainerView: UIView
    var currentPagingHeaderContainerViewY: CGFloat = 0
    var currentIndex: Int = 0
    var currentListScrollView: UIScrollView?
    var heightForPagingHeader: CGFloat = 0
    var heightForPinHeader: CGFloat = 0
    var heightForPagingHeaderContainerView: CGFloat = 0
    let cellIdentifier = "cell"
    var currentListInitializeContentOffsetY: CGFloat = 0
    var singleScrollView: UIScrollView?

    deinit {
        listDict.values.forEach {
            $0.listScrollView().removeObserver(self, forKeyPath: "contentOffset")
            $0.listScrollView().removeObserver(self, forKeyPath: "contentSize")
        }
    }

    public init(dataSource: JXPagingSmoothViewDataSource) {
        self.dataSource = dataSource
        pagingHeaderContainerView = UIView()
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        listCollectionView = JXPagingSmoothCollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        super.init(frame: CGRect.zero)

        listCollectionView.dataSource = self
        listCollectionView.delegate = self
        listCollectionView.isPagingEnabled = true
        listCollectionView.bounces = false
        listCollectionView.showsHorizontalScrollIndicator = false
        listCollectionView.scrollsToTop = false
        listCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        if #available(iOS 10.0, *) {
            listCollectionView.isPrefetchingEnabled = true
        }
        if #available(iOS 11.0, *) {
            listCollectionView.contentInsetAdjustmentBehavior = .never
        }
        listCollectionView.pagingHeaderContainerView = pagingHeaderContainerView
        addSubview(listCollectionView)
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func reloadData() {
        guard let dataSource = dataSource else { return }
        currentListScrollView = nil
        currentIndex = defaultSelectedIndex
        currentPagingHeaderContainerViewY = 0
        isSyncListContentOffsetEnabled = false

        listHeaderDict.removeAll()
        listDict.values.forEach { (list) in
            list.listScrollView().removeObserver(self, forKeyPath: "contentOffset")
            list.listScrollView().removeObserver(self, forKeyPath: "contentSize")
            list.listView().removeFromSuperview()
        }
        listDict.removeAll()

        heightForPagingHeader = dataSource.heightForPagingHeader(in: self)
        heightForPinHeader = dataSource.heightForPinHeader(in: self)
        heightForPagingHeaderContainerView = heightForPagingHeader + heightForPinHeader

        let pagingHeader = dataSource.viewForPagingHeader(in: self)
        let pinHeader = dataSource.viewForPinHeader(in: self)
        pagingHeaderContainerView.addSubview(pagingHeader)
        pagingHeaderContainerView.addSubview(pinHeader)

        pagingHeaderContainerView.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: heightForPagingHeaderContainerView)
        pagingHeader.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: heightForPagingHeader)
        pinHeader.frame = CGRect(x: 0, y: heightForPagingHeader, width: bounds.size.width, height: heightForPinHeader)
        listCollectionView.setContentOffset(CGPoint(x: listCollectionView.bounds.size.width*CGFloat(defaultSelectedIndex), y: 0), animated: false)
        listCollectionView.reloadData()

        if dataSource.numberOfLists(in: self) == 0 {
            singleScrollView = UIScrollView()
            addSubview(singleScrollView!)
            singleScrollView?.addSubview(pagingHeader)
            singleScrollView?.contentSize = CGSize(width: bounds.size.width, height: heightForPagingHeader)
        }else if singleScrollView != nil {
            singleScrollView?.removeFromSuperview()
            singleScrollView = nil
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        listCollectionView.frame = bounds
        if pagingHeaderContainerView.frame == CGRect.zero {
            reloadData()
        }
        if singleScrollView != nil {
            singleScrollView?.frame = bounds
        }
    }

// 参数scrollView其实就是接收到滑动事件的tableView，此方法的注释中这两个词同义
func listDidScroll(scrollView: UIScrollView) {
    // 判断横向collectionView是否正在被拖拽或减速，是的话就不处理tableView的纵向操作
    if listCollectionView.isDragging || listCollectionView.isDecelerating {
        return
    }
    // 去字典里面获取当前分页的下标
    let index = listIndex(for: scrollView)
    if index != currentIndex {
        return
    }
    currentListScrollView = scrollView
    // scrollView.contentOffset.y的初始值是-heightForPagingHeaderContainerView
    // 故contentOffsetY的初始值0
    // 目的是让contentOffsetY是相对于0开始的
    let contentOffsetY = scrollView.contentOffset.y + heightForPagingHeaderContainerView
    
    if contentOffsetY < heightForPagingHeader {
        // pagingHeader还在显示区域内
        isSyncListContentOffsetEnabled = true
        currentPagingHeaderContainerViewY = -contentOffsetY
        // 同步左右切换的各个tableView的offsetY，避免左右滑动出现不对齐
        for list in listDict.values {
            if list.listScrollView() != currentListScrollView {
                list.listScrollView().setContentOffset(scrollView.contentOffset, animated: false)
            }
        }
        // 这里取出的是当前分页tableView中的header
        let header = listHeader(for: scrollView)
        if pagingHeaderContainerView.superview != header {
            // 此时pinHeader还未到吸顶状态，依然需要跟随整个tableView进行纵向的滑动
            // 故把pagingHeaderContainerView放到tableView中
            pagingHeaderContainerView.frame.origin.y = 0
            header?.addSubview(pagingHeaderContainerView)
        }
    }else {
        // pagingHeader不在显示区域内（在顶部的不可见区域内）
        if pagingHeaderContainerView.superview != self {
            // 此时pinHeader到达吸顶状态，不跟随tableView进行纵向滚动
            // 故把pagingHeaderContainerView放到JXPagingSmoothView中
            // 由于pagingHeader在上方不可见区域，pinHeader吸顶在上方可见区域，结合结构图可知orgin.y=-heightForPagingHeader
            pagingHeaderContainerView.frame.origin.y = -heightForPagingHeader
            addSubview(pagingHeaderContainerView)
        }
        if isSyncListContentOffsetEnabled {
            isSyncListContentOffsetEnabled = false
            currentPagingHeaderContainerViewY = -heightForPagingHeader
            // 同步左右切换的各个tableView的offsetY，避免左右滑动出现不对齐
            for list in listDict.values {
                if list.listScrollView() != currentListScrollView {
                    list.listScrollView().setContentOffset(CGPoint(x: 0, y: -heightForPinHeader), animated: false)
                }
            }
        }
    }
}

    //MARK: - KVO

    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            if let scrollView = object as? UIScrollView {
                listDidScroll(scrollView: scrollView)
            }
        }else if keyPath == "contentSize" {
            if let scrollView = object as? UIScrollView {
                let minContentSizeHeight = bounds.size.height - heightForPinHeader
                if minContentSizeHeight > scrollView.contentSize.height {
                    scrollView.contentSize = CGSize(width: scrollView.contentSize.width, height: minContentSizeHeight)
                    //新的scrollView第一次加载的时候重置contentOffset
                    if currentListScrollView != nil, scrollView != currentListScrollView! {
                        scrollView.contentOffset = CGPoint(x: 0, y: currentListInitializeContentOffsetY)
                    }
                }
            }
        }else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

    //MARK: - Private
    func listHeader(for listScrollView: UIScrollView) -> UIView? {
        for (index, list) in listDict {
            if list.listScrollView() == listScrollView {
                return listHeaderDict[index]
            }
        }
        return nil
    }

    func listIndex(for listScrollView: UIScrollView) -> Int {
        for (index, list) in listDict {
            if list.listScrollView() == listScrollView {
                return index
            }
        }
        return 0
    }

    func listDidAppear(at index: Int) {
        guard let dataSource = dataSource else { return }
        let count = dataSource.numberOfLists(in: self)
        if count <= 0 || index >= count {
            return
        }
        listDict[index]?.listDidAppear?()
    }

    func listDidDisappear(at index: Int) {
        guard let dataSource = dataSource else { return }
        let count = dataSource.numberOfLists(in: self)
        if count <= 0 || index >= count {
            return
        }
        listDict[index]?.listDidDisappear?()
    }

    /// 列表左右切换滚动结束之后，需要把pagerHeaderContainerView添加到当前index的列表上面
    func horizontalScrollDidEnd(at index: Int) {
        currentIndex = index
        // 根据下标拿到tableView里面的header和tableView自身
        guard let listHeader = listHeaderDict[index], let listScrollView = listDict[index]?.listScrollView() else {
            return
        }
        // 把当前下标的tableView的scrollToTop设为true（点击状态栏可以回滚到最上方）
        listDict.values.forEach { $0.listScrollView().scrollsToTop = ($0.listScrollView() === listScrollView) }
        // 封面需要显示，header放回到tableView的header中
        if listScrollView.contentOffset.y <= -heightForPinHeader {
            pagingHeaderContainerView.frame.origin.y = 0
            listHeader.addSubview(pagingHeaderContainerView)
        }
    }
}

extension JXPagingSmoothView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return bounds.size
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let dataSource = dataSource else { return 0 }
        return dataSource.numberOfLists(in: self)
    }

public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let dataSource = dataSource else { return UICollectionViewCell(frame: CGRect.zero) }
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
    // 根据页面下标从字典中取出list
    // list是当前分页的vc或者vc.view，具体看myTableView是否有myVc来控制
    var list = listDict[indexPath.item]
    // 字典中不存在当前下标的list，开始创建list
    if list == nil {
        // 调用数据源方法拿到list
        list = dataSource.pagingView(self, initListAtIndex: indexPath.item)
        // 存入字典中
        listDict[indexPath.item] = list!
        // 刷新UI
        list?.listView().setNeedsLayout()
        list?.listView().layoutIfNeeded()
        // list.listScrollView() 实际上就是myTableView（看delegate的官方注释）
        // 设置tableView的基础属性
        if list?.listScrollView().isKind(of: UITableView.self) == true {
            (list?.listScrollView() as? UITableView)?.estimatedRowHeight = 0
            (list?.listScrollView() as? UITableView)?.estimatedSectionHeaderHeight = 0
            (list?.listScrollView() as? UITableView)?.estimatedSectionFooterHeight = 0
        }
        if #available(iOS 11.0, *) {
            list?.listScrollView().contentInsetAdjustmentBehavior = .never
        }
        // tableView设置的contentInset.top，这部分是空出来给放头部的
        list?.listScrollView().contentInset = UIEdgeInsets(top: heightForPagingHeaderContainerView, left: 0, bottom: 0, right: 0)
        // 当前的竖直偏移量，用于保证水平切换后的tableView竖直偏移量都一致，从而视觉上觉得仅仅是tableView在水平滑动
        currentListInitializeContentOffsetY = -heightForPagingHeaderContainerView + min(-currentPagingHeaderContainerViewY, heightForPagingHeader)
        // 设置contentOffset.top是为了把刚刚contentInset空出来的部分显示出来，是个负数
        list?.listScrollView().contentOffset = CGPoint(x: 0, y: currentListInitializeContentOffsetY)
        // listHeader是存放pagingHeaderContainerView的容器
        let listHeader = UIView(frame: CGRect(x: 0, y: -heightForPagingHeaderContainerView, width: bounds.size.width, height: heightForPagingHeaderContainerView))
        // listHeader是添加到tableView上的，这样可以让头部和cell的滑动一致
        list?.listScrollView().addSubview(listHeader)
        // 如果真正的头部pagingHeaderContainerView现在还没人认领，那就添加到当前分页里面
        if pagingHeaderContainerView.superview == nil {
            listHeader.addSubview(pagingHeaderContainerView)
        }
        // 更新头部的字典
        listHeaderDict[indexPath.item] = listHeader
        // 添加KVO，监测tableView的contentOffset和contentSize属性
        list?.listScrollView().addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
        list?.listScrollView().addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
    }
    // 字典中存在当前下标的list（不存在也在上方创建了）
    // 当前list的tableView设置scrollsToTop=true，即点击状态栏回滚到最上面
    listDict.values.forEach { $0.listScrollView().scrollsToTop = ($0 === list) }
    // list.listView() 就是vc或者vc.view（看delegate的官方注释）
    // 由于cell是复用过来的，所以首先删除一下原来cell.contentView中的子控件，然后添加list.listView()进去
    if let listView = list?.listView(), listView.superview != cell.contentView {
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        listView.frame = cell.contentView.bounds
        cell.contentView.addSubview(listView)
    }
    return cell
}

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        listDidAppear(at: indexPath.item)
    }

    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        listDidDisappear(at: indexPath.item)
    }

// 水平滚动过程中，会多次触发此方法
public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    // 回调给代理对象
    delegate?.pagingSmoothViewDidScroll?(scrollView)
    // 从0开始，小数，滚动的进度（从第一页滚到第二页，indexPercent=[0,1]）
    let indexPercent = scrollView.contentOffset.x/scrollView.bounds.size.width
    // 从0开始，整数，滚动的进度（从第一页滚到第二页，indexPercent=0变成1）
    let index = Int(scrollView.contentOffset.x/scrollView.bounds.size.width)
    // listScrollView本质就是myTableView
    let listScrollView = listDict[index]?.listScrollView()
    // indexPercent - CGFloat(index) == 0
    // ### 保证滚动结束
    // index != currentIndex
    // ### 保证滚动到新的分页，而不是滚动后又回到滚动前的分页
    // !(scrollView.isDragging || scrollView.isDecelerating)
    // ### 非带进去，就是(!isDragging && !isDecelerating)，保证滚动结束
    // listScrollView?.contentOffset.y ?? 0 <= -heightForPinHeader
    // ### 结合层次结构图，根据contentOffset.y 确定pagingHeaderContainerView的父控件
    if (indexPercent - CGFloat(index) == 0) && index != currentIndex && !(scrollView.isDragging || scrollView.isDecelerating) && listScrollView?.contentOffset.y ?? 0 <= -heightForPinHeader {
        // 左右滚动结束了，调用下面的方法，主要逻辑是把pagingHeaderContainerView添加到当前index的列表上面
        horizontalScrollDidEnd(at: index)
    }else {
        // 避免已经把pagingHeaderContainerView添加到self了，还继续添加
        if pagingHeaderContainerView.superview != self {
            //左右滚动进行时，把listHeaderContainerView添加到self，达到悬浮在顶部的效果
            pagingHeaderContainerView.frame.origin.y = currentPagingHeaderContainerViewY
            addSubview(pagingHeaderContainerView)
        }
    }
    // 记录一下currentIndex
    if index != currentIndex {
        currentIndex = index
    }
}

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            let index = Int(scrollView.contentOffset.x/scrollView.bounds.size.width)
            horizontalScrollDidEnd(at: index)
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x/scrollView.bounds.size.width)
        horizontalScrollDidEnd(at: index)
    }
}

public class JXPagingSmoothCollectionView: UICollectionView, UIGestureRecognizerDelegate {
    var pagingHeaderContainerView: UIView?
    // 确定collectionView是否响应当前手势
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let point = touch.location(in: pagingHeaderContainerView)
        // 如果手势发生在头部，则不响应手势，避免头部触发左右滑动
        if pagingHeaderContainerView?.bounds.contains(point) == true {
            return false
        }
        // 触发左右滑动
        return true
    }
}
