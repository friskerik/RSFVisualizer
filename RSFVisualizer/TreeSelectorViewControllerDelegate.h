//
//  TreeSelectorViewControllerDelegate.h
//  RSFVisualizer
//
//  Created by Erik Frisk on 24/01/15.
//  Copyright (c) 2015 Erik Frisk. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TreeSelectorViewControllerDelegate <NSObject>
-(void)selectedTreeWithName:(NSString *)treeName;
@end
