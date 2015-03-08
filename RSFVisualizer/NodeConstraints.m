//
//  NodeConstraints.m
//  RSFVisualizer
//
//  Created by Erik Frisk on 07/03/15.
//  Copyright (c) 2015 Erik Frisk. All rights reserved.
//

#import "NodeConstraints.h"

@implementation NodeConstraints

-(id)initWithConstraintList:(NSArray *)constraintList
{
  self=[super init];
  if (self) {
    NSMutableDictionary *nodeConstraints = [[NSMutableDictionary alloc] init];
    NodeConstraint *dictConstraint;
    
    for (NSDictionary *cl in constraintList) { // Iterate over all constraints in constraintList and represent in a more compact form
      // @{@"variableIndex": v, @"constraint" : c}];

      // Get variable and corresponding new constraint
      NSNumber *varIdx = [cl objectForKey:@"variableIndex"];
      NodeConstraint *constraint = [cl objectForKey:@"constraint"];

      if ((dictConstraint = [nodeConstraints objectForKey:varIdx])) {
        // Existing constraint for variable, merge constraints
        [dictConstraint mergeConstraint:constraint];
      } else {
        // Insert a new constraint for key varIdx
//        [nodeConstraints setObject:constraint forKey:varIdx];
        [nodeConstraints setObject:[[NodeConstraint alloc] initWithConstraint:constraint] forKey:varIdx];
      }
    }
    self.constraints = nodeConstraints;
  }
  return self;
}


-(void)debugPrint
{
  NSEnumerator *enumerator = [self.constraints keyEnumerator];
  id key;
  
  while ((key = [enumerator nextObject])) {
    NodeConstraint *c = [self.constraints objectForKey:key];
    
    if (c.lowerBound && c.upperBound) {
      NSLog(@"%@ < v%@ ≤ %@\n", c.lowerBound, key, c.upperBound);
    } else if (!c.lowerBound && c.upperBound) {
      NSLog(@"v%@ ≤ %@\n", key, c.upperBound);
    } else {
      NSLog(@"%@ < v%@\n", c.lowerBound, key);
    }
  }
}

@end
