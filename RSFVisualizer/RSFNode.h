//
//  RSFNode.h
//  RSFVisualizer
//
//  Created by Erik Frisk on 12/01/15.
//  Copyright (c) 2015 Erik Frisk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct _NodePosition
{
  double x;
  double y;
} NodePosition;

NodePosition NodePositionMake(double x, double y);

@interface RSFNode : NSObject
@property (nonatomic) int nodeId;
@property (nonatomic) int treeId;
@property (nonatomic) int variableIdx;
@property (nonatomic) int level;
@property (nonatomic) double splitValue;

@property (nonatomic) NodePosition pos;
@property (nonatomic, strong) RSFNode *left;
@property (nonatomic, strong) RSFNode *right;
@property (nonatomic) BOOL hasLayout;

-(void)layoutTree;

-(int)numberOfNodes;
-(int)numberOfLeaves;
-(int)depth;
-(BOOL)isLeaf;
-(BOOL)hasLayout;

-(int)subTreeVariableIndex:(RSFNode *)node withMarkings:(NSArray *)markings;

@end
