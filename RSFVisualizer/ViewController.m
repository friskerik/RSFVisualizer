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
#import "IDGenerator.h"

@interface ViewController ()
@property (nonatomic, strong) RSFNode *rootNode;
@property (nonatomic, strong) NSData *d;
@property (nonatomic, strong) RSF *rsf;
@property (weak, nonatomic) IBOutlet UIView *treeViewContaner;
@property (weak, nonatomic) IBOutlet UILabel *treeLabel;
@property (weak, nonatomic) IBOutlet UISlider *treeSlider;
@property (nonatomic) int currentTreeIdx;
@end

@implementation ViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self setup];
}

-(void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  NSLog(@"viewDidAppear!\n");
  [self showTree:self.currentTreeIdx];
}


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

-(void)showTree:(int)treeIdx
{
  if (treeIdx < [self.rsf.trees count]) {
    for (UIView *v in self.treeViewContaner.subviews) {
      [v removeFromSuperview];
    }

    self.rootNode = self.rsf.trees[treeIdx];

    // Compute layoutFrame, and screen size of graph
    CGSize graphSize = [RSFTreeView sizeOfGraph:self.rootNode];
    
    // Add RSFTreeView, center located on the screen, frame max 90% of width/height of View
    double frameScale = 1.0;
    frameScale = MIN(frameScale, 0.9*self.treeViewContaner.bounds.size.width/graphSize.width);
    frameScale = MIN(frameScale, 0.9*self.treeViewContaner.bounds.size.height/graphSize.height);
    
    double frameWidth = graphSize.width*frameScale;
    double frameHeight = graphSize.height*frameScale;

    CGRect treeRect = CGRectMake((self.treeViewContaner.bounds.size.width - frameWidth)/2.0, (self.treeViewContaner.bounds.size.height - frameHeight)/2.0, frameWidth, frameHeight);

//    NSLog(@"(showTree) treeViewContainer.frame: (%f,%f) %f x %f\n", self.treeViewContaner.frame.origin.x, self.treeViewContaner.frame.origin.y,
//          self.treeViewContaner.frame.size.width, self.treeViewContaner.frame.size.height);
//    NSLog(@"(showTree) frameWidth x frameHeight: %f x %f\n", frameWidth, frameHeight);
//    NSLog(@"(showTree) treeRect: (%f,%f) %f x %f\n", treeRect.origin.x, treeRect.origin.y,
//          treeRect.size.width, treeRect.size.height);
    RSFTreeView *treeView = [[RSFTreeView alloc] initWithFrame:treeRect];

    // Configure rendering
    treeView.drawBorder = NO;
    treeView.nodeLabel = NODE_ID;
    treeView.rootNode = self.rootNode;
    [treeView scaleToFit];
    
    // Add view
    [self.treeViewContaner addSubview:treeView];
    
    self.treeLabel.text = [self treeInfo:self.currentTreeIdx];
  }
}

-(NSString *)treeInfo:(int)treeIdx
{
  return [NSString stringWithFormat:@"Tree %d: %d nodes, %d leaves, and depth %d", treeIdx+1, [self.rsf.trees[treeIdx] numberOfNodes], [self.rsf.trees[treeIdx] numberOfLeaves], [self.rsf.trees[treeIdx] depth]];
}

-(void)setup
{
  // Read RSF definition files
//  rsf.rsfName = @"fleet1";
  self.rsf.rsfName = @"fleet";

  // Found any?
  if ([self.rsf.trees count]>0) {
    NSLog(@"Read %lu tree(s) from file %@\n", (unsigned long)[self.rsf.trees count], self.rsf.rsfName);
    self.currentTreeIdx = 0;
    self.treeSlider.minimumValue = 1;
    self.treeSlider.maximumValue = [self.rsf.trees count];
    
    // Add gesture recognizers
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    swipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.treeViewContaner addGestureRecognizer:swipe];
    swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.treeViewContaner addGestureRecognizer:swipe];

  } else {
    NSLog(@"Error reading tree %@\n", self.rsf.rsfName);
  }
}

-(void)swipe:(UIGestureRecognizer *)gesture
{
  if (gesture.state==UIGestureRecognizerStateEnded) {
    if ([gesture isKindOfClass:[UISwipeGestureRecognizer class]]) {
      UISwipeGestureRecognizer *swipeGesture = (UISwipeGestureRecognizer *)gesture;
      if (swipeGesture.direction == UISwipeGestureRecognizerDirectionLeft) {
        self.currentTreeIdx++;
        self.treeSlider.value = self.currentTreeIdx+1;
        [self showTree:self.currentTreeIdx];
      } else if (swipeGesture.direction == UISwipeGestureRecognizerDirectionRight) {
        self.currentTreeIdx--;
        self.treeSlider.value = self.currentTreeIdx+1;
        [self showTree:self.currentTreeIdx];
      }
    }
  }
}
- (IBAction)sliderMoved:(UISlider *)sender
{
  if ((int)self.treeSlider.value-1!=self.currentTreeIdx) {
    self.currentTreeIdx = (int)self.treeSlider.value-1;
    [self showTree:self.currentTreeIdx];
  }
  NSLog(@"Slider value: %d\n", (int)self.treeSlider.value);
}


