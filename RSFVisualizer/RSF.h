//
//  RSF.h
//  RSFVisualizer
//
//  Created by Erik Frisk on 13/01/15.
//  Copyright (c) 2015 Erik Frisk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IDGenerator.h"
#import "RSFFileReader.h"
#import "RSFNode.h"
#import "NodeConstraint.h"

@interface RSF : NSObject
@property (nonatomic, strong) NSString *rsfName;
@property (nonatomic, strong) NSDictionary *rsfFileInfo;
@property (nonatomic, strong) NSArray *trees; // of RSFNode *
@property (nonatomic, strong) NSArray *variableNames; // of NSString *
@property (nonatomic, strong) NSString *title;
@end
