//
//  RSFTreeView.h
//  RSFVisualizer
//
//  Created by Erik Frisk on 12/01/15.
//  Copyright (c) 2015 Erik Frisk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSFNode.h"

@interface RSFTreeView : UIView
@property (nonatomic, weak) RSFNode *rootNode;
@end
