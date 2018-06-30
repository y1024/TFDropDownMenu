//
//  ViewController.m
//  TFDropDownMenu
//
//  Created by jiangyunfeng on 2018/6/20.
//  Copyright © 2018年 jiangyunfeng. All rights reserved.
//

#import "ViewController.h"
#import "TFDropDownMenuView.h"

@interface ViewController ()<TFDropDownMenuViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *array1 = [NSMutableArray arrayWithObjects:@"热门推荐", @"美食", @"影院", @"自助餐", @"景区", @"汽车", @"网吧", @"游戏", nil];
    NSMutableArray *array2 = [NSMutableArray arrayWithObjects:@"面积最大", @"面积最小", @"价格最高", @"价格最低", nil];
    NSMutableArray *array3 = [NSMutableArray arrayWithObjects:@"从大到小", @"从小到大", @"从高到低", @"从低到高", @"从右到左", @"从左到右", @"从前到后", @"从后到前", nil];
    NSArray *array11 = @[
                   @[@"好玩的", @"好吃的", @"好景的", @"好喝的", @"好唱的"],
                   @[@"美食城1",@"美食城2", @"美食城3", @"美食城5", @"美食城10"],
                   @[@"金逸影院", @"万达影院", @"兄弟影院", @"新影联影院", @"保利影院", @"大地影院"],
                   @[@"韩式烤肉", @"日式自助", @"海底捞", @"湘十二楼", @"金百万"],
                   @[@"长城", @"故宫", @"天安门", @"明十三陵", @"颐和园", @"圆明园"],
                   @[@"玛莎拉蒂", @"法拉利", @"奔驰", @"宝马", @"奥迪"],
                   @[@"休闲网咖", @"学子网吧"],
                   @[@"英雄联盟", @"王者荣耀", @"大吉大利", @"大话西游", @"传奇"]
                   ];
    
    NSMutableArray *data1 = [NSMutableArray arrayWithObjects:array1, array2, array3, nil];
    NSMutableArray *data2 = [NSMutableArray arrayWithObjects:array11, @[], @[], nil];
    TFDropDownMenuView *menu = [[TFDropDownMenuView alloc] initWithFrame:CGRectMake(0, 50, UIScreen.mainScreen.bounds.size.width, 40) firstArray:data1 secondArray:data2];
    menu.delegate = self;
    [self.view addSubview:menu];
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)menuView:(TFDropDownMenuView *)menu selectIndex:(TFIndexPatch *)index {
    NSLog(@"index: %@", index);
}

- (void)menuView:(TFDropDownMenuView *)menu tfColumn:(NSInteger)column {
    NSLog(@"column: %ld", column);
}

@end
