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
#import "User.h"
#import <AVOSCloud/AVOSCloud.h>
#define XFKEY @"57b6c6d8"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,IFlyRecognizerViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIButton *chatBtn;
@property (nonatomic, strong) dispatch_source_t timer;
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
    
    [self getNetworkData];
    
    [self refreshContent];
}

#pragma mark - network
- (void)getNetworkData{
    AVQuery *aq = [[AVQuery alloc]initWithClassName:@"board"];
    [aq addDescendingOrder:@"createdAt"];

    aq.skip = _dataSource.count;
    aq.limit = 20;
    [aq findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error || objects.count == 0) {
            return ;
        }
        
        [self.dataSource addObjectsFromArray:objects];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.tableView reloadData];
        });
    }];
}

/**
 *  轮询获取内容
 */
- (void)refreshContent{
    __block int count = 0;
    
    // 获得队列
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    // 创建一个定时器(dispatch_source_t本质还是个OC对象)
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    // 设置定时器的各种属性（几时开始任务，每隔多长时间执行一次）
    // GCD的时间参数，一般是纳秒（1秒 == 10的9次方纳秒）
    // 何时开始执行第一个任务
    // dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC) 比当前时间晚3秒
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
    uint64_t interval = (uint64_t)(5.0 * NSEC_PER_SEC);
    dispatch_source_set_timer(self.timer, start, interval, 0);
    
    // 设置回调
    dispatch_source_set_event_handler(self.timer, ^{
        NSLog(@"------------%@", [NSThread currentThread]);
        count++;
        [self getNetworkData];

        if (count == 40000) {
            // 取消定时器
            dispatch_cancel(self.timer);
            self.timer = nil;
        }
    });
    
    // 启动定时器
    dispatch_resume(self.timer);}

#pragma mark - table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageBoardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageBoardCell"];
    if ([self.dataSource[indexPath.row] isKindOfClass:[AVObject class]]) {
        AVObject *object = self.dataSource[indexPath.row];
        cell.contentLbl.text = [object objectForKey:@"content"];
        cell.nameLbl.text = [object objectForKey:@"fromUserName"];
        
    }
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
    
    //不保存录音文件
//    [_iflyRecognizerView setParameter:@"asrview.pcm " forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    
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
    [_iflyRecognizerView setParameter:instance.dot forKey:[IFlySpeechConstant ASR_PTT]];
    
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
        
        NSString *resultFromJson = [ISRDataHelper stringFromJson:resultString];
        if (resultFromJson) {
            dispatch_async(dispatch_get_main_queue(), ^{

                AVObject *content = [AVObject objectWithClassName:@"board"];
                
                [content setObject:[User currentUser].name forKey:@"fromUserName"];
                [content setObject:resultFromJson forKey:@"content"];
                [self.dataSource addObject:content];
                [self.tableView reloadData];
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataSource.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                [content saveInBackground];
            });

        }

    }

}

@end
