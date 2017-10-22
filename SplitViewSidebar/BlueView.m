#import "BlueView.h"
#import "Utility.h"
#import "InvestInfo.h"

@implementation BlueView
{
    NSPoint points[4];
    NSUInteger pointCount;
    
    NSMutableParagraphStyle * paragraphStyle;
    NSBezierPath* dotPath;
    NSBezierPath* dotPathGreen;
    
    NSDictionary *attributes1;
    NSDictionary *attributes2;
    NSDictionary *attributes3;
    
    NSCalendar *calWeek;
    
    NSDate* today;
    NSCalendar* currentCalendar;
    
    CGFloat w, h;
    
    NSInteger todayMonth, todayYear, todayDay;
    NSInteger startMonth, startYear, startDay;
    
    NSInteger monthForQ; // month for Qtr
    NSInteger monthForY; // month for Year
    
    NSMutableArray* arrBarRects;
}

CGFloat pattern[] = {2, 1};

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initValue];
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if( self ) {
        [self initValue];
    }
    return self;
}

-(void) initValue {
    paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    attributes1 = [NSDictionary dictionaryWithObjectsAndKeys:
                   [NSFont fontWithName:@"Helvetica" size:15], NSFontAttributeName,
                   [NSColor blackColor], NSForegroundColorAttributeName, nil];
    
    attributes2 = [NSDictionary dictionaryWithObjectsAndKeys:
                   [NSFont fontWithName:@"Helvetica-Light" size:13], NSFontAttributeName,
                   paragraphStyle, NSParagraphStyleAttributeName,
                   [NSColor blackColor], NSForegroundColorAttributeName, nil];
    
    attributes3 = [NSDictionary dictionaryWithObjectsAndKeys:
                   [NSFont fontWithName:@"Helvetica" size:13], NSFontAttributeName,
                   paragraphStyle, NSParagraphStyleAttributeName,
                   [NSColor redColor], NSForegroundColorAttributeName, nil];
    
    calWeek = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    calWeek.firstWeekday = 1;// set first week day to Monday
    // 1: Sunday, 2: Monday, ..., 7:Saturday
    
    currentCalendar = NSCalendar.currentCalendar;
    
    _nCurSel = -1;
    
    _start = [NSDate date];
    _end   = [NSDate date];
    
    arrBarRects = [[NSMutableArray alloc] init];
}

-(void) updateFrame {
    
    CGFloat height = 800;
    if( _arrInvests && _arrInvests.count > 30 ) {
        height = hHeader + 25 * _arrInvests.count;
    }
    
    CGFloat width = 0;
    NSInteger cellCnt = 0;
    NSDateComponents*  comp;
    if( _viewMode == WEEKLY || _viewMode == MONTHLY ) {
        
        comp = [currentCalendar components:NSWeekCalendarUnit
                                  fromDate:self.start
                                    toDate:self.end
                                   options:0];
        cellCnt = comp.week + 1 ;
        if( _viewMode == WEEKLY ) {
            width = cellCnt * wDayCell * 7;
        }
        else
            width = cellCnt * wWeekCell;
        
        if( width < 840 )
            width = 840;
    }
    else {

        comp = [currentCalendar components:NSMonthCalendarUnit
                                  fromDate:self.start
                                    toDate:self.end
                                   options:0];
        cellCnt = comp.month + 1;
        
        CGFloat limit = 840;
        if( _viewMode == TERMLY ) {
            width = cellCnt * wTermCell;
        } else {
            width = cellCnt * wYearCell;
            limit = 870;
        }
        
        if( width < limit )
            width = limit;
    }
    self.frame = NSMakeRect(0, 0, width, height );
}

