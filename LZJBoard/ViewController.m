//
//  ViewController.m
//  LZJBoard
//
//  Created by Heyz on 16/8/19.
//  Copyright © 2016年 LZJ. All rights reserved.
//

#import "ViewController.h"
#import "MessageBoardCell.h"
#import "UIView+Common.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIButton *chatBtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 44;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerNib:[UINib nibWithNibName:@"MessageBoardCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MessageBoardCell"];
    
    [self.view addSubview:self.chatBtn];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table view 



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageBoardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageBoardCell"];
    return cell;
}


#pragma mark - chat button
-(UIButton *)chatBtn{
    if (_chatBtn == nil) {
        _chatBtn = [[UIButton alloc]initWithFrame:CGRectMake((self.view.selfW-100)/2.0f, self.view.selfH - 50, 100, 30)];
        [_chatBtn setTitle:@"开始记录" forState:(UIControlStateNormal)];
        [_chatBtn setTitleColor:[UIColor redColor] forState:(UIControlStateNormal)];
        _chatBtn.backgroundColor = [UIColor colorWithHexString:@"f0f2f2"];
        
        [_chatBtn addTarget:self action:@selector(record:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _chatBtn;
}

- (void)record:(UIButton *)btn{
    
}

@end
