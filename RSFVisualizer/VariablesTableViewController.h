//
//  VariablesTableViewController.h
//  RSFVisualizer
//
//  Created by Erik Frisk on 29/01/15.
//  Copyright (c) 2015 Erik Frisk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSF.h"
#import "RSFTreeMarkingDelegate.h"

@protocol VariablesTableViewControllerDelegate <NSObject>

-(void)switchVariableMarking:(int)variableIdx;
@end

@interface VariablesTableViewController : UITableViewController
@property (nonatomic, weak) RSF *rsf;
@property (nonatomic, strong) id<VariablesTableViewControllerDelegate,RSFTreeMarkingDelegate> delegate;
@end
