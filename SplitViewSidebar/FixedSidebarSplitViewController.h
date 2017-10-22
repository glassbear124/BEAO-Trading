#import <Cocoa/Cocoa.h>

#import "InsertWindowController.h"
#import "FindWindowController.h"
#import "EnquireWindowController.h"
#import "NotificationWindow.h"
#import "BlueView.h"
#import <sqlite3.h>


@interface FixedSidebarSplitViewController : NSSplitViewController <NSSplitViewDelegate, NSTableViewDelegate, NSTableViewDataSource, InsertWindowDelegate, FindWindowDelegate, EnquireWindowDelegate, BlueViewDelegate, NotificationWindowDelegate> {
    IBOutlet NSSegmentedControl *filterToolbar;
    IBOutlet NSTableView* fileNamesList;
    IBOutlet NSTableView* investList;    
}

@property IBOutlet NSViewController* sidebarViewController ;
@property IBOutlet NSViewController* bodyViewController ;
@property IBOutlet NSView* sidebarView ;
@property IBOutlet NSView* bodyView ;

@property CGFloat fixedWidth ;
@property (assign) sqlite3* curDB;
/* The superclass NSSplitViewController does not declare
 this as an outlet.  I want an outlet for Interface Builder.   Note that,
 in the xib, both outlets 'splitView' and 'view' are connected to the
 same NSSplitView.  Strange, but makes sense, and it works.  */
@property IBOutlet NSSplitView* splitView ;

- (IBAction)collapseSidebar:(id)sender ;
- (IBAction)deleteItem:(id)sender ;
- (IBAction)ZoomInItem:(id)sender ;
- (IBAction)ZoomOutItem:(id)sender ;
- (IBAction)QuestionItem:(id)sender ;

@end
