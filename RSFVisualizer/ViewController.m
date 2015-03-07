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
#import "TreeSelectorTableViewController.h"
#import "VariablesTableViewController.h"
#import "RSFTreeMarkingDelegate.h"

@interface ViewController () <UIScrollViewDelegate,TreeSelectorViewControllerDelegate, VariablesTableViewControllerDelegate,RSFTreeMarkingDelegate>
@property (nonatomic, strong) RSFNode *rootNode;
@property (nonatomic, strong) NSData *d;
@property (nonatomic, strong) RSF *rsf;
@property (nonatomic, strong) NSDictionary *rsfFiles;
@property (nonatomic, strong) NSArray *rsfTreeNames;
@property (nonatomic) int currentTreeIdx;
@property (nonatomic, strong) RSFTreeView *treeView; // Current treeView
@property (nonatomic,weak) UIPopoverController *treeSelectionPopoverController;
@property (nonatomic, strong) NSMutableArray *variableMarkings; // of {@NO, @YES}
@property (nonatomic, strong) NSMutableArray *subTreeMarkings; // of {@NO, @YES}

@property (weak, nonatomic) IBOutlet UIScrollView *treeViewContainer;
@property (weak, nonatomic) IBOutlet UILabel *treeLabel;
@property (weak, nonatomic) IBOutlet UISlider *treeSlider;
@property (weak, nonatomic) IBOutlet UILabel *minValueLabel;
@property (weak, nonatomic) IBOutlet UISwitch *legendSwitch;
@property (weak, nonatomic) IBOutlet UILabel *maxValueLabel;
@end

@implementation ViewController

#pragma mark - Initializers, view life cycle
- (void)viewDidLoad
{
//#if TARGET_IPHONE_SIMULATOR
//  NSLog(@"Documents Directory: %@", [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
//#endif
  
  [super viewDidLoad];
  
  self.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
  self.navigationItem.leftItemsSupplementBackButton = YES;
  
  RSFFileReader *rsfFilereader = [[RSFFileReader alloc] init];
  self.rsfFiles = [rsfFilereader GetRSFFilesInDocumentsDirectory];

  NSMutableArray *treeNames = [[NSMutableArray alloc] init];
  NSEnumerator *enumerator = [self.rsfFiles keyEnumerator];
  NSString *k;
  
  while ((k = [enumerator nextObject])) {
    [treeNames addObject:k];
  }
  self.rsfTreeNames = treeNames;
  self.treeLabel.text = @"";
}

-(void)viewDidLayoutSubviews
{
  [super viewDidLayoutSubviews];
  if ([self.rsf.trees count] > self.currentTreeIdx) {
    [self showTree:self.currentTreeIdx];
  }
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

    self.variableMarkings = [[NSMutableArray alloc] initWithCapacity:[self.rsf.variableNames count]];
    self.subTreeMarkings  = [[NSMutableArray alloc] initWithCapacity:[self.rsf.variableNames count]];
    for (int i=0; i < [self.rsf.variableNames count]; i++) {
      self.variableMarkings[i] = @NO;
      self.subTreeMarkings[i] = @NO;
    }
    [self updateUI];
    // Get master controller in split view
    VariablesTableViewController *vtvc = (VariablesTableViewController *)[self.splitViewController.viewControllers[0] topViewController];
    vtvc.rsf = self.rsf;
    vtvc.delegate = self;
  } else {
    NSLog(@"Error reading tree %@\n", rsfName);
  }
}

-(void)updateUI
{
  if (self.rsf) {
    self.treeSlider.minimumValue = 1;
    self.treeSlider.maximumValue = [self.rsf.trees count];
    self.minValueLabel.text = @"1";
    self.maxValueLabel.text = [NSString stringWithFormat:@"%d", (int)[self.rsf.trees count]];
    self.title = [@"Random Survival Forest: " stringByAppendingString:self.rsf.title];
  }
}

#pragma mark - UIScrollViewDelegate methods
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
  return self.treeView;
}

#pragma mark - UI Actions
- (IBAction)nextTree:(UIButton *)sender
{
  if (self.currentTreeIdx < [self.rsf.trees count]-2) {
    self.currentTreeIdx = self.currentTreeIdx + 1;
    [self showTree:self.currentTreeIdx];
    self.treeSlider.value = self.currentTreeIdx + 1;
    [self.treeView redraw];
  }
}

