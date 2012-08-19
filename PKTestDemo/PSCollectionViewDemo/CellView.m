//
//  CellView.m
//  PSCollectionViewDemo
//
//  Created by Eric on 12-6-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CellView.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"
#import <QuartzCore/QuartzCore.h>

@implementation CellView
@synthesize picView;

+ (BOOL)automaticallyNotifiesObserversForKey: (NSString *)theKey
{
    BOOL automatic;
    
    if ([theKey isEqualToString:@"picView"]) {
        automatic = NO;
    } else {
        automatic = [super automaticallyNotifiesObserversForKey:theKey];
    }
    
    return automatic;
}

- (void)dealloc
{
    self.picView = nil;
    [super dealloc];
}
- (void)prepareForReuse
{
    [super prepareForReuse];
    self.picView.image = nil;
    if (self.object) {
//        [[SDImageCache sharedImageCache] removeImageForKey:[self.object objectForKey:@"url"] fromDisk:NO];
    }
}
- (void)fillViewWithObject:(id)object
{
    [super fillViewWithObject:object];
    if (self.object) {
        NSURL *URL = [NSURL URLWithString:[object objectForKey:@"url"]];        
//        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://imgur.com/%@%@", [item objectForKey:@"hash"], [item objectForKey:@"ext"]]];
        [self.picView  setImageWithURL:URL placeholderImage:[UIImage imageNamed:@"placeholder"]];

    }
    self.layer.borderWidth = .5f;
    self.layer.borderColor = [[UIColor blackColor] CGColor];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setClipsToBounds:YES];
        self.picView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return self;
}

@end
