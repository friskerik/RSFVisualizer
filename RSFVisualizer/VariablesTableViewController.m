//
//  VariablesTableViewController.m
//  RSFVisualizer
//
//  Created by Erik Frisk on 29/01/15.
//  Copyright (c) 2015 Erik Frisk. All rights reserved.
//

#import "VariablesTableViewController.h"

@interface VariablesTableViewController ()
@property (nonatomic, strong) NSArray *sortedVariableDict;
@end

@implementation VariablesTableViewController

-(void)setRsf:(RSF *)rsf
{
  _rsf = rsf;

  NSMutableArray *varDict = [[NSMutableArray alloc] initWithCapacity:[rsf.variableNames count]];
  int i=1;
  for (NSString *v in rsf.variableNames) {
    [varDict addObject:@[v, [NSNumber numberWithInt:i]]];
    i++;
  }
  
  self.sortedVariableDict = [varDict sortedArrayUsingComparator:^NSComparisonResult(NSArray *obj1, NSArray *obj2) {
    NSString *key1 = (NSString *)[obj1 firstObject];
    NSString *key2 = (NSString *)[obj2 firstObject];
    return [key1 localizedCaseInsensitiveCompare:key2];
  }];
  
  [self.tableView reloadData];
}
- (void)viewDidLoad
{
  [super viewDidLoad];
  self.tableView.allowsMultipleSelection = YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return self.sortedVariableDict ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.sortedVariableDict ? [self.sortedVariableDict count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Variable Cell" forIndexPath:indexPath];

  cell.textLabel.text = (NSString *)[self.sortedVariableDict[indexPath.row] firstObject];
  return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  int varIdx = [(NSNumber *)[(NSArray *)self.sortedVariableDict[indexPath.row] lastObject] intValue];
  [self.delegate switchVariableMarking:varIdx];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
  int varIdx = [(NSNumber *)[(NSArray *)self.sortedVariableDict[indexPath.row] lastObject] intValue];
  [self.delegate switchVariableMarking:varIdx];  
}
@end