- (void)drawRect:(NSRect)dirtyRect {
    
    NSRect bounds = self.bounds;
    [super drawRect:bounds];
    
    today = [NSDate date];
    
    NSDateComponents* components = [currentCalendar components:NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitDay fromDate:today];
    todayMonth = components.month;
    todayYear  = components.year;
    todayDay   = components.day;
    
    components = [currentCalendar components:NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitDay fromDate:self.start];
    startMonth = components.month;
    startYear  = components.year;
    startDay   = components.day;
    
    w = self.frame.size.width;
    h = self.frame.size.height;
    
    [[NSColor whiteColor] set];
    [NSBezierPath fillRect:self.frame];
    
    [self drawGreyRect:NSMakeRect(0, h-hHeader, w, hHeader)];
    [self drawGreyRect:NSMakeRect(0, h-hHeader/2, w, 1)];
    
    dotPath = [NSBezierPath bezierPath];
    [dotPath setLineDash:pattern count:2 phase:1];
    
    dotPathGreen = [NSBezierPath bezierPath];
    [dotPathGreen setLineDash:pattern count:2 phase:1];
    dotPathGreen.lineWidth = 2;
    
    if( self.viewMode == WEEKLY )
        [self drawWeek];
    else if( self.viewMode == MONTHLY )
        [self drawMonth];
    else if( self.viewMode == TERMLY )
        [self drawTrimester];
    else
        [self drawYear];
    
    [self drawGraph];
    
    [[NSColor lightGrayColor] set];
    NSFrameRectWithWidth(self.frame, 1);
}

-(void) drawLine:(NSRect)rt {
    [[NSColor lightGrayColor] set];
    NSFrameRectWithWidth(rt, 1);
}

- (void) drawGreyRect:(NSRect)rt {
    [[NSColor colorWithCalibratedRed:0.9 green:0.9 blue:0.9 alpha:1.0] set];
    NSRectFill(rt);
    
    [[NSColor lightGrayColor] set];
    NSFrameRectWithWidth(rt, 1);
}

-(NSDate*) weekFirstDay:(NSDate*)date {
    NSDate* startOfWeek;
    NSTimeInterval interval;
    [calWeek rangeOfUnit:NSCalendarUnitWeekOfYear
               startDate:&startOfWeek
                interval:&interval
                 forDate:date];
    return startOfWeek;
}

-(void) drawWeek {
    
    NSDate *dateTmp = [self weekFirstDay:self.start];
    
    int nCell = w / wDayCell + 1;
    
    NSString* strToday = [Utility dateToStr:today];
    
    for( int i = 0; i < nCell; i++ ) {
        
        NSDateComponents * dateComponents = [currentCalendar components: NSDayCalendarUnit | NSWeekOfMonthCalendarUnit fromDate:dateTmp];
        NSString* strDayTmp = [Utility dateToStr:dateTmp];
        if( [strToday isEqualToString:strDayTmp] == true ) {
            [[Utility gBorderColor] set];
            
            CGFloat x = i*wDayCell;
            if( x == 0 )
                x = 2;
            [dotPathGreen moveToPoint:NSMakePoint(x, h-hHeader)];
            [dotPathGreen lineToPoint:NSMakePoint(x, 0)];
            [dotPathGreen stroke];
        }
        
        if( i % 7 == 0 ) {
            [self drawLine:NSMakeRect(i*wDayCell, h-hHeader, 1, hHeader)];
            
            [dotPath moveToPoint:NSMakePoint(i*wDayCell, h-hHeader)];
            [dotPath lineToPoint:NSMakePoint(i*wDayCell, 0)];
            [dotPath stroke];
            
            NSString* str = [NSString stringWithFormat:@"Week %ld, %@", dateComponents.weekOfMonth, [Utility dateToShortStr:dateTmp]];
            NSAttributedString * currentText=[[NSAttributedString alloc] initWithString:str attributes: attributes1];
            [currentText drawInRect:NSMakeRect(i*wDayCell+10, h-hHeader/2-3, wDayCell*7, hHeader/2)];
        }
        else {
            [self drawLine:NSMakeRect(i*wDayCell, h-hHeader, 1, hHeader/2)];
        }
        
        NSAttributedString * currentText;
        if( i%7 == 0 )
            currentText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld", dateComponents.day] attributes: attributes3];
        else {
            currentText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld", dateComponents.day] attributes: attributes2];
        }
        
        [currentText drawInRect:NSMakeRect(i*wDayCell, h-hHeader-3, wDayCell, hHeader/2)];
        dateTmp = [dateTmp dateByAddingTimeInterval:(60*60*24)];
    }
}

