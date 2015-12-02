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

+ (RACSignal * _Nonnull)importPhotos {
    NSURLRequest *request = [self popularURLRequest];
    return [[[[[[NSURLConnection rac_sendAsynchronousRequest:request] reduceEach:^id(NSURLResponse *response, NSData *data) {
        return data;
    }] deliverOn:[RACScheduler mainThreadScheduler]] map:^id(NSData *data) {
        id results = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        return [[[results[@"photos"] rac_sequence] map:^id(NSDictionary *photoDictionary) {
            FRPPhotoModel *model = [[FRPPhotoModel alloc] init];
            [self configurePhotoModel:model withDictionary:photoDictionary];
            [self downloadThumbnailForPhotoModel:model];
            return model;
        }] array];
    }] publish] autoconnect];
}

+ (RACSignal * _Nonnull)fetchPhotoDetails:(FRPPhotoModel * _Nonnull)photoModel {
    NSURLRequest *request = [self photoURLRequest:photoModel];
    return [[[[[[NSURLConnection rac_sendAsynchronousRequest:request] reduceEach:^id (NSURLResponse *response, NSData *data) {
        return data;
    }] deliverOn:[RACScheduler mainThreadScheduler]] map:^id(NSData *data) {
        id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil][@"photo"];
        [self configurePhotoModel:photoModel withDictionary:result];
        [self downloadFullSizedImageForPhotoModel:photoModel];
        return photoModel;
    }] publish] autoconnect];
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
    RAC(model, thumbnailData) = [self download:model.thumbnailURL];
}

+ (void)downloadFullSizedImageForPhotoModel:(FRPPhotoModel *)model {
    RAC(model, fullsizedData) = [self download:model.fullsizedURL];
}

+ (RACSignal *)download:(NSString *)urlString {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    return [[[NSURLConnection rac_sendAsynchronousRequest:request] map:^id(RACTuple *value) {
        return [value second];
    }] deliverOn:[RACScheduler mainThreadScheduler]];
}

@end
