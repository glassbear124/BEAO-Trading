#import "FixedSidebarSplitViewController.h"
#import "NSView+SSYAutoLayout.h"

#import "AppDelegate.h"

#import "MyFileInfo.h"
#import "InvestInfo.h"

#import "MyScrlView.h"
#import "Utility.h"

@implementation FixedSidebarSplitViewController
{
    NSMutableArray* arrFileNames;
    NSMutableArray* arrCurInvests;
    
    NSMutableArray* arrAllInvests;
    
    BlueView* blueView;
    IBOutlet MyScrlView* scrlView;
    
    IBOutlet NSView* bottomTable;
    IBOutlet NSView* topScrol;
    
    FindWindowController* wcFind;
    InsertWindowController* wcInsert;
    EnquireWindowController* wcEnquire;
    NotificationWindow* wcNotification;
    
    IBOutlet NSMenu* recentItem;
    
    NSURL* docPath;
    int folderIx;
}

@synthesize curDB;

/* This is implmented by superclass but not as an IBOutlet, so we need this to
 avoid compiler warning. */
@dynamic splitView ;

/* Because NSSplitViewItem is not available in Interface Builder without using
 Storyboards, we must add our split view items in code, here. */
- (void)viewDidLoad {
    
    NSSplitViewItem* sidebarItem = [[NSSplitViewItem alloc] init] ;
    sidebarItem.viewController = self.sidebarViewController ;  // See Note 1
    [self insertSplitViewItem:sidebarItem atIndex:0] ;
    
    NSSplitViewItem* bodyItem = [[NSSplitViewItem alloc] init] ;
    bodyItem.viewController = self.bodyViewController ;
    [self insertSplitViewItem:bodyItem atIndex:1] ;  // See Note 1.
    
    [super viewDidLoad] ;
    
    arrFileNames = [[NSMutableArray alloc] init];
    
    [Utility setOpenInsert:false];
    [Utility setOpenFind:false];
    [Utility setOpenEnquire:false];
    [Utility setOpenNotification:false];
    
    [self setFixedWidth:150];
    
    blueView = [[BlueView alloc] initWithFrame:NSMakeRect(0, 0, 840, 800)];
    blueView.delegate = self;
    scrlView.documentView = blueView;
    
    scrlView.hidden = YES;
    bottomTable.hidden = YES;
    
    arrAllInvests = [[NSMutableArray alloc] init];
    
    NSApplication *app = [NSApplication sharedApplication];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(applicationWillTerminate:)
     name:NSApplicationWillTerminateNotification object:app];
    
//    [scrlView.contentView setPostsBoundsChangedNotifications:YES];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(boundsDidChange:) name:NSViewBoundsDidChangeNotification object:scrlView.contentView];
//-(void) boundsDidChange : (id)sender {}
    
    NSArray* arr = [[NSDocumentController sharedDocumentController] recentDocumentURLs];
//    NSMenu *fileMenu = [[[NSApp mainMenu] itemAtIndex:1] submenu];
    
    if( arr.count == 0 ) {
//        [fileMenu removeItemAtIndex:2];
    } else {
//        NSMenu* openRecent = [[fileMenu itemAtIndex:2] submenu];
//
        int i = 0;
        for( NSURL* url in arr ) {
            NSString* fileName = [url lastPathComponent];
            NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:fileName action:@selector(loadPage:) keyEquivalent:@""];
            item.tag = i;
            [recentItem insertItem:item atIndex:0];
            i++;
        }
    }
}

-(void) loadPage {
    NSLog( @"ddd");
}

-(void) loadPage:(id)sender {
    NSMenuItem* item = (NSMenuItem*)sender;
    NSArray* arr = [[NSDocumentController sharedDocumentController] recentDocumentURLs];
    NSURL* url = [arr objectAtIndex:item.tag];
    [self openDB:url.absoluteString];
//    NSLog( @"%@", url );
    
}

-(void) applicationWillTerminate : (id) sender {
    [self closeDB];
}


-(void) viewDidAppear {
    [super viewDidAppear];
}

