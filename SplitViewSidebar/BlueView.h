//
//  BlueView.h
//  view to draw calendar graph
//  SplitViewController
//
//

#import <Cocoa/Cocoa.h>

// calendar mode
#define WEEKLY  0
#define MONTHLY 1
#define TERMLY  2
#define YEARLY  3

// width and height
#define hHeader 50
#define wYearCell   30.0f
#define wTermCell    60.0f
#define wWeekCell  70
#define wDayCell   30


@protocol BlueViewDelegate <NSObject>

-(void) selectInvest:(id)sender;
-(void) editInvest:(id)sender;

@end


@interface BlueView : NSView

@property (assign) int viewMode; // 0: week, 1: month, 2: Term, 3: year

@property (nonatomic, retain) NSDate* start;
@property (nonatomic, retain) NSDate* end;

@property (nonatomic, retain) NSView* vParent;

@property (nonatomic, retain) NSMutableArray* arrInvests;
@property (assign) int nCurSel;

@property (retain, nonatomic) id<BlueViewDelegate> delegate;

-(NSDate*) weekFirstDay:(NSDate*)date;

-(void) updateFrame;

@end
