//
//  MixtureLayoutDataModel.h
//  ZBSimpleLayoutDemo
//
//  Created by Zombie on 2020/7/3.
//  Copyright © 2020 Zombie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZBSimpleCollectionViewLayout.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MixtureLayoutType) {
    MixtureLayoutTypeSection0,
    MixtureLayoutTypeSection1,
    MixtureLayoutTypeSection2,
    MixtureLayoutTypeSection3,
    MixtureLayoutTypeSection4
};

@interface MixtureLayoutDataModel : NSObject

@property (nonatomic, assign) MixtureLayoutType dataType;

@property (nonatomic, assign) ZBCollectionViewLayoutTypeConfig layoutConfig;
@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, assign) CGSize headerSize;
@property (nonatomic, assign) CGSize footerSize;
@property (nonatomic, assign) CGSize decorationSize;
@property (nonatomic, assign) CGFloat lineSpace;
@property (nonatomic, assign) CGFloat itemSpace;
@property (nonatomic, assign) UIEdgeInsets sectionInsets;
@property (nonatomic, assign) UIEdgeInsets decorationInsets;

@property (nonatomic, assign) NSInteger itemCount;
@property (nonatomic, copy) NSString * title;

@end

NS_ASSUME_NONNULL_END
