//
//  TFDropDownMenuView.m
//  TFDropDownMenu
//
//  Created by jiangyunfeng on 2018/6/20.
//  Copyright © 2018年 jiangyunfeng. All rights reserved.
//

#import "TFDropDownMenuView.h"
#import "Masonry.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define STATUSBAR_HEIGHT ([[UIApplication sharedApplication] statusBarFrame].size.height)
#define NAVBAR_HEIGHT (STATUSBAR_HEIGHT+44)
#define SCREEN_SCALE [UIScreen mainScreen].scale

@interface TFDropDownMenuView()

//MARK: 数据源
/**一级菜单title数组*/
@property (strong, nonatomic) NSMutableArray *firstArray;
/**二级菜单title数组*/
@property (strong, nonatomic) NSMutableArray *secondArray;

@property (assign, nonatomic) NSInteger numberOfColumn;//列数
@property (assign, nonatomic) BOOL isShow;
@property (assign, nonatomic) NSInteger currentSelectColumn;//记录最近选中column
@property (assign, nonatomic) NSInteger lastSelectSection;//记录上一次的section选择，用于回显

@property (strong, nonatomic) NSMutableArray *currentSelectSections;//记录最近选中的sections
@property (strong, nonatomic) NSMutableArray *currentBgLayers;//菜单背景layers
@property (strong, nonatomic) NSMutableArray *currentTitleLayers;//菜单titlelayers
@property (strong, nonatomic) NSMutableArray *currentSeparatorLayers;//菜单分隔竖线separatorlayers
@property (strong, nonatomic) NSMutableArray *currentIndicatorLayers;//菜单箭头layers


@property (strong, nonatomic) UIView *backgroundView;//整体背景
@property (strong, nonatomic) UIView *bottomLineView;//菜单底部横线

@property (strong, nonatomic) UITableView *leftTableView;//
@property (strong, nonatomic) UICollectionView *leftCollectionView;//
@property (strong, nonatomic) UITableView *rightTableView;//
@property (strong, nonatomic) UICollectionView *rightCollectionView;//


@end

@implementation TFDropDownMenuView

/**
 菜单初始化方法
 
 @param frame frame
 @param firstArray 一级菜单
 @param secondArray 二级菜单
 @return 实例对象
 */
- (instancetype)initWithFrame:(CGRect)frame firstArray:(NSMutableArray *)firstArray secondArray:(NSMutableArray *)secondArray {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self initAttributes];
        self.firstArray = [NSMutableArray arrayWithArray:firstArray];
        self.secondArray = [NSMutableArray arrayWithArray:secondArray];
        [self addAllSubView];
        [self addAction];
    }
    
    return self;
}

- (void)initAttributes {
    _menuBackgroundColor = [UIColor whiteColor];
    _itemTextSelectColor = [UIColor colorWithRed:246.0/255.0 green:79.0/255.0 blue:0.0/255.0 alpha:1.0];
    _itemTextUnSelectColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    _cellTextSelectColor = [UIColor colorWithRed:246.0/255.0 green:79.0/255.0 blue:0.0/255.0 alpha:1.0];
    _cellTextUnSelectColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    _separatorColor = [UIColor colorWithRed:219.0/255.0 green:219.0/255.0 blue:219.0/255.0 alpha:1.0];
    _cellSelectBackgroundColor = [UIColor whiteColor];
    _cellUnselectBackgroundColor = [UIColor whiteColor];
    
    _itemFontSize = 14.0;
    _cellTitleFontSize = 14.0;
    _cellDetailTitleFontSize = 11.0;
    _tableViewHeight = 300.0;
    _cellHeight = 44;
    _ratioLeftToScreen = 0.5;
    _kAnimationDuration = 0.25;
    _textAlignment = TFDropDownTextAlignmentLeft;
    _numberOfColumn = _firstArray.count;
    
    
}

