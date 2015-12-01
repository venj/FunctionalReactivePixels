//
//  FRPGallaryFlowLayout.m
//  FunctionalReactivePixels
//
//  Created by 朱文杰 on 15/11/30.
//  Copyright © 2015年 朱文杰. All rights reserved.
//

#import "FRPGallaryFlowLayout.h"

@implementation FRPGallaryFlowLayout

- (instancetype) init {
    if (!(self = [super init])) {
        return nil;
    }
    self.itemSize = CGSizeMake(145, 145);
    self.minimumInteritemSpacing = 10;
    self.minimumLineSpacing = 10;
    self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    return self;
}

@end
