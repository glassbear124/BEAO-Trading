//
//  AppDelegate.m
//  SplitViewController
//
//

#import "AppDelegate.h"

@interface AppDelegate ()


@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    // Insert code here to initialize your application
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(void) showNoti {
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    notification.title = @"Hello, World!";
    notification.informativeText = [NSString stringWithFormat:@"details details details"];
    notification.soundName = NSUserNotificationDefaultSoundName;
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];    
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename {
    NSLog( @"ddd" );
    return YES;
}

-(BOOL) userNotificationCenter:(NSUserNotificationCenter *)center
shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}


@end
