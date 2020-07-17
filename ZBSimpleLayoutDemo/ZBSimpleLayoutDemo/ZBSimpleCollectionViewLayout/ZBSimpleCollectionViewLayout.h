//
//  ZBSimpleCollectionViewLayout.h
//  YinTongStore
//
//  Created by 蓝禾 on 2019/12/2.
//  Copyright © 2019 Zombie. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ZBCollectionViewLayoutType) {
    /// 普通流式布局
    ZBCollectionViewLayoutNormal,
    /// 一拖N布局
    ZBCollectionViewLayoutMultiSplit,
    /// 瀑布流布局
    ZBCollectionViewLayoutFalls
};

struct ZBCollectionViewLayoutTypeConfig {
    ///布局样式
    ZBCollectionViewLayoutType type;
    ///瀑布流布局时的列数（默认且最小为2）
    NSInteger falls;
    ///一拖N布局时N的数量（默认且最小为2）
    NSInteger multiSplit;
    ///一拖N布局方向 默认 NO：左一 右N；YES：左N 右一
    BOOL oneAtRight;
};

typedef struct ZBCollectionViewLayoutTypeConfig ZBCollectionViewLayoutTypeConfig;

/// 创建ZBCollectionViewLayoutTypeConfig
static inline ZBCollectionViewLayoutTypeConfig ZBConfigMake(ZBCollectionViewLayoutType type, NSInteger falls, NSInteger multiSplit, BOOL oneAtRight) {
    ZBCollectionViewLayoutTypeConfig c; c.type = type; c.falls = falls; c.multiSplit = multiSplit; c.oneAtRight = oneAtRight; return c;
}
/// 初始化ZBCollectionViewLayoutTypeConfig
extern const ZBCollectionViewLayoutTypeConfig ZBLayoutTypeConfigDefault;


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

/// 区头是否悬浮顶部
- (BOOL)ZBSimpleCollectionViewLayoutHeaderPinToTopAtSection:(NSInteger)section;
/// 区头悬浮顶部的偏移量
- (CGFloat)ZBSimpleCollectionViewLayoutHeaderPinToTopOffsetAtSection:(NSInteger)section;

@end

@interface ZBSimpleCollectionViewLayout : UICollectionViewLayout

@property (nonatomic, weak) id <ZBSimpleCollectionViewLayoutDelegate> delegate;
/// 更新数据（在每次reloadData方法之前设置有效） 默认NO: 会重新计算全部布局；YES: 只计算最后一区增加items的布局---每次设置为YES时，计算完成后会自动设置为NO
@property (nonatomic, assign) BOOL updateData;

@end

NS_ASSUME_NONNULL_END
