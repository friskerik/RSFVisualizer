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
@property (nonatomic, strong) NSString *rsfXMLFileName;
@end

@implementation RSF

-(void)setRsfFileInfo:(NSDictionary *)rsfFileInfo
{
  _rsfFileInfo = rsfFileInfo;
  
  NSURL *txtURL = [rsfFileInfo objectForKey:@"txt"];
  NSURL *xmlURL = [rsfFileInfo objectForKey:@"xml"];
  
  NSString *rsfFilePath = [txtURL path];
  NSString *xmlFilePath = [xmlURL path];
  
  RSFFileReader *fr = [[RSFFileReader alloc] init];
  
  // Hande XML file
  fr.xmlFilePath = xmlFilePath; // reads and parses xml file
  self.variableNames = fr.variableNames;
  
  // Handle graph definition file
  fr.rsfFilePath = rsfFilePath; // reads file into buffer
  
  // Generate tree representation from data
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

-(void)setRsfName:(NSString *)rsfName
{
  _rsfName = rsfName;
  
  NSString *rsfTxtFileName = [rsfName stringByAppendingString:@".txt"];
  NSString *rsfXMLFileName = [rsfName stringByAppendingString:@".xml"];
  
  NSString *rsfFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:rsfTxtFileName];
  NSString *xmlFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:rsfXMLFileName];

  RSFFileReader *fr = [[RSFFileReader alloc] init];

  // Hande XML file
  fr.xmlFilePath = xmlFilePath; // reads and parses xml file
  self.variableNames = fr.variableNames;
  
  // Handle graph definition file
  fr.rsfFilePath = rsfFilePath; // reads file into buffer
  
  // Generate tree representation from data
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
