#import <objc/runtime.h>

@interface PUIProgressWindow : NSObject
- (void)setProgressValue:(float)arg1;
- (void)_createLayer;
- (void)setVisible:(BOOL)arg1;
-(id)initWithProgressBarVisibility:(BOOL)arg1 createContext:(BOOL)arg2 contextLevel:(float)arg3 appearance:(int)arg4;
@end

CFDataRef shutDown(CFMessagePortRef local, SInt32 msgid, CFDataRef data, void *info);

PUIProgressWindow *window;


%hook BKSystemAppSentinel


- (void) _handleRelaunchRequestFromSystemApp:(id)arg1 withOptions:(unsigned long)arg2{
    arg2 = 2;
    %orig;
}


%end

%hook BKDisplayRenderOverlaySpinny

-(id)initWithOverlayDescriptor:(id)arg1 level:(float)arg2{
    if (window == nil && arg2 > -1)
    {
        window = [[PUIProgressWindow alloc] initWithProgressBarVisibility:NO createContext:YES contextLevel:1000 appearance:0];
        [window _createLayer];
        [window setVisible:YES];
        //[window _createLayer];
    }
    return %orig(arg1, -1);
}

- (BOOL) presentWithAnimationSettings:(id)arg1{
    return true;
}

%end

%hook PUIProgressWindow

- (id)initWithProgressBarVisibility:(BOOL)arg1 createContext:(BOOL)arg2 contextLevel:(float)arg3 appearance:(int)arg4 {

    
    CFMessagePortRef port = CFMessagePortCreateLocal(kCFAllocatorDefault, CFSTR("com.wizages.bab"), &shutDown, NULL, NULL);
    CFMessagePortSetDispatchQueue(port, dispatch_get_main_queue());
    window = %orig(arg1, arg2, arg3, arg4);
    return window;
}

CFDataRef shutDown(CFMessagePortRef local, SInt32 msgid, CFDataRef data, void *info) {
    [window _createLayer];
	[window setVisible:NO];
    return NULL;
}

%end

%hook SpringBoard

- (void)applicationDidFinishLaunching:(UIApplication *)application {

	%orig;

	int32_t local = 0;
    CFMessagePortRef port = CFMessagePortCreateRemote(kCFAllocatorDefault, CFSTR("com.wizages.bab"));
    int progressPointer = local;
    NSData *progressMessage = [NSData dataWithBytes:&local length:sizeof(progressPointer)];
    if (port > 0) {
        CFMessagePortSendRequest(port, 0, (CFDataRef)progressMessage, 1000, 0, NULL, NULL);
    }

}

%end