//
//  StreetSideView.h
//  mb
//
//  Created by Kevin Branigan on 12-06-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;
@class GraphView;

@interface StreetSideView : UIView <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSString * streetname;
@property (strong, nonatomic) NSString * streetside;
@property (strong, nonatomic) UIColor * color;

@property (strong, nonatomic) NSDictionary * data;
@property (strong, nonatomic) ViewController * viewController;

@property (strong, nonatomic) UITableView * tableView;
@property (strong, nonatomic) GraphView * graphView;

@property (strong, nonatomic) NSMutableArray * cells;

- (void)setData:(NSDictionary *)data;

@end
