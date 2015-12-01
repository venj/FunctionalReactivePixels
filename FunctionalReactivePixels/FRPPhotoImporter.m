//
//  FRPPhotoImporter.m
//  FunctionalReactivePixels
//
//  Created by 朱文杰 on 15/11/30.
//  Copyright © 2015年 朱文杰. All rights reserved.
//

#import "FRPPhotoImporter.h"
#import "FRPPhotoModel.h"
#import "AppDelegate.h"

@implementation FRPPhotoImporter

+ (RACReplaySubject * _Nonnull)importPhotos {
    RACReplaySubject *subject = [RACReplaySubject subject];
    NSURLRequest *request = [self popularURLRequest];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (data) {
            id results = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            [subject sendNext:[[[results[@"photos"] rac_sequence] map:^id(NSDictionary *photoDictionary) {
                FRPPhotoModel *model = [[FRPPhotoModel alloc] init];
                [self configurePhotoModel:model withDictionary:photoDictionary];
                [self downloadThumbnailForPhotoModel:model];
                return model;
            }] array]];
            [subject sendCompleted];
        }
        else {
            [subject sendError:connectionError];
        }
    }];

    return subject;
}

+ (RACReplaySubject * _Nonnull)fetchPhotoDetails:(FRPPhotoModel * _Nonnull)photoModel {
    RACReplaySubject *subject = [RACReplaySubject subject];
    NSURLRequest *request = [self photoURLRequest:photoModel];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (data) {
            id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil][@"photo"];
            [self configurePhotoModel:photoModel withDictionary:result];
            [self downloadFullSizedImageForPhotoModel:photoModel];
            [subject sendNext:photoModel];
            [subject sendCompleted];
        }
    }];
    return subject;
}

+ (NSURLRequest * _Nonnull)popularURLRequest {
    return [[AppDelegate shared].apiHelper urlRequestForPhotoFeature:PXAPIHelperPhotoFeaturePopular resultsPerPage:100 page:0 photoSizes:PXPhotoModelSizeThumbnail sortOrder:PXAPIHelperSortOrderRating];
}

+ (NSURLRequest *_Nonnull)photoURLRequest:(FRPPhotoModel *)photoModel {
    return [[AppDelegate shared].apiHelper urlRequestForPhotoID:[photoModel.identifier integerValue]];
}

+ (void)configurePhotoModel:(FRPPhotoModel *)model withDictionary:(NSDictionary *)dictionary {
    model.photoName = dictionary[@"name"];
    model.identifier = dictionary[@"id"];
    model.photographerName = dictionary[@"user"][@"username"];
    model.rating = dictionary[@"rating"];
    model.thumbnailURL = [self urlForImageSize:3 inArray:dictionary[@"images"]];
    if (dictionary[@"comments_count"]) {
        model.fullsizedURL = [self urlForImageSize:4 inArray:dictionary[@"images"]];
    }
}

+ (NSString * _Nonnull)urlForImageSize:(NSInteger)size inArray:(NSArray *)array {
    return [[[[[array rac_sequence] filter:^BOOL(id value) {
        return [value[@"size"] integerValue] == size;
    }] map:^id(id value) {
        return value[@"url"];
    }] array] firstObject];
}

+ (void)downloadThumbnailForPhotoModel:(FRPPhotoModel *)model {
    [self download:model.thumbnailURL withCompletion:^(NSData *data) {
        model.thumbnailData = data;
    }];
}

+ (void)downloadFullSizedImageForPhotoModel:(FRPPhotoModel *)model {
    [self download:model.fullsizedURL withCompletion:^(NSData *data) {
        model.fullsizedData = data;
    }];
}

+ (void)download:(NSString *)urlString withCompletion:(void(^)(NSData *data))completion {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (completion) {
            completion(data);
        }
    }];
}

@end
