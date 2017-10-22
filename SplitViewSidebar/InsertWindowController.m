//
//  InsertWindowController.m
//  Bear Trading
//  Add/Edit invest Window
//  Created by Admin on 4/2/17.
//  Copyright © 2017 Xiaosoft. All rights reserved.
//

#import "InsertWindowController.h"
#import "Reminder.h"
#import "Utility.h"

// calendar type
#define cal_reminder 1
#define cal_begine   2
#define cal_end      3

@interface InsertWindowController ()
{
    IBOutlet NSTextField* txtId;
    IBOutlet NSTextField* txtName;
    IBOutlet NSTextField* txtIssuer;
    IBOutlet NSTextField* txtAmount;
    IBOutlet NSTextField* txtPrice;
    IBOutlet NSTextField* txtDuration;
    
    IBOutlet NSTextField* txtReminder;
    IBOutlet NSTextField* lblReminderCount;
    IBOutlet NSPopUpButton* btnColor;
    IBOutlet NSPopUpButton* btnUnit;
    
    IBOutlet NSTextField* txtBegin;
    IBOutlet NSButton* btnBegin;
    IBOutlet NSTextField* txtEnd;
    IBOutlet NSButton* btnEnd;
    
    IBOutlet NSButton* btnInsert;
    IBOutlet NSButton* btnCancel;
    
    IBOutlet NSTextView* txtNote;
    
    NSPopover* calendarPopover;
    MLCalendarView* calendarView;
    
    int calendarType; // 1: reminder 2: begin, 3: end;
    
    NSDate* dateBegin;
    NSDate* dateEnd;
    NSDate* dateReminder;
    
    MLCalendarView* reminderCalender;
    int nSelReminder;

}
@end

@implementation InsertWindowController

- (void)windowDidLoad {
    [super windowDidLoad];    
}

-(void) loadWindow{
    [super loadWindow];

    if( reminderCalender == nil ) {
        reminderCalender = [[MLCalendarView alloc] initWithMulti];
        reminderCalender.delegate = self;
        NSSize s = reminderCalender.view.frame.size;
        reminderCalender.view.frame = NSMakeRect(35, 90, s.width, s.height);
        reminderCalender.isMultiSelect = true;
        [self.window.contentView addSubview:reminderCalender.view];
    }
}

-(void) showWindow:(id)sender {
    [super showWindow:sender];
    
    if( self.isAdd == true ) {
        btnInsert.title = @"Insert";
        txtId.stringValue = @"";
        txtId.enabled = YES;
        txtName.stringValue = @"";
        txtIssuer.stringValue = @"";
        txtAmount.stringValue = @"";
        txtPrice.stringValue = @"";
        txtDuration.stringValue = @"";
    }
    else {
        btnInsert.title = @"Save";
        btnInsert.enabled = false;
        
        if( self.invest.id ) {
            txtId.stringValue = self.invest.id;
            txtId.enabled = NO;
        }
        if( self.invest.name )
            txtName.stringValue = self.invest.name;
        if( self.invest.issuer )
            txtIssuer.stringValue = self.invest.issuer;
        if( self.invest.amount )
            txtAmount.stringValue = self.invest.amount;
        txtPrice.stringValue = [NSString stringWithFormat:@"%.2f", self.invest.price];
        
        NSLog(@"%@ %ld", self.invest.note, self.invest.note.length );
        if( self.invest.note )
            txtNote.string = self.invest.note;
    }
    
    if( self.invest.start ) {
        txtBegin.stringValue = [self.invest startStr];
        dateBegin = self.invest.start;
    }
    
    if( self.invest.end) {
        txtEnd.stringValue = [self.invest endStr];
        dateEnd = self.invest.end;
    }
    
    if( self.invest.arrReminders ) {
        reminderCalender.arrReminders = self.invest.arrReminders;
        lblReminderCount.stringValue = [NSString stringWithFormat:@"%ld day(s) reminder", self.invest.arrReminders.count];
        [reminderCalender layoutCalendar];
    }
    
    NSTimeInterval interval = [dateEnd timeIntervalSinceDate:dateBegin];
    int day = interval/3600/24;
    if( day > -1 )
        txtDuration.stringValue = [NSString stringWithFormat:@"%d Days", day];
    
    [btnColor selectItemAtIndex:self.invest.color];
    [btnUnit selectItemAtIndex:self.invest.unit];
    
    _btnSetting.enabled = NO;
    txtReminder.enabled = NO;
}

- (void)windowWillClose:(NSNotification *)notification
{
    if ([self.delegate respondsToSelector:@selector(closeWindow:)]) {
        [self.delegate closeWindow:self];
    }
}

