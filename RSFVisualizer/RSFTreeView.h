//
//  RSFTreeView.h
//  RSFVisualizer
//
//  Created by Erik Frisk on 12/01/15.
//  Copyright (c) 2015 Erik Frisk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSFNode.h"

typedef enum {NODE_ID, NODE_LEVEL} NodeLabelType;

@interface RSFTreeView : UIView
@property (nonatomic, weak) RSFNode *rootNode;
@property (nonatomic, weak) NSArray *variableNames; // of NSString *

@property (nonatomic) BOOL drawBorder;
@property (nonatomic) BOOL legend;
@property (nonatomic) NodeLabelType nodeLabel;

+(CGSize)sizeOfGraph:(RSFNode *)rootNode;
-(void)scaleToFit;
@end
