//
//  TreeSelectorTableViewController.h
//  RSFVisualizer
//
//  Created by Erik Frisk on 24/01/15.
//  Copyright (c) 2015 Erik Frisk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TreeSelectorViewControllerDelegate.h"

@interface TreeSelectorTableViewController : UITableViewController
@property (nonatomic, weak) NSArray *rsfTreeNames;
@property (nonatomic, strong) id<TreeSelectorViewControllerDelegate> delegate;
@end
