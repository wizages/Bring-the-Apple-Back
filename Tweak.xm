#import <objc/runtime.h>
#import "header.h"

@interface PUIProgressWindow : NSObject
- (void)setProgressValue:(float)arg1;
- (void)_createLayer;
- (void)setVisible:(BOOL)arg1;
-(id)initWithProgressBarVisibility:(BOOL)arg1 createContext:(BOOL)arg2 contextLevel:(float)arg3 appearance:(int)arg4;
@end

@interface SBBacklightController: NSObject
+ (id)sharedInstance;
+ (id)_sharedInstanceCreateIfNeeded:(BOOL)arg1 ;
+ (id)sharedInstanceIfExists;
- (void)startFadeOutAnimationFromLockSource:(int)arg1 ;
- (void)animateBacklightToFactor:(float)arg1 duration:(double)arg2 source:(long long)arg3 completion:(void (^)(void))arg4 ;
@end

CFDataRef shutDown(CFMessagePortRef local, SInt32 msgid, CFDataRef data, void *info);
CFDataRef startUp(CFMessagePortRef local, SInt32 msgid, CFDataRef data, void *info);

PUIProgressWindow *window;


%hook BKSystemAppSentinel


- (void) _handleRelaunchRequestFromSystemApp:(id)arg1 withOptions:(unsigned long)arg2{
    arg2 = 2;
    %orig;
}


%end

%hook BKDisplayRenderOverlay 

-(void)freeze{
    //Fuck you freezer!

    //%orig;
}

%end

%hook BKDisplayRenderOverlaySpinny

-(id)initWithOverlayDescriptor:(id)arg1 level:(float)arg2{

    if (window == nil && arg2 > -1)
    {
        window = [[PUIProgressWindow alloc] initWithProgressBarVisibility:NO createContext:YES contextLevel:1000 appearance:0];
        [window _createLayer];
        [window setVisible:YES];
    }
    

    return %orig(arg1, -1);
}

- (BOOL) presentWithAnimationSettings:(id)arg1{
    return true;
}

%end

%hook PUIProgressWindow

- (id)initWithProgressBarVisibility:(BOOL)arg1 createContext:(BOOL)arg2 contextLevel:(float)arg3 appearance:(int)arg4 {

    
    CFMessagePortRef port = CFMessagePortCreateLocal(kCFAllocatorDefault, CFSTR("com.wizages.babEnd"), &shutDown, NULL, NULL);
    CFMessagePortSetDispatchQueue(port, dispatch_get_main_queue());
    CFMessagePortRef port2 = CFMessagePortCreateLocal(kCFAllocatorDefault, CFSTR("com.wizages.babStart"), &startUp, NULL, NULL);
    CFMessagePortSetDispatchQueue(port2, dispatch_get_main_queue());
    window = %orig(arg1, arg2, arg3, arg4);
    
    return window;
}

CFDataRef shutDown(CFMessagePortRef local, SInt32 msgid, CFDataRef data, void *info) {
    //
	[window setVisible:NO];
    [window _createLayer];
    HBLogDebug(@"Hide");
    return NULL;
}

CFDataRef startUp(CFMessagePortRef local, SInt32 msgid, CFDataRef data, void *info) {
    [window _createLayer];
    [window setVisible:YES];
    HBLogDebug(@"Show");
    return NULL;
}

-(void)setVisible:(BOOL)arg1{
    %orig;
    if(arg1){
        HBLogDebug(@"Show");
    } else {
        HBLogDebug(@"Hide");
    }
}

%end

%hook SpringBoard

- (void)applicationDidFinishLaunching:(UIApplication *)application {

    BKSHIDServicesSetBacklightFactorWithFadeDuration(1.0, 0, false);
    BKSDisplayServicesSetScreenBlanked(NO);

    int32_t local = 0;
    int progressPointer = local;
    NSData *progressMessage = [NSData dataWithBytes:&local length:sizeof(progressPointer)];

    CFMessagePortRef port2 = CFMessagePortCreateRemote(kCFAllocatorDefault, CFSTR("com.wizages.babStart"));
    
    if (port2 > 0) {
        CFMessagePortSendRequest(port2, 0, (CFDataRef)progressMessage, 1000, 0, NULL, NULL);
    }

	%orig;

    CFMessagePortRef port = CFMessagePortCreateRemote(kCFAllocatorDefault, CFSTR("com.wizages.babEnd"));
    
    if (port > 0) {
        CFMessagePortSendRequest(port, 0, (CFDataRef)progressMessage, 1000, 0, NULL, NULL);
    }

}

%end