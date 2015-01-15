//
//  RSFNode+additions.m
//  RSFVisualizer
//
//  Created by Erik Frisk on 15/01/15.
//  Copyright (c) 2015 Erik Frisk. All rights reserved.
//

#import "RSFNode+additions.h"

@implementation RSFNode (additions)

+(CGRect)computeLayoutFrame:(RSFNode *)rootNode
{
  CGRect r;
  if ([rootNode isLeaf]) {
    r = CGRectMake(rootNode.pos.x, rootNode.pos.y, 0.0, 0.0);
  } else {
    CGRect rl = [RSFNode computeLayoutFrame:rootNode.left];
    CGRect rr = [RSFNode computeLayoutFrame:rootNode.right];
    
    r.origin.x = MIN(rl.origin.x, rr.origin.x);
    r.origin.y = MIN(rl.origin.y, rr.origin.y);
    
    CGFloat rightMost = MAX(rl.origin.x+rl.size.width, rr.origin.x+rr.size.width);
    CGFloat leftMost  = MIN(rl.origin.x, rr.origin.x);
    r.size.width = rightMost - leftMost;
    r.size.height = rootNode.pos.y - r.origin.y;
  }
  return r;
}

@end
