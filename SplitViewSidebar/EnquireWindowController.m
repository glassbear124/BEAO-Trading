//
//  FindWindowController.m
//  Bear Trading
//
//  Created by Admin on 4/2/17.
//  Copyright © 2017 Xiaosoft. All rights reserved.
//

#import "EnquireWindowController.h"
#import "AppDelegate.h"

@interface EnquireWindowController ()
{
    IBOutlet NSButton* btnOk;
    IBOutlet NSImageView* imgView;
}
@end

@implementation EnquireWindowController


- (void)windowDidLoad {
    [super windowDidLoad];
    
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)windowWillClose:(NSNotification *)notification
{
    if ([self.delegate respondsToSelector:@selector(closeEnquireWindow:)]) {
        [self.delegate closeEnquireWindow:self];
    }
}

-(void) loadWindow{
    [super loadWindow];
    

}
- (IBAction)onOK:(id)sender {
    [[NSApp mainWindow] close];
    if ([self.delegate respondsToSelector:@selector(closeEnquireWindow:)]) {
        [self.delegate closeEnquireWindow:self];
    }
}

@end
