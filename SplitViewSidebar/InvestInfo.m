//
//  FileInfo.m
//  Bear Trading
//
//  Created by Admin on 3/29/17.
//  Copyright © 2017 Xiaosoft. All rights reserved.
//

#import "InvestInfo.h"
#import "Reminder.h"
#import "Utility.h"

@implementation InvestInfo

-(InvestInfo*) init {
    self = [super init];
    if( self ) {
        
        unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *comps = [calendar components:unitFlags fromDate:[NSDate date]];
        comps.hour   = 0;
        comps.minute = 0;
        comps.second = 0;
        NSDate *newDate = [calendar dateFromComponents:comps];
        
        self.start = newDate;
        self.end = newDate;
        
        _arrReminders = [[NSMutableArray alloc] init];
    }
    return self;
}

-(NSString*) getReminderDate {
    
    if( !_arrReminders || _arrReminders.count == 0 )
        return @"";
    
    NSString* strDate = @"";
    for( Reminder* reminder in _arrReminders ) {
        strDate = [strDate stringByAppendingString:reminder.date];
        strDate = [strDate stringByAppendingString:@";"];
    }
    return strDate;
}

-(NSString*) getReminderMessage {
    
    if( !_arrReminders || _arrReminders.count == 0 )
        return @"";

    NSString* strMessage = @"";
    for( Reminder* reminder in _arrReminders ) {
        strMessage = [strMessage stringByAppendingString:reminder.message];
        strMessage = [strMessage stringByAppendingString:@"#$%"];
    }
    return strMessage;
}

-(NSString*) startStr {
    return [Utility dateToStr:_start];
}

-(NSString*) endStr {
    return [Utility dateToStr:_end];
}


-(bool) createInvest :(sqlite3_stmt*)statement {
    
    _id = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(statement,0)];
    _tIx = sqlite3_column_int(statement, 1);
    const char* pName = (const char*)sqlite3_column_text(statement,2);
    if( !strcmp(pName, "(null)") )
        _name = @"";
    else
        _name = [[NSString alloc] initWithUTF8String:pName];
    
    const char* pIssuer = (const char*)sqlite3_column_text(statement,3);
    if( !strcmp(pIssuer, "(null)") ) {
        _issuer = @"";
    }
    else
        _issuer = [[NSString alloc] initWithUTF8String:pIssuer];
    
    const char* pAmount = (const char*)sqlite3_column_text(statement,4);
    if( !strcmp(pAmount, "(null)") )
        _amount = @"";
    else
        _amount = [[NSString alloc] initWithUTF8String:pAmount];
    _price = sqlite3_column_double(statement, 5);
    
    NSString* strStart = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(statement,6)];
    _start = [Utility strToDate:strStart];
    NSString* strEnd = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(statement,7)];
    _end = [Utility strToDate:strEnd];
    
    _color = sqlite3_column_int(statement,8);
    _unit = sqlite3_column_int(statement,9);
    
    const char* pNote = (const char*)sqlite3_column_text(statement,10);
    if( pNote == NULL || !strcmp(pNote, "(null)") ) {
        _note = @"";
    }
    else
        _note = [[NSString alloc] initWithUTF8String:pNote];
    
    NSString* strReminderDate = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(statement,11)];
    NSArray* dateArray = [strReminderDate componentsSeparatedByString:@";"];
    for( NSString* str in dateArray ) {
        if( str.length == 0 )
            continue;
        Reminder* reminder = [[Reminder alloc] init];
        reminder.date = str;
        [_arrReminders addObject:reminder];
    }
    
    NSString* strReminderMsg = [[NSString alloc] initWithUTF8String:(const char*)sqlite3_column_text(statement,12)];
    NSArray* msgArray = [strReminderMsg componentsSeparatedByString:@"#$%"];
    int i = 0;
    for( Reminder* reminder in _arrReminders ) {
        reminder.message = msgArray[i];
        i++;
    }
    return YES;
}


@end
