//
//  FindWindowController.m
//  Bear Trading
//
//  Created by Admin on 4/2/17.
//  Copyright © 2017 Xiaosoft. All rights reserved.
//

#import "FindWindowController.h"

#import "InvestInfo.h"
#import "Utility.h"

@interface FindWindowController ()
{
    IBOutlet NSTextField* txtID;
    IBOutlet NSTextField* txtSecurity;
    IBOutlet NSTextField* txtDuration;
    
    IBOutlet NSTextField* lblStart;
    IBOutlet NSTextField* lblEnd;
    
    IBOutlet NSDatePicker* start;
    IBOutlet NSDatePicker* end;
    
    IBOutlet NSButton* chkStart;
    IBOutlet NSButton* chkEnd;
    
    IBOutlet NSTableView* tblInvests;
    NSMutableArray* arrInvests;
    
    IBOutlet NSComboBox* cmbCountry;
}
@end

@implementation FindWindowController


- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)windowWillClose:(NSNotification *)notification
{
    if ([self.delegate respondsToSelector:@selector(closeFindWindow:)]) {
        [self.delegate closeFindWindow:self];
    }
}

-(void) loadWindow{
    [super loadWindow];
    
    if( arrInvests == nil ) {
        arrInvests = [[NSMutableArray alloc] init];
    }
    
    chkStart.state = NSOffState;
    chkEnd.state = NSOffState;
    
    
    lblStart.textColor = [NSColor lightGrayColor];
    lblEnd.textColor = [NSColor lightGrayColor];
    
    start.enabled = NO;
    end.enabled = NO;
    start.dateValue = [NSDate date];
    end.dateValue = [NSDate date];
    
    start.textColor = [NSColor lightGrayColor];
    end.textColor = [NSColor lightGrayColor];
    
    [cmbCountry removeAllItems];
    
    NSString* sql = [NSString stringWithFormat:@"SELECT name FROM main"];
    sqlite3_stmt* pStmt;
    if( sqlite3_prepare_v2(_curDB, [sql UTF8String], -1, &pStmt, NULL) == SQLITE_OK ) {
        while(sqlite3_step(pStmt) == SQLITE_ROW ) {
            NSString *folderName = [NSString stringWithCString:(const char *)sqlite3_column_text(pStmt, 0)
                                                      encoding:NSUTF8StringEncoding];
            [cmbCountry addItemWithObjectValue:folderName];
        }
        sqlite3_finalize(pStmt);
    }
}

-(IBAction) onCheck :(id) sender {
    NSButton* btn = (NSButton*)sender;
    if( btn == chkStart ) {
        if( btn.state == NSOnState ) {
            lblStart.textColor = [NSColor blackColor];
            start.textColor = [NSColor blackColor];
            start.enabled = YES;
        } else {
            lblStart.textColor = [NSColor lightGrayColor];
            start.textColor = [NSColor lightGrayColor];
            start.enabled = NO;
        }
    } else {
        if( btn.state == NSOnState ) {
            lblEnd.textColor = [NSColor blackColor];
            end.textColor = [NSColor blackColor];
            end.enabled = YES;
        } else {
            lblEnd.textColor = [NSColor lightGrayColor];
            end.textColor = [NSColor lightGrayColor];
            end.enabled = NO;
        }
    }
}


-(IBAction) onCancel:(id)sender {
    
    [[NSApp mainWindow] close];
    if ([self.delegate respondsToSelector:@selector(closeFindWindow:)]) {
        [self.delegate closeFindWindow:self];
    }
}

