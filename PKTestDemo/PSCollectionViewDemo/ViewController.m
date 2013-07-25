//
//  ViewController.m
//  PSCollectionViewDemo
//
//  Created by Eric on 12-6-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "PSCollectionViewCell.h"
#import "CellView.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"
#import "SVPullToRefresh.h"

#define MAX_IMAGE_CACHE_SIZE 1000000
#define MAX_IMAGE_CACHE_COUNT 200
#define IMAGE_HEIGHT 90.0f
@interface ViewController ()

@end

@implementation ViewController
@synthesize collectionView;
@synthesize items;
@synthesize haveMore;
@synthesize refresh;
@synthesize isLoading;
@synthesize pageIndex;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.items = [NSMutableArray array];

    }
    return self;
}
-(void)dealloc{
    [collectionView release];
    [items removeAllObjects];
    [items release];
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.haveMore = YES;
    self.refresh = YES;
    self.isLoading = NO;
    self.pageIndex = 0;
    collectionView = [[PSCollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    [self.view addSubview:collectionView];
    collectionView.collectionViewDelegate = self;
    collectionView.collectionViewDataSource = self;

    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    collectionView.numColsPortrait = 3;
    collectionView.numColsLandscape = 3;
    
//    for (int index = 0; index < 5; index ++) {
//        PSCollectionViewCell *cell = [[CellView alloc] init];
//        cell.frame = CGRectZero;
//        [collectionView enqueueReusableView:cell];
//        [cell release];
//    }
    
    // loading view
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicatorView.center = self.view.center;
    [activityIndicatorView startAnimating];
    collectionView.loadingView = activityIndicatorView;
    [activityIndicatorView release];
    
    // empty view
    UILabel *emptyLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
    emptyLabel.backgroundColor = [UIColor yellowColor];
    emptyLabel.text = @"Empty!!!";
    emptyLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    emptyLabel.textColor = [UIColor blackColor];
    emptyLabel.textAlignment = UITextAlignmentCenter;
    collectionView.emptyView = emptyLabel;
    [emptyLabel release];
    
    // Add pull refresh view
    [collectionView addPullToRefreshWithActionHandler:^{
        [self refreshTable];
    }];
    
    // Add infinite scrolling view
    SVPullToRefresh *footerView =[[SVPullToRefresh alloc] initWithScrollView:collectionView];
    footerView.frame = CGRectMake(0.0f, 0.0f, collectionView.bounds.size.width, 40.0f);
    footerView.backgroundColor = [UIColor clearColor];
    collectionView.footerView = footerView;////collectionView.infiniteScrollingView;
    collectionView.infiniteScrollingView = footerView;
    [footerView release];
    [collectionView addInfiniteScrollingWithActionHandler:^{
        [self loadMoreDataToTable];
    }];
    
    // 刷一发
    [collectionView.pullToRefreshView triggerRefresh];
}
- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self setCollectionView:nil];    
    // Release any retained subviews of the main view.
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [[SDImageCache sharedImageCache] clearMemory];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - PSCollectionViewDataSource

- (PSCollectionViewCell *)collectionView:(PSCollectionView *)collectionView viewAtIndex:(NSInteger)index {
    NSDictionary *item = [self.items objectAtIndex:index];
    
    // You should probably subclass PSCollectionViewCell
    CellView *v = (CellView *)[self.collectionView dequeueReusableView];
//    if (!v) {
//        v = [[[PSCollectionViewCell alloc] initWithFrame:CGRectZero] autorelease];
//    }
    if(v == nil) {
        NSArray *nib =
        [[NSBundle mainBundle] loadNibNamed:@"CellView" owner:self options:nil];
        v = [nib objectAtIndex:0];
    }
    
    [v fillViewWithObject:item];
   
    return v;
}

- (CGFloat)heightForViewAtIndex:(NSInteger)index {
    NSDictionary *item = [self.items objectAtIndex:index];
    return [(NSNumber *)[item objectForKey:@"height"] floatValue];
    // You should probably subclass PSCollectionViewCell
    return [PSCollectionViewCell heightForViewWithObject:item inColumnWidth:self.collectionView.colWidth];
}

- (NSInteger)numberOfViewsInCollectionView:(PSCollectionView *)collectionView {
    return [self.items count];
}

#pragma mark - PSCollectionViewDelegate

- (void)collectionView:(PSCollectionView *)collectionView 
         didSelectView:(PSCollectionViewCell *)view
               atIndex:(NSInteger)index 
{
    // Do something with the tap
}

#pragma mark -
- (void) refreshTable
{
    /*
     
     Code to actually refresh goes here.
     
     */
    self.refresh = YES;
    self.isLoading = NO;
    
    self.pageIndex = 0;

    [self loadDataSource];
    
}

- (void) loadMoreDataToTable
{
    /*
     
     Code to actually load more data goes here.
     
     */
    [self loadDataSource];
}

- (void)loadDataSource {
    // Request
    if ( self.isLoading ) {
        return;
    }
    
    self.isLoading = YES;
    NSString *URLPath = [NSString stringWithFormat:@"http://morelife.sinaapp.com/v/1/snaps/%d/list",self.pageIndex++];
//    NSString *URLPath = [NSString stringWithFormat:@"http://imgur.com/gallery.json"];
    NSURL *URL = [NSURL URLWithString:URLPath];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
        
        if (!error && responseCode == 200) {
            id res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if (res && [res isKindOfClass:[NSDictionary class]]) {
//                self.items = [res objectForKey:@"gallery"];
                NSLog(@"dataSourceDidLoad");
                NSArray *picsItems = [res objectForKey:@"pics"];
                self.haveMore = [[res objectForKey:@"more"]  boolValue];

                [self dataSourceDidLoad:picsItems];
                
                [self.collectionView.pullToRefreshView stopAnimating];
            } else {
                NSDictionary *dic = [NSDictionary dictionaryWithObject:res forKey:@"nani"];
                NSError *error = [NSError errorWithDomain:@"heheDomain" code:111 userInfo:dic];
                [self dataSourceDidError:error];
            }
        } else {
            [self dataSourceDidError:error];
        }
    }];
}