- (void)addAllSubView {
    CGFloat backgroundLayerWidth = self.frame.size.width / _numberOfColumn;
    
    [_currentBgLayers removeAllObjects];
    [_currentTitleLayers removeAllObjects];
    [_currentSeparatorLayers removeAllObjects];
    [_currentIndicatorLayers removeAllObjects];
    
    _currentSelectSections = [NSMutableArray array];
    for (NSInteger i = 0; i < _numberOfColumn; i++) {
        [_currentSelectSections addObject:[NSNumber numberWithInteger:0]];
        
        // backgroundLayer
        CGPoint backgroundLayerPosition = CGPointMake((i + 0.5) * backgroundLayerWidth, self.bounds.size.height * 0.5);
        CALayer *backgroundLayer = [self creatBackgroundLayer:backgroundLayerPosition backgroundColor:_menuBackgroundColor];
        
        [self.layer addSublayer:backgroundLayer];
        [_currentBgLayers addObject:backgroundLayer];
        
        // titleLayer
        NSString *titleStr = [self titleOfMenu:i];
        
        CGPoint titleLayerPosition = CGPointMake((i + 0.5) * backgroundLayerWidth, self.bounds.size.height * 0.5);
        CATextLayer *titleLayer = [self creatTitleLayer:titleStr position:titleLayerPosition textColor:_itemTextUnSelectColor];
        [self.layer addSublayer:titleLayer];
        [_currentTitleLayers addObject:titleLayer];
        
        // indicatorLayer
        CGSize textSize = [self calculateStringSize:titleStr];// calculateStringSize(titleStr)
        CGPoint indicatorLayerPosition = CGPointMake(titleLayerPosition.x + (textSize.width / 2) + 10, self.bounds.size.height * 0.5 + 2);
        
        CAShapeLayer *indicatorLayer = [self creatIndicatorLayer:indicatorLayerPosition color:_itemTextUnSelectColor];
        [self.layer addSublayer:indicatorLayer];
        [_currentIndicatorLayers addObject:indicatorLayer];
        
        // separatorLayer
        if (i != _numberOfColumn - 1) {
            CGPoint separatorLayerPosition = CGPointMake(ceil((i + 1) * backgroundLayerWidth) - 1, self.bounds.size.height * 0.5);
            
            CAShapeLayer *separatorLayer = [self creatSeparatorLayer:separatorLayerPosition color:_separatorColor];
            [self.layer addSublayer:separatorLayer];
            [_currentSeparatorLayers addObject:separatorLayer];
        }
    }
    [self addSubview:self.bottomLineView];
}

//MARK: 各种子视图加载
- (UIView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-(1.0/SCREEN_SCALE), self.frame.size.width, (1.0/SCREEN_SCALE))];
        _bottomLineView.backgroundColor = _separatorColor;
    }
    return _bottomLineView;
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        [_backgroundView setOpaque:NO];
        [_backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backTapped:)]];
    }
    return _backgroundView;
}

- (UITableView *)leftTableView {
    if (!_leftTableView) {
        _leftTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width * _ratioLeftToScreen, 0)];
        _leftTableView.dataSource = self;
        _leftTableView.delegate = self;
        _leftTableView.rowHeight = _cellHeight;
        _leftTableView.backgroundColor = [UIColor colorWithWhite:0.99 alpha:1];
        _leftTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _leftTableView.separatorColor = _separatorColor;
    }
    return _leftTableView;
}

- (UITableView *)rightTableView {
    if (!_rightTableView) {
        _rightTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.frame.origin.x + self.bounds.size.width * _ratioLeftToScreen, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width * (1 - _ratioLeftToScreen), 0)];
        _rightTableView.dataSource = self;
        _rightTableView.delegate = self;
        _rightTableView.rowHeight = _cellHeight;
        _rightTableView.backgroundColor = [UIColor colorWithWhite:0.99 alpha:1];
        _rightTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _rightTableView.separatorColor = _separatorColor;
    }
    return _rightTableView;
}


