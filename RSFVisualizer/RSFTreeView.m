//
//  RSFTreeView.m
//  RSFVisualizer
//
//  Created by Erik Frisk on 12/01/15.
//  Copyright (c) 2015 Erik Frisk. All rights reserved.
//

#import "RSFTreeView.h"
#import "RSFNodeView.h"
#import "RSFNode.h"

@implementation RSFTreeView

-(void)setRootNode:(RSFNode *)rootNode
{
  _rootNode = rootNode;
  [self layoutNodes:_rootNode];
  [self setNeedsDisplay];
}

-(void)awakeFromNib
{
  [self setup];
}

-(id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  [self setup];

  return self;
}

-(void)setup
{
  self.opaque = NO;
  
  if (self.rootNode) {
    [self layoutNodes:self.rootNode];
  }
}


#define NODE_RADIUS 15
#define X_MARGIN 0.0
#define Y_MARGIN 0.0

-(CGPoint)screenPoint:(NodePosition)pos
{
  CGPoint p;
  
  p.x = pos.x*NODE_RADIUS*2.0 + NODE_RADIUS + X_MARGIN*self.bounds.size.width;
  p.y = self.bounds.size.height - pos.y*NODE_RADIUS*2.0 - NODE_RADIUS - Y_MARGIN*self.bounds.size.height;

  return p;
}

-(void)layoutNodes:(RSFNode *)node
{
  CGPoint nodePos = [self screenPoint:node.pos];
  CGRect nodeRect = CGRectMake(nodePos.x-NODE_RADIUS, nodePos.y-NODE_RADIUS, NODE_RADIUS*2.0, NODE_RADIUS*2.0);

  RSFNodeView *v = [[RSFNodeView alloc] initWithFrame:nodeRect];
  v.nodeId = node.nodeId;
  [self addSubview:v];

  if (node.left) {
    [self layoutNodes:node.left];
  }
  if (node.right) {
    [self layoutNodes:node.right];
  }
}


#define ARROW_BARB_ANGLE 25.0*M_PI/180.0
#define ARROW_BARB_LENGTH 10
-(void)drawArrowFrom:(CGPoint)p1 to:(CGPoint)p2
{
  // Draw stem
  UIBezierPath *arrow = [[UIBezierPath alloc] init];
  [arrow moveToPoint:p1];
  [arrow addLineToPoint:p2];
  [arrow stroke];
  
  // Draw arrowhead
  CGPoint bv = [self rotateVector:CGPointMake(p2.x-p1.x, p2.y-p1.y) angle:ARROW_BARB_ANGLE];
  double normFact = sqrt(bv.x*bv.x+bv.y*bv.y);
  bv.x = bv.x/normFact*ARROW_BARB_LENGTH;
  bv.y = bv.y/normFact*ARROW_BARB_LENGTH;
  
  [arrow removeAllPoints];
  [arrow moveToPoint:CGPointMake(p2.x-bv.x, p2.y-bv.y)];
  [arrow addLineToPoint:p2];
  
  bv = [self rotateVector:CGPointMake(p2.x-p1.x, p2.y-p1.y) angle:-ARROW_BARB_ANGLE];
  normFact = sqrt(bv.x*bv.x+bv.y*bv.y);
  bv.x = bv.x/normFact*ARROW_BARB_LENGTH;
  bv.y = bv.y/normFact*ARROW_BARB_LENGTH;
  [arrow addLineToPoint:CGPointMake(p2.x-bv.x, p2.y-bv.y)];
  [arrow closePath];
  [arrow stroke];
  [arrow fill];
}

-(CGPoint)rotateVector:(CGPoint)v angle:(double)fi
{
  CGPoint v2 = CGPointMake(cos(fi)*v.x - sin(fi)*v.y, sin(fi)*v.x + cos(fi)*v.y);
  return v2;
}

-(void)drawEdge:(RSFNode *)n1 to:(RSFNode *)n2
{
  CGPoint p1 = [self screenPoint:n1.pos];
  CGPoint p2 = [self screenPoint:n2.pos];

  CGPoint v, r1, r2;
  double phi;
  double dx;
  double dy;
  
  v.x = p2.x-p1.x; v.y = p2.y - p1.y;
  phi = atan2(-v.x, v.y);
  dx  = sin(phi)*NODE_RADIUS;
  dy  = cos(phi)*NODE_RADIUS;
  
  r1.x = p1.x - dx; r1.y = p1.y + dy;
  r2.x = p2.x + dx; r2.y = p2.y - dy;
  
  [self drawArrowFrom:r1 to:r2];
}

-(void)drawEdges:(RSFNode *)node
{
  if (node.left) {
    [self drawEdge:node to:node.left];
    [self drawEdges:node.left];
  }
  if (node.right) {
    [self drawEdge:node to:node.right];
    [self drawEdges:node.right];
  }
}

- (void)drawRect:(CGRect)rect
{
  if (self.rootNode) {
    [self drawEdges:self.rootNode];
  }
  UIBezierPath  *border = [UIBezierPath bezierPathWithRect:self.bounds];
  [[UIColor blackColor] setStroke];
  [border stroke];
}

@end
