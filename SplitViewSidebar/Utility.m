//
//  Utility.m
//  Bear Trading
//
//  Created by Admin on 3/30/17.
//  Copyright © 2017 Xiaosoft. All rights reserved.
//

#import "Utility.h"

@implementation Utility

NSDateFormatter* dateFormatter;
NSDateFormatter* shortDateFormatter;

bool isOpenInsert;
bool isOpenFind;
bool isOpenEnquire;
bool isOpenNotification;

+(NSString*) getMonth:(NSInteger)ix {
    NSArray* arrMon = @[@"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun", @"Jul", @"Aug", @"Sep", @"Oct", @"Nov", @"Dec"];
    return arrMon[ix%12];
}

+(NSInteger) getMonthDay:(NSInteger)year :(NSInteger)ix {
    NSInteger a[12] = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
    if( ix == 1 && year % 4 == 0 && year % 100 != 0 ) {
        return 29;
    }
    return a[ix%12];
}

+(bool) isNotification {
    return isOpenNotification;
}

+(void) setOpenNotification:(bool)value {
    isOpenNotification = value;
}


+(bool) isEnquire {
    return isOpenEnquire;
}

+(bool) isInsert {
    return isOpenInsert;
}

+(void) setOpenEnquire:(bool)value {
    isOpenEnquire = value;
}

+(void) setOpenInsert:(bool)value {
    isOpenInsert = value;
}

+(bool) isFind {
    return isOpenFind;
}

+(void) setOpenFind:(bool)value {
    isOpenFind = value;
}

+(NSColor*) rColor {
    return [NSColor colorWithCalibratedRed:1 green:0.7 blue:0.7 alpha:1.0];
}
+(NSColor*) rBorderColor {
    return [NSColor colorWithCalibratedRed:1 green:0.4 blue:0.4 alpha:1.0];
}

+(NSColor*) gColor {
    return [NSColor colorWithCalibratedRed:0.7 green:1.0 blue:0.7 alpha:1.0];
}
+(NSColor*) gBorderColor {
    return [NSColor colorWithCalibratedRed:0.4 green:0.8 blue:0.4 alpha:1.0];
}

+(NSColor*) bColor {
    return [NSColor colorWithCalibratedRed:0.7 green:0.7 blue:1 alpha:1.0];
}
+(NSColor*) bBorderColor {
    return [NSColor colorWithCalibratedRed:0.4 green:0.4 blue:1 alpha:1.0];
}

+(NSColor*) yColor {
    return [NSColor colorWithCalibratedRed:1 green:1 blue:0.7 alpha:1.0];
}
+(NSColor*) yBorderColor {
    return [NSColor colorWithCalibratedRed:0.9 green:0.7 blue:0.4 alpha:1.0];
}

+(NSString*) dateToShortStr: (NSDate*) date {
    if( shortDateFormatter == nil ) {
        shortDateFormatter = [[NSDateFormatter alloc] init];
        shortDateFormatter.locale = [NSLocale currentLocale];
        shortDateFormatter.dateFormat = @"yyyy-MM";
    }
    return [shortDateFormatter stringFromDate:date];
}

+(NSString*) dateToStr : (NSDate*) date {
    if( dateFormatter == nil ) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [NSLocale currentLocale];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
    }
    return [dateFormatter stringFromDate:date];
}

+(NSDate*) strToDate : (NSString*) str {
    if( dateFormatter == nil ) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [NSLocale currentLocale];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
    }
    return [dateFormatter dateFromString:str];
}

@end
