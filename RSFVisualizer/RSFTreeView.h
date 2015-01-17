//
//  RSFTreeView.h
//  RSFVisualizer
//
//  Created by Erik Frisk on 12/01/15.
//  Copyright (c) 2015 Erik Frisk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSFNode.h"

typedef enum {NODE_ID, NODE_LEVEL} NodeLabel;

@interface RSFTreeView : UIView
@property (nonatomic, weak) RSFNode *rootNode;
@property (nonatomic) BOOL drawBorder;
@property (nonatomic) NodeLabel nodeLabel;

+(CGSize)sizeOfLayoutFrame:(CGRect)layoutFrame;
+(CGSize)sizeOfGraph:(RSFNode *)rootNode;
-(void)scaleToFit;
@end
