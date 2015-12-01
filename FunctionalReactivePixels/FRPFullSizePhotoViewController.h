//
//  FRPFullSizePhotoViewController.h
//  FunctionalReactivePixels
//
//  Created by 朱文杰 on 15/12/1.
//  Copyright © 2015年 朱文杰. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FRPFullSizePhotoViewController;
@protocol FRPFillSizePhotoViewControllerDelegate <NSObject>

- (void)userDidScroll:(FRPFullSizePhotoViewController *)viewController toPhotoAtIndex:(NSInteger)index;

@end

@class FRPPhotoModel;
@interface FRPFullSizePhotoViewController : UIViewController
@property (nonatomic, readonly) NSArray<FRPPhotoModel *> *photoModelArray;
@property (nonatomic, weak) id<FRPFillSizePhotoViewControllerDelegate>delegate;

- (instancetype) initWithPhotoModels:(NSArray<FRPPhotoModel *> *)photoModelArray currentPhotoIndex:(NSInteger)photoIndex;
@end
