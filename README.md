# ZBSimpleCollectionViewLayout
简单快捷自定义UICollectionViewLayout布局

**我们继承UICollectionViewLayout可以实现很多自定义布局。**
## 介绍
ZBSimpleCollectionViewLayout也继承UICollectionViewLayout实现了三种流式布局：**普通流式布局 、一拖N布局、瀑布流布局**，三种可以`单独使用`也可以`混合使用`。
```objc
typedef NS_ENUM(NSInteger, ZBCollectionViewLayoutType) {
    /// 普通流式布局
    ZBCollectionViewLayoutNormal,
    /// 一拖N布局
    ZBCollectionViewLayoutMultiSplit,
    /// 瀑布流布局
    ZBCollectionViewLayoutFalls
};
```
>支持设置区头区尾，以及DecorationView装饰视图。

![混合使用](https://upload-images.jianshu.io/upload_images/5808981-7347b76430cb8825.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![混合使用](https://upload-images.jianshu.io/upload_images/5808981-56c245cd2e3e026b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
## 使用方法：

1.导入头文件：`#import "ZBSimpleCollectionViewLayout.h"` 

2.遵循协议：`ZBSimpleCollectionViewLayoutDelegate` 

3.设置代理并添加到UICollectionView即可
```objc
ZBSimpleCollectionViewLayout * layout = [[ZBSimpleCollectionViewLayout alloc]init];
layout.delegate = self;
UICollectionView * collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:layout];

```
4.根据需求实现相关Delegate

- 协议内容：
```objc
@protocol ZBSimpleCollectionViewLayoutDelegate <NSObject>

@required
/// 每个item的size （瀑布流布局时宽度设置无效，宽度根据布局列数自动计算）
- (CGSize)ZBSimpleCollectionViewLayoutItemSizeForIndexPath:(NSIndexPath *)indexPath;

@optional
/// 返回每区布局类型基本配置
- (ZBCollectionViewLayoutTypeConfig)ZBSimpleCollectionViewLayoutTypeAtSection:(NSInteger)section;
/// 每列的距离(item之间的距离)
- (CGFloat)ZBSimpleCollectionViewLayoutItemSpaceAtSection:(NSInteger)section;
/// 每行的距离
- (CGFloat)ZBSimpleCollectionViewLayoutLineSpaceAtSection:(NSInteger)section;
/// 区的内间距
- (UIEdgeInsets)ZBSimpleCollectionViewLayoutSectionInsetsAtSection:(NSInteger)section;

/// 区头区尾大小（size.width超过最大值时会自动设置成最大值（滚动视图的宽减滚动视图左右内间距））
- (CGSize)ZBSimpleCollectionViewLayoutHeaderSizeAtSection:(NSInteger)section;
- (CGSize)ZBSimpleCollectionViewLayoutFooterSizeAtSection:(NSInteger)section;

/// 区的装饰视图大小
- (CGSize)ZBSimpleCollectionViewLayoutDecorationViewSizeAtSection:(NSInteger)section;
/// 区的装饰视图基于本身大小的内偏移
- (UIEdgeInsets)ZBSimpleCollectionViewLayoutDecorationViewSizeInsetsAtSection:(NSInteger)section;
/// 区的装饰视图对应的注册kind（identity）
- (NSString *)ZBSimpleCollectionViewLayoutDecorationKindAtSection:(NSInteger)section;

@end

```
- 其他
```objc
@interface ZBSimpleCollectionViewLayout : UICollectionViewLayout

@property (nonatomic, weak) id <ZBSimpleCollectionViewLayoutDelegate> delegate;
/// 更新数据（在每次reloadData方法之前设置有效） 默认NO: 会重新计算全部布局；YES: 只计算最后一区增加items的布局---每次设置为YES时，计算完成后会自动设置为NO
@property (nonatomic, assign) BOOL updateData;

@end
```
>以上的`updateDta`属性是为了`collectionView reloadData`刷新页面数据 但是布局没有改变时设置为`YES`，这样不会去重新计算布局。或者只是最后一区的数据有增加，比如翻页时数据的增加，设置为`YES`时只计算新增的cell布局，其他不变。避免数据不断增加时去计算原有不变的布局

## 使用实例（瀑布流布局）
```objc
#import "FallsLayoutViewController.h"
#import "ZBSimpleCollectionViewLayout.h"

#import "TestCollectionViewCell.h"

@interface FallsLayoutViewController () <ZBSimpleCollectionViewLayoutDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView * collectionView;

@end

@implementation FallsLayoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"瀑布流布局";
    
    ZBSimpleCollectionViewLayout * layout = [[ZBSimpleCollectionViewLayout alloc]init];
    layout.delegate = self;
    
    UICollectionView * collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:layout];
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
    [self.view addSubview:collectionView];
    [collectionView registerClass:[TestCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    _collectionView = collectionView;
    
    
}


- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.collectionView.frame = self.view.bounds;
}

#pragma mark - ZBSimpleCollectionViewLayoutDelegate
- (CGSize)ZBSimpleCollectionViewLayoutItemSizeForIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(0, 180 + arc4random() % 50);
}

- (CGFloat)ZBSimpleCollectionViewLayoutItemSpaceAtSection:(NSInteger)section {
    return 10;
}

- (CGFloat)ZBSimpleCollectionViewLayoutLineSpaceAtSection:(NSInteger)section {
    return 10;
}

- (ZBCollectionViewLayoutTypeConfig)ZBSimpleCollectionViewLayoutTypeAtSection:(NSInteger)section {
    ZBCollectionViewLayoutTypeConfig config = ZBLayoutTypeConfigDefault;
    config.type = ZBCollectionViewLayoutFalls;
    config.falls = 2;
    return config;
}

#pragma mark - UICollectionViewDataSource
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TestCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.label.text = [NSString stringWithFormat:@"Section: %ld\nRow: %ld", indexPath.section, indexPath.row];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 20;
}

@end
```
![瀑布流布局](https://upload-images.jianshu.io/upload_images/5808981-e57ef6fc3cfdff7a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