- (void)dataSourceDidLoad:(NSArray *)picsItems {
    if (self.refresh) {
        NSLog(@" clear all image cache");
        [[SDImageCache sharedImageCache] cleanDisk];
        [[SDImageCache sharedImageCache] clearDisk];
        [[SDImageCache sharedImageCache] clearMemory];
        [self.items removeAllObjects];
        self.refresh = NO;
    }
//    if (self.items.count >= 200) {
//        self.haveMore = NO;
//    }
    // 清除个缓存。
    if (self.pageIndex%8 == 0) {
        // 这个略卡 ， 每次读文件
//        NSLog(@"COUNT[%d] memorySize:%d",self.items.count,[[SDImageCache sharedImageCache] getMemorySize]);            
//        if ([[SDImageCache sharedImageCache] getMemorySize] > MAX_IMAGE_CACHE_SIZE) {
//            NSLog(@"clear Memory");
//            [[SDImageCache sharedImageCache] clearMemory];
//        }
//        if ([[SDImageCache sharedImageCache] getMemoryCount] >= MAX_IMAGE_CACHE_COUNT) {
//            NSLog(@"clear Memory");
//            [[SDImageCache sharedImageCache] clearMemory];
//        }
    }
    // 无聊的加个随机高度
    NSMutableArray *array = [NSMutableArray arrayWithArray:picsItems];
    for (int index = 0; index < array.count; index ++) {
        NSMutableDictionary *dict= [NSMutableDictionary dictionaryWithDictionary:[array objectAtIndex:index]];
        [dict setObject:[NSNumber numberWithFloat:(90+random()%100)] forKey:@"height"];
        [array replaceObjectAtIndex:index withObject:dict];
    }
    [self.items addObjectsFromArray:array];
    [self.collectionView reloadData];
    if (!self.haveMore) {
        collectionView.showsInfiniteScrolling = NO;
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"more" 
                                                            message:@"false" 
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles: nil];
        [alertView show];
        [alertView autorelease];
    }
    self.isLoading = NO;
}

- (void)dataSourceDidError:(NSError *)error {
    [self.collectionView reloadData];
    if (self.refresh) {
        self.refresh = NO;
    }
    else if (self.pageIndex > 0) {
        self.pageIndex -= 1;
    }
    [self.collectionView.pullToRefreshView stopAnimating];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"error" 
                                                        message:[NSString stringWithFormat:@"%@",error]
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles: nil];
    [alertView show];
    [alertView autorelease];
    self.isLoading = NO;
}
@end
