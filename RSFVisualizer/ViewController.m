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

@interface ViewController () <UIScrollViewDelegate,TreeSelectorViewControllerDelegate>
@property (nonatomic, strong) RSFNode *rootNode;
@property (nonatomic, strong) NSData *d;
@property (nonatomic, strong) RSF *rsf;
@property (nonatomic, strong) NSDictionary *rsfFiles;
@property (nonatomic, strong) NSArray *rsfTreeNames;
@property (nonatomic) int currentTreeIdx;
@property (nonatomic, strong) RSFTreeView *treeView; // Current treeView
@property (nonatomic,weak) UIPopoverController *treeSelectionPopoverController;

@property (weak, nonatomic) IBOutlet UIScrollView *treeViewContainer;
@property (weak, nonatomic) IBOutlet UILabel *treeLabel;
@property (weak, nonatomic) IBOutlet UISlider *treeSlider;
@property (weak, nonatomic) IBOutlet UILabel *minValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxValueLabel;
@property (weak, nonatomic) IBOutlet UISwitch *legendSwitch;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *vimpButton;
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
  self.vimpButton.enabled = NO;
  self.treeLabel.text = @"";
  
  
//  NSString *key = @"rsf_200";
////  NSString *key = @"fleet";
//  
//  [self setup:key withURLs:[self.rsfFiles objectForKey:key]]; // Search files in the document folder
////  [self setup:key withURLs:nil]; // Search fil in the resources
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
- (IBAction)nextTree:(UIButton *)sender
{
  if (self.currentTreeIdx < [self.rsf.trees count]-2) {
    self.currentTreeIdx = self.currentTreeIdx + 1;
    [self showTree:self.currentTreeIdx];
    self.treeSlider.value = self.currentTreeIdx + 1;
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
      self.treeView.variableMarkings[ii] = @NO;
    }
    [self.treeView redraw];
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
    
    // Get master controller in split view
    VariablesTableViewController *vtvc = (VariablesTableViewController *)[self.splitViewController.viewControllers[0] topViewController];
    vtvc.variableNames = self.rsf.variableNames;
  } else {
    NSLog(@"Error reading tree %@\n", rsfName);
  }
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
  return self.treeView;
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

    self.treeView.variableMarkings = [[NSMutableArray alloc] init];
    for (int ii=0; ii < [self.rsf.variableNames count]; ii++) {
      [self.treeView.variableMarkings addObject:@NO];
    }

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
    
    // Add view
    [self.treeViewContainer addSubview:self.treeView];
    
    // Update tree information text
    self.treeLabel.text = [self treeInfo:self.currentTreeIdx];
  }
}



-(void)tap:(UITapGestureRecognizer *)gesture
{
  RSFTreeView *view = (RSFTreeView *)gesture.view;
  CGPoint p = [gesture locationInView:view];
  RSFNode *tappedNode = [view tappedNode:p];
  
  if (tappedNode && ![tappedNode isLeaf]) {
    view.variableMarkings[tappedNode.variableIdx-1] = [view.variableMarkings[tappedNode.variableIdx-1] isEqual:@YES] ? @NO : @YES;
    [view redraw];
//    NSString *alertTitle = self.rsf.variableNames[tappedNode.variableIdx-1];
//    
//    NSString *alertMessage = [NSString stringWithFormat:@"split value = %f", tappedNode.splitValue];
//    
//    UIAlertController* alert = [UIAlertController alertControllerWithTitle:alertTitle
//                                                                   message:alertMessage
//                                                            preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
//                                                          handler:^(UIAlertAction * action) {}];
//    
//    [alert addAction:defaultAction];
//
//    if (![tappedNode isLeaf]) {
//      UIAlertAction* markAction = [UIAlertAction actionWithTitle:@"Toggle mark" style:UIAlertActionStyleDefault
//                                                         handler:^(UIAlertAction * action) {
//                                                           if (![tappedNode isLeaf]) {
//                                                             view.variableMarkings[tappedNode.variableIdx-1] = [view.variableMarkings[tappedNode.variableIdx-1] isEqual:@YES] ? @NO : @YES;
//                                                             [view redraw];
//                                                           }
//                                                         }];
//      
//      [alert addAction:markAction];
//    }
//    [self presentViewController:alert animated:YES completion:nil];
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.destinationViewController isKindOfClass:[TreeSelectorTableViewController class]]) {
    TreeSelectorTableViewController *tsvc = (TreeSelectorTableViewController *)segue.destinationViewController;
    tsvc.rsfTreeNames = self.rsfTreeNames;
    tsvc.delegate = self;
  }
}

-(void)selectedTreeWithName:(NSString *)treeName
{
  [self.treeSelectionPopoverController dismissPopoverAnimated:YES];
  [self setup:treeName withURLs:[self.rsfFiles objectForKey:treeName]];
  self.treeSlider.value = 1;
  [self showTree:0];
}

@end
