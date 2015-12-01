//
//  FRPPhotoModel.h
//  FunctionalReactivePixels
//
//  Created by 朱文杰 on 15/11/30.
//  Copyright © 2015年 朱文杰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FRPPhotoModel : NSObject
@property (nonatomic, strong) NSString *photoName;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, strong) NSString *photographerName;
@property (nonatomic, strong) NSNumber *rating;
@property (nonatomic, strong) NSString *thumbnailURL;
@property (nonatomic, strong) NSData *thumbnailData;
@property (nonatomic, strong) NSString *fullsizedURL;
@property (nonatomic, strong) NSData *fullsizedData;
@end
