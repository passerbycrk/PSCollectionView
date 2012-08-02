//
//  PKMemMonitorWnd.m
//
//  Created by zhongsheng on 12-8-2.
//
//

#import "PKMemMonitorWnd.h"
#import <mach/mach.h>

@interface PKMemMonitorWnd(/*private*/)
@property (nonatomic, retain) UILabel *memoryMonitorLabel;
@property (nonatomic, retain) NSTimer *memoryMonitorTimer;
@property (nonatomic, assign) unsigned int memoryPeak;
- (void)refreshMemoryMonitor;
@end
@implementation PKMemMonitorWnd
@synthesize
memoryMonitorLabel = _memoryMonitorLabel,
memoryPeak = _memoryPeak,
memoryMonitorTimer = _memoryMonitorTimer;

- (void)dealloc
{
    [self.memoryMonitorTimer invalidate];
    self.memoryMonitorTimer = nil;
    self.memoryMonitorLabel = nil;
    [super dealloc];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        self.windowLevel = UIWindowLevelStatusBar;
        self.memoryMonitorLabel = [[[UILabel alloc] initWithFrame:self.bounds] autorelease];
        self.memoryMonitorLabel.font = [UIFont systemFontOfSize:12];
        self.memoryMonitorLabel.textColor = [UIColor greenColor];
        self.memoryMonitorLabel.backgroundColor = [UIColor blackColor];
        self.memoryMonitorLabel.alpha = 0.7f;
        
        [self addSubview:self.memoryMonitorLabel];
        
        [self makeKeyAndVisible];
    }
    return self;
}
#pragma mark - Public
- (void)startMonitor
{
    [self stopMonitor];
    [self showMonitor:YES];
    
    _memoryMonitorTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                               target:self
                                                             selector:@selector(refreshMemoryMonitor)
                                                             userInfo:nil
                                                              repeats:YES];
    // 添加到当前runloop中
    NSRunLoop *runloop = [NSRunLoop currentRunLoop];
    [runloop addTimer:_memoryMonitorTimer forMode:NSRunLoopCommonModes];
    [runloop addTimer:_memoryMonitorTimer forMode:UITrackingRunLoopMode];
}
- (void)stopMonitor
{
    if (_memoryMonitorTimer) {
        [_memoryMonitorTimer invalidate];     
    }
    _memoryMonitorTimer = nil;
}
- (void)showMonitor:(BOOL)show
{
    if (show) {
        self.alpha = 1.0f;
    }else{
        self.alpha = 0.0f;
    }
}
#pragma mark - Private
- (void)refreshMemoryMonitor
{
    //// 设备总空间
    unsigned int usedMemory = [UIDevice usedMemory];
    unsigned int freeMemory = [UIDevice freeMemory];
    if (usedMemory > self.memoryPeak) {
        self.memoryPeak = usedMemory;
    }
    
    NSString *monitor = [NSString stringWithFormat:@"used:%7.1fMB free:%7.1fkb peak:%7.1fkb",
                         usedMemory/1024.0f/1024.0f,
                         freeMemory/1024.0f, self.memoryPeak/1024.0f];
    self.memoryMonitorLabel.frame = self.bounds;
    self.memoryMonitorLabel.text = monitor;
    
    [self.memoryMonitorLabel setNeedsDisplay];
}
@end


@implementation UIDevice (memory)

// 内存信息
+ (unsigned int)freeMemory{
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t pagesize;
    vm_statistics_data_t vm_stat;
    
    host_page_size(host_port, &pagesize);
    (void) host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    return vm_stat.free_count * pagesize;
}

+ (unsigned int)usedMemory{
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    return (kerr == KERN_SUCCESS) ? info.resident_size : 0;
}


@end