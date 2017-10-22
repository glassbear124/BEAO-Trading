//
//  InsertWindowController.h
//  Bear Trading
//
//  Created by Admin on 4/2/17.
//  Copyright © 2017 Xiaosoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MLCalendarView.h"
#import "InvestInfo.h"


@protocol InsertWindowDelegate <NSObject>
-(void) updateInvest:(id)sender;
-(void) addInvest:(id)sender;
-(void) closeWindow:(id)sender;
-(bool) isExistInvest:(NSString*)sID;
@end

@interface InsertWindowController : NSWindowController<MLCalendarViewDelegate, NSTextFieldDelegate, NSTextViewDelegate>

@property (assign) bool isAdd;
@property (nonatomic, retain) InvestInfo* invest;

@property (retain, nonatomic) id <InsertWindowDelegate> delegate;

@property (retain, nonatomic) IBOutlet NSButton* btnSetting;

@end