//-(void)setup2
//{
//  NSMutableArray *nodes = [[NSMutableArray alloc] initWithCapacity:39];
//  IDGenerator *idGen = [[IDGenerator alloc] init];
//  
//  for (int ii=0; ii<=38; ii++) {
//    nodes[ii] = [[RSFNode alloc] init];
//    RSFNode *n = (RSFNode *)nodes[ii];
//    n.nodeId = [idGen newID];
//  }
//  ((RSFNode *)nodes[0]).left = nodes[1];
//  ((RSFNode *)nodes[1]).left = nodes[2];
//  ((RSFNode *)nodes[1]).right = nodes[3];
//  ((RSFNode *)nodes[3]).left = nodes[4];
//  ((RSFNode *)nodes[4]).left = nodes[5];
//  ((RSFNode *)nodes[5]).left = nodes[6];
//  ((RSFNode *)nodes[5]).right = nodes[7];
//  ((RSFNode *)nodes[7]).left = nodes[8];
//  ((RSFNode *)nodes[7]).right = nodes[9];
//  ((RSFNode *)nodes[3]).left = nodes[4];
//  ((RSFNode *)nodes[4]).right = nodes[10];
//  ((RSFNode *)nodes[10]).left = nodes[11];
//  ((RSFNode *)nodes[10]).right = nodes[12];
//  ((RSFNode *)nodes[3]).right = nodes[13];
//  
//  ((RSFNode *)nodes[0]).right = nodes[14];
//  ((RSFNode *)nodes[14]).left = nodes[15];
//  ((RSFNode *)nodes[14]).right = nodes[16];
//  ((RSFNode *)nodes[16]).left = nodes[17];
//  ((RSFNode *)nodes[17]).left = nodes[18];
//  ((RSFNode *)nodes[18]).left = nodes[19];
//  ((RSFNode *)nodes[19]).left = nodes[20];
//  ((RSFNode *)nodes[19]).right = nodes[21];
//  ((RSFNode *)nodes[18]).right = nodes[22];
//  ((RSFNode *)nodes[17]).right = nodes[23];
//  ((RSFNode *)nodes[23]).left = nodes[24];
//  ((RSFNode *)nodes[24]).left = nodes[25];
//  ((RSFNode *)nodes[24]).right = nodes[26];
//  ((RSFNode *)nodes[23]).right = nodes[27];
//  ((RSFNode *)nodes[16]).right = nodes[28];
//  ((RSFNode *)nodes[28]).left = nodes[29];
//  ((RSFNode *)nodes[28]).right = nodes[30];
//  ((RSFNode *)nodes[30]).left = nodes[31];
//  ((RSFNode *)nodes[31]).left = nodes[32];
//  ((RSFNode *)nodes[31]).right = nodes[33];
//  ((RSFNode *)nodes[30]).right = nodes[34];
//  ((RSFNode *)nodes[34]).left = nodes[35];
//  ((RSFNode *)nodes[34]).right = nodes[36];
//  ((RSFNode *)nodes[36]).left = nodes[37];
//  ((RSFNode *)nodes[36]).right = nodes[38];
//  
//  
//  self.rootNode = nodes[0];
//  
//  // Compute layoutFrame, and screen size of graph
//  CGSize graphSize = [RSFTreeView sizeOfGraph:self.rootNode];
//  
//  // Add RSFTreeView, center located on the screen, frame max 90% of width/height of View
//  double frameScale = 1.0;
//  frameScale = MIN(frameScale, 0.9*self.view.bounds.size.width/graphSize.width);
//  frameScale = MIN(frameScale, 0.9*self.view.bounds.size.height/graphSize.height);
//  
//  double frameWidth = graphSize.width*frameScale;
//  double frameHeight = graphSize.height*frameScale;
//  
//  RSFTreeView *treeView = [[RSFTreeView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - frameWidth)/2.0, (self.view.bounds.size.height - frameHeight)/2.0, frameWidth, frameHeight)];
//
//  // Configure rendering
//  treeView.drawBorder = YES;
//  treeView.nodeLabel = NODE_ID;
//  treeView.rootNode = self.rootNode;
//  [treeView scaleToFit];
//  
//  // Add view
//  [self.view addSubview:treeView];
//}

@end
