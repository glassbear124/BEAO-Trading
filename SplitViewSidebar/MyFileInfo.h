//
//  FileInfo.h
//  Bear Trading
//
//  Created by Admin on 3/29/17.
//  Copyright © 2017 Xiaosoft. All rights reserved.
//

#import <Foundation/Foundation.h>

// Country information

@interface MyFileInfo : NSObject

@property (assign) int ix;   // country id
@property (nonatomic, retain) NSString* name;  // country name
@property (nonatomic, retain) NSMutableArray* arrInvests;
@end