-(BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem {
    
    BOOL enable = NO;
    
    if( [toolbarItem.itemIdentifier isEqualToString:@"toolbar_collapse"] ) {
        enable = YES;
    }
    else if( [toolbarItem.itemIdentifier isEqualToString:@"toolbar_notification"] ) {
        if( arrFileNames.count > 0 ) {
            enable = ![Utility isNotification];
        }
    }
    else if( [toolbarItem.itemIdentifier isEqualToString:@"toolbar_print"]) {
        enable = !scrlView.hidden;
    }
    else if( [toolbarItem.itemIdentifier isEqualToString:@"toolbar_find"] ) {
        if( arrFileNames.count > 0 )
            enable = ![Utility isFind];
        
        if( [Utility isInsert] == true )
            enable = NO;
    }
    else if( [toolbarItem.itemIdentifier isEqualToString:@"toolbar_insert"] ) {
        if( arrFileNames.count > 0) {
            if( fileNamesList.selectedRow == arrFileNames.count - 1 )
                enable = NO;
            else
                enable = ![Utility isInsert];
            
            if( [Utility isFind] == true )
                enable = NO;
        }
    }
    else if( [toolbarItem.itemIdentifier isEqualToString:@"toolbar_delete"] ) {
        if( arrCurInvests != nil && [investList selectedRow] > -1 )
            enable = YES;
    }
    else if( [toolbarItem.itemIdentifier isEqualToString:@"toolbar_zoomin"] ) {
        if( arrFileNames.count > 0 && blueView.viewMode != WEEKLY )
            enable = YES;
    }
    else if( [toolbarItem.itemIdentifier isEqualToString:@"toolbar_zoomout"] ) {
        if( arrFileNames.count > 0 && blueView.viewMode != YEARLY )
            enable = YES;
    }
    else if( [toolbarItem.itemIdentifier isEqualToString:@"toolbar_question"] ) {
        enable = ![Utility isEnquire];
    }
    return enable;
}

- (void)setFixedWidth:(CGFloat)width {
    /* Apparently, NSSplitView uses Auto Layout to set minimum and maximum
     thickness, because without the following line, we get "can't
     simulatenously satisfy constraints exceptions from Auto Layout in the
     sequel.  It is not only because of our initial setting in Interface
     Builder.  For example, if you remove the following line, build, run and
     change the Fixed Width field in the user interface from -1 to 200 you
     get an Auto Layout exception as expected.  But then if you change it from
     200 to 300 you also get an Auto Layout exception.  Seems like this is 
     a bug, that maybe Apple should have built -removeWidthConstraints into
     -setMinimumThickness: and setMaximumThickness:.  NSSplitViewItem would
     need access to its view in order to do that and, it looks like it does
     not have that. */
    [self.sidebarView removeWidthConstraints] ;
    
    [[self.splitViewItems firstObject] setMinimumThickness:width] ;
    [[self.splitViewItems firstObject] setMaximumThickness:width] ;
}

- (CGFloat)fixedWidth {
    return [self.splitViewItems firstObject].minimumThickness ;
    /* Should get same answer with maximum thickness, unless fixedWidth has
     never been set, then you'll get NSSplitViewItemUnspecifiedDimension,
     which is apparently -1.0 */
}

/* Needed so that the initial value, NSSplitViewItemUnspecifiedDimension = -1,
 is displayed in the user interface when the app launches, because the
 splitViewItems does not get populated until after Cocoa Bindings does its
 initial 'get'. */
+ (NSSet*)keyPathsForValuesAffectingFixedWidth {
    return [NSSet setWithObjects:@"splitViewItems", nil] ;
}

-(void) setTitle {
    NSString *fileName = [[[docPath absoluteString] lastPathComponent] stringByDeletingPathExtension];
    self.view.window.title = [NSString stringWithFormat:@"BEAO portfolio management - %@", fileName];
}

#pragma mark - SQLite

-(bool) createTable {
    
    // create main table
    NSString* format = @"CREATE TABLE main (id INTEGER PRIMARY KEY AUTOINCREMENT, name VARCHAR)";
    const char* sql_stmt1 = [format UTF8String];
    char *errMsg;
    if (sqlite3_exec(curDB, sql_stmt1, NULL, NULL, &errMsg) != SQLITE_OK) {
        return false;
    }
    
    
    // create detail table
    format = @"CREATE TABLE detail"
    "(id VARCHAR PRIMARY KEY, tix INTEGER, name VARCHAR, issuer VARCHAR, amount VARCHAR, price FLOAT, "
    "start VARCHAR, end VARCHAR, color INTEGER, unit INTEGER, note TEXT, reminder_date VARCHAR, reminder_message TEXT)";
    const char* sql = [format UTF8String];
    if (sqlite3_exec(curDB, sql, NULL, NULL, &errMsg) != SQLITE_OK) {
        return false;
    }
    return true;
}

-(bool) newDB {
    
    if( docPath == nil )
        return false;
    
    curDB = nil;
    const char *dbpath = [docPath.absoluteString UTF8String];
    if (sqlite3_open(dbpath, &curDB) == SQLITE_OK) {
        if( [self createTable] == true ) {
            [self folderNameDialog];
            [self setTitle];
        }
        return true;
    }
    return false;
}

-(void) closeDB {
    if( curDB ) {
        sqlite3_close(curDB); curDB = nil;
    }
}

-(bool) isExistFolder : (NSString*) folder {
    NSString* sql = [NSString stringWithFormat:@"SELECT * FROM main WHERE name='%@'", folder];
    sqlite3_stmt * pStmt;
    sqlite3_prepare(curDB, [sql UTF8String], -1, &pStmt, NULL);
    sqlite3_step(pStmt);
    int i = sqlite3_column_int(pStmt, 0);
    sqlite3_finalize(pStmt);
    return ( i > 0 );
}

-(int) addFolderDB : (NSString*)folderName {
    if( curDB == nil )
        return -1;
    
    sqlite3_stmt    *statement;
    NSString* sql = [NSString stringWithFormat:@"INSERT INTO main (name) VALUES (\"%@\")", folderName];
    sqlite3_prepare_v2( curDB, [sql UTF8String], -1, &statement, NULL);
    if (sqlite3_step(statement) != SQLITE_DONE)
        return -1;
    sqlite3_finalize(statement);
    
    sql = [NSString stringWithFormat:@"SELECT MAX(id) FROM main"];
    if( sqlite3_prepare(curDB, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK && sqlite3_step(statement) == SQLITE_ROW ) {
        int ix = sqlite3_column_int(statement, 0);
        sqlite3_finalize(statement);
        return ix;
    }
    return 0;
}

-(bool) isExistInvest:(NSString*)sID {
    
    if( curDB == nil )
        return false;
    NSString* sql = [NSString stringWithFormat:@"SELECT * FROM detail WHERE id='%@'", sID];
    sqlite3_stmt * pStmt;
    sqlite3_prepare(curDB, [sql UTF8String], -1, &pStmt, NULL);
    sqlite3_step(pStmt);
    int i = sqlite3_column_int(pStmt, 0);
    sqlite3_finalize(pStmt);
    return (i>0);
}


-(bool) deleteFolderDB : (NSString*) folderName {
    
    if( curDB == nil )
        return false;
    
    sqlite3_stmt* statement;
    NSString* stmt = [NSString stringWithFormat:@"SELECT id FROM main WHERE name='%@'", folderName];
    int retVal = sqlite3_prepare_v2(curDB, [stmt UTF8String], -1, &statement, NULL);
    if( retVal != SQLITE_OK )
        return false;
    
    sqlite3_step(statement);
    int ix = sqlite3_column_int(statement, 0);
    
    // all invest delete from detail.
    stmt = [NSString stringWithFormat:@"DELETE FROM detail WHERE tix=%d", ix];
    if( sqlite3_prepare_v2( curDB, [stmt UTF8String], -1, &statement, nil) == SQLITE_OK ){
        if (sqlite3_step(statement) == SQLITE_DONE ){
            NSLog(@"Successfully deleted row.");
        } else {
            NSLog(@"Could not delete row.");
        }
    } else {
        NSLog(@"DELETE statement could not be prepared");
    }
    sqlite3_finalize(statement);

    // delete item from main
    stmt = [NSString stringWithFormat:@"DELETE FROM main WHERE id=%d", ix];
    if( sqlite3_prepare_v2( curDB, [stmt UTF8String], -1, &statement, nil) == SQLITE_OK ){
        if (sqlite3_step(statement) == SQLITE_DONE ){
            sqlite3_finalize(statement);
            return true;;
        }
    }
    sqlite3_finalize(statement);
    return false;
}



-(void) openDB : (NSString*) databasePath {
    const char* dbPath = [databasePath UTF8String];
    curDB = nil;
    if (sqlite3_open(dbPath, &curDB) != SQLITE_OK)
        return;
      
    sqlite3_stmt* statement;
    NSString *query = @"SELECT * FROM main ORDER BY id";
    int retVal = sqlite3_prepare_v2(curDB, [query UTF8String], -1, &statement, NULL);
    
    [arrFileNames removeAllObjects];
    if ( retVal == SQLITE_OK ) {
        int i = 0;
        while(sqlite3_step(statement) == SQLITE_ROW ) {
            
            int ix = sqlite3_column_int(statement, 0);
            NSString *folderName = [NSString stringWithCString:(const char *)sqlite3_column_text(statement, 1)
                                                 encoding:NSUTF8StringEncoding];
            [self addFolderUI:folderName:ix];
            if( i == 0 ) {
                [self retrieveRecordsByFolderIx:0];
            }
            i++;
        }
    }
    sqlite3_clear_bindings(statement);
    sqlite3_finalize(statement);
}

-(void) insertRecord : (InvestInfo*) invest{
    
    if( curDB == nil )
        return;
    
    sqlite3_stmt    *statement;
    NSString* format = @"INSERT INTO detail "
        "(id, tix, name, issuer, amount, price, start, end, color, unit, note, reminder_date, reminder_message) "
        "VALUES ('%@', %d, '%@', '%@', '%@', %f, '%@', '%@', %d, %d, '%@', '%@', '%@')";
    
    NSString *insertSQL = [NSString stringWithFormat:format,
                           invest.id, invest.tIx, invest.name, invest.issuer, invest.amount, invest.price,
                           [invest startStr],
                           [invest endStr], invest.color, invest.unit, invest.note,
                           [invest getReminderDate], [invest getReminderMessage] ];
    
    sqlite3_prepare_v2( curDB, [insertSQL UTF8String], -1, &statement, NULL);
    if (sqlite3_step(statement) == SQLITE_DONE)
    {
        // add ok
        NSLog( @"insert record ok" );
    } else {
        NSLog( @"insert record fail" );
        // add fail
    }
    sqlite3_finalize(statement);
}

-(void) retrieveRecords {
    [arrAllInvests removeAllObjects];
    
    NSString *querySQL = @"SELECT * FROM detail";
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(curDB ,[querySQL UTF8String] , -1, &statement, NULL) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            InvestInfo *invest = [[InvestInfo alloc] init];
            [invest createInvest:statement];
            [arrAllInvests addObject:invest];
        }
        sqlite3_finalize(statement);
    }
}

