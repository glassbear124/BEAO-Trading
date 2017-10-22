//
//  Utility.h
//  Bear Trading
//
//  Created by Admin on 3/30/17.
//  Copyright © 2017 Xiaosoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface Utility : NSObject {

}

+(NSInteger) getMonthDay:(NSInteger)year :(NSInteger)ix;
+(NSString*) getMonth:(NSInteger)ix;

+(NSColor*) rColor;
+(NSColor*) rBorderColor;

+(NSColor*) gColor;
+(NSColor*) gBorderColor;

+(NSColor*) bColor;
+(NSColor*) bBorderColor;

+(NSColor*) yColor;
+(NSColor*) yBorderColor;

+(NSString*) dateToStr : (NSDate*) date;
+(NSDate*) strToDate : (NSString*) str;

+(NSString*) dateToShortStr: (NSDate*) date;

+(bool) isInsert;
+(void) setOpenInsert:(bool)value;
+(bool) isFind;
+(void) setOpenFind:(bool)value;

+(bool) isEnquire;
+(void) setOpenEnquire:(bool)value;

+(bool) isNotification;
+(void) setOpenNotification:(bool)value;

@end