/// 背景layer
- (CALayer *)creatBackgroundLayer:(CGPoint)position backgroundColor:(UIColor *)backgroundColor {
    CALayer *layer = [[CALayer alloc] init];
    layer.position = position;
    layer.backgroundColor = [_menuBackgroundColor CGColor];
    layer.bounds = CGRectMake(0, 0, self.bounds.size.width/_numberOfColumn, self.bounds.size.height - 1);
    return layer;
}
/// 标题Layer
- (CATextLayer *)creatTitleLayer:(NSString *)text position:(CGPoint)position textColor:(UIColor *)textColor {
    // size
    CGSize textSize = [self calculateStringSize:text];
    CGFloat maxWidth = self.bounds.size.width / _numberOfColumn - 25;
    CGFloat textLayerWidth = textSize.width < maxWidth ? textSize.width : maxWidth;
    
    //textLayer
    CATextLayer *textLayer = [[CATextLayer alloc] init];
    textLayer.bounds = CGRectMake(0, 0, textLayerWidth, textSize.height);
    textLayer.fontSize = _itemFontSize;
    textLayer.string = text;
    textLayer.alignmentMode = kCAAlignmentCenter;
    textLayer.truncationMode = kCATruncationEnd;
    textLayer.foregroundColor = [textColor CGColor];
    textLayer.contentsScale = SCREEN_SCALE;
    textLayer.position = position;
    return textLayer;
}
///箭头指示符indicatorLayer
- (CAShapeLayer *)creatIndicatorLayer:(CGPoint)position color:(UIColor *)color {
    // path
    UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
    [bezierPath moveToPoint:CGPointMake(0, 0)];
    [bezierPath addLineToPoint:CGPointMake(5, 5)];
    [bezierPath moveToPoint:CGPointMake(5, 5)];
    [bezierPath addLineToPoint:CGPointMake(10, 0)];
    [bezierPath closePath];

    // shapeLayer
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.path = bezierPath.CGPath;
    shapeLayer.lineWidth = 0.8;
    shapeLayer.strokeColor = [color CGColor];
    shapeLayer.bounds = CGPathGetBoundingBox(shapeLayer.path);
    shapeLayer.position = position;
    return shapeLayer;
}
///竖分隔线separatorLayer
- (CAShapeLayer *)creatSeparatorLayer:(CGPoint)position color:(UIColor *)color {
    // path
    UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
    [bezierPath moveToPoint:CGPointMake(0, 0)];
    [bezierPath addLineToPoint:CGPointMake(5, self.bounds.size.height - 16)];
    [bezierPath closePath];

    // separatorLayer
    CAShapeLayer *separatorLayer = [[CAShapeLayer alloc] init];
    separatorLayer.path = bezierPath.CGPath;
    separatorLayer.lineWidth = 1;
    separatorLayer.strokeColor = [color CGColor];
    separatorLayer.bounds = CGPathGetBoundingBox(separatorLayer.path);
    separatorLayer.position = position;
    return separatorLayer;
}

- (CGSize)calculateStringSize: (NSString *)string {
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:_itemFontSize]};
    NSStringDrawingOptions option = NSStringDrawingUsesLineFragmentOrigin;
    CGSize size = [string boundingRectWithSize:CGSizeMake(280, 0) options:option attributes:attributes context:nil].size;
    return CGSizeMake(ceil(size.width)+2, size.height);
}

//MARK: 数据
/**菜单title*/
- (NSString *)titleOfMenu:(NSInteger)column {
    if (column < _firstArray.count && column < _secondArray.count) {
        NSArray *aArray = [NSArray arrayWithArray:_secondArray[column]];
        if (aArray.count > 0) { //有二级目录
            NSArray *strArray = [NSArray arrayWithArray:aArray.firstObject];
            if (strArray.count > 0) {
                return [NSString stringWithFormat:@"%@", strArray.firstObject];
            }
        } else { //没有二级目录
            NSArray *strArray = [NSArray arrayWithArray:_firstArray[column]];
            if (strArray.count > 0) {
                return [NSString stringWithFormat:@"%@", strArray.firstObject];
            }
        }
    }
    return @"";
}

/**一级目录数*/
- (NSInteger)numberOfSectionsInColumn:(NSInteger)column {
    if (column < _firstArray.count) {
        NSArray *aAarray = [NSArray arrayWithArray:_firstArray[column]];
        return aAarray.count;
    }
    return 0;
}

/**二级目录数*/
- (NSInteger)numberOfRowsInColumn:(NSInteger)column section:(NSInteger)section {
    if (column < _secondArray.count) {
        NSArray *rowArray = [NSArray arrayWithArray:_secondArray[column]];
        if (section < rowArray.count) {
            NSArray *aAarray = [NSArray arrayWithArray:rowArray[section]];
            return aAarray.count;
        }
    }
    return 0;
}

