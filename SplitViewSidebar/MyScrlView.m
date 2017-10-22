#import "MyScrlView.h"

@implementation MyScrlView
{
}



- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if( self )
    {
        
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    
    NSRect bounds = [self bounds] ;
    [super drawRect:bounds] ;
    
}



@end