- (IBAction)previousTree:(UIButton *)sender
{
  if (self.currentTreeIdx > 0) {
    self.currentTreeIdx = self.currentTreeIdx - 1;
    [self showTree:self.currentTreeIdx];
    self.treeSlider.value = self.currentTreeIdx + 1;
  }
}

- (IBAction)treeInfoPressed:(UIButton *)sender
{
  NSLog(@"Todo, popup tree information");
}

- (IBAction)legendSwitch:(UISwitch *)sender
{
  if (self.treeViewContainer.subviews[0]) {
    RSFTreeView *v = self.treeViewContainer.subviews[0];
    v.legend = !sender.on;
  }
}
- (IBAction)sliderMoved:(UISlider *)sender
{
  if (sender.value-1 != self.currentTreeIdx) {
    self.currentTreeIdx = self.treeSlider.value - 1;
    [self showTree:self.currentTreeIdx];
  }
}
- (IBAction)clearMarkings:(UIButton *)sender
{
  if (self.treeView) {
    for (int ii=0; ii < [self.rsf.variableNames count]; ii++) {
      self.variableMarkings[ii] = @NO;
      self.subTreeMarkings[ii] = @NO;
    }
    [self.treeView redraw];
  }
}

#pragma mark - RSFTreeMarkingDelegate methods
-(BOOL)isVariableMarked:(int)nodeIdx
{
  return [self.variableMarkings[nodeIdx-1] isEqual:@YES] ? YES : NO;
}

-(BOOL)isSubTreeMarked:(int)nodeIdx
{
  return [self.subTreeMarkings[nodeIdx-1] isEqual:@YES] ? YES : NO;
}

#pragma mark - VariablesTableViewControllerDelegate method
-(void)switchVariableMarking:(int)variableIdx
{
  self.variableMarkings[variableIdx-1] = [self.variableMarkings[variableIdx-1] isEqual:@YES] ? @NO : @YES;
  [self.treeView redraw];
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
    self.treeView = [[RSFTreeView alloc] initWithFrame:CGRectZero]; // Create with dummy size

    // Configure rendering
    self.treeView.drawBorder = NO;
    self.treeView.legend = !self.legendSwitch.on;
    self.treeView.nodeLabel = NODE_LEVEL;
    self.treeView.rootNode = self.rootNode;
    self.treeView.variableNames = self.rsf.variableNames;
    self.treeView.delegate = self;

    CGSize treeSize = [self.treeView sizeOfGraph];
    self.treeView.frame = CGRectMake(0.0, 0.0, treeSize.width, treeSize.height);

    double minZoomScale = self.treeViewContainer.frame.size.width/treeSize.width;
    minZoomScale = MIN(minZoomScale, self.treeViewContainer.frame.size.height/treeSize.height);
    
    
    self.treeViewContainer.contentSize = treeSize;
    self.treeViewContainer.minimumZoomScale = minZoomScale;
    self.treeViewContainer.maximumZoomScale = 2;
    self.treeViewContainer.showsHorizontalScrollIndicator = YES;
    self.treeViewContainer.showsVerticalScrollIndicator = YES;
    self.treeViewContainer.delegate = self;
    self.treeViewContainer.zoomScale = minZoomScale;
    
    // Add gesture recognizers
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.treeView addGestureRecognizer:tapGestureRecognizer];

    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    [self.treeView addGestureRecognizer:doubleTapRecognizer];
    
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
//    longPressGestureRecognizer.minimumPressDuration = 1.0; // seconds
    [self.treeView addGestureRecognizer:longPressGestureRecognizer];
    
    // Add view
    [self.treeViewContainer addSubview:self.treeView];
    
    // Update tree information text
    self.treeLabel.text = [self treeInfo:self.currentTreeIdx];
  }
}

#pragma mark - Gesture recognizers

