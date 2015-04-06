//
//  ViewController.h
//  ContactPicker-Demo
//
//  Created by wiki on 15/4/6.
//  Copyright (c) 2015年 ST. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THContactPickerView.h"


@interface ViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) THContactPickerView *contactPickerView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *contacts;
@property (nonatomic, readonly) NSArray *selectedContacts;
@property (nonatomic) NSInteger selectedCount;
@property (nonatomic, readonly) NSArray *filteredContacts;

//- (NSPredicate *)newFilteringPredicateWithText:(NSString *) text;
- (void) p_didChangeSelectedItems;
//- (NSString *) titleForRowAtIndexPath:(NSIndexPath *)indexPath;

@end
