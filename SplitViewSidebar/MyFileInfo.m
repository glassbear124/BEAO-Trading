//
//  FileInfo.m
//  Bear Trading
//
//  Created by Admin on 3/29/17.
//  Copyright © 2017 Xiaosoft. All rights reserved.
//

#import "MyFileInfo.h"

@implementation MyFileInfo

-(MyFileInfo*) init {
    self = [super init];
    if( self ) {
        _arrInvests = [[NSMutableArray alloc] init];        
    }
    return self;
}


@end
