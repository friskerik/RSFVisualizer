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
  self.scaleFactor = 1.0;
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
  CGFloat r = MIN(self.bounds.size.width, self.bounds.size.height)/2.0*0.92;
  
  path = [UIBezierPath bezierPathWithArcCenter:p radius:r startAngle:0 endAngle:2*M_PI clockwise:YES];
  [[UIColor blackColor] setStroke];
  [[UIColor yellowColor] setFill];
  [path setLineWidth:2.0*self.bounds.size.width/30.0]; // 2.0 linewidth when radius is 15 points
  
  [path fill];
  [path stroke];
  
  NSString *s = [NSString stringWithFormat:@"%d", self.nodeLabel];
  UIFont *f = [[UIFont preferredFontForTextStyle:s] fontWithSize:12.0*self.scaleFactor];
  
  CGSize labelSize = [s sizeWithAttributes:@{NSFontAttributeName : f}];

  CGPoint labelp = p;
  labelp.x -= labelSize.width/2.0;
  labelp.y -= labelSize.height/2.0;
  
  [s drawAtPoint:labelp withAttributes:@{NSFontAttributeName : f}];
}

@end