-(void) drawMonth {
    
    int nCell = w / wWeekCell + 1;
    NSString* strPreMonth = @"";
    
    NSDate* dateTmp = [self weekFirstDay:self.start];
    
    for( int i = 0; i < nCell; i++ ) {
        
        NSString* strMonth = [Utility dateToShortStr:dateTmp];
        NSTimeInterval interval = [dateTmp timeIntervalSinceNow];
        int day = interval / (60*60*24);
        if( day > -7 && day < 1 ) {
            
            int day1 = abs(day);
            CGFloat x = i*wWeekCell+day1*(wWeekCell/7.0f);
            
            [[Utility gBorderColor] set];
            [dotPathGreen moveToPoint:NSMakePoint(x, h-hHeader)];
            [dotPathGreen lineToPoint:NSMakePoint(x, 0)];
            [dotPathGreen stroke];
        }
        
        if( [strPreMonth isEqualToString:strMonth] == false ) {
            [self drawLine:NSMakeRect(i*wWeekCell, h-hHeader, 1, hHeader)];
            
            [dotPath moveToPoint:NSMakePoint(i*wWeekCell, h-hHeader)];
            [dotPath lineToPoint:NSMakePoint(i*wWeekCell, 0)];
            [dotPath stroke];
            
            NSAttributedString * currentText=[[NSAttributedString alloc] initWithString:strMonth attributes: attributes1];
            [currentText drawInRect:NSMakeRect(i*wWeekCell+10, h-hHeader/2-3, wWeekCell, hHeader/2)];
            strPreMonth = strMonth;
        }
        else {
            [self drawLine:NSMakeRect(i*wWeekCell, h-hHeader, 1, hHeader/2)];
        }
        
        NSDateComponents * dateComponents = [currentCalendar components: NSDayCalendarUnit | NSWeekOfMonthCalendarUnit fromDate:dateTmp];
        NSString* str = [NSString stringWithFormat:@"Week %ld", [dateComponents weekOfMonth]];
        NSAttributedString * currentText=[[NSAttributedString alloc] initWithString:str attributes: attributes2];
        [currentText drawInRect:NSMakeRect(i*wWeekCell, h-(hHeader+3), wWeekCell, hHeader/2)];
        
        dateTmp = [dateTmp dateByAddingTimeInterval:(60*60*24*7)];
    }
}

-(void) drawTrimester {
    
    NSInteger month = startMonth;
    NSInteger year  = startYear;
    if( month % 3 == 0 ) { // !!!!!
        month--;
    }
    monthForQ = month;
    
    int nCell = w / wTermCell + 1;
    for( int i = 0; i < nCell; i++ ) {
        
        if( year == todayYear && month == todayMonth ) {
            CGFloat x = i*wTermCell+todayDay*(wTermCell/[Utility getMonthDay:year :month-1]);
            [[Utility gBorderColor] set];
            [dotPathGreen moveToPoint:NSMakePoint(x, h-hHeader)];
            [dotPathGreen lineToPoint:NSMakePoint(x, 0)];
            [dotPathGreen stroke];
        }
        
        if( i == 0 || month % 3 == 1 ) {
            if( month % 3 == 1 ) {
                [self drawLine:NSMakeRect(i*wTermCell, h-hHeader, 1, hHeader)];
                
                [dotPath moveToPoint:NSMakePoint(i*wTermCell, h-hHeader)];
                [dotPath lineToPoint:NSMakePoint(i*wTermCell, 0)];
                [dotPath stroke];
            }
            
            NSString* str = [NSString stringWithFormat:@"Qtr%ld, %ld", month/3+1, year];
            NSAttributedString * currentText=[[NSAttributedString alloc] initWithString:str attributes: attributes1];
            [currentText drawInRect:NSMakeRect(i*wTermCell+10, h-hHeader/2-3, wTermCell*3, hHeader/2)];
        }
        else {
            [self drawLine:NSMakeRect(i*wTermCell, h-hHeader, 1, hHeader/2)];
        }
        
        NSAttributedString * currentText=[[NSAttributedString alloc] initWithString:[Utility getMonth:month-1] attributes: attributes2];
        [currentText drawInRect:NSMakeRect(i*wTermCell, h-hHeader-3, wTermCell, hHeader/2)];
        month++;
        if( month > 12 ) {
            month = 1;
            year++;
        }
    }
}

