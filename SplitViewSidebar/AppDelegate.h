//
//  AppDelegate.h
//  SplitViewController
//

#import <Cocoa/Cocoa.h>


@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate>

@property (weak) IBOutlet NSWindow *window;

-(void) showNoti;

@end

