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

//  [self setupSimple];
  [self setup];
}

#define LARGE_VIEW_SIZE 700
-(void)setup
{
  RSF *rsf = [[RSF alloc] init];
  rsf.rsfName = @"fleet1";
//  rsf.rsfName = @"fleet";
  
  if ([rsf.trees count]>0) {
    int treeIdx = 0;
    NSLog(@"Read %lu tree(s) from file %@\n", (unsigned long)[rsf.trees count], rsf.rsfName);
    NSLog(@"Tree %d has %d nodes, %d leaves, and depth %d\n", treeIdx, [rsf.trees[treeIdx] numberOfNodes], [rsf.trees[treeIdx] numberOfLeaves], [rsf.trees[treeIdx] depth]);

    self.rootNode = rsf.trees[treeIdx]; [self.rootNode layoutTree];
    RSFTreeView *treeView = [[RSFTreeView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - LARGE_VIEW_SIZE)/2.0, (self.view.bounds.size.height - LARGE_VIEW_SIZE)/2.0, LARGE_VIEW_SIZE, LARGE_VIEW_SIZE)];
    treeView.rootNode = self.rootNode;
    [self.view addSubview:treeView];
  } else {
    NSLog(@"Error reading tree %@\n", rsf.rsfName);
  }
}

#define VIEW_SIZE 400
-(void)setupSimple
{
  
  self.rootNode = [self simpleGraph2AutoLayout];
  
  RSFTreeView *treeView = [[RSFTreeView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - VIEW_SIZE)/2.0, (self.view.bounds.size.height - VIEW_SIZE)/2.0, VIEW_SIZE, VIEW_SIZE)];
  treeView.rootNode = self.rootNode;
  [self.view addSubview:treeView];
  
}

-(RSFNode *)simpleGraph
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

  return n1;
}

-(RSFNode *)simpleGraph2
{
  RSFNode *n1 = [[RSFNode alloc] init];
  n1.nodeId = 1; n1.pos = NodePositionMake(2.0, 7.0);
  
  RSFNode *n2 = [[RSFNode alloc] init];
  n2.nodeId = 2; n2.pos = NodePositionMake(1.0, 5.0);
  
  RSFNode *n3 = [[RSFNode alloc] init];
  n3.nodeId = 3; n3.pos = NodePositionMake(3.0, 5.0);
  
  RSFNode *n4 = [[RSFNode alloc] init];
  n4.nodeId = 4; n4.pos = NodePositionMake(2.0, 3.0);

  RSFNode *n5 = [[RSFNode alloc] init];
  n5.nodeId = 5; n5.pos = NodePositionMake(1.0, 1.0);

  RSFNode *n6 = [[RSFNode alloc] init];
  n6.nodeId = 6; n6.pos = NodePositionMake(3.0, 1.0);

  RSFNode *n7 = [[RSFNode alloc] init];
  n7.nodeId = 7; n7.pos = NodePositionMake(4.0, 3.0);

  n1.left = n2;
  n1.right = n3;
  n2.left = nil;
  n2.right = nil;
  n3.left = n4;
  n4.left = n5;
  n4.right = n6;
  n5.left = nil;
  n5.right = nil;
  n6.left = nil;
  n6.right = nil;
  n3.right = n7;
  n7.left = nil;
  n7.right = nil;
  
  return n1;
}

-(RSFNode *)simpleGraph2AutoLayout
{
  RSFNode *n1 = [[RSFNode alloc] init];
  n1.nodeId = 1;
  
  RSFNode *n2 = [[RSFNode alloc] init];
  n2.nodeId = 2;
  
  RSFNode *n3 = [[RSFNode alloc] init];
  n3.nodeId = 3;
  
  RSFNode *n4 = [[RSFNode alloc] init];
  n4.nodeId = 4;
  
  RSFNode *n5 = [[RSFNode alloc] init];
  n5.nodeId = 5;
  
  RSFNode *n6 = [[RSFNode alloc] init];
  n6.nodeId = 6;
  
  RSFNode *n7 = [[RSFNode alloc] init];
  n7.nodeId = 7;
  
  n1.left = n2;
  n1.right = n3;
  n2.left = nil;
  n2.right = nil;
  n3.left = n4;
  n4.left = n5;
  n4.right = n6;
  n5.left = nil;
  n5.right = nil;
  n6.left = nil;
  n6.right = nil;
  n3.right = n7;
  n7.left = nil;
  n7.right = nil;
  
  [n1 layoutTree];
  
  return n1;
}



@end
