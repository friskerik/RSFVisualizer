//
//  ViewController.m
//  RSFVisualizer
//
//  Created by Erik Frisk on 12/01/15.
//  Copyright (c) 2015 Erik Frisk. All rights reserved.
//

#import "ViewController.h"
#import "RSFNode.h"
#import "RSFTreeView.h"
#import "RSFFileReader.h"
#import "RSFNode+additions.h"

@interface ViewController ()
@property (nonatomic, strong) RSFNode *rootNode;
@property (nonatomic, strong) NSData *d;
@end

@implementation ViewController

- (void)viewDidLoad
{
  [super viewDidLoad];

  [self setup];
}

-(void)setup
{
  // Read RSF definition files
  RSF *rsf = [[RSF alloc] init];
  rsf.rsfName = @"fleet1";
//  rsf.rsfName = @"fleet";

  // Found any?
  if ([rsf.trees count]>0) {
    // Extract 1 tree
    int treeIdx = 0;
    NSLog(@"Read %lu tree(s) from file %@\n", (unsigned long)[rsf.trees count], rsf.rsfName);
    NSLog(@"Tree %d has %d nodes, %d leaves, and depth %d\n", treeIdx, [rsf.trees[treeIdx] numberOfNodes], [rsf.trees[treeIdx] numberOfLeaves], [rsf.trees[treeIdx] depth]);

    self.rootNode = rsf.trees[treeIdx];
    
    // Layout tree
    [self.rootNode layoutTree];

    // Compute layoutFrame, and screen size of graph
    CGRect layoutFrame = [RSFNode computeLayoutFrame:self.rootNode];
    CGSize graphSize = [RSFTreeView sizeOfLayoutFrame:layoutFrame];
    
    NSLog(@"layoutFrame: (%f,%f) %f x %f\n", layoutFrame.origin.x, layoutFrame.origin.y, layoutFrame.size.width, layoutFrame.size.height);
    NSLog(@"graphSize  :  %f x %f\n", graphSize.width, graphSize.height);

    // Add RSFTreeView, center located on the screen
    RSFTreeView *treeView = [[RSFTreeView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - graphSize.width)/2.0, (self.view.bounds.size.height - graphSize.height)/2.0, graphSize.width, graphSize.height)];

    // Configure rendering
    treeView.drawBorder = NO;
    treeView.nodeLabel = NODE_LEVEL;
    treeView.rootNode = self.rootNode;
    
    // Add view
    [self.view addSubview:treeView];
  } else {
    NSLog(@"Error reading tree %@\n", rsf.rsfName);
  }
}


@end
