
#import "RNNativeCiesdk.h"

@implementation RNNativeCiesdk

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup { return YES; }

RCT_EXPORT_MODULE()

@end
  
