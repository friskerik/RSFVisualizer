//
//  NodeConstraint.h
//  RSFVisualizer
//
//  Created by Erik Frisk on 07/03/15.
//  Copyright (c) 2015 Erik Frisk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NodeConstraint : NSObject
@property (nonatomic, strong) NSNumber *lowerBound;
@property (nonatomic, strong) NSNumber *upperBound;

-(id)initWithLowerBound:(NSNumber *)lb;
-(id)initWithUpperBound:(NSNumber *)ub;
-(id)initWithLowerBound:(NSNumber *)lb andUpperBound:(NSNumber *)ub;
-(id)initWithConstraint:(NodeConstraint *)c;

-(void)mergeConstraint:(NodeConstraint *)c;
-(NSString *)description;
@end
