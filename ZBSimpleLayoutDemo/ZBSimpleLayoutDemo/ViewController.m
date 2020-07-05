//
//  ViewController.m
//  ZBSimpleLayoutDemo
//
//  Created by Zombie on 2020/6/29.
//  Copyright © 2020 Zombie. All rights reserved.
//

#import "ViewController.h"

#import "NormalLayoutViewController.h"
#import "MultiSplitLayoutViewController.h"
#import "FallsLayoutViewController.h"
#import "MixtureLayoutViewController.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
{
    NSArray * _titles;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _titles = @[@"普通布局", @"一拖N布局", @"瀑布流布局", @"混合布局(以上三种布局可以混合用)"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
        {
            [self.navigationController pushViewController:[NormalLayoutViewController new] animated:YES];
        }
            break;
        case 1:
        {
            [self.navigationController pushViewController:[MultiSplitLayoutViewController new] animated:YES];
        }
            break;
        case 2:
        {
            [self.navigationController pushViewController:[FallsLayoutViewController new] animated:YES];
        }
            break;
        case 3:
        {
            [self.navigationController pushViewController:[MixtureLayoutViewController new] animated:YES];
        }
            break;
            
        default:
            break;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = _titles[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _titles.count;
}

@end
