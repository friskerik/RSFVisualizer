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
  RSFNode *n1 = [[RSFNode alloc] init];
  n1.nodeId = 1; n1.pos = NodePositionMake(2.0, 5.0);

  RSFNode *n2 = [[RSFNode alloc] init];
  n2.nodeId = 2; n2.pos = NodePositionMake(1.0, 3.0);

  RSFNode *n3 = [[RSFNode alloc] init];
  n3.nodeId = 3; n3.pos = NodePositionMake(3.0, 3.0);

  RSFNode *n4 = [[RSFNode alloc] init];
  n4.nodeId = 4; n4.pos = NodePositionMake(2.0, 1.0);

  n1.left = n2;
  n1.right = n3;
  n2.left = nil;
  n2.right = n4;
  n3.left = n4;
  n3.right = nil;

  self.rootNode = n1;
  
  RSFTreeView *treeView = [[RSFTreeView alloc] initWithFrame:CGRectMake(20, 20, 200, 200)];
  treeView.rootNode = self.rootNode;
  [self.view addSubview:treeView];

  RSF *rsf = [[RSF alloc] init];
  rsf.rsfName = @"fleet1";
//  rsf.rsfName = @"fleet";
  
  if ([rsf.trees count]>0) {
    int treeIdx = 0;
    NSLog(@"Read %lu tree(s) from file %@\n", (unsigned long)[rsf.trees count], rsf.rsfName);
    NSLog(@"Tree %d has %d nodes, %d leaves, and depth %d\n", treeIdx, [rsf.trees[treeIdx] numberOfNodes], [rsf.trees[treeIdx] numberOfLeaves], [rsf.trees[treeIdx] depth]);
  } else {
    NSLog(@"Error reading tree %@\n", rsf.rsfName);
  }
}

@end
