//
//  JHTaoBaoCell.m
//  CollectionViewAndTableView
//
//  Created by 家濠 on 2022/1/20.
//

#import "JHTaoBaoCell.h"

#define cellId @"cellId"

@interface JHTaoBaoCell () <UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation JHTaoBaoCell

- (void)layoutSubviews {
    self.tableView.frame = self.bounds;
    [self.contentView addSubview:self.tableView];
    [self.tableView reloadData];
}

#pragma mark - 数据源方法

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    cell.textLabel.text = [NSString stringWithFormat:@"淘宝cell---%ld",indexPath.row];
    return cell;
}

#pragma mark - 懒加载

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [UITableView new];
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellId];
    }
    return _tableView;
}

@end
