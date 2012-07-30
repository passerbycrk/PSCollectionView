//
//  ViewController.h
//  PSCollectionViewDemo
//
//  Created by Eric on 12-6-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSCollectionView.h"

@interface ViewController : UIViewController<PSCollectionViewDelegate,PSCollectionViewDataSource,UIScrollViewDelegate>
@property(nonatomic,retain) PSCollectionView *collectionView;
@property(nonatomic,retain) NSMutableArray *items;
@property(nonatomic,assign) BOOL haveMore;
@property(nonatomic,assign) BOOL refresh;
@property(nonatomic,assign) NSUInteger pageIndex;
-(void)loadDataSource;
@end
