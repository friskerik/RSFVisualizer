//
//  RSFTreeMarkingDelegate.h
//  RSFVisualizer
//
//  Created by Erik Frisk on 31/01/15.
//  Copyright (c) 2015 Erik Frisk. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RSFTreeMarkingDelegate <NSObject>
-(BOOL)isVariableMarked:(int)nodeIdx;
-(BOOL)isSubTreeMarked:(int)nodeIdx;
@end