/**一级目录名字*/
- (NSString *)titleForColumn:(NSInteger)column section:(NSInteger)section {
    if (column < _firstArray.count) {
        NSArray *strArray = [NSArray arrayWithArray:_firstArray[column]];
        if (section < strArray.count) {
            return [NSString stringWithFormat:@"%@", strArray[section]];
        }
    }
    return @"";
}

/**二级目录名字*/
- (NSString *)titleForColumn:(NSInteger)column section:(NSInteger)section row:(NSInteger)row {
    if (column < _secondArray.count) {
        NSArray *aArray = [NSArray arrayWithArray:_secondArray[column]];
        if (row < aArray.count) { //有二级目录
            NSArray *strArray = [NSArray arrayWithArray:aArray[section]];
            if (row < strArray.count) {
                return [NSString stringWithFormat:@"%@", strArray[row]];
            }
        }
    }
    return @"";
}

/**一级目录图片*/
- (NSString *)imageNameForColumn:(NSInteger)column section:(NSInteger)section {
    if (column < _firstImageArray.count) {
        NSArray *imgArray = [NSArray arrayWithArray:_firstImageArray[column]];
        if (section < imgArray.count) {
            return [NSString stringWithFormat:@"%@", imgArray[section]];
        }
    }
    return nil;
}

/**二级目录图片*/
- (NSString *)imageNameForColumn:(NSInteger)column section:(NSInteger)section row:(NSInteger)row {
    if (column < _secondImageArray.count) {
        NSArray *aArray = [NSArray arrayWithArray:_secondImageArray[column]];
        if (section < aArray.count) { //有二级目录
            NSArray *imgArray = [NSArray arrayWithArray:aArray[section]];
            if (row < imgArray.count ){
                return [NSString stringWithFormat:@"%@", imgArray[row]];
            }
        }
    }
    return nil;
}

/**一级目录detail*/
-(NSString *) detailTextForColumn:(NSInteger)column section:(NSInteger)section {
    if (column < _firstRightArray.count) {
        NSArray *strArray = [NSArray arrayWithArray:_firstRightArray[column]];
        if (section < strArray.count) {
            return [NSString stringWithFormat:@"%@", strArray[section]];
        }
    }
    return @"";
}

/**二级目录detail*/
- (NSString *)detailTextForColumn:(NSInteger)column section:(NSInteger)section row:(NSInteger)row {
    if (column < _secondRightArray.count) {
        NSArray *aArray = [NSArray arrayWithArray:_secondRightArray[column]];
        if (row < aArray.count) { //有二级目录
            NSArray *strArray = [NSArray arrayWithArray:aArray[section]];
            if (row < strArray.count) {
                return [NSString stringWithFormat:@"%@", strArray[row]];
            }
        }
    }
    return @"";
}

//MARK: 事件Action
/**菜单添加事件*/
- (void)addAction {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuTapped:)];
    [self addGestureRecognizer:tap];
}
/**菜单点击响应*/
- (void)menuTapped:(UITapGestureRecognizer *)sender {
    if (_delegate) {
        CGPoint tapPoint = [sender locationInView:self];
        NSInteger tapIndex = tapPoint.x / (self.frame.size.width / _numberOfColumn);
        for (NSInteger i = 0; i < self.numberOfColumn; i++) {
            if (i != tapIndex) {
                [self animateForIndicator:_currentIndicatorLayers[i] show:NO complete:^{
                    [self animateForTitleLayer:self.currentTitleLayers[i] indicator:nil show:NO complete:^{
                    }];
                }];
            }
        }
        // 收回或弹出当前的menu
        if (_currentSelectColumn == tapIndex && _isShow) {// 收回menu
            [self animateForIndicator:_currentIndicatorLayers[tapIndex] titlelayer:_currentTitleLayers[tapIndex] show:NO complete:^{
                self.currentSelectColumn = tapIndex;
                self.isShow = false;
            }];
            _currentSelectSections[_currentSelectColumn] = [NSNumber numberWithInteger:_lastSelectSection];
        } else {// 弹出menu
            if ([self.delegate respondsToSelector:@selector(menuView:tfColumn:)]) {
                [self.delegate menuView:self tfColumn:tapIndex];
            }
            _currentSelectColumn = tapIndex;
            _lastSelectSection = [NSString stringWithFormat:@"%@", _currentSelectSections[_currentSelectColumn]].integerValue;
            // 载入数据
            [_leftTableView reloadData];
            if ([self numberOfRowsInColumn:_currentSelectColumn section:_lastSelectSection]) {
                [_rightTableView reloadData];
            }
            [self animateForIndicator:_currentIndicatorLayers[tapIndex] titlelayer:_currentTitleLayers[tapIndex] show:YES complete:^{
                self.isShow = YES;
            }];
        }
    }
    
}

