//
//  PKMemMonitorWnd.h
//
//  Created by zhongsheng on 12-8-2.
//
//

#import <UIKit/UIKit.h>

@interface PKMemMonitorWnd : UIWindow

- (void)startMonitor;

- (void)stopMonitor;

- (void)showMonitor:(BOOL)show;

@end


@interface UIDevice (memory)
+ (unsigned int)freeMemory;
+ (unsigned int)usedMemory;
@end