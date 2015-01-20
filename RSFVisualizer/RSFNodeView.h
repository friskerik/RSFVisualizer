//
//  RSFNodeView.h
//  RSFVisualizer
//
//  Created by Erik Frisk on 12/01/15.
//  Copyright (c) 2015 Erik Frisk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSFNode.h"

@interface RSFNodeView : UIView
@property (nonatomic) int nodeLabel;
@property (nonatomic) double scaleFactor;
@property (nonatomic, weak) RSFNode *node;
@end
