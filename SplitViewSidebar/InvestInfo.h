//
//  FileInfo.h
//  Bear Trading
//
//  Created by Admin on 3/29/17.
//  Copyright © 2017 Xiaosoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface InvestInfo : NSObject

@property (assign) int tIx;

@property (nonatomic, retain) NSString* id;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* issuer;
@property (nonatomic, retain) NSString* amount;
@property (assign) float price;
@property (assign) int nDuration;
@property (nonatomic, retain) NSDate* start;
@property (nonatomic, retain) NSDate* end;
@property (assign) int color; // 0:r 1:g 2:b 3:y
@property (assign) int unit;  // UGX, KES, TZS
@property (nonatomic, retain) NSString* note;
@property (nonatomic, retain) NSMutableArray* arrReminders;

-(NSString*) getReminderDate;
-(NSString*) getReminderMessage;

-(bool) createInvest :(sqlite3_stmt*)statement;
-(NSString*) startStr;
-(NSString*) endStr;

@end
