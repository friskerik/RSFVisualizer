//
//  RSF.m
//  RSFVisualizer
//
//  Created by Erik Frisk on 13/01/15.
//  Copyright (c) 2015 Erik Frisk. All rights reserved.
//

#import "RSF.h"

@interface RSF()
@property (nonatomic, strong) NSString *rsfTxtFileName;
@end

@implementation RSF

-(void)setRsfName:(NSString *)rsfName
{
  _rsfName = rsfName;
  
  self.rsfTxtFileName = [rsfName stringByAppendingString:@".txt"];
  
  NSString *rsfFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.rsfTxtFileName];
  RSFFileReader *fr = [[RSFFileReader alloc] init];
  fr.rsfFilePath = rsfFilePath; // reads file into buffer
  
  [fr skipHeader]; // Skip the first line, header
  IDGenerator *idGen = [[IDGenerator alloc] init];
  
  NSMutableArray *trees = [[NSMutableArray alloc] init];
  RSFNode *rootNode;
  
  while ((rootNode = [self ReadRSFTree:idGen onLevel:0 withReader:fr])) {
    if (rootNode) {
      [trees addObject:rootNode];
      [idGen reset];
    }
  }
  
  self.trees = trees;
}

-(RSFNode *)ReadRSFTree:(IDGenerator *)idGen onLevel:(int)level withReader:(RSFFileReader *)fr
{
  RSFNodeSpec *nodeSpec = [fr readRSFEntry:idGen];
  RSFNode *node = nil;
  
  if (nodeSpec) {
    node = [[RSFNode alloc] init];
    
    node.nodeId = nodeSpec.nodeID;
    node.treeId = nodeSpec.treeID;
    node.variableIdx = nodeSpec.parmID;
    node.level = level;
    node.splitValue = nodeSpec.contPT;

    if (nodeSpec.parmID != 0) {
      // This is not a leaf node, read the sub-trees
      node.left  = [self ReadRSFTree:idGen onLevel:level+1 withReader:fr];
      node.right = [self ReadRSFTree:idGen onLevel:level+1 withReader:fr];
    }
  }
  return node;
}
@end
