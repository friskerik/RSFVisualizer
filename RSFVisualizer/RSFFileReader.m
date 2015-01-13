//
//  RSFFileReader.m
//  RSFVisualizer
//
//  Created by Erik Frisk on 13/01/15.
//  Copyright (c) 2015 Erik Frisk. All rights reserved.
//

#import "RSFFileReader.h"

@interface RSFFileReader()
@property (nonatomic, strong) NSData *data;
@property (nonatomic) int idx;
@end

@implementation RSFFileReader

-(void)setRsfFilePath:(NSString *)rsfFilePath
{
  _rsfFilePath = rsfFilePath;
  
  self.data = [NSData dataWithContentsOfFile:rsfFilePath];
  self.idx = 0;
}

#define BUFFERSIZE 200
-(NSString *)readOneLine
{
  char c_str[BUFFERSIZE];
  char *buffer= (char *)[self.data bytes];
  
  int n=0;
  while (self.idx < [self.data length] && buffer[self.idx]!='\n') {
    c_str[n] = buffer[self.idx];
    self.idx++;
    n++;
  }
  if (self.idx > [self.data length] || buffer[self.idx]!='\n')  {
    return nil;
  } else {
    self.idx++;
    c_str[n]='\0';
    return [NSString stringWithCString:c_str encoding:NSASCIIStringEncoding];
  }
}

-(void)skipHeader
{
  [self readOneLine];
}

-(RSFNodeSpec *)readRSFEntry:(IDGenerator *)idGen
{
  NSArray *a = [[self readOneLine] componentsSeparatedByString:@" "];
  if ( [a count] == 6 ) {
    // No treeID nodeID parmID contPT mwcpSZ
    RSFNodeSpec *n = [[RSFNodeSpec alloc] init];
    NSString *s = a[1];
    n.treeID = (int)[s integerValue];
    n.nodeID = [idGen newID];
    s = a[3];
    n.parmID = (int)[s integerValue];
    if (n.parmID==0) {
      n.contPT = 0.0;
    } else {
      s = a[4];
      n.contPT = (double)[s doubleValue];
    }
    return n;
  } else {
    return nil;
  }
}

@end
