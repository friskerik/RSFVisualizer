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
//#import "RSFNodeView.h"
#import "RSFFileReader.h"
#import "RSFNode+additions.h"
#import "IDGenerator.h"

@interface ViewController ()
@property (nonatomic, strong) RSFNode *rootNode;
@property (nonatomic, strong) NSData *d;
@property (nonatomic, strong) RSF *rsf;
@property (nonatomic) int currentTreeIdx;

@property (weak, nonatomic) IBOutlet UIView *treeViewContainer;
@property (weak, nonatomic) IBOutlet UILabel *treeLabel;
@property (weak, nonatomic) IBOutlet UISlider *treeSlider;
@property (weak, nonatomic) IBOutlet UILabel *minValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxValueLabel;
@property (weak, nonatomic) IBOutlet UISwitch *legendSwitch;
@end

@implementation ViewController

#pragma mark - Initializers, view life cycle
- (void)viewDidLoad
{
//#if TARGET_IPHONE_SIMULATOR
//  NSLog(@"Documents Directory: %@", [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
//#endif
  
  [super viewDidLoad];
  
  RSFFileReader *rsfFilereader = [[RSFFileReader alloc] init];
  NSDictionary *rsfFiles = [rsfFilereader GetRSFFilesInDocumentsDirectory];

//  NSString *key = @"rsf_200";
  NSString *key = @"fleet";
  
  [self setup:key withURLs:[rsfFiles objectForKey:key]]; // Search files in the document folder
//  [self setup:key withURLs:nil]; // Search fil in the resources
}

-(void)viewDidLayoutSubviews
{
  [super viewDidLayoutSubviews];
  [self showTree:self.currentTreeIdx];
}

#pragma mark - Setters, and getters
-(RSF *)rsf
{
  if (!_rsf) _rsf = [[RSF alloc] init];
  return _rsf;
}

-(void)setCurrentTreeIdx:(int)currentTreeIdx
{
  if ([self.rsf.trees count] > 0) {
    _currentTreeIdx = currentTreeIdx;
    _currentTreeIdx = MAX(0, _currentTreeIdx);
    _currentTreeIdx = MIN((int)[self.rsf.trees count]-1, _currentTreeIdx);
  }
}

- (IBAction)legendSwitch:(UISwitch *)sender
{
  if (self.treeViewContainer.subviews[0]) {
    RSFTreeView *v = self.treeViewContainer.subviews[0];
    v.legend = sender.on;
  }
}
- (IBAction)sliderMoved:(UISlider *)sender
{
  if (sender.value-1 != self.currentTreeIdx) {
    self.currentTreeIdx = self.treeSlider.value - 1;
    [self showTree:self.currentTreeIdx];
  }
}

#pragma mark - Main setup, read RSF files
-(void)setup:(NSString *)rsfName withURLs:(NSDictionary *)rsfFileURLs
{
  // Read RSF definition files
  if (rsfFileURLs) {
    self.rsf.rsfFileInfo = rsfFileURLs;
  } else {
    self.rsf.rsfName = rsfName;
  }
  
  // Found any?
  if ([self.rsf.trees count]>0) {
    NSLog(@"Read %lu tree(s) from file %@\n", (unsigned long)[self.rsf.trees count], rsfName);
    self.currentTreeIdx = 0;
    self.treeSlider.minimumValue = 1;
    self.treeSlider.maximumValue = [self.rsf.trees count];
    self.minValueLabel.text = @"1";
    self.maxValueLabel.text = [NSString stringWithFormat:@"%d", (int)[self.rsf.trees count]];
    
    self.title = [@"Random Survival Forest: " stringByAppendingString:rsfName];
  } else {
    NSLog(@"Error reading tree %@\n", rsfName);
  }
}


