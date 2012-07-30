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

@implementation CellView
@synthesize picView;
- (void)prepareForReuse
{
    [super prepareForReuse];
//    self.alpha = 0.0f;
}
- (void)fillViewWithObject:(id)object
{
    [super fillViewWithObject:object];
    NSURL *URL = [NSURL URLWithString:[object objectForKey:@"url"]];
//    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://imgur.com/%@%@", [item objectForKey:@"hash"], [item objectForKey:@"ext"]]];
    
    [self.picView  setImageWithURL:URL placeholderImage:[UIImage imageNamed:@"placeholder"]];
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    [picView release];
    [super dealloc];
}
@end
