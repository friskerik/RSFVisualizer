//
//  TerminalNodeViewController.h
//  RSFVisualizer
//
//  Created by Erik Frisk on 08/03/15.
//  Copyright (c) 2015 Erik Frisk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSF.h"
#import "RSFNode.h"

@interface TerminalNodeViewController : UIViewController
@property (nonatomic, weak) RSF *rsf;
@property (nonatomic, weak) RSFNode *node;
@end
