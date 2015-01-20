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
#import "RSFNodeView.h"
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
    
    // Add gesture recognizers
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    swipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.treeViewContainer addGestureRecognizer:swipe];
    swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    swipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.treeViewContainer addGestureRecognizer:swipe];
    
  } else {
    NSLog(@"Error reading tree %@\n", rsfName);
  }
}

#pragma mark - Gesture handler och interface action handlers
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
}
- (IBAction)switchFlipped:(UISwitch *)sender
{
  if ([self.treeViewContainer.subviews count]>0) {
    RSFTreeView *v = (RSFTreeView *)self.treeViewContainer.subviews[0];
    if (sender.on) {
      v.legend = YES;
    } else {
      v.legend = NO;
    }
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
    CGSize graphSize = [RSFTreeView sizeOfGraph:self.rootNode];
    
    // Add RSFTreeView, center located on the screen, frame max 90% of width/height of View
    double frameScale = 1.0;
    frameScale = MIN(frameScale, 0.95*self.treeViewContainer.bounds.size.width/graphSize.width);
    frameScale = MIN(frameScale, 0.95*self.treeViewContainer.bounds.size.height/graphSize.height);

    double frameWidth = graphSize.width*frameScale;
    double frameHeight = graphSize.height*frameScale;

    CGRect treeRect = CGRectMake((self.treeViewContainer.bounds.size.width - frameWidth)/2.0,
                                 (self.treeViewContainer.bounds.size.height - frameHeight)/2.0,
                                 frameWidth,
                                 frameHeight);
    
    RSFTreeView *treeView = [[RSFTreeView alloc] initWithFrame:treeRect];

    // Configure rendering
    treeView.drawBorder = NO;
    treeView.legend = self.legendSwitch.on;
    treeView.nodeLabel = NODE_LEVEL;
    treeView.rootNode = self.rootNode;
    treeView.variableNames = self.rsf.variableNames;
    [treeView scaleToFit];
    
    // Add view
    [self.treeViewContainer addSubview:treeView];
    
    // Add tapGestureRecognizer
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.treeViewContainer addGestureRecognizer:tapGestureRecognizer];
    
    // Update tree information text
    self.treeLabel.text = [self treeInfo:self.currentTreeIdx];
  }
}

#pragma mark - Gesture recognizer
-(void)tap:(UITapGestureRecognizer *)gesture
{
  if (gesture.state == UIGestureRecognizerStateEnded) {
    RSFTreeView *tv = (RSFTreeView *)self.treeViewContainer.subviews[0];
    CGPoint p = [gesture locationInView:tv];

    for (UIView *v in tv.subviews) {
      if( CGRectContainsPoint(v.frame, p) ) {
        RSFNodeView *nv = (RSFNodeView *)v;
        NSLog(@"Tap on node with id %d\n", nv.node.nodeId);

        if ( nv.node.variableIdx>0 ) {
          NSString *nodeMessage = [NSString stringWithFormat:@"split value: %f", nv.node.splitValue];
          
          UIAlertController* alert = [UIAlertController alertControllerWithTitle:self.rsf.variableNames[nv.node.variableIdx-1]
                                                                         message:nodeMessage
                                                                  preferredStyle:UIAlertControllerStyleAlert];
          
          UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * action) {}];
          
          [alert addAction:defaultAction];
          [self presentViewController:alert animated:YES completion:nil];
        }
      }
    }
  }
}


-(NSString *)treeInfo:(int)treeIdx
{
  return [NSString stringWithFormat:@"Tree %d: %d nodes, %d leaves, and depth %d", treeIdx+1, [self.rsf.trees[treeIdx] numberOfNodes], [self.rsf.trees[treeIdx] numberOfLeaves], [self.rsf.trees[treeIdx] depth]];
}

@end
