//
//  FindWindowController.h
//  Bear Trading
//  Find Window
//  Created by Admin on 4/2/17.
//  Copyright © 2017 Xiaosoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <sqlite3.h>


@protocol FindWindowDelegate <NSObject>
-(void) closeFindWindow:(id)sender;
-(void) dblClickItem:(id)sender;
@end


@interface FindWindowController : NSWindowController <NSTableViewDelegate, NSTableViewDataSource>

@property (retain, nonatomic) id <FindWindowDelegate> delegate;
@property (assign) sqlite3* curDB;
@end
