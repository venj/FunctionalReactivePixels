//
//  FRPPhotoImporter.h
//  FunctionalReactivePixels
//
//  Created by 朱文杰 on 15/11/30.
//  Copyright © 2015年 朱文杰. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FRPPhotoModel;
@interface FRPPhotoImporter : NSObject
+ (RACSignal * _Nonnull)importPhotos;
+ (RACReplaySubject * _Nonnull)fetchPhotoDetails:(FRPPhotoModel * _Nonnull)photoModel;
@end
