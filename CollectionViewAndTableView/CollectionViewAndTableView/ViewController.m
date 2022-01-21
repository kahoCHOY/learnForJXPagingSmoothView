//
//  ViewController.m
//  CollectionViewAndTableView
//
//  Created by 家濠 on 2022/1/20.
//

#import "ViewController.h"
#import "JHTaoBaoCell.h"
#import "JHJingDongCell.h"
#import "JHPinDuoDuoCell.h"

#define TaoBaoId @"TaoBaoId"
#define JingdongId @"JingdongId"
#define PinDuoDuoId @"PinDuoDuoId"

@interface ViewController () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    self.title = @"左右滑动我";
    
    self.collectionView.frame = self.view.bounds;
    [self.view addSubview:self.collectionView];
    
    [self.collectionView reloadData];
    
}

#pragma mark - 数据源方法

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 3;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.item) {
        case 0: {
            JHTaoBaoCell *taoBaoCell = [collectionView dequeueReusableCellWithReuseIdentifier:TaoBaoId forIndexPath:indexPath];
            return taoBaoCell;
        }
            break;
        case 1: {
            JHJingDongCell *jingdongCell = [collectionView dequeueReusableCellWithReuseIdentifier:JingdongId forIndexPath:indexPath];
            return jingdongCell;
        }
            break;
        default:{
            JHPinDuoDuoCell *pinDuoDuoCell = [collectionView dequeueReusableCellWithReuseIdentifier:PinDuoDuoId forIndexPath:indexPath];
            return pinDuoDuoCell;
        }
    }
    
}

#pragma mark - 代理方法

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.bounds.size;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"将要显示的页面是%@",cell);
}

#pragma mark - 懒加载

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        // self就是ViewController
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = UIColor.whiteColor;
        // 没有弹性效果，改成YES就会有弹性效果，自己改试一下
        _collectionView.bounces = NO;
        // 翻页功能，自己改NO对比一下
        _collectionView.pagingEnabled = YES;
        // 点击刘海滚动最上面
        _collectionView.scrollsToTop = NO;
        // 预加载，NO的话，当前仅当你翻页的时候再调用cellFor...方法，YES的话提前几页就给你调了
        _collectionView.prefetchingEnabled = NO;
        // 自动调整内间距，百度一下
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        // 注册一下cell，等下拿着id去dequeue，这样就不用自己alloc init了
        [_collectionView registerClass:[JHTaoBaoCell class] forCellWithReuseIdentifier:TaoBaoId];
        [_collectionView registerClass:[JHJingDongCell class] forCellWithReuseIdentifier:JingdongId];
        [_collectionView registerClass:[JHPinDuoDuoCell class] forCellWithReuseIdentifier:PinDuoDuoId];
    }
    return _collectionView;
}


@end
