//
//  RSFFileReader.h
//  RSFVisualizer
//
//  Created by Erik Frisk on 13/01/15.
//  Copyright (c) 2015 Erik Frisk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSFNodeSpec.h"
#import "IDGenerator.h"
#import "RSFNode.h"

@interface RSFFileReader : NSObject
@property (nonatomic, strong) NSString *rsfFilePath;
@property (nonatomic, strong) NSString *xmlFilePath;
@property (nonatomic, strong) NSArray  *variableNames;

-(void)skipHeader;
-(NSString *)readOneLine;
-(RSFNodeSpec *)readRSFEntry:(IDGenerator *)idGen;
-(NSDictionary *)GetRSFFilesInDocumentsDirectory;

@end
