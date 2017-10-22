//
//  FindWindowController.h
//  Bear Trading
//
//  Created by Admin on 4/2/17.
//  Copyright © 2017 Xiaosoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol EnquireWindowDelegate <NSObject>
-(void) closeEnquireWindow:(id)sender;
@end


@interface EnquireWindowController : NSWindowController

@property (retain, nonatomic) id <EnquireWindowDelegate> delegate;

@end
