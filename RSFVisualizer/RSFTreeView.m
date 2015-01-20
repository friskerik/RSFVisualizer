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
#import "RSFNode+additions.h"

@interface RSFTreeView()
@property (nonatomic) double scaleFactor;
@property (nonatomic, strong) NSDictionary *nodeInformationStyle;
@property (nonatomic) CGFloat heightOfNodeInformation;
@end

@implementation RSFTreeView

#pragma mark - Initializers
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
  self.drawBorder = NO;
  self.legend = YES;
  self.nodeLabel = NODE_ID;
  self.scaleFactor = 1.0;
  [self resetNodeInformationStyle];

  if (self.rootNode) {
    [self layoutNodes:self.rootNode];
  }  
}

#pragma mark - Setters and getters
-(void)setRootNode:(RSFNode *)rootNode
{
  _rootNode = rootNode;
  if (![rootNode hasLayout]) {
    [rootNode layoutTree];
  }
  [self layoutNodes:_rootNode];
  [self setNeedsDisplay];
}

-(void)setNodeLabel:(NodeLabelType)nodeLabel
{
  _nodeLabel = nodeLabel;
  [self removeAllNodesFromView];
  [self layoutNodes:self.rootNode];
  [self setNeedsDisplay];
}

-(void)resetNodeInformationStyle
{
  NSString *nodeInformation = [NSString stringWithFormat:@"v%d : %.2f", 0, 0.0]; // dummy node information string
  UIFont *f = [[UIFont preferredFontForTextStyle:nodeInformation] fontWithSize:10.0*self.scaleFactor];
  self.nodeInformationStyle = @{NSBackgroundColorAttributeName  : [UIColor whiteColor], NSForegroundColorAttributeName : [UIColor blueColor], NSFontAttributeName : f};
  CGSize nodeInfoSize = [nodeInformation sizeWithAttributes:self.nodeInformationStyle];
  self.heightOfNodeInformation = nodeInfoSize.height;
}

-(void)setLegend:(BOOL)legend
{
  _legend = legend;
  [self setNeedsDisplay];
}

#pragma mark - Set scale to fit bounds
-(void)scaleToFit
{
  if (self.rootNode) {
    CGSize graphSize = [RSFTreeView sizeOfGraph:self.rootNode];
    
    self.scaleFactor = self.bounds.size.width/graphSize.width;
    self.scaleFactor = MIN(self.scaleFactor, self.bounds.size.height/graphSize.height);
    self.scaleFactor = MIN(self.scaleFactor, 1.0);
    [self resetNodeInformationStyle];
    
    [self removeAllNodesFromView];
    [self layoutNodes:self.rootNode];
    [self setNeedsDisplay];
  }
}

#pragma mark - Drawing utility functions
#define NODE_RADIUS 15
#define X_MARGIN 0 // Percent of a node diameter
#define Y_MARGIN 0
#define X_SCALE 1.7
#define Y_SCALE 2.2

-(CGPoint)screenPoint:(NodePosition)pos
{
  CGPoint p;
  
  p.x = (pos.x*X_SCALE*NODE_RADIUS*2.0 + NODE_RADIUS + X_MARGIN*NODE_RADIUS*2.0)*self.scaleFactor;
  p.y = self.bounds.size.height - ((pos.y*Y_SCALE*NODE_RADIUS*2.0 + NODE_RADIUS) - Y_MARGIN*NODE_RADIUS*2.0)*self.scaleFactor;

  return p;
}

#pragma mark - Layout nodes
-(void)removeAllNodesFromView
{
  for (UIView *v in self.subviews) {
    [v removeFromSuperview];
  }
}

-(CGRect)nodeRectOnScreen:(RSFNode *)node
{
  CGPoint nodePos = [self screenPoint:node.pos];
  return CGRectMake(nodePos.x-self.scaleFactor*NODE_RADIUS, nodePos.y-self.scaleFactor*NODE_RADIUS, self.scaleFactor*NODE_RADIUS*2.0, self.scaleFactor*NODE_RADIUS*2.0);
}

-(void)layoutNodes:(RSFNode *)node
{
  CGRect nodeRect = [self nodeRectOnScreen:node];
  
  RSFNodeView *v = [[RSFNodeView alloc] initWithFrame:nodeRect];
  v.scaleFactor = self.scaleFactor;
  v.node = node;
  
  switch (self.nodeLabel) {
    case NODE_ID:
      v.nodeLabel = node.nodeId;
      break;
    case NODE_LEVEL:
      v.nodeLabel = node.level;
      break;
    default:
      break;
  }
  [self addSubview:v];

  if (node.left) {
    [self layoutNodes:node.left];
  }
  if (node.right) {
    [self layoutNodes:node.right];
  }
}