/**背景点击*/
- (void)backTapped:(UITapGestureRecognizer *)sender {
    [self animateForIndicator:_currentIndicatorLayers[_currentSelectColumn] titlelayer:_currentTitleLayers[_currentSelectColumn] show:NO complete:^{
        self.isShow = NO;
    }];
}

/**使用代码选中列表中选项*/
- (void)selectedAtIndex:(TFIndexPatch *)indexPath {
    // 判断传入Index是否合法
    
    if (indexPath.column >= 0 && indexPath.section >= 0 && indexPath.column < _firstArray.count && indexPath.section < [self numberOfSectionsInColumn:indexPath.column]) {
    } else {
        NSLog(@"传入的indexPath不合法");
    }
    if (indexPath.row < [self numberOfRowsInColumn:indexPath.column section:indexPath.section] && indexPath.row >= 0) {
    } else {
        NSLog(@"传入的indexPath不合法");
    }
    // 选择
    CATextLayer *titleLayer = _currentTitleLayers[indexPath.column];
    _currentSelectColumn = indexPath.column;
    _currentSelectSections[indexPath.column] = [NSNumber numberWithInteger:indexPath.section];
    if (indexPath.hasRow) {
        titleLayer.string = [self titleForColumn:indexPath.column section:indexPath.section];
        [self animateForTitleLayer:titleLayer indicator: _currentIndicatorLayers[_currentSelectColumn] show: _isShow complete:^{
        }];
    }else {
        titleLayer.string = [self titleForColumn:indexPath.column section:indexPath.section row:indexPath.row];
        [self animateForTitleLayer:titleLayer indicator: _currentIndicatorLayers[_currentSelectColumn] show: _isShow complete:^{
        }];
    }
    if ([self.delegate respondsToSelector:@selector(menuView:selectIndex:)]) {
        [self.delegate menuView:self selectIndex:indexPath];
    }
}
/// 默认选中
- (void)selectDeafult {
    for (NSInteger i = 0; i < _firstArray.count; i++) {
        if ([self numberOfRowsInColumn:i section:0] > 0) {
            TFIndexPatch *index = [[TFIndexPatch alloc] initWithColumn:i section:0 row:0];
            [self selectedAtIndex:index];
         } else {
             TFIndexPatch *index = [[TFIndexPatch alloc] initWithColumn:i section:0 row:-1];
             [self selectedAtIndex:index];
         }
    }
}



//MARK: 动画
/**动画串联*/
- (void)animateForIndicator:(CAShapeLayer *)indicator titlelayer:(CATextLayer *)titlelayer show:(BOOL)show complete:(void(^)(void))complete {
    [self animateForIndicator:indicator show:show complete:^{
        [self animateForTitleLayer:titlelayer indicator:indicator show:show complete:^{
            [self animateForBackgroundView:show complete:^{
                [self animateTableViewWithShow:show complete:^{
                }];
            }];
        }];
    }];
    if (complete) {
        complete();
    }
}

/**箭头指示符动画*/
- (void)animateForIndicator:(CAShapeLayer *)indicator show:(BOOL)show complete:(void(^)(void))complete {
    if (show) {
        indicator.transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
        indicator.strokeColor = [_itemTextSelectColor CGColor];
    }else {
        indicator.transform = CATransform3DIdentity;
        indicator.strokeColor = [_itemTextUnSelectColor CGColor];
    }
    if (complete) {
        complete();
    }
}