-(void)longPress:(UILongPressGestureRecognizer *)gesture
{
  if (gesture.state==UIGestureRecognizerStateBegan) {
    RSFTreeView *view = (RSFTreeView *)gesture.view;
    CGPoint p = [gesture locationInView:view];
    RSFNode *longPressNode = [view tappedNode:p];

    int subTreeVarIdx = [self.rsf.trees[self.currentTreeIdx] subTreeVariableIndex:longPressNode withMarkings:self.subTreeMarkings];
    if (subTreeVarIdx > 0) {
      // Node in a marked subtree
      if (longPressNode && [longPressNode isLeaf]) {
        // Is a leaf, can only remove marking
        self.subTreeMarkings[subTreeVarIdx-1] =  @NO;
      } else if(longPressNode){
        // Is not a leaf, flip marking
        self.subTreeMarkings[subTreeVarIdx-1] =  [self.subTreeMarkings[subTreeVarIdx-1] isEqual:@YES] ? @NO  :@YES;
      }
    } else {
      // Node not in a marked subtree
      if (longPressNode && ![longPressNode isLeaf]) {
        // Mark node opnly if it is not a leaf
        self.subTreeMarkings[longPressNode.variableIdx-1] =  @YES;
      }
    }    
    [self.treeView redraw];
  }
}


-(void)doubleTap:(UITapGestureRecognizer *)gesture
{
  if (gesture.state == UIGestureRecognizerStateRecognized) {
    CGFloat newZoomScale;
    CGFloat zoomDelta = (self.treeViewContainer.maximumZoomScale - self.treeViewContainer.minimumZoomScale)*0.3;
    
    if (self.treeViewContainer.zoomScale > self.treeViewContainer.maximumZoomScale - zoomDelta) {
      // Zoom out to show whole graph
      newZoomScale = self.treeViewContainer.minimumZoomScale;
    } else {
      // Zoom in a little
      newZoomScale = MIN(self.treeViewContainer.zoomScale + zoomDelta, self.treeViewContainer.maximumZoomScale);
    }
//    NSLog(@"doubleTap: zoomScale = %f, maximimZoomScale = %f, minimumZoomScale = %f, newZoomScale = %f", self.treeViewContainer.zoomScale, self.treeViewContainer.maximumZoomScale, self.treeViewContainer.minimumZoomScale, newZoomScale);
    [self.treeViewContainer setZoomScale:newZoomScale animated:YES];
  }
}

-(void)tap:(UITapGestureRecognizer *)gesture
{
  RSFTreeView *view = (RSFTreeView *)gesture.view;
  CGPoint p = [gesture locationInView:view];
  RSFNode *tappedNode = [view tappedNode:p];
  
  if (tappedNode && ![tappedNode isLeaf]) {
    self.variableMarkings[tappedNode.variableIdx-1] = [self.variableMarkings[tappedNode.variableIdx-1] isEqual:@YES] ? @NO : @YES;
    [view redraw];
  } else if(  tappedNode ) {
//    NSLog(@"Tapped on a leaf node");
    [tappedNode.constraints debugPrint];
  }
}

-(NSString *)treeInfo:(int)treeIdx
{
  if ([self.rsf.trees count]>0) {
    return [NSString stringWithFormat:@"Tree %d: %d nodes, %d leaves, and depth %d", treeIdx+1, [self.rsf.trees[treeIdx] numberOfNodes], [self.rsf.trees[treeIdx] numberOfLeaves], [self.rsf.trees[treeIdx] depth]];
  } else {
    return @"";
  }
}

#pragma mark - View navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.destinationViewController isKindOfClass:[TreeSelectorTableViewController class]]) {
    TreeSelectorTableViewController *tsvc = (TreeSelectorTableViewController *)segue.destinationViewController;
    tsvc.rsfTreeNames = self.rsfTreeNames;
    tsvc.delegate = self;
  }
}

#pragma mark - A new RSFTree selected callback
-(void)selectedTreeWithName:(NSString *)treeName
{
  [self.treeSelectionPopoverController dismissPopoverAnimated:YES];
//  dispatch_async(dispatch_queue_create("RSFLoadqueue", DISPATCH_QUEUE_SERIAL), ^(void){
//    [self setup:treeName withURLs:[self.rsfFiles objectForKey:treeName]];
//    dispatch_async(dispatch_get_main_queue(), ^(void){ self.treeSlider.value = 1;
//                                                      [self updateUI];
//                                                      [self showTree:0];});
//  });
  [self setup:treeName withURLs:[self.rsfFiles objectForKey:treeName]];
  self.treeSlider.value = 1;
  [self updateUI];
  [self showTree:0];
}

@end
