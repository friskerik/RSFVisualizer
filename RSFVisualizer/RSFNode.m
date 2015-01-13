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


@implementation RSFNode

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
@end