-(void) retrieveRecordsByFolderIx : (int) ix {
    MyFileInfo* info = [arrFileNames objectAtIndex:ix];
    [info.arrInvests removeAllObjects];
    
    NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM detail WHERE tix=%d", info.ix];
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(curDB ,[querySQL UTF8String] , -1, &statement, NULL) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            InvestInfo *invest = [[InvestInfo alloc] init];
            [invest createInvest:statement];
            [info.arrInvests addObject:invest];
        }
        sqlite3_finalize(statement);
    }
}

-(void) deleteRecord: (InvestInfo*)invest {
    if( curDB == nil )
        return;
    
    sqlite3_stmt    *statement;
    NSString* strSql = [NSString stringWithFormat:@"DELETE FROM detail WHERE id='%@'", invest.id];
    const char* query_stmt = [strSql UTF8String];
    if( sqlite3_prepare_v2( curDB, query_stmt, -1, &statement, nil) == SQLITE_OK ){
        if (sqlite3_step(statement) == SQLITE_DONE ){
            NSLog(@"Successfully deleted row.");
        } else {
            NSLog(@"Could not delete row.");
        }
    } else {
        NSLog(@"DELETE statement could not be prepared");
    }
    sqlite3_finalize(statement);
}

-(void) updateRecord: (InvestInfo*)invest {
    
    if( curDB == nil )
        return;
    
    NSString *updateQuery = [NSString stringWithFormat:@"UPDATE detail SET 'name'=?, 'issuer'=?, 'amount'=?, 'price'=?, 'start'=?, 'end'=?, 'color'=?, 'unit'=?, 'note'=?, "
                                                        "'reminder_date'=?, 'reminder_message'=? WHERE id='%@'", invest.id];
    sqlite3_stmt *stmt;
    // Prepare Stment
    const char* szQuery = [updateQuery UTF8String];
    if (sqlite3_prepare_v2( curDB, szQuery, -1, &stmt, NULL) == SQLITE_OK) {
        
        sqlite3_bind_text(stmt, 1, [invest.name UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 2, [invest.issuer UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 3, [invest.amount UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_double(stmt, 4, invest.price);
        sqlite3_bind_text(stmt, 5, [[invest startStr] UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 6, [[invest endStr] UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(stmt, 7, invest.color);
        sqlite3_bind_int(stmt, 8, invest.unit);
        sqlite3_bind_text(stmt, 9, [invest.note UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 10, [[invest getReminderDate] UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(stmt, 11, [[invest getReminderMessage] UTF8String], -1, SQLITE_TRANSIENT);
        
        if(sqlite3_step(stmt) == SQLITE_DONE) {
            NSLog(@"Query Executed");
        } else {
            NSLog(@"Query NOT Executed: %s", sqlite3_errmsg(curDB));
        }
        sqlite3_finalize(stmt);
        
    }else{
        NSLog(@"Statement NOT Prepared: %s", sqlite3_errmsg(curDB));
    }
}


#pragma mark - menu delegate

-(IBAction) onFileNew:(id)sender {
    
//    NSString* path = @"file:///Volumes/Work/Untitled.sheet";
//    [self newDB:path];
    
    NSSavePanel*    savePanel = [NSSavePanel savePanel];
    [savePanel setNameFieldStringValue:@"Untitled"];
    NSArray * buttonItems = [[NSArray alloc] initWithObjects:@"sheet", nil];
    [savePanel setAllowedFileTypes:buttonItems];
    
    [savePanel beginSheetModalForWindow:self.view.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            [savePanel orderOut:nil];
            NSError * error = nil;
            [[NSFileManager defaultManager] removeItemAtURL:savePanel.URL error:&error];
            docPath = savePanel.URL;
            if( [self newDB] == false ) {
                NSRunAlertPanel(@"Error", @"Can't create Sheet file.", @"Ok", nil, nil);
                return;
            }
        }
    }];
}



-(IBAction) onFileOpen:(id)sender {
    
//    NSString* path = @"file:///Volumes/Work/new.sheet";
//    [self openDB:path];
    
    NSOpenPanel * openPanel = [NSOpenPanel openPanel];
    openPanel.allowsMultipleSelection = NO;
    [openPanel beginSheetModalForWindow:self.view.window completionHandler: ^(NSInteger code) {
        if (code != NSModalResponseOK)
            return;
        docPath = openPanel.URL;
        [self setTitle];
        
        [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:docPath];
        
        [self openDB:docPath.absoluteString];
    }];
}

-(IBAction) onFileSaveAs:(id)sender {
    
}

#pragma mark - Toolbar delegate

- (IBAction)collapseSidebar:(id)sender {
    
    BOOL isCollapsed = [[[[self splitViewItems] firstObject] animator] isCollapsed];
    
    [[[[self splitViewItems] firstObject] animator] setCollapsed:!isCollapsed];
    
    NSToolbarItem* item = (NSToolbarItem*)sender;
    
    if( isCollapsed == YES ) {
        item.image = [NSImage imageNamed:@"collapse.png"];
        item.label = @"Collapse";
    } else {
        item.image = [NSImage imageNamed:@"expand.png"];
        item.label = @" Expand ";
    }
}

-(IBAction)inserItem:(id)sender {
    
    if( [Utility isInsert] == NO ) {
        wcInsert = [[InsertWindowController alloc] initWithWindowNibName:@"InsertWindowController"];
        wcInsert.delegate = self;
        wcInsert.invest = [[InvestInfo alloc] init];
        [wcInsert loadWindow];
        [Utility setOpenInsert:YES];
    }
    wcInsert.isAdd = true;
    
    [wcInsert showWindow:nil];
    [wcInsert.window makeKeyAndOrderFront:nil];
    
    [investList deselectRow:investList.selectedRow];
    blueView.nCurSel = -1;
    
    scrlView.needsDisplay = YES;
}

- (IBAction)deleteItem:(id)sender{
    
    NSInteger i = investList.selectedRow;
    if( i < 0 || arrCurInvests.count == 0 )
        return;
    
    InvestInfo* invest = [arrCurInvests objectAtIndex:i];
    [self deleteRecord:invest];
    
    [arrCurInvests removeObjectAtIndex:i];
    [investList reloadData];
    scrlView.needsDisplay = YES;
}

- (IBAction)ZoomInItem:(id)sender {
    if( blueView.viewMode > 0 ) {
        blueView.viewMode--;
        [blueView updateFrame];
        scrlView.needsDisplay = YES;
    }
}

- (IBAction)ZoomOutItem:(id)sender {
    if( blueView.viewMode < 3 ) {
        blueView.viewMode++;
        [blueView updateFrame];
        scrlView.needsDisplay = YES;
    }
}

-(IBAction)onPrint:(id)sender {
    [blueView print:self];
    scrlView.needsDisplay = YES;
}

-(IBAction) onNotification:(id)sender {
    if( [Utility isNotification] == NO ) {
        wcNotification = [[NotificationWindow alloc] initWithWindowNibName:@"NotificationWindow"];
        wcNotification.curDB = curDB;
        wcNotification.delegate = self;
        [wcNotification loadWindow];
        [Utility setOpenNotification:YES];
    }
}

- (IBAction) FindItem:(id) sender {
    
    if( [Utility isFind] == NO ) {
        wcFind = [[FindWindowController alloc] initWithWindowNibName:@"FindWindow"];
        wcFind.delegate = self;
        wcFind.curDB = curDB;
        [wcFind loadWindow];
        [Utility setOpenFind:YES];
    }
    [wcFind showWindow:nil];
    [wcFind.window makeKeyAndOrderFront:nil];
}

- (IBAction)QuestionItem:(id)sender {

    if( [Utility isEnquire] == NO ) {
        wcEnquire = [[EnquireWindowController alloc] initWithWindowNibName:@"EnquireWindow"];
        wcEnquire.delegate = self;
        [wcEnquire loadWindow];
        [Utility setOpenEnquire:YES];
    }
}

-(void) initScroll {
    NSPoint newScrollOrigin;
    if (  blueView.isFlipped ) {
        newScrollOrigin=NSMakePoint(0, 0);
    } else {
        newScrollOrigin=NSMakePoint(0, NSMaxY(scrlView.documentView.frame) - NSHeight(scrlView.contentView.bounds) );
    }
    
    [blueView scrollPoint:newScrollOrigin];
    [scrlView reflectScrolledClipView:scrlView.contentView];
}

-(void) addFolderUI : (NSString*)folderName :(int)ix{
    
    if( arrFileNames.count == 0 ) {
        MyFileInfo* info = [[MyFileInfo alloc] init];
        info.name = @"All Entries";
        [arrFileNames addObject:info];
    }
    
    MyFileInfo* info = [[MyFileInfo alloc] init];
    info.name = folderName;
    info.ix = ix;
    [arrFileNames insertObject:info atIndex:(arrFileNames.count-1)];
    [fileNamesList reloadData];
    
    if( arrFileNames.count == 2 ) {
        scrlView.hidden = NO;
        bottomTable.hidden = NO;
        blueView.arrInvests = info.arrInvests;
        arrCurInvests = info.arrInvests;
        blueView.frame = NSMakeRect(0, 0, 840, 800);
        [self initScroll];
    }
}

-(void) folderNameDialog {
    NSAlert *alert = [NSAlert alertWithMessageText:@"Folder Name:"
                                     defaultButton:@"Add"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 350, 24)];
    input.stringValue = @"";
    alert.accessoryView = input;
    NSInteger button = [alert runModal];
    if( button == NSModalResponseOK ) {
        if( input.stringValue.length == 0 ) {
            NSRunAlertPanel(@"Error", @"The Folder name is empty.", @"Ok", nil, nil);
            return;
        }
        
        NSString* folderName = input.stringValue;
        if( [self isExistFolder:folderName] == true ) {
            NSRunAlertPanel(@"Error", @"The duplicated Folder name.", @"Ok", nil, nil);
            return;
        }
        
        int ix = [self addFolderDB:folderName];
        if( ix > 0 )
            [self addFolderUI:folderName: ix];
    }
}

- (IBAction)filterToolbarClicked:(NSSegmentedControl*)sender
{
    
    if( curDB == nil ) {
        NSRunAlertPanel(@"Error", @"Please create database before to create folder.", @"Ok", nil, nil);
        return;
    }
    
    switch ( sender.selectedSegment ) {
        case 0:
            [self folderNameDialog];
        break;
            
        case 1: {
            NSInteger i =  fileNamesList.selectedRow;
            if( i < 0 || arrFileNames.count == 0 )
                return;
            
            if( i == arrFileNames.count - 1 ) {
                NSRunAlertPanel(@"Error", @"The \"All Entries\" folder can't delete.", @"Ok", nil, nil);
                return;
            }
            
            NSInteger answer = NSRunAlertPanel(@"Confirm", @"All investment for this file will remove.\nDo you really this file?", @"Cancel", @"Ok", nil);
            if( answer != NSAlertDefaultReturn ) {
                
                MyFileInfo* info = [arrFileNames objectAtIndex:i];
                if( [self deleteFolderDB:info.name] == true ) {
                    [arrFileNames removeObjectAtIndex:i];
                    if( arrFileNames.count == 1 ) {
                        [arrFileNames removeAllObjects];
                        scrlView.hidden = YES;
                        bottomTable.hidden = YES;
                        blueView.arrInvests = nil;
                        arrCurInvests = nil;
                    }
                    [fileNamesList reloadData];
                }
            }
        }
        break;
            
        default:
            break;
    }
}

#pragma mark - TableView Delegate
-(NSInteger) numberOfRowsInTableView:(NSTableView*)tableView {
    if( tableView == fileNamesList )
        return arrFileNames.count;
    else
        return arrCurInvests.count;
}

- (NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *identifier = tableColumn.identifier;
    NSTableCellView *cell = [tableView makeViewWithIdentifier:identifier owner:self];
    
    if ( tableView == fileNamesList ) {
        MyFileInfo* obj = [arrFileNames objectAtIndex:row];
        cell.textField.stringValue = obj.name;
    } else  {
        InvestInfo* info = [arrCurInvests objectAtIndex:row];
        if ([identifier isEqualToString:@"number"]) {
            cell.textField.stringValue = [NSString stringWithFormat:@"%d", (int)row+1];
        }
        else if ([identifier isEqualToString:@"info"] && info.id != nil ) {
            cell.textField.stringValue = info.id;
        }
        else if ([identifier isEqualToString:@"name"] && info.name != nil ) {
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
    }
    return cell;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    
    if( tableView == fileNamesList ) {
        
        if( row < arrFileNames.count - 1 ) {
            if( arrAllInvests.count > 1 )
               [arrAllInvests removeAllObjects];
            MyFileInfo* info = [arrFileNames objectAtIndex:row];
            [self retrieveRecordsByFolderIx:(int)row];
            arrCurInvests = info.arrInvests;
            
        } else {
            [self retrieveRecords];
            arrCurInvests = arrAllInvests;
        }
        
        blueView.viewMode = WEEKLY;
        blueView.arrInvests = arrCurInvests;
        [blueView updateFrame];

        [self reDrawBlueView];
    } else {
        blueView.nCurSel = (int)row;
        scrlView.needsDisplay = YES;
    }
    return YES;
}

-(IBAction) onClick:(id)sender {
    NSInteger sel = [investList selectedRow];
    if( sel < 0 ) {
        blueView.nCurSel = -1;
        scrlView.needsDisplay = YES;
    }
}

-(IBAction) onDoubleClick:(id) sender {

    NSInteger sel = [investList selectedRow];
    if( sel < 0 )
        return;
    
    if( [Utility isInsert] == NO ) {
        wcInsert = [[InsertWindowController alloc] initWithWindowNibName:@"InsertWindowController"];
        wcInsert.delegate = self;
        [wcInsert loadWindow];
        [Utility setOpenInsert:YES];
    }
    
    wcInsert.isAdd = false;
    wcInsert.invest = [arrCurInvests objectAtIndex:sel];
    
    [wcInsert showWindow:nil];
    [wcInsert.window makeKeyAndOrderFront:nil];
        
    [investList deselectRow:sel];
    blueView.nCurSel = -1;
    scrlView.needsDisplay = YES;
}

-(void) reDrawBlueView {
    [investList reloadData];
    
    NSDate* dateStart = [NSDate date];
    NSDate* dateEnd = [NSDate date];
    
    for( InvestInfo* info in arrCurInvests ) {
        if( [dateStart compare:info.start] == NSOrderedDescending )
            dateStart = info.start;
        
        if( [dateEnd compare:info.end] == NSOrderedAscending )
            dateEnd = info.end;
    }
    
    blueView.start = [blueView weekFirstDay:dateStart];
    blueView.end = dateEnd;
    
    [blueView updateFrame];
    scrlView.needsDisplay = YES;
}

#pragma mark - EnquireWindow Delegate
-(void) closeEnquireWindow:(id)sender {
    [Utility setOpenEnquire:false];
}

#pragma mark - InsertWindow Delegate

-(void) updateInvest:(id)sender {
    InsertWindowController* insert = (InsertWindowController*)sender;
    [self updateRecord:insert.invest];
    [self reDrawBlueView];
}

-(void) closeWindow:(id)sender {
    [Utility setOpenInsert:NO];
}

-(void) addInvest:(id)sender {
    InsertWindowController* insert = (InsertWindowController*)sender;
    MyFileInfo* curInfo = [arrFileNames objectAtIndex:[fileNamesList selectedRow]];
    insert.invest.tIx = curInfo.ix;
    [arrCurInvests addObject:insert.invest];
    
    [self insertRecord:insert.invest];
    [self reDrawBlueView];
}


#pragma mark - FindWindow Delegate
-(void) closeFindWindow:(id)sender {
    [Utility setOpenFind:NO];
}

-(void) dblClickItem:(id)sender {
    wcInsert = [[InsertWindowController alloc] initWithWindowNibName:@"InsertWindowController"];
    wcInsert.delegate = self;
    [wcInsert loadWindow];
    wcInsert.isAdd = false;
    wcInsert.invest = (InvestInfo*)sender;
    [wcInsert showWindow:nil];
    [wcInsert.window makeKeyAndOrderFront:nil];
}

#pragma mark - NotificationWindow Delegate
-(void) closeNotificationWindow:(id)sender {
    [Utility setOpenNotification:NO];
}

-(void) dblNotiClickItem:(id)sender {
    
}


#pragma mark - BlueView Delegate
-(void) selectInvest:(id)sender {
    int sel = blueView.nCurSel;
    if( sel > -1 ) {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:sel];
        [investList selectRowIndexes:indexSet byExtendingSelection:NO];
    } else {
        [investList deselectRow:[investList selectedRow]];
    }
}

-(void) editInvest:(id)sender {
    int sel = blueView.nCurSel;
    if( [Utility isInsert] == NO ) {
        wcInsert = [[InsertWindowController alloc] initWithWindowNibName:@"InsertWindowController"];
        wcInsert.delegate = self;
        [wcInsert loadWindow];
        [Utility setOpenInsert:YES];
    }
    
    wcInsert.isAdd = false;
    wcInsert.invest = [arrCurInvests objectAtIndex:sel];
    
    [wcInsert showWindow:nil];
    [wcInsert.window makeKeyAndOrderFront:nil];
    
    [investList deselectRow:sel];
    blueView.nCurSel = -1;
    scrlView.needsDisplay = YES;
}

@end
