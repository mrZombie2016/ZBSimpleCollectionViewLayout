//
//  MixtureLayoutDataManager.h
//  ZBSimpleLayoutDemo
//
//  Created by Zombie on 2020/7/3.
//  Copyright © 2020 Zombie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MixtureLayoutDataModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MixtureLayoutDataManager : NSObject

@property (nonatomic, strong) NSArray <MixtureLayoutDataModel *>* layoutData;

- (void)createLayoutData;

@end

NS_ASSUME_NONNULL_END
