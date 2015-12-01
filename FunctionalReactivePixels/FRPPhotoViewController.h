//
//  FRPPhotoViewController.h
//  FunctionalReactivePixels
//
//  Created by 朱文杰 on 15/12/1.
//  Copyright © 2015年 朱文杰. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FRPPhotoModel;
@interface FRPPhotoViewController : UIViewController
@property (nonatomic, readonly) NSInteger photoIndex;
@property (nonatomic, readonly) FRPPhotoModel *photoModel;
- (instancetype)initWithPhotoModel:(FRPPhotoModel *)photoModel index:(NSInteger)index;
@end
