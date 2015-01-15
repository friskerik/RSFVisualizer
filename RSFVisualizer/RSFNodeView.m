//
//  RSFNodeView.m
//  RSFVisualizer
//
//  Created by Erik Frisk on 12/01/15.
//  Copyright (c) 2015 Erik Frisk. All rights reserved.
//

#import "RSFNodeView.h"

@implementation RSFNodeView

-(void)awakeFromNib
{
  [self setup];
}

-(void)setup
{
  self.opaque = NO;
}

-(id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  
  [self setup];
  
  return self;
}

-(void)setNodeLabel:(int)nodeLabel
{
  _nodeLabel = nodeLabel;
  [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect
{
  UIBezierPath *path = [[UIBezierPath alloc] init];
  
  CGPoint p = CGPointMake(self.bounds.origin.x + self.bounds.size.width/2.0, self.bounds.origin.y + self.bounds.size.height/2.0);
  CGFloat r = MIN(self.bounds.size.width, self.bounds.size.height)/2.0*0.95;
  
  path = [UIBezierPath bezierPathWithArcCenter:p radius:r startAngle:0 endAngle:2*M_PI clockwise:YES];
  [[UIColor blackColor] setStroke];
  [[UIColor yellowColor] setFill];
  [path setLineWidth:2.0];
  
  
  [path fill];
  [path stroke];
  
  NSString *s = [NSString stringWithFormat:@"%d", self.nodeLabel];
  CGSize labelSize = [s sizeWithAttributes:nil];
  
  CGPoint labelp = p;
  labelp.x -= labelSize.width/2.0;
  labelp.y -= labelSize.height/2.0;
  
  [s drawAtPoint:labelp withAttributes:nil];
  
//  UIBezierPath *border = [UIBezierPath bezierPathWithRect:self.bounds];
//  [[UIColor blackColor] setStroke];
//  [border stroke];
}

@end
