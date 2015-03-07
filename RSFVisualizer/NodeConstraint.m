//
//  NodeConstraint.m
//  RSFVisualizer
//
//  Created by Erik Frisk on 07/03/15.
//  Copyright (c) 2015 Erik Frisk. All rights reserved.
//

#import "NodeConstraint.h"

@implementation NodeConstraint

-(id)initWithLowerBound:(NSNumber *)lb
{
  self = [super init];
  
  if (self) {
    self.lowerBound = lb;
  }
  return self;
}

-(id)initWithUpperBound:(NSNumber *)ub
{
  self = [super init];
  
  if (self) {
    self.upperBound = ub;
  }
  return self;
}

-(id)initWithLowerBound:(NSNumber *)lb andUpperBound:(NSNumber *)ub
{
  self = [super init];
  
  if (self) {
    self.lowerBound = lb;
    self.upperBound = ub;
  }
  return self;
}

-(id)initWithConstraint:(NodeConstraint *)c
{
  self = [super init];
  
  if (self) {
    self.lowerBound = c.lowerBound;
    self.upperBound = c.upperBound;
  }
  return self;
}

-(void)mergeConstraint:(NodeConstraint *)c
{
//  NSLog(@"Merge (%@) into (%@)", [c description], [self description]);
  if( c.lowerBound) {
    // A (possibly) new lower bound is provided
    if (!self.lowerBound) {
      self.lowerBound = c.lowerBound;
    } else {
      self.lowerBound = [NSNumber numberWithDouble:MAX([self.lowerBound doubleValue], [c.lowerBound doubleValue])];
    }
  }
  if( c.upperBound) {
    // A (possibly) new upper bound is provided
    if (!self.upperBound) {
      self.upperBound = c.upperBound;
    } else {
      self.upperBound = [NSNumber numberWithDouble:MIN([self.upperBound doubleValue], [c.upperBound doubleValue])];
    }
  }
//  NSLog(@"=> %@\n", [self description]);
}


-(NSString *)description
{
  NSString *s;
  if (self.lowerBound && self.upperBound) {
    s = [NSString stringWithFormat:@"%@ < v <= %@", self.lowerBound, self.upperBound];
  } else if (!self.lowerBound && self.upperBound) {
    s = [NSString stringWithFormat:@"v <= %@", self.upperBound];
  } else {
    s = [NSString stringWithFormat:@"%@ < v", self.lowerBound];
  }
  return s;
}

@end
