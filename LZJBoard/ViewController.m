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
#import <iflyMSC/iflyMSC.h>
#import "IATConfig.h"
#import "ISRDataHelper.h"
#define XFKEY @"57b6c6d8"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,IFlyRecognizerViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIButton *chatBtn;

@property (nonatomic, strong) IFlySpeechRecognizer *iFlySpeechRecognizer;
@property (nonatomic, strong) IFlyRecognizerView  *iflyRecognizerView;
@property (nonatomic, strong) IFlyDataUploader *uploader;

@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 44;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerNib:[UINib nibWithNibName:@"MessageBoardCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MessageBoardCell"];
    self.dataSource = [NSMutableArray array];
    
    [self.view addSubview:self.chatBtn];
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@",XFKEY];
    [IFlySpeechUtility createUtility:initString];
    
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
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageBoardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageBoardCell"];
    cell.contentLbl.text = self.dataSource[indexPath.row];
    return cell;
}


#pragma mark - chat button
-(UIButton *)chatBtn{
    if (_chatBtn == nil) {
        _chatBtn = [[UIButton alloc]initWithFrame:CGRectMake((self.view.selfW - 100)/2.0f, self.view.selfH - 50, 100, 30)];
        [_chatBtn setTitle:@"开始记录" forState:(UIControlStateNormal)];
        [_chatBtn setTitleColor:[UIColor redColor] forState:(UIControlStateNormal)];
        _chatBtn.backgroundColor = [UIColor colorWithHexString:@"f0f2f2"];
        
        [_chatBtn addTarget:self action:@selector(record:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _chatBtn;
}

- (void)record:(UIButton *)btn{
    if (!_iFlySpeechRecognizer) {
        
        [self initRecognizer];//初始化识别对象
    }
    [_iflyRecognizerView start];
}

- (void)initRecognizer{
    _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
    [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    [_iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    
    //view 语音听写
    _iflyRecognizerView = [[IFlyRecognizerView alloc] initWithCenter:self.view.center];
    _iflyRecognizerView.delegate = self;
    [_iflyRecognizerView setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    [_iflyRecognizerView setParameter:@"asrview.pcm " forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    
    IATConfig *instance = [IATConfig sharedInstance];
    //设置最长录音时间
    [_iflyRecognizerView setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
    //设置后端点
    [_iflyRecognizerView setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
    //设置前端点
    [_iflyRecognizerView setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
    //网络等待时间
    [_iflyRecognizerView setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
    
    //设置采样率，推荐使用16K
    [_iflyRecognizerView setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
    if ([instance.language isEqualToString:[IATConfig chinese]]) {
        //设置语言
        [_iflyRecognizerView setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
        //设置方言
        [_iflyRecognizerView setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
    }else if ([instance.language isEqualToString:[IATConfig english]]) {
        //设置语言
        [_iflyRecognizerView setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
    }
    //设置是否返回标点符号
//    [_iflyRecognizerView setParameter:instance.dot forKey:[IFlySpeechConstant ASR_PTT]];
    
//    _uploader = [[IFlyDataUploader alloc]init];
    
    
}

-(void)onError:(IFlySpeechError *)error{
    NSLog(@"on error : %@" ,error.errorDesc);
}

-(void)onResult:(NSArray *)resultArray isLast:(BOOL)isLast{
    
    NSLog(@"听写结果(json)：%@",  resultArray);
    
    NSMutableString *resultString = [[NSMutableString alloc] init];
    if(resultArray){
        NSDictionary *dic = resultArray[0];
        for (NSString *key in dic) {
            [resultString appendFormat:@"%@",key];
        }
        
        NSString * resultFromJson =  [ISRDataHelper stringFromJson:resultString];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.dataSource addObject:resultFromJson?resultFromJson:@"啥呀"];
            [self.tableView reloadData];
        });

    }

}

@end
