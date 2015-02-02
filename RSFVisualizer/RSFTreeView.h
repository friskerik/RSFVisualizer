//
//  RSFTreeView.h
//  RSFVisualizer
//
//  Created by Erik Frisk on 21/01/15.
//  Copyright (c) 2015 Erik Frisk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSFNode.h"
#import "RSFTreeMarkingDelegate.h"

typedef enum {NODE_ID, NODE_LEVEL} NodeLabelType;

@interface RSFTreeView : UIView
@property (nonatomic, weak) RSFNode *rootNode;
@property (nonatomic, weak) NSArray *variableNames; // of NSString *
//@property (nonatomic, strong) NSMutableArray *variableMarkings;
@property (nonatomic) BOOL drawBorder;
@property (nonatomic) BOOL legend;
@property (nonatomic) NodeLabelType nodeLabel;

@property (nonatomic, strong) id<RSFTreeMarkingDelegate> delegate;

-(CGSize)sizeOfGraph;
-(void)scaleToFit;
-(void)redraw;
-(RSFNode *)tappedNode:(CGPoint)p;
@end