#pragma mark - Show current tree
-(void)showTree:(int)treeIdx
{
  if (treeIdx < [self.rsf.trees count]) {
    for (UIView *v in self.treeViewContainer.subviews) {
      [v removeFromSuperview];
    }

    self.rootNode = self.rsf.trees[treeIdx];

    // Compute layoutFrame, and screen size of graph
    RSFTreeView *treeView = [[RSFTreeView alloc] initWithFrame:CGRectZero]; // Create with dummy size

    // Configure rendering
    treeView.drawBorder = NO;
    treeView.legend = self.legendSwitch.on;
    treeView.nodeLabel = NODE_LEVEL;
    treeView.rootNode = self.rootNode;
    treeView.variableNames = self.rsf.variableNames;

    // Nicely locate the tree in the center of the screen
    CGSize treeSize = [treeView sizeOfGraph];
    double graphLayoutRatio = treeSize.width/treeSize.height;
    double frameWidth;
    double frameHeight;
    if (graphLayoutRatio > self.treeViewContainer.bounds.size.width/self.treeViewContainer.bounds.size.height) { // Landscape
      frameWidth  = 0.9*self.treeViewContainer.bounds.size.width;
      frameHeight = frameWidth/graphLayoutRatio;
    } else { // Portrait
      frameHeight = 0.9*self.treeViewContainer.bounds.size.height;
      frameWidth  = frameHeight*graphLayoutRatio;
    }
    treeView.frame = CGRectMake((self.treeViewContainer.bounds.size.width - frameWidth)/2.0,
                                (self.treeViewContainer.bounds.size.height - frameHeight)/2.0,
                                frameWidth,
                                frameHeight);
//#define GRAY_SHADE 0.9
//    treeView.backgroundColor = [UIColor colorWithRed:GRAY_SHADE green:GRAY_SHADE blue:GRAY_SHADE alpha:1];
    [treeView scaleToFit];
    
    // Add gesture recognizers
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [treeView addGestureRecognizer:tapGestureRecognizer];
    
    UISwipeGestureRecognizer *swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    UISwipeGestureRecognizer *swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.treeViewContainer addGestureRecognizer:swipeLeftGestureRecognizer];
    [self.treeViewContainer addGestureRecognizer:swipeRightGestureRecognizer];
    
    // Add view
    [self.treeViewContainer addSubview:treeView];
    
    // Update tree information text
    self.treeLabel.text = [self treeInfo:self.currentTreeIdx];
  }
}

-(void)swipe:(UISwipeGestureRecognizer *)gesture
{
  if (gesture.state == UIGestureRecognizerStateEnded) {
    if (gesture.direction==UISwipeGestureRecognizerDirectionLeft && (self.currentTreeIdx < [self.rsf.trees count]-2)) {
      self.currentTreeIdx = self.currentTreeIdx + 1;
      self.treeSlider.value = self.currentTreeIdx + 1;
      [self showTree:self.currentTreeIdx];
    } else if (gesture.direction==UISwipeGestureRecognizerDirectionRight && self.currentTreeIdx > 0) {
      self.currentTreeIdx = self.currentTreeIdx - 1;
      self.treeSlider.value = self.currentTreeIdx - 1;
      [self showTree:self.currentTreeIdx];
    }
  }
}

-(void)tap:(UITapGestureRecognizer *)gesture
{
  RSFTreeView *view = (RSFTreeView *)gesture.view;
  CGPoint p = [gesture locationInView:view];
  RSFNode *tappedNode = [view tappedNode:p];
  
  if (tappedNode) {
    NSLog(@"Tapped on node with id %d\n", tappedNode.nodeId);
  }
}

-(NSString *)treeInfo:(int)treeIdx
{
  return [NSString stringWithFormat:@"Tree %d: %d nodes, %d leaves, and depth %d", treeIdx+1, [self.rsf.trees[treeIdx] numberOfNodes], [self.rsf.trees[treeIdx] numberOfLeaves], [self.rsf.trees[treeIdx] depth]];
}

@end
