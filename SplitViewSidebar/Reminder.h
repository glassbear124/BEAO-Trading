//
//  Reminder.h
//  Bear Trading
//
//  Created by Admin on 3/29/17.
//  Copyright © 2017 Xiaosoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Reminder : NSObject

@property (nonatomic, retain) NSString* date;       // reminder date
@property (nonatomic, retain) NSString* message;    // reminder message

@property (nonatomic, retain) NSString* ID;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* country;

@end