- (void) createCalendarPopover {
    NSPopover* myPopover = calendarPopover;
    if(!myPopover) {
        myPopover = [[NSPopover alloc] init];
        calendarView = [[MLCalendarView alloc] init];
        calendarView.delegate = self;
        myPopover.contentViewController = calendarView;
//        myPopover.appearance = [NSAppearance appearanceNamed:NSAppearanceNameAqua];
        myPopover.animates = YES;
        myPopover.behavior = NSPopoverBehaviorTransient;
    }
    calendarPopover = myPopover;
}


#pragma mark -

- (IBAction)showCalendar:(id)sender {
    [self createCalendarPopover];
    
    NSDate* date;
    calendarType = cal_end;
    
    if( sender == btnBegin ) {
        date =  [Utility strToDate:txtBegin.stringValue];
        dateBegin = date;
        calendarType = cal_begine;
    }
    else {
        date = [Utility strToDate:txtEnd.stringValue];
        dateEnd = date;
    }
    
    calendarView.date = date;
    calendarView.selectedDate = date;
    NSButton* btn = sender;
    NSRect cellRect = [btn bounds];
    [calendarPopover showRelativeToRect:cellRect ofView:btn preferredEdge:NSMaxYEdge];
}

-(bool) isNumeric:(NSString*) checkText{
    return [[NSScanner scannerWithString:checkText] scanFloat:NULL];
}

-(IBAction) onSetReminder : (id) sender {
    
    if( [_btnSetting.title isEqualToString:@"Set"] ) {
        Reminder* reminder = [[Reminder alloc] init];
        reminder.date = [Utility dateToStr:reminderCalender.selectedDate];
        reminder.message = txtReminder.stringValue;
        [self.invest.arrReminders addObject:reminder];
        
        txtReminder.stringValue = @"";
        
    } else {
        if( nSelReminder > -1 ) {
            [self.invest.arrReminders removeObjectAtIndex:nSelReminder];
            txtReminder.stringValue = @"";
            _btnSetting.title = @"Set";
        }
    }
    
    lblReminderCount.stringValue = [NSString stringWithFormat:@"%ld day(s) reminder", self.invest.arrReminders.count];
    [reminderCalender layoutCalendar];
    
    txtReminder.enabled = NO;
    _btnSetting.enabled = NO;
    
}