-(IBAction) onSearch:(id)sender {
    
    [arrInvests removeAllObjects];
    NSString* strSearch = @"";
    
    if( txtID.stringValue.length > 0 ) {
        strSearch = [NSString stringWithFormat:@"id='%@'", txtID.stringValue];
    }
    
    if( cmbCountry.stringValue.length > 0 ) {
        
        NSString* sql = [NSString stringWithFormat:@"SELECT id FROM main WHERE name='%@'", cmbCountry.stringValue];
        sqlite3_stmt* pStmt;
        if( sqlite3_prepare_v2(_curDB, [sql UTF8String], -1, &pStmt, NULL) == SQLITE_OK ) {
            sqlite3_step(pStmt);
            
            int ix = -1;
            ix = sqlite3_column_int(pStmt, 0);
            sqlite3_finalize(pStmt);
            if( ix > -1 ) {
                if( strSearch.length > 0 )
                    strSearch = [strSearch stringByAppendingString:@" AND"];
                NSString* cond1 = [NSString stringWithFormat:@" tix=%d", ix];
                strSearch = [strSearch stringByAppendingString:cond1];
            }
        }
    }
    
    if( txtSecurity.stringValue.length > 0 ) {
        if( strSearch.length > 0 )
            strSearch = [strSearch stringByAppendingString:@" AND"];
        NSString* cond1 = [NSString stringWithFormat:@" name='%@'", txtSecurity.stringValue];
        strSearch = [strSearch stringByAppendingString:cond1];
    }
    
    if( chkStart.state == NSOnState ) {
        if( strSearch.length > 0 )
            strSearch = [strSearch stringByAppendingString:@" AND "];
        // DATE(start) >= DATE(strSearch)
        NSString* strStart = [NSString stringWithFormat:@"DATE(start) >= DATE('%@')", [Utility dateToStr:start.dateValue]];
        strSearch = [strSearch stringByAppendingString:strStart];
    }
    
    if( chkEnd.state == NSOnState ) {
        if( strSearch.length > 0 )
            strSearch = [strSearch stringByAppendingString:@" AND "];
        
        NSString* strEnd = [NSString stringWithFormat:@"DATE(end) <= DATE('%@')", [Utility dateToStr:end.dateValue]];
        strSearch = [strSearch stringByAppendingString:strEnd];
    }
    
    if( strSearch.length > 0 ) {
        NSString* sql = [NSString stringWithFormat:@"SELECT * FROM detail WHERE %@", strSearch];
        
        sqlite3_stmt* pStmt;
        if( sqlite3_prepare_v2(_curDB, [sql UTF8String], -1, &pStmt, NULL) == SQLITE_OK ) {
            while( sqlite3_step(pStmt) == SQLITE_ROW ) {
                InvestInfo* invest = [[InvestInfo alloc] init];
                [invest createInvest:pStmt];
                [arrInvests addObject:invest];
            }
            sqlite3_finalize(pStmt);
            [tblInvests reloadData];
        }
    }
}


-(NSInteger) numberOfRowsInTableView:(NSTableView*)tableView {
    return arrInvests.count;
}

- (NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *identifier = tableColumn.identifier;
    NSTableCellView *cell = [tableView makeViewWithIdentifier:identifier owner:self];
    
    InvestInfo* info = [arrInvests objectAtIndex:row];
    if ([identifier isEqualToString:@"number"]) {
        cell.textField.stringValue = [NSString stringWithFormat:@"%d", (int)row+1];
    }
    else if ([identifier isEqualToString:@"info"]) {
        if( info.id != nil )
            cell.textField.stringValue = info.id;
    }
    else if ([identifier isEqualToString:@"name"]) {
        
        if( info.name != nil )
            cell.textField.stringValue = info.name;
    }
    else if ([identifier isEqualToString:@"duration"]) {
        
        NSTimeInterval interval = [info.end timeIntervalSinceDate:info.start];
        int day = interval/3600/24;
        
        cell.textField.stringValue = [NSString stringWithFormat:@"%d Days", day];
    }
    else if ([identifier isEqualToString:@"start"]) {
        cell.textField.stringValue = [info startStr];
    }
    else if ([identifier isEqualToString:@"finish"]) {
        cell.textField.stringValue = [info endStr];
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
    
    if ([self.delegate respondsToSelector:@selector(dblClickItem:)]) {
        [self.delegate dblClickItem:[arrInvests objectAtIndex:sel]];
    }
    [tblInvests deselectRow:sel];
}



@end
