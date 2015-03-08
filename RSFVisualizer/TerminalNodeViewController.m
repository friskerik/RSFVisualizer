//
//  TerminalNodeViewController.m
//  RSFVisualizer
//
//  Created by Erik Frisk on 08/03/15.
//  Copyright (c) 2015 Erik Frisk. All rights reserved.
//

#import "TerminalNodeViewController.h"
#import "NodeConstraints.h"
@interface TerminalNodeViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation TerminalNodeViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self setup];
}

-(void)setup
{
//  [self.node.constraints debugPrint];
  
  NSDictionary *constraints = self.node.constraints.constraints;
  
  NSEnumerator *enumerator = [constraints keyEnumerator];
  NSNumber *key;
//  NSMutableString *constraintString = [[NSMutableString alloc] initWithString:@""];
  
  NSMutableAttributedString *constraintString = [[NSMutableAttributedString alloc] initWithString:@""];
  NSMutableParagraphStyle *parStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
  parStyle.lineSpacing = NSLineBreakByWordWrapping+5;
  
  NSDictionary *bodyAttributes = @{NSFontAttributeName : self.textView.font, NSParagraphStyleAttributeName : parStyle};
  NSDictionary *variableAttributes = @{NSFontAttributeName : self.textView.font, NSForegroundColorAttributeName : [UIColor redColor], NSParagraphStyleAttributeName : parStyle};
  
  while ((key = [enumerator nextObject])) {
    if ([constraintString length]>0) {
      [constraintString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    }
    
    NodeConstraint *c = [constraints objectForKey:key];
    NSString *varName = [self.rsf.variableNames objectAtIndex:[key integerValue]-1];
    if (c.lowerBound && c.upperBound) {
      [constraintString appendAttributedString:[[NSAttributedString alloc]
                                                initWithString:[NSString stringWithFormat:@"%.2f < ", [c.lowerBound doubleValue]]
                                                attributes:bodyAttributes]];
      [constraintString appendAttributedString:[[NSAttributedString alloc]
                                                initWithString:[NSString stringWithFormat:@"%@", varName]
                                                attributes:variableAttributes]];
       
      [constraintString appendAttributedString:[[NSAttributedString alloc]
                                                initWithString:[NSString stringWithFormat:@" ≤ %.2f", [c.upperBound doubleValue]]
                                                attributes:bodyAttributes]];
      
    } else if (!c.lowerBound && c.upperBound) {
      [constraintString appendAttributedString:[[NSAttributedString alloc]
                                                initWithString:[NSString stringWithFormat:@"%@", varName]
                                                attributes:variableAttributes]];
      
      [constraintString appendAttributedString:[[NSAttributedString alloc]
                                                initWithString:[NSString stringWithFormat:@" ≤ %.2f", [c.upperBound doubleValue]]
                                                attributes:bodyAttributes]];
    } else {
      [constraintString appendAttributedString:[[NSAttributedString alloc]
                                                initWithString:[NSString stringWithFormat:@"%.2f < ", [c.lowerBound doubleValue]]
                                                attributes:bodyAttributes]];
      [constraintString appendAttributedString:[[NSAttributedString alloc]
                                                initWithString:[NSString stringWithFormat:@"%@", varName]
                                                attributes:variableAttributes]];
    }
  }
  
  self.textView.attributedText = constraintString;
  self.textView.textAlignment = NSTextAlignmentCenter;
  
  //  CGSize constraintSize = [constraintString sizeWithAttributes:nil];
  CGSize constraintSize = [self.textView.attributedText size];
  CGSize titleSize = [self.titleLabel.attributedText size];
  constraintSize.width = (MAX(constraintSize.width, titleSize.width) + 30)*1.1;
  constraintSize.height = (titleSize.height + 30+constraintSize.height)*1.1;
  
  self.preferredContentSize = constraintSize;
}

@end