-(void) drawYear {
    
    NSInteger month = startMonth;
    NSInteger year  = startYear;
    if( month == 12 ) {
        month--;
    }
    monthForY = month;
    
    int nCell = w / wYearCell + 1;
    for( int i = 0; i < nCell; i++ ) {
        
        if( year == todayYear && month == todayMonth ) {
            CGFloat x = i*wYearCell+todayDay*(wYearCell/[Utility getMonthDay:year: month-1]);
            
            [[Utility gBorderColor] set];
            [dotPathGreen moveToPoint:NSMakePoint(x, h-hHeader)];
            [dotPathGreen lineToPoint:NSMakePoint(x, 0)];
            [dotPathGreen stroke];
        }
        
        if( i == 0 || month == 1) {
            if( month == 1 ) {
                [self drawLine:NSMakeRect(i*wYearCell, h-hHeader, 1, hHeader)];
                [dotPath moveToPoint:NSMakePoint(i*wYearCell, h-hHeader)];
                [dotPath lineToPoint:NSMakePoint(i*wYearCell, 0)];
                [dotPath stroke];
            }
            
            NSString* str = [NSString stringWithFormat:@"%ld", year];
            NSAttributedString * currentText=[[NSAttributedString alloc] initWithString:str attributes: attributes1];
            [currentText drawInRect:NSMakeRect(i*wYearCell+10, h-hHeader/2-3, wYearCell*12, hHeader/2)];
        }
        else {
            [self drawLine:NSMakeRect(i*wYearCell, h-hHeader, 1, hHeader/2)];
        }

        NSAttributedString * currentText=[[NSAttributedString alloc] initWithString:[Utility getMonth:month-1] attributes: attributes2];
        [currentText drawInRect:NSMakeRect(i*wYearCell, h-hHeader-3, wYearCell,hHeader/2)];
        
        month++;
        if( month > 12 ) {
            month = 1;
            year++;
        }
    }
}

#define GRAPH_HEIGHT 15


