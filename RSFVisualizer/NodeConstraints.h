//
//  NodeConstraints.h
//  RSFVisualizer
//
//  Created by Erik Frisk on 07/03/15.
//  Copyright (c) 2015 Erik Frisk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NodeConstraint.h"

@interface NodeConstraints : NSObject
@property (nonatomic, strong) NSDictionary *constraints;

-(id)initWithConstraintList:(NSArray *)constraintList; // designated initializer
-(void)debugPrint;
@end
