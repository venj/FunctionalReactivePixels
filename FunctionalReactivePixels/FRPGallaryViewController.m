//
//  FRPGallaryViewController.m
//  FunctionalReactivePixels
//
//  Created by 朱文杰 on 15/11/30.
//  Copyright © 2015年 朱文杰. All rights reserved.
//

#import "FRPGallaryViewController.h"
#import "FRPGallaryFlowLayout.h"
#import "FRPPhotoImporter.h"
#import "FRPCell.h"
#import "FRPFullSizePhotoViewController.h"
#import <ReactiveCocoa/RACDelegateProxy.h>

@interface FRPGallaryViewController ()
@property (nonatomic, strong) NSArray<FRPPhotoModel *> *photoArray;
@property (nonatomic, strong) id collectionViewDelegate;
@end

@implementation FRPGallaryViewController

static NSString * const reuseIdentifier = @"Cell";

- (instancetype _Nullable) init {
    FRPGallaryFlowLayout *flowLayout = [[FRPGallaryFlowLayout alloc] init];
    self = [self initWithCollectionViewLayout:flowLayout];
    if (!self) {
        return nil;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Popular on 500px";
    // Register cell classes
    [self.collectionView registerClass:[FRPCell class] forCellWithReuseIdentifier:reuseIdentifier];

    @weakify(self);
    [RACObserve(self, photoArray) subscribeNext:^(id x) {
        @strongify(self)
        [self.collectionView reloadData];
    }];

    RAC(self, photoArray) = [[[[FRPPhotoImporter importPhotos] doCompleted:^{
        @strongify(self);
        [self.collectionView reloadData];
    }] logError] catchTo:[RACSignal empty]];

    RACDelegateProxy *viewControllerDelegate = [[RACDelegateProxy alloc] initWithProtocol:@protocol(FRPFullSizePhotoViewControllerDelegate)];
    [[viewControllerDelegate rac_signalForSelector:@selector(userDidScroll:toPhotoAtIndex:) fromProtocol:@protocol(FRPFullSizePhotoViewControllerDelegate)] subscribeNext:^(RACTuple *value) {
        @strongify(self);
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:[value.second integerValue] inSection:0]  atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
    }];

    self.collectionViewDelegate = [[RACDelegateProxy alloc] initWithProtocol:@protocol(UICollectionViewDelegate)];
    [[self.collectionViewDelegate rac_signalForSelector:@selector(collectionView:didSelectItemAtIndexPath:) fromProtocol:@protocol(UICollectionViewDelegate)] subscribeNext:^(RACTuple *value) {
        @strongify(self);
        FRPFullSizePhotoViewController *viewController = [[FRPFullSizePhotoViewController alloc] initWithPhotoModels:self.photoArray currentPhotoIndex:[(NSIndexPath *)(value.second) item]];
        viewController.delegate = (id<FRPFullSizePhotoViewControllerDelegate>)viewControllerDelegate;
        [self.navigationController pushViewController:viewController animated:YES];
    }];

    self.collectionView.delegate = self.collectionViewDelegate;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photoArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FRPCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    [cell setPhotoModel:self.photoArray[indexPath.row]];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/
@end