-(void) drawGraph {
    
    if( _arrInvests == nil )
        return;
    
    NSDate *start;
    NSTimeInterval interval;
    
    if( _viewMode == WEEKLY || _viewMode == MONTHLY) {
        [calWeek rangeOfUnit:NSCalendarUnitWeekOfYear
                   startDate:&start
                    interval:&interval
                     forDate:self.start];
    }
    
    int i = 0;
    [arrBarRects removeAllObjects];
    for( InvestInfo* info in _arrInvests ) {
        
        int x = [info.start timeIntervalSinceDate:start] / (3600*24);
        
        NSDateComponents*  comp1 = [currentCalendar components:NSDayCalendarUnit fromDate:info.start  toDate:info.end  options:0];
        NSInteger diff = comp1.day;
        
        if( _viewMode == WEEKLY ) {
            x *= wDayCell, diff *= wDayCell;
        }
        else if( _viewMode == MONTHLY ) {
            x *= (wWeekCell/7.0f); diff *= (wWeekCell/7.0f);
        }
        else { // if( _viewMode == TERMLY || _viewMode == YEARLY ) {
            NSDateComponents *comps = [currentCalendar components:NSMonthCalendarUnit fromDate:self.start  toDate:info.start  options:0];
            NSInteger monthDiff = comps.month;
            
            CGFloat wUnit;
            if( _viewMode == TERMLY ) {
                if( monthForQ != startMonth )
                    monthDiff++;
                wUnit = wTermCell;
            } else {
                if( monthForY != startMonth )
                    monthDiff++;
                wUnit = wYearCell;
            }
            
            comps = [currentCalendar components:NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitDay fromDate:info.start];
            NSInteger stMon = comps.month;
            NSInteger stYr  = comps.year;
            NSInteger stDay   = comps.day;
            
            x = monthDiff * wUnit + stDay * (wUnit/[Utility getMonthDay:stYr :stMon-1]);
            
            comps = [currentCalendar components:NSMonthCalendarUnit|NSDayCalendarUnit fromDate:info.start  toDate:info.end  options:0];
            monthDiff = [comps month];
            NSInteger dayDiff   = [comps day];
            
            comps = [currentCalendar components:NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitDay fromDate:info.end];
            NSInteger edMon = [comps month];
            NSInteger edYr  = [comps year];
            diff = monthDiff * wUnit + dayDiff * (wUnit/[Utility getMonthDay:edYr :edMon-1]);
        }
        
        NSRect rt = NSMakeRect( x, h - ((hHeader + 20) + i * 25), diff, GRAPH_HEIGHT);
        NSValue* rectVal = [NSValue valueWithRect:rt];
        [arrBarRects addObject:rectVal];
        
        NSColor* fillColor, *borderColor;
        switch( info.color ) {
            case 0: //r
                fillColor = [Utility rColor];
                borderColor = [Utility rBorderColor];
                break;
            case 1: //g
                fillColor = [Utility gColor];
                borderColor = [Utility gBorderColor];
                break;
            case 2: //b
                fillColor = [Utility bColor];
                borderColor = [Utility bBorderColor];
                break;
            default: // y
                fillColor = [Utility yColor];
                borderColor = [Utility yBorderColor];
                break;
        }
        
        [fillColor set];    NSRectFill(rt);
        [borderColor set];
        if( i == _nCurSel)
            NSFrameRectWithWidth(rt, 3);
        else
            NSFrameRectWithWidth(rt, 1);
        i++;
    }
}

- (void) handleSingleClickEvent: (NSEvent*) theEvent {
    NSPoint p1 = [theEvent locationInWindow];
    NSPoint p2 = [self convertPoint:p1 fromView:nil];
    
    NSRect rt;
    int i =0;
    _nCurSel = -1;
    for( NSValue* rectVal in arrBarRects ) {
        [rectVal getValue:&rt];
        if( NSPointInRect(p2, rt) == true ) {
            _nCurSel = i;
            break;
        }
        i++;
    }
    self.needsDisplay = YES;
    if( [self.delegate respondsToSelector:@selector(selectInvest:)]) {
        [self.delegate selectInvest:self];
    }
}

- (void) handleDoubleClickEvent: (NSEvent*) theEvent {
    
    NSPoint p1 = [theEvent locationInWindow];
    NSPoint p2 = [self convertPoint:p1 fromView:nil];
    
    NSRect rt;
    int i =0;
    _nCurSel = -1;
    for( NSValue* rectVal in arrBarRects ) {
        [rectVal getValue:&rt];
        if( NSPointInRect(p2, rt) == true ) {
            _nCurSel = i;
            if( [self.delegate respondsToSelector:@selector(editInvest:)]) {
                [self.delegate editInvest:self];
            }
            break;
        }
        i++;
    }
    _nCurSel = -1;
    self.needsDisplay = YES;

}


- (void)mouseUp:(NSEvent *)event
{
    NSInteger clickCount = [event clickCount];
    if ( clickCount > 1 ) {
        [self handleDoubleClickEvent:event];
    } else {
        [self handleSingleClickEvent:event];
    }
}

@end
