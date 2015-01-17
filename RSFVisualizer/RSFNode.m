//
//  RSFNode.m
//  RSFVisualizer
//
//  Created by Erik Frisk on 12/01/15.
//  Copyright (c) 2015 Erik Frisk. All rights reserved.
//

#import "RSFNode.h"

NodePosition
NodePositionMake(double x, double y)
{
  NodePosition pos;
  pos.x = x;
  pos.y = y;
  return pos;
}

@interface RSFNode()
@end

@implementation RSFNode

#pragma mark - Initializer
-(id)init
{
  self = [super init];
  if (self) {
    self.hasLayout = NO;
  }
  return self;
}

#pragma mark - Utility functions
-(int)numberOfNodes
{
  int n=1;
  if (self.left) {
    n = n + [self.left numberOfNodes];
  }
  if (self.right) {
    n = n + [self.right numberOfNodes];
  }
  return n;
}

-(bool)isLeaf
{
  if (self.left !=nil || self.right !=nil) {
    return false;
  } else {
    return true;
  }
}

-(int)numberOfLeaves
{
  int n;
  if ([self isLeaf]) {
    n=1;
  } else {
    n=0;
    if (self.left) {
      n = n + [self.left numberOfLeaves];
    }
    if (self.right) {
      n = n + [self.right numberOfLeaves];
    }
  }
  return n;
}

-(int)depth
{
  if ([self isLeaf]) {
    return 1;
  } else {
    int d = 0;
    if (self.left) {
      d = [self.left depth];
    }
    if (self.right) {
      d = MAX(d, [self.right depth]);
    }
    return d+1;
  }
}

#pragma mark - Tree layout
-(void)layoutTree
{
  if (![self hasLayout]) {
    // Layout tree
    [self nodeLayout:[self depth]-1];
    
    // Shift layout so that leftmost border is at x=0.0
    [self shiftNodesRight:-[self minimumXPosition]];
  }
  //  [self dumpLayout];
}

-(double)minimumXPosition
{
  double x = self.pos.x;
  if (self.left) {
    x = MIN(x, [self.left minimumXPosition]);
  }
  if (self.right) {
    x = MIN(x, [self.right minimumXPosition]);
  }
  return x;
}

-(void)dumpLayout
{
  NSLog(@"Node %d: (%f,%f)", self.nodeId, self.pos.x, self.pos.y);
  [self.left dumpLayout];
  [self.right dumpLayout];
}

#define NODEDISTANCE 1.2
-(void)nodeLayout:(int)level
{
  self.hasLayout = YES;
  if ([self isLeaf]) {
    self.pos = NodePositionMake(0.0, (double)level);
  } else {
    int n = [self depth];

    // Layout children (assumes both left and right child)
    [self.left nodeLayout:level-1];
    [self.right nodeLayout:level-1];

    // Allocate countours
    NSMutableArray *lc = [[NSMutableArray alloc] initWithCapacity:n-1];
    NSMutableArray *rc = [[NSMutableArray alloc] initWithCapacity:n-1];
    for (int ii=0; ii<n-1; ii++) {
      [lc addObject:[NSNull null]];
      [rc addObject:[NSNull null]];
    }
    
    // Compute contours for children
    [self.left rightContour:rc onLevel:0];
    [self.right leftContour:lc onLevel:0];

    // Compute amount to shift right tree
    double minDistance = DBL_MAX;
    for (int ii=0; ii < n-1; ii++) {
//      if ([lc[ii] doubleValue]>=0.0 && [rc[ii] doubleValue]>=0.0) {
      if (![lc[ii] isKindOfClass:[NSNull class]] && ![rc[ii] isKindOfClass:[NSNull class]]) {
        minDistance = MIN( minDistance, [lc[ii] doubleValue]-[rc[ii] doubleValue] );
      }
    }

    // Shift right tree
    [self.right shiftNodesRight:NODEDISTANCE - minDistance];
    
    // Set root node
    self.pos = NodePositionMake((self.left.pos.x + self.right.pos.x)/2.0, level);      
  }
}

-(void)shiftNodesRight:(double)delta
{
  self.pos = NodePositionMake(self.pos.x + delta, self.pos.y);
  [self.left shiftNodesRight:delta];
  [self.right shiftNodesRight:delta];
}

-(void)leftContour:(NSMutableArray *)c onLevel:(int)level
{
  if (![c[level] isKindOfClass:[NSNull class]]) {
    c[level] = [NSNumber numberWithDouble:MIN([c[level] doubleValue],self.pos.x)];
  } else {
    c[level] = [NSNumber numberWithDouble:self.pos.x];
  }

  [self.left leftContour:c onLevel:level+1];
  [self.right leftContour:c onLevel:level+1];
}

-(void)rightContour:(NSMutableArray *)c onLevel:(int)level
{
  if (![c[level] isKindOfClass:[NSNull class]]) {
    c[level] = [NSNumber numberWithDouble:MAX([c[level] doubleValue],self.pos.x)];
  } else {
    c[level] = [NSNumber numberWithDouble:self.pos.x];
  }
  [self.left rightContour:c onLevel:level+1];
  [self.right rightContour:c onLevel:level+1];
}

@end
