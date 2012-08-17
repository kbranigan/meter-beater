//
//  StreetSideAttributeCell.m
//  mb
//
//  Created by Kevin Branigan on 12-06-13.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StreetSideAttributeCell.h"
#import "GraphView.h"

#import <QuartzCore/QuartzCore.h>

@implementation StreetSideAttributeCell

//@synthesize graphView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  
  if (self) {
    
  }
  
  return self;
}

- (id)initWithText:(NSString*)text
{
  self = [self initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:text];
  
  if (self) {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.textLabel.text = text;
    [self.textLabel sizeToFit];
  }
  
  return self;
}

- (void) layoutSubviews
{
  [super layoutSubviews];
  self.textLabel.frame = CGRectMake(10.0, 0.0, self.frame.size.width - 20, 40);
  //self.detailTextLabel.frame = CGRectMake(10.0, 40,  self.frame.size.width - 20, 60);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
  [super setSelected:selected animated:animated];
  
  /*if (selected)
  {
    if (graphView == nil)
    {
      graphView = [[GraphView alloc] initWithFrame:CGRectMake(10, 40, self.frame.size.width - 20, 100)];
      //graphView.ssv = self;
      [self addSubview:graphView];
    }
    else
    {
      graphView.hidden = NO;
    }
  }
  else
  {
    //[graphView removeFromSuperview];
    graphView.hidden = YES;
  }*/
}

@end
