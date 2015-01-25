//
//  TreeSelectorTableViewController.m
//  RSFVisualizer
//
//  Created by Erik Frisk on 24/01/15.
//  Copyright (c) 2015 Erik Frisk. All rights reserved.
//

#import "TreeSelectorTableViewController.h"

@interface TreeSelectorTableViewController ()

@end

@implementation TreeSelectorTableViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.rsfTreeNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RSFTreeCell" forIndexPath:indexPath];
  
  cell.textLabel.text = self.rsfTreeNames[indexPath.row];
  cell.detailTextLabel.text = @"No vimp";
  return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [self.delegate selectedTreeWithName: self.rsfTreeNames[indexPath.row]];
  [self dismissViewControllerAnimated:YES completion:nil];
  
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
