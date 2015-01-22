//
//  RSFTreeView.m
//  RSFVisualizer
//
//  Created by Erik Frisk on 21/01/15.
//  Copyright (c) 2015 Erik Frisk. All rights reserved.
//

#import "RSFTreeView.h"

@interface RSFTreeView()
@property (nonatomic) double scaleFactor;

@end

@implementation RSFTreeView

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
}

-(void)setRootNode:(RSFNode *)rootNode
{
  _rootNode = rootNode;
  if (![rootNode hasLayout]) {
    [rootNode layoutTree];
  }
  [self setNeedsDisplay];
}

-(void)setNodeLabel:(NodeLabelType)nodeLabel
{
  _nodeLabel = nodeLabel;
  [self setNeedsDisplay];
}

-(void)setLegend:(BOOL)legend
{
  if (legend != _legend) {
    _legend = legend;
    [self setNeedsDisplay];
  }
}

#pragma mark - Graph size functions
#define NODE_RADIUS 15
#define X_SCALE 1.7
#define Y_SCALE 2.2
#define VAR_INFO_SPACING_FACTOR 0.28

-(void)scaleToFit
{
  if (self.rootNode) {
    self.scaleFactor = 1.0;
    CGSize graphSize = [self sizeOfGraph];
    self.scaleFactor = MIN(self.bounds.size.width/graphSize.width, self.bounds.size.height/graphSize.height);
  }
}

-(CGSize)sizeOfGraph
{
  CGRect graphRect = CGRectZero;

  double scaleFactorSave = self.scaleFactor;
  self.scaleFactor = 1.0; // Compute size of graph with no scaling

  [self sizeNodes:self.rootNode inRect:&graphRect];
  [self sizeNodeInformation:self.rootNode inRect:&graphRect];
  self.scaleFactor = scaleFactorSave; // restore scaling

  return graphRect.size;
}

#pragma mark - Drawing utility functions

-(CGPoint)screenPoint:(NodePosition)pos
{
  CGPoint p;
  
  p.x = (pos.x*X_SCALE*NODE_RADIUS*2.0 + NODE_RADIUS)*self.scaleFactor;
  p.y = self.bounds.size.height - ((pos.y*Y_SCALE*NODE_RADIUS*2.0 + NODE_RADIUS))*self.scaleFactor;
  
  return p;
}

#pragma mark - Main draw rect
-(void)redraw
{
  [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
  [self drawNodes:self.rootNode]; // draw nodes and edges
  [self drawNodeInformation:self.rootNode]; // draw node information

//  CGRect graphRect = CGRectZero;
//  [self sizeNodes:self.rootNode inRect:&graphRect];
//  [self sizeNodeInformation:self.rootNode inRect:&graphRect];
//
//  UIBezierPath *graphBorder = [UIBezierPath bezierPathWithRect:graphRect];
//  [[UIColor redColor] setStroke];
//  [graphBorder stroke];
  
  if (self.drawBorder) {
    UIBezierPath *border = [UIBezierPath bezierPathWithRect:self.bounds];
    [[UIColor blackColor] setStroke];
    [border stroke];
  }
}

-(NSDictionary *)nodeInformationStyle
{
  NSString *nodeInformation = [NSString stringWithFormat:@"v%d : %.2f", 0, 0.0]; // dummy node information string
  UIFont *f = [[UIFont preferredFontForTextStyle:nodeInformation] fontWithSize:10.0*self.scaleFactor];
  return @{NSBackgroundColorAttributeName  : [UIColor whiteColor], NSForegroundColorAttributeName : [UIColor blueColor], NSFontAttributeName : f};
}

-(void)drawNodeInformation:(RSFNode *)node
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
    [nodeInformation drawAtPoint:p withAttributes:[self nodeInformationStyle]];
    
    [self drawNodeInformation:node.left];
    [self drawNodeInformation:node.right];
  }
}

