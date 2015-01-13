//
//  IDGenerator.m
//  RSFVisualizer
//
//  Created by Erik Frisk on 13/01/15.
//  Copyright (c) 2015 Erik Frisk. All rights reserved.
//

#import "IDGenerator.h"

@interface IDGenerator()
@property (nonatomic) int id;
@end
@implementation IDGenerator

-(id)init
{
  self = [super init];
  if (self) {
    self.id = 0;
  }
  return self;
}

-(int)newID
{
  return self.id++;
}

-(void)reset
{
  self.id = 0;
}

@end
