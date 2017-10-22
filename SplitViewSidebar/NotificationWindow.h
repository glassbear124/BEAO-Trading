//
//  FindWindowController.h
//  Bear Trading
//
//  Created by Admin on 4/2/17.
//  Copyright © 2017 Xiaosoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <sqlite3.h>


@protocol NotificationWindowDelegate <NSObject>
-(void) closeNotificationWindow:(id)sender;
-(void) dblNotiClickItem:(id)sender;
@end


@interface NotificationWindow : NSWindowController <NSTableViewDelegate, NSTableViewDataSource>

@property (retain, nonatomic) id <NotificationWindowDelegate> delegate;
@property (assign) sqlite3* curDB;
@end