-(void)sizeNodeInformation:(RSFNode *)node inRect:(CGRect *)rect
{
  if (node) {
    if (rect->size.width>0 && node.variableIdx>0) {
      CGRect nr = [self nodeRectOnScreen:node];
      NSString *nodeInformation;
      if (self.legend) {
        nodeInformation = [NSString stringWithFormat:@"v%d : %.2f", node.variableIdx, node.splitValue];
      } else {
        nodeInformation = [NSString stringWithFormat:@"%@ : %.2f", self.variableNames[node.variableIdx-1], node.splitValue];
      }
      
      CGSize nodeInfoSize = [nodeInformation sizeWithAttributes:self.nodeInformationStyle];
      CGRect nodeInfoRect = CGRectMake(nr.origin.x + nr.size.width/2.0 - nodeInfoSize.width/2.0, nr.origin.y-VAR_INFO_SPACING_FACTOR*2.0*NODE_RADIUS*self.scaleFactor-nodeInfoSize.height, nodeInfoSize.width, nodeInfoSize.height);
      
      CGFloat xMin = MIN(nodeInfoRect.origin.x, rect->origin.x);
      CGFloat xMax = MAX(nodeInfoRect.origin.x + nodeInfoRect.size.width, rect->origin.x + rect->size.width);
      CGFloat yMin = MIN(nodeInfoRect.origin.y, rect->origin.y);
      CGFloat yMax = MAX(nodeInfoRect.origin.y + nodeInfoRect.size.height, rect->origin.y + rect->size.height);
      
      rect->origin.x    = xMin;
      rect->origin.y    = yMin;
      rect->size.width  = xMax-xMin;
      rect->size.height = yMax - yMin;
      [self sizeNodeInformation:node.left inRect:rect];
      [self sizeNodeInformation:node.right inRect:rect];
    }
  }
}

-(CGRect)nodeRectOnScreen:(RSFNode *)node
{
  CGPoint nodePos = [self screenPoint:node.pos];
  return CGRectMake(nodePos.x-self.scaleFactor*NODE_RADIUS, nodePos.y-self.scaleFactor*NODE_RADIUS, self.scaleFactor*NODE_RADIUS*2.0, self.scaleFactor*NODE_RADIUS*2.0);
}

-(RSFNode *)tappedNode:(CGPoint)p
{
  return [self tappedNode:p inTree:self.rootNode];
}

-(RSFNode *)tappedNode:(CGPoint)p inTree:(RSFNode *)rootNode
{
  RSFNode *ret = nil;
  
  if (rootNode) {
    CGRect nodeRect = [self nodeRectOnScreen:rootNode];
    if (CGRectContainsPoint(nodeRect, p)) {
      ret = rootNode;
    } else {
      ret = [self tappedNode:p inTree:rootNode.left];
      if (!ret) {
        ret = [self tappedNode:p inTree:rootNode.right];
      }
    }
  }
  
  return ret;
}

-(void)drawNodes:(RSFNode *)node
{
  if (node) {
    CGPoint p = [self screenPoint:node.pos]; // Center point of node
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    
    CGFloat r = NODE_RADIUS*self.scaleFactor*0.92;
    path = [UIBezierPath bezierPathWithArcCenter:p radius:r startAngle:0 endAngle:2*M_PI clockwise:YES];
    
    [[UIColor blackColor] setStroke];
    [[UIColor yellowColor] setFill];
    [path setLineWidth:2.0*self.scaleFactor];
    
    [path fill];
    [path stroke];
    
    NSString *s;
    if (self.nodeLabel==NODE_ID) {
      s = [NSString stringWithFormat:@"%d", node.nodeId];
    } else {
      s = [NSString stringWithFormat:@"%d", node.level];
    }
    
    UIFont *f = [[UIFont preferredFontForTextStyle:s] fontWithSize:12.0*self.scaleFactor];
    
    CGSize labelSize = [s sizeWithAttributes:@{NSFontAttributeName : f}];
    
    CGPoint labelp = p; p.y = p.y - r;
    labelp.x -= labelSize.width/2.0;
    labelp.y -= labelSize.height/2.0;
    
    [s drawAtPoint:labelp withAttributes:@{NSFontAttributeName : f}];

    [self drawEdges:node];
    [self drawNodes:node.left];
    [self drawNodes:node.right];
  }
}

-(void)sizeNodes:(RSFNode *)node inRect:(CGRect *)rect
{
  if (node) {
    CGRect nr = [self nodeRectOnScreen:node];
    
    if (rect->size.width==0) {
      *rect = nr;
    } else {
      CGFloat xMin = MIN(nr.origin.x, rect->origin.x);
      CGFloat xMax = MAX(nr.origin.x + nr.size.width, rect->origin.x + rect->size.width);
      CGFloat yMin = MIN(nr.origin.y, rect->origin.y);
      CGFloat yMax = MAX(nr.origin.y + nr.size.height, rect->origin.y + rect->size.height);
      
      rect->origin.x    = xMin;
      rect->origin.y    = yMin;
      rect->size.width  = xMax-xMin;
      rect->size.height = yMax - yMin;
    }
    [self sizeNodes:node.left inRect:rect];
    [self sizeNodes:node.right inRect:rect];
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

@end