/**backgroundView动画*/
- (void)animateForBackgroundView:(BOOL)show complete:(void(^)(void))complete {
    
    if (show) {
        [self.superview addSubview:_backgroundView];
        [self.superview addSubview:self];
        [UIView animateWithDuration:_kAnimationDuration animations:^{
            self.backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        }];
    } else {
        _currentSelectSections[_currentSelectColumn] = [NSNumber numberWithInteger:_lastSelectSection];
        [UIView animateWithDuration:_kAnimationDuration animations:^{
            self.backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        } completion:^(BOOL finished) {
            [self.backgroundView removeFromSuperview];
        }];
    }
    if (complete) {
        complete();
    }
}

/**tableView动画*/
- (void)animateTableViewWithShow:(BOOL)show complete:(void(^)(void))complete {
    
    BOOL haveItems = NO;
    NSInteger numberOfSection = [self numberOfSectionsInColumn:_currentSelectColumn];
    for (NSInteger i = 0; i < numberOfSection; i++) {
        if ([self numberOfRowsInColumn:_currentSelectColumn section:i] > 0) {
            haveItems = YES;
            break;
        }
    }
    CGFloat tempHeight = numberOfSection * _cellHeight;
    CGFloat heightForTableView = (tempHeight > _tableViewHeight) ? _tableViewHeight : tempHeight;
    
    if (show) {
        if (haveItems) {
            _leftTableView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width * _ratioLeftToScreen, 0);
            _rightTableView.frame = CGRectMake(self.frame.origin.x + self.bounds.size.width * _ratioLeftToScreen, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width * (1 - _ratioLeftToScreen), 0);
            [self.superview addSubview:_leftTableView];
            [self.superview addSubview:_rightTableView];
            [UIView animateWithDuration:_kAnimationDuration animations:^{
                self.leftTableView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width * self.ratioLeftToScreen, heightForTableView);
                self.rightTableView.frame = CGRectMake(self.frame.origin.x + self.bounds.size.width * self.ratioLeftToScreen, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width * (1 - self.ratioLeftToScreen), heightForTableView);
            }];
        } else {
            [_rightTableView removeFromSuperview];
            _leftTableView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width, 0);
            [self.superview addSubview:_leftTableView];
            [UIView animateWithDuration:_kAnimationDuration animations:^{
                self.leftTableView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width, heightForTableView);
            }];
        }
    } else {
        if (haveItems) {
            [UIView animateWithDuration:_kAnimationDuration animations:^{
                self.leftTableView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width * self.ratioLeftToScreen, 0);
                self.rightTableView.frame = CGRectMake(self.frame.origin.x + self.bounds.size.width * self.ratioLeftToScreen, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width * (1 - self.ratioLeftToScreen), 0);
            } completion:^(BOOL finished) {
                [self.leftTableView removeFromSuperview];
                [self.rightTableView removeFromSuperview];
            }];
        } else {
            [UIView animateWithDuration:_kAnimationDuration animations:^{
                self.leftTableView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.bounds.size.height, self.bounds.size.width, 0);
            } completion:^(BOOL finished) {
                [self.leftTableView removeFromSuperview];
            }];
        }
        
    }
    if (complete) {
        complete();
    }
}

/**titleLayer动画*/
- (void)animateForTitleLayer:(CATextLayer *)textLayer indicator:(CAShapeLayer *)indicator show:(BOOL)show complete:(void(^)(void))complete {
    
    CGSize textSize = [self calculateStringSize:[NSString stringWithFormat:@"%@", textLayer.string]];
    
    CGFloat maxWidth = self.bounds.size.width / _numberOfColumn - 25;
    CGFloat textLayerWidth = (textSize.width < maxWidth) ? textSize.width : maxWidth;
    CGFloat textLayerHeight = textSize.height;
    textLayer.bounds = CGRectMake(0, 0, textLayerWidth, textLayerHeight);
    if (indicator) {
        indicator.position = CGPointMake(textLayer.position.x + textLayerWidth / 2 + 10, indicator.position.y) ;
    }
    if (show) {
        textLayer.foregroundColor = [_itemTextSelectColor CGColor];
    }else {
        textLayer.foregroundColor = [_itemTextUnSelectColor CGColor];
    }
    if (complete) {
        complete();
    }
}

@end