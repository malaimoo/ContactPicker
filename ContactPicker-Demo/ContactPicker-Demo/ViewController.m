//
//  ViewController.m
//  ContactPicker-Demo
//
//  Created by wiki on 15/4/6.
//  Copyright (c) 2015年 ST. All rights reserved.
//

//
//  ManageContactsViewController.m
//  CloudRecord
//
//  Created by wiki on 15/4/3.
//  Copyright (c) 2015年 wiki. All rights reserved.
//

#import "ViewController.h"
#import "ZCAddressBook.h"
#import "EmployeModel.h"

static const CGFloat kPickerViewHeight = 100.0;
NSString *THContactPickerContactCellReuseID = @"THContactPickerContactCell";


@interface ViewController ()<THContactPickerDelegate>
@property (nonatomic, strong) NSMutableArray *privateSelectedContacts;
@end


@implementation ViewController{
    NSMutableDictionary *_mainContact;
    NSArray *_mainContactAlphaArr;
    NSMutableDictionary *_filtredMainContact;
}
#pragma mark- ==============1. 数据变量初始化 ==============

-(void)globalVarInit{
    
    _mainContact = [NSMutableDictionary dictionary];
    NSDictionary * mainContactDic  = [[ZCAddressBook shareControl] getPersonInfo];
    _mainContactAlphaArr = [[ZCAddressBook shareControl] sortMethod];// 必须在getPersoninfo之后
    
    
    for (int i=0; i<_mainContactAlphaArr.count; i++) {
        NSString *alpha = _mainContactAlphaArr[i];
        NSArray *alphaContactArr = mainContactDic [alpha];
        NSMutableArray * newAlphaModelArr = [NSMutableArray array];
        for (NSDictionary *employeeDic in alphaContactArr) {
            EmployeModel *aEmploye = [[EmployeModel alloc]initWithDic:employeeDic];
            [newAlphaModelArr addObject:aEmploye];
        }
        [_mainContact setObject:newAlphaModelArr forKey:alpha];
    }
    _filtredMainContact = [_mainContact mutableCopy];
    
}

#pragma mark- ==============2. 界面控件初始化 =================


-(void)naviBarInit{
    
    self.title = @"添加员工";
    //    右按键
    UIButton *confirmAddBt = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 30)];
    [confirmAddBt addTarget:self action:@selector(confirmAdd) forControlEvents:UIControlEventTouchUpInside];
    [confirmAddBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [confirmAddBt setTitle:@"确认" forState:UIControlStateNormal];
    UIBarButtonItem* confirmBarBt = [[UIBarButtonItem alloc]initWithCustomView:confirmAddBt];
    self.navigationItem.rightBarButtonItem = confirmBarBt;
    //    左按键
    UIButton *backBt = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
    [backBt setImage:[UIImage imageNamed:@"iv_1_03"] forState:UIControlStateNormal];
    [backBt setImageEdgeInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [backBt addTarget:self action:@selector(leftBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem * backBarBt = [[UIBarButtonItem alloc]initWithCustomView:backBt];
    self.navigationItem.leftBarButtonItem = backBarBt;
}

#pragma mark- ==============3. View 生命周期================


- (void)viewDidLoad {
    [super viewDidLoad];
    [self globalVarInit];
    [self naviBarInit];
    // Do any additional setup after loading the view from its nib.
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeBottom|UIRectEdgeLeft|UIRectEdgeRight];
    }
    
    // Initialize and add Contact Picker View
    self.contactPickerView = [[THContactPickerView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, kPickerViewHeight)];
    self.contactPickerView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth;
    self.contactPickerView.delegate         = self;
    [self.contactPickerView setPlaceholderLabelText:@""];
    [self.contactPickerView setPromptLabelText:@"添加员工:"];
//    [self.contactPickerView setPlaceholderLabelTextColor:MRGB];
//    [self.contactPickerView setPromptLabelTextColor:MRGB];
    
    //[self.contactPickerView setLimitToOne:YES];
    [self.view addSubview:self.contactPickerView];
    
    CALayer *layer = [self.contactPickerView layer];
    [layer setShadowColor:[[UIColor colorWithRed:225.0/255.0 green:226.0/255.0 blue:228.0/255.0 alpha:1] CGColor]];
    [layer setShadowOffset:CGSizeMake(0, 2)];
    [layer setShadowOpacity:1];
    [layer setShadowRadius:1.0f];
    
    // Fill the rest of the view with the table view
    CGRect tableFrame = CGRectMake(0, self.contactPickerView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.contactPickerView.frame.size.height);
    
    self.tableView = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate         = self;
    self.tableView.dataSource       = self;
    [self.view insertSubview:self.tableView belowSubview:self.contactPickerView];
}

- (void)viewDidLayoutSubviews {
    [self p_adjustTableFrame];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    /*Register for keyboard notifications*/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSArray *)selectedContacts{
    return [self.privateSelectedContacts copy];
}

#pragma mark - Publick properties

- (void)adjustTableViewInsetTop:(CGFloat)topInset bottom:(CGFloat)bottomInset {
    self.tableView.contentInset = UIEdgeInsetsMake(topInset,
                                                   self.tableView.contentInset.left,
                                                   bottomInset,
                                                   self.tableView.contentInset.right);
    self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
}

- (NSInteger)selectedCount {
    return self.privateSelectedContacts.count;
}

#pragma mark - Private properties

- (NSMutableArray *)privateSelectedContacts {
    if (!_privateSelectedContacts) {
        _privateSelectedContacts = [NSMutableArray array];
    }
    return _privateSelectedContacts;
}

#pragma mark - Private methods

/**
 *  根据新的 str 筛选主 Dic 并且制作新的 Dic
 *
 *  @param str              输入的字符
 *  @param filtedDictionary 输出筛选好的DIc
 */

-(void )p_filterMainDicUsingString:(NSString *)str toFillDic:(NSMutableDictionary *)filtedDictionary{
    for (int i=0; i<_mainContactAlphaArr.count; i++) {
        NSString *alpha = _mainContactAlphaArr[i];
        NSArray *alphaContactArr = _mainContact [alpha];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fullName contains[cd] %@",str];
        NSArray * newAlphaArr = [alphaContactArr filteredArrayUsingPredicate:predicate];
        [filtedDictionary setObject:newAlphaArr forKey:alpha];
    }
}

/**
 *  搜寻需要删除的联系人的indexpath
 *
 *  @param contact 需要删除的联系人
 *
 *  @return 联系人所在的indexpath
 */

-(NSIndexPath *)p_indexPathToDeleteOfContact:(id)contact{
    
    for (NSString *key in _mainContact) {
        NSArray *array = _mainContact [key];
        for (id acontact in array) {
            if (acontact == contact)
                return [NSIndexPath indexPathForItem:[array indexOfObject:contact] inSection:[_mainContactAlphaArr indexOfObject:key]];
        }
    }
    return nil;
}


/**
 *  通过indexpath 获得某一个字母的联系人数组
 *
 *  @param indexPath 路径
 *
 *  @return 某一个字母的联系人数组
 */

- (NSArray *)p_contactArrOfAlphaThIndex:(NSInteger)section{
    NSString *alpha = _mainContactAlphaArr[section];
    NSArray *alphaContactArr = _filtredMainContact [alpha];
    return alphaContactArr;
}

/**
 *  重新定位 tableview 的大小。
 */
- (void)p_adjustTableFrame {
    CGFloat yOffset = self.contactPickerView.frame.origin.y + self.contactPickerView.frame.size.height;
    
    CGRect tableFrame = CGRectMake(0, yOffset, self.view.frame.size.width, self.view.frame.size.height - yOffset-49);
    self.tableView.frame = tableFrame;
}

- (void)p_adjustTableViewInsetTop:(CGFloat)topInset {
    [self adjustTableViewInsetTop:topInset bottom:self.tableView.contentInset.bottom];
}

- (void)p_adjustTableViewInsetBottom:(CGFloat)bottomInset {
    [self adjustTableViewInsetTop:self.tableView.contentInset.top bottom:bottomInset];
}

- (void)p_didChangeSelectedItems{
    
}

#pragma mark- ==============4. 点击事件处理 =================

-(void)confirmAdd{
    
    
}

#pragma mark- ==============5. 触发请求方法 =================
#pragma  mark - NSNotificationCenter

- (void)keyboardDidShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect kbRect = [self.view convertRect:[[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:self.view.window];
    [self p_adjustTableViewInsetBottom:self.tableView.frame.origin.y + self.tableView.frame.size.height - kbRect.origin.y];
}

- (void)keyboardDidHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect kbRect = [self.view convertRect:[[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:self.view.window];
    [self p_adjustTableViewInsetBottom:self.tableView.frame.origin.y + self.tableView.frame.size.height - kbRect.origin.y];
}

#pragma mark- ==============6. 协议方法====================

#pragma mark - UITableView Delegate and Datasource functions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _mainContactAlphaArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSArray *contactArrOfAlpha =[self p_contactArrOfAlphaThIndex:section];
    return contactArrOfAlpha.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return _mainContactAlphaArr [section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:THContactPickerContactCellReuseID];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:THContactPickerContactCellReuseID];
    }
    //    设置cell 的文字等
    NSArray *ContactOfAlphaArr = [self p_contactArrOfAlphaThIndex:indexPath.section];
    EmployeModel *aEmploye     = ContactOfAlphaArr[indexPath.row];
    cell.textLabel.text        = aEmploye.fullName;
//    cell.tintColor             = MRGB;
    
    if ([self.privateSelectedContacts containsObject:[ContactOfAlphaArr objectAtIndex:indexPath.row]]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell    = [tableView cellForRowAtIndexPath:indexPath];
    
    NSArray *alphaContactArr = [self p_contactArrOfAlphaThIndex:indexPath.section];
    EmployeModel *aEmploye   = alphaContactArr[indexPath.row];
    NSString *contactTilte   = aEmploye.fullName;
    
    if ([self.privateSelectedContacts containsObject:aEmploye]){ // contact is already selected so remove it from ContactPickerView
        cell.accessoryType = UITableViewCellAccessoryNone;
        [self.privateSelectedContacts removeObject:aEmploye];
        [self.contactPickerView removeContact:aEmploye];
    } else {
        // Contact has not been selected, add it to THContactPickerView
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.privateSelectedContacts addObject:aEmploye];
        [self.contactPickerView addContact:aEmploye withName:contactTilte];
    }
    
    _filtredMainContact = [_mainContact mutableCopy];
    [self p_didChangeSelectedItems];
    [self.tableView reloadData];
}


#pragma mark - THContactPickerTextViewDelegate


/**
 *  筛选包含字符串的联系人
 *
 *  @param textViewText
 */
- (void)contactPickerTextViewDidChange:(NSString *)textViewText {
    if ([textViewText isEqualToString:@""]){
        _filtredMainContact = [_mainContact mutableCopy];
    } else {
        [self p_filterMainDicUsingString:textViewText toFillDic:_filtredMainContact];
    }
    [self.tableView reloadData];
}


- (void)contactPickerDidResize:(THContactPickerView *)contactPickerView {
    CGRect frame         = self.tableView.frame;
    frame.origin.y       = contactPickerView.frame.size.height + contactPickerView.frame.origin.y;
    self.tableView.frame = frame;
}


/**
 *  删除已输入的联系人
 *
 *  @param contact 需要删除的contact
 */
- (void)contactPickerDidRemoveContact:(id)contact {
    [self.privateSelectedContacts removeObject:contact];
    
    NSIndexPath * indexPath = [self p_indexPathToDeleteOfContact:contact];
    UITableViewCell *cell   = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType      = UITableViewCellAccessoryNone;
    
    [self p_didChangeSelectedItems];
}

- (BOOL)contactPickerTextFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length > 0){
        NSString *contact = [[NSString alloc] initWithString:textField.text];
        [self.privateSelectedContacts addObject:contact];
        [self.contactPickerView addContact:contact withName:textField.text];
    }
    return YES;
}

#pragma mark- ==============7. 第三方功能区 =================


@end
