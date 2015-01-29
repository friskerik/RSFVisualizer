//
//  VariablesTableViewController.m
//  RSFVisualizer
//
//  Created by Erik Frisk on 29/01/15.
//  Copyright (c) 2015 Erik Frisk. All rights reserved.
//

#import "VariablesTableViewController.h"

@interface VariablesTableViewController ()

@end

@implementation VariablesTableViewController

-(void)setVariableNames:(NSArray *)variableNames
{
  _variableNames = variableNames;
  [self.tableView reloadData];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return self.variableNames ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.variableNames ? [self.variableNames count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Variable Cell" forIndexPath:indexPath];

  cell.textLabel.text = self.variableNames[indexPath.row];
  return cell;
}

@end