-(IBAction)onDone:(id)sender {
    
    if( sender == btnInsert ) {
        
        if( txtId.stringValue.length == 0 ) {
            NSRunAlertPanel(@"Error", @"The 'ID' is empty.", @"Ok", nil, nil);
            return;
        }
        
        if( txtIssuer.stringValue.length == 0 ) {
            NSRunAlertPanel(@"Error", @"The 'Issuer' is empty.", @"Ok", nil, nil);
            return;
        }
        
        if( txtName.stringValue.length == 0 ) {
            NSRunAlertPanel(@"Error", @"The 'Security Type' is empty.", @"Ok", nil, nil);
            return;
        }
        
        if( txtPrice.stringValue.length == 0 ) {
            NSRunAlertPanel(@"Error", @"The 'Price' is empty.", @"Ok", nil, nil);
            return;
        }
        
        if( txtAmount.stringValue.length == 0 ) {
            NSRunAlertPanel(@"Error", @"The 'Amount tendered' is empty.", @"Ok", nil, nil);
            return;
        }
        
        NSString *str = txtId.stringValue;
        NSCharacterSet *alphaNumSet = [NSCharacterSet alphanumericCharacterSet];
        NSCharacterSet *alphaSet = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
        NSCharacterSet *numberExSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789,"];
        
        BOOL valid = [[str stringByTrimmingCharactersInSet:alphaNumSet] isEqualToString:@""];
        if( valid == false ) {
            NSRunAlertPanel(@"Error", @"The 'ID' must have only number and letter.", @"Ok", nil, nil);
            return;
        }
        
        str = txtIssuer.stringValue;
        valid = [[str stringByTrimmingCharactersInSet:alphaSet] isEqualToString:@""];
        if( valid == false ) {
            NSRunAlertPanel(@"Error", @"The 'Issuer' must have only letter.", @"Ok", nil, nil);
            return;
        }
        
        str = txtName.stringValue;
        valid = [[str stringByTrimmingCharactersInSet:alphaSet] isEqualToString:@""];
        if( valid == false ) {
            NSRunAlertPanel(@"Error", @"The 'Security Type' must have only letter.", @"Ok", nil, nil);
            return;
        }
        
        str = txtAmount.stringValue;
        valid = [[str stringByTrimmingCharactersInSet:numberExSet] isEqualToString:@""];
        if( valid == false ) {
            NSRunAlertPanel(@"Error", @"The 'Amount tendered' must have only number and comma.", @"Ok", nil, nil);
            return;
        }
        
        if ( _isAdd && [self.delegate respondsToSelector:@selector(isExistInvest:)] == true ) {
            if([self.delegate isExistInvest:txtId.stringValue] == true) {
                NSRunAlertPanel(@"Error", @"The invest ID duplicated.", @"Ok", nil, nil);
                return;
            }
        }
        
        NSTimeInterval diff = [dateEnd timeIntervalSinceDate:dateBegin];
        if( diff < 0.0f ) {
            NSRunAlertPanel(@"Error", @"The End date must later than Start date.", @"Ok", nil, nil);
            return;
        }
        
        if( [self isNumeric:txtPrice.stringValue] == false ) {
            NSRunAlertPanel(@"Error", @"The Price must numeric.", @"Ok", nil, nil);
            return;
        }
        
        self.invest.start = dateBegin;
        self.invest.end = dateEnd;
        
        if( txtId.stringValue.length > 0 )
            self.invest.id = txtId.stringValue;
        
        if( txtName.stringValue.length > 0 )
            self.invest.name = txtName.stringValue;
        
        if( txtIssuer.stringValue.length > 0 )
            self.invest.issuer = txtIssuer.stringValue;
        
        if( txtAmount.stringValue.length > 0 )
            self.invest.amount = txtAmount.stringValue;
        
        if( txtPrice.stringValue.length > 0 )
            self.invest.price = txtPrice.stringValue.floatValue;
        
        if( txtNote.string.length > 0 )
            self.invest.note = txtNote.string;
                
        self.invest.color = (int)btnColor.indexOfSelectedItem;
        self.invest.unit = (int)btnUnit.indexOfSelectedItem;
        
        if( _isAdd ) {
            if ([self.delegate respondsToSelector:@selector(addInvest:)]) {
                [self.delegate addInvest:self];
            }            
        } else {
            if ([self.delegate respondsToSelector:@selector(updateInvest:)]) {
                [self.delegate updateInvest:self];
            }
        }
    }
    
    [[NSApp mainWindow] close];
    if ([self.delegate respondsToSelector:@selector(closeWindow:)]) {
        [self.delegate closeWindow:self];
    }
}

-(IBAction) onChangeColor:(id)sender {
    btnInsert.enabled = YES;
}

#pragma mark - MLCalendar Delegate

- (void) didReminderSelectDate:(NSDate *)selectedDate {
    
    _btnSetting.enabled = NO;
    txtReminder.enabled = NO;
    
    if( reminderCalender.selectedDate ) {
        
        NSString* selDate = [Utility dateToStr:reminderCalender.selectedDate];
        nSelReminder = -1;
        int ix = 0;
        for( Reminder* reminder in self.invest.arrReminders ) {
            if( [selDate isEqualToString:reminder.date] == true ) {
                txtReminder.stringValue = reminder.message;
                nSelReminder = ix;
                break;
            }
            ix++;
        }
        
        if( nSelReminder > -1 ) {
            _btnSetting.title = @"Remove";
            Reminder* reminder = [self.invest.arrReminders objectAtIndex:nSelReminder];
            txtReminder.stringValue = reminder.message;
        } else {
            _btnSetting.title = @"Set";
            txtReminder.stringValue = @"";
        }
        
        _btnSetting.enabled = YES;
        txtReminder.enabled = YES;
    }
    
    if( btnInsert.enabled == false )
        btnInsert.enabled = true;
}

- (void) didSelectDate:(NSDate *)selectedDate {
    
    [calendarPopover close];
    if( calendarType == cal_begine ) {
        txtBegin.stringValue = [Utility dateToStr:selectedDate];
        dateBegin = selectedDate;
    }
    else if( calendarType == cal_end ){
        txtEnd.stringValue = [Utility dateToStr:selectedDate];
        dateEnd = selectedDate;
    }
    
    NSTimeInterval interval = [dateEnd timeIntervalSinceDate:dateBegin];
    int day = interval/3600/24;
    if( day > -1 )
        txtDuration.stringValue = [NSString stringWithFormat:@"%d Days", day];
        
    if( btnInsert.enabled == false )
        btnInsert.enabled = true;
}

#pragma mark - TextField Delegate

- (void)controlTextDidChange:(NSNotification *)notification {
    btnInsert.enabled = YES;
}

#pragma mark - TextView Delegate

-(void)textDidChange:(NSNotification *)notification {
    btnInsert.enabled = YES;
}

@end
