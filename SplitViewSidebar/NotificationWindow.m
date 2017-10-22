//
//  FindWindowController.m
//  Bear Trading
//
//  Created by Admin on 4/2/17.
//  Copyright © 2017 Xiaosoft. All rights reserved.
//

#import "NotificationWindow.h"

#import "InvestInfo.h"
#import "Reminder.h"
#import "MyFileInfo.h"
#import "Utility.h"

@interface NotificationWindow ()
{
    IBOutlet NSTextField* lblStart;
    IBOutlet NSButton* chkStart;
    IBOutlet NSTableView* tblInvests;
    NSMutableArray* arrInvests;
    NSMutableArray* arrCountries;
    
    NSArray *sortedArray;
}
@end

@implementation NotificationWindow


- (void)windowDidLoad {
    [super windowDidLoad];
}

- (void)windowWillClose:(NSNotification *)notification
{
    if ([self.delegate respondsToSelector:@selector(closeNotificationWindow:)]) {
        [self.delegate closeNotificationWindow:self];
    }
}

-(void) loadWindow{
    [super loadWindow];
    
    if( arrInvests == nil ) {
        arrInvests = [[NSMutableArray alloc] init];
    } else {
        [arrInvests removeAllObjects];
    }
    
    
    if( arrCountries == nil ) {
        arrCountries = [[NSMutableArray alloc] init];
    }
    [arrCountries removeAllObjects];
    
    chkStart.state = NSOffState;
    lblStart.textColor = [NSColor lightGrayColor];
    
    // load all country names from main
    NSString* sql = [NSString stringWithFormat:@"SELECT * FROM main"];
    sqlite3_stmt* pStmt;
    if( sqlite3_prepare_v2(_curDB, [sql UTF8String], -1, &pStmt, NULL) == SQLITE_OK ) {
        while( sqlite3_step(pStmt) == SQLITE_ROW ) {
            MyFileInfo* conutry = [[MyFileInfo alloc] init];
            conutry.ix = sqlite3_column_int(pStmt, 0);  // id filed of main
            const char* pName = (const char*)sqlite3_column_text(pStmt,1); // name field of main
            if( !strcmp(pName, "(null)") )
                conutry.name = @"";
            else
                conutry.name = [[NSString alloc] initWithUTF8String:pName];
            [arrCountries addObject:conutry];
        }
        sqlite3_finalize(pStmt);
    }
    
    
    // load all reminders from detail
    sql = [NSString stringWithFormat:@"SELECT * FROM detail WHERE reminder_date"];
    if( sqlite3_prepare_v2(_curDB, [sql UTF8String], -1, &pStmt, NULL) == SQLITE_OK ) {
        while( sqlite3_step(pStmt) == SQLITE_ROW ) {
            InvestInfo* invest = [[InvestInfo alloc] init];
            [invest createInvest:pStmt];
            
            for( Reminder* reminder in invest.arrReminders ) {
                reminder.ID = invest.id;
                reminder.name = invest.name;
                // get country name;
                for( MyFileInfo* country in arrCountries ) {
                    if( country.ix == invest.tIx ) {
                        reminder.country = country.name;
                        break;
                    }
                }
                [arrInvests addObject:reminder];
            }
        }
        sqlite3_finalize(pStmt);
        
        // sorting notification by date
        sortedArray = [arrInvests sortedArrayUsingComparator:^NSComparisonResult(Reminder *p1, Reminder *p2){
            return [p1.date compare:p2.date];
            
        }];
        [tblInvests reloadData];
    }
}


-(IBAction) onCheck :(id) sender {
    NSButton* btn = (NSButton*)sender;
    if( btn == chkStart ) {
        if( btn.state == NSOnState ) {
            lblStart.textColor = [NSColor blackColor];
        } else {
            lblStart.textColor = [NSColor lightGrayColor];
        }
    }
}


-(IBAction) onCancel:(id)sender {
    
    [[NSApp mainWindow] close];
    if ([self.delegate respondsToSelector:@selector(closeNotificationWindow:)]) {
        [self.delegate closeNotificationWindow:self];
    }
}

-(NSInteger) numberOfRowsInTableView:(NSTableView*)tableView {
    return sortedArray.count;
}

- (NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *identifier = tableColumn.identifier;
    NSTableCellView *cell = [tableView makeViewWithIdentifier:identifier owner:self];
    
    Reminder* info = [sortedArray objectAtIndex:row];
    if ([identifier isEqualToString:@"number"]) {
        cell.textField.stringValue = [NSString stringWithFormat:@"%d", (int)row+1];
    }
    else if ([identifier isEqualToString:@"date"]) {
        cell.textField.stringValue = info.date;
    }
    else if ([identifier isEqualToString:@"message"]) {
        
        if( info.message != nil )
            cell.textField.stringValue = info.message;
    }
    else if ([identifier isEqualToString:@"id"]) {
        cell.textField.stringValue = info.ID;
    }
    else if( [identifier isEqualToString:@"country"] ) {
        cell.textField.stringValue = info.country;
    }
    else if ([identifier isEqualToString:@"name"]) {
        cell.textField.stringValue = info.name;
    }
    return cell;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {    
    return YES;
}

-(IBAction) onDoubleClick:(id) sender {
    
    NSInteger sel = [tblInvests selectedRow];
    if( sel < 0 )
        return;
    
    if ([self.delegate respondsToSelector:@selector(dblNotiClickItem:)]) {
        [self.delegate dblNotiClickItem:[sortedArray objectAtIndex:sel]];
    }
    [tblInvests deselectRow:sel];
}



@end