#pragma mark - Draw arrows
#define ARROW_BARB_ANGLE 20.0*M_PI/180.0
#define ARROW_BARB_LENGTH 8
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
  bv.x = bv.x/normFact*ARROW_BARB_LENGTH*self.scaleFactor;
  bv.y = bv.y/normFact*ARROW_BARB_LENGTH*self.scaleFactor;
  
  [arrow removeAllPoints];
  [arrow moveToPoint:CGPointMake(p2.x-bv.x, p2.y-bv.y)];
  [arrow addLineToPoint:p2];
  
  bv = [self rotateVector:CGPointMake(p2.x-p1.x, p2.y-p1.y) angle:-ARROW_BARB_ANGLE];
  normFact = sqrt(bv.x*bv.x+bv.y*bv.y);
  bv.x = bv.x/normFact*ARROW_BARB_LENGTH*self.scaleFactor;
  bv.y = bv.y/normFact*ARROW_BARB_LENGTH*self.scaleFactor;
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

#pragma mark - Draw edges
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
  dx  = sin(phi)*NODE_RADIUS*self.scaleFactor;
  dy  = cos(phi)*NODE_RADIUS*self.scaleFactor;
  
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

#pragma mark - Main draw rect
- (void)drawRect:(CGRect)rect
{
  if (self.rootNode) {
    [self drawEdges:self.rootNode];
    [self drawVariableInformation:self.rootNode];
  }
  if (self.drawBorder) {
    UIBezierPath *border = [UIBezierPath bezierPathWithRect:self.bounds];
    [[UIColor blackColor] setStroke];
    [border stroke];
  }
}

#pragma mark - Draw variable information
#define VAR_INFO_SPACING_FACTOR 0.28
-(void)drawVariableInformation:(RSFNode *)node
{
  if (node && node.variableIdx>0) {
    CGRect nodeRect = [self nodeRectOnScreen:node];
    NSString *nodeInformation;
    if (self.legend) {
      nodeInformation = [NSString stringWithFormat:@"v%d : %.2f", node.variableIdx, node.splitValue];
    } else {
      nodeInformation = [NSString stringWithFormat:@"%@ : %.2f", self.variableNames[node.variableIdx-1], node.splitValue];
    }

    CGSize nodeInfoSize = [nodeInformation sizeWithAttributes:self.nodeInformationStyle];
  
    CGPoint p = CGPointMake(nodeRect.origin.x + nodeRect.size.width/2.0 - nodeInfoSize.width/2.0, nodeRect.origin.y-VAR_INFO_SPACING_FACTOR*2.0*NODE_RADIUS*self.scaleFactor-nodeInfoSize.height);
    [nodeInformation drawAtPoint:p withAttributes:self.nodeInformationStyle];
    
    [self drawVariableInformation:node.left];
    [self drawVariableInformation:node.right];
  }
}

#pragma mark - Graph size determination utility functions
+(CGSize)sizeOfGraph:(RSFNode *)rootNode
{
  if (![rootNode hasLayout]) {
    [rootNode layoutTree];
  }
  CGSize graphSize = [RSFTreeView sizeOfLayoutFrame:[RSFNode computeLayoutFrame:rootNode]];

  NSString *nodeInformation = [NSString stringWithFormat:@"v%d : %.2f", 0, 0.0]; // dummy node information string
  UIFont *f = [[UIFont preferredFontForTextStyle:nodeInformation] fontWithSize:10.0];
  
  CGSize nodeInfoSize = [nodeInformation sizeWithAttributes:@{NSBackgroundColorAttributeName  : [UIColor whiteColor], NSForegroundColorAttributeName : [UIColor blueColor], NSFontAttributeName : f}];
  graphSize.height = graphSize.height + nodeInfoSize.height + VAR_INFO_SPACING_FACTOR*2.0*NODE_RADIUS;

  return graphSize;
}


+(CGSize)sizeOfLayoutFrame:(CGRect)layoutFrame
{
  CGFloat width = layoutFrame.size.width*X_SCALE*NODE_RADIUS*2.0 + 2*NODE_RADIUS + 2*X_MARGIN*NODE_RADIUS*2.0;
  CGFloat height = layoutFrame.size.height*Y_SCALE*NODE_RADIUS*2.0 + 2*NODE_RADIUS + 2*Y_MARGIN*NODE_RADIUS*2.0;

  return CGSizeMake(width, height);
}

@end
