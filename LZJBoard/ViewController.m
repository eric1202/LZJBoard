//
//  ViewController.m
//  LZJBoard
//
//  Created by Heyz on 16/8/19.
//  Copyright © 2016年 LZJ. All rights reserved.
//

#import "ViewController.h"
#import "MessageBoardCell.h"
#import "MessageBoardPicCellTableViewCell.h"
#import "UIView+Common.h"
#import <iflyMSC/iflyMSC.h>
#import "IATConfig.h"
#import "ISRDataHelper.h"
#import "User.h"
#import "UIImageView+WebCache.h"
#import "PictureRecordCreateController.h"
#import <AVOSCloud/AVOSCloud.h>
#import "DateTools.h"
#import "BoardPeakViewController.h"
#import "DrawingViewController.h"
#define XFKEY @"57b6c6d8"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,IFlyRecognizerViewDelegate,UIImagePickerControllerDelegate,UIViewControllerPreviewingDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIButton *chatBtn;
@property (strong, nonatomic) UIButton *pictureBtn;
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, strong) IFlySpeechRecognizer *iFlySpeechRecognizer;
@property (nonatomic, strong) IFlyRecognizerView  *iflyRecognizerView;
@property (nonatomic, strong) IFlyDataUploader *uploader;

@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    
//    [self refreshContent];// 不需要实时刷新的
    
    [self popPeak];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getNetworkData];
}

- (void)initUI{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 60.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerNib:[UINib nibWithNibName:@"MessageBoardCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MessageBoardCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"MessageBoardPicCellTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MessageBoardPicCellTableViewCell"];
    
    
    self.dataSource = [NSMutableArray array];
    
    [self.view addSubview:self.chatBtn];
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@",XFKEY];
    [IFlySpeechUtility createUtility:initString];

}

#pragma mark - network
- (void)getNetworkData{
    WeakSelf
    AVQuery *aq = [[AVQuery alloc]initWithClassName:@"board"];
    [aq addDescendingOrder:@"createdAt"];
    
    aq.limit = 100;
    [aq findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error || objects.count == 0) {
            return ;
        }
        [weakSelf_SC.dataSource removeAllObjects];
        [weakSelf_SC.dataSource addObjectsFromArray:objects];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [weakSelf_SC.tableView reloadData];
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
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC));
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
        if ([object objectForKey:@"fileURL"]) {
            MessageBoardPicCellTableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:@"MessageBoardPicCellTableViewCell"];
            [cell1.imageV sd_setImageWithURL:[NSURL URLWithString:[object objectForKey:@"fileURL"]] placeholderImage:[UIImage new]];
            cell1.contentLbl.text = [object objectForKey:@"content"];
            cell1.nameLbl.text = [object objectForKey:@"fromUserName"];
            cell1.timeLbl.text = [object.createdAt shortTimeAgoSinceNow];
            return cell1;
        }
        cell.contentLbl.text = [object objectForKey:@"content"];
        cell.nameLbl.text = [object objectForKey:@"fromUserName"];
        
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.alpha = 0.2;
    [UIView animateWithDuration:0.3
                          delay:0
                        options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseIn)
                     animations:^{
                         cell.alpha = 1;
                     }                completion:nil];
}

#pragma mark - UI
- (UIButton *)chatBtn{
    if (_chatBtn == nil) {
        _chatBtn = [[UIButton alloc]initWithFrame:CGRectMake((self.view.selfW - 100)/2.0f, self.view.selfH - 50, 100, 30)];
        [_chatBtn setTitle:@"语音记录" forState:(UIControlStateNormal)];
        [_chatBtn setTitleColor:[UIColor redColor] forState:(UIControlStateNormal)];
        _chatBtn.backgroundColor = [UIColor colorWithHexString:@"f0f2f2"];
        
        [_chatBtn addTarget:self action:@selector(record:) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _chatBtn;
}

- (IBAction)drawRecord:(id)sender {
    [self.navigationController pushViewController:[DrawingViewController new] animated:YES];
}

/**
 *  记录图片
 *
 *  @param btn
 */
- (IBAction)pictureRecord:(id)sender {
    UIImagePickerController *pk = [[UIImagePickerController alloc]init];
    pk.delegate = self;
    [self presentViewController:pk animated:YES completion:nil];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    PictureRecordCreateController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PictureRecordCreateController"];
    vc.image = info[@"UIImagePickerControllerOriginalImage"];
    [self.navigationController pushViewController:vc animated:YES];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - chat function
/**
 *  记录语音
 *
 *  @param btn
 */
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
        
        NSString *resultFromJson = [ISRDataHelper stringFromJson:resultString];
        
        //remove 句号 逗号 感叹号 再第一个位置的
        if (resultFromJson && resultFromJson.length>1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                AVObject *content = [AVObject objectWithClassName:@"board"];
                
                [content setObject:[User currentUser].name forKey:@"fromUserName"];
                [content setObject:resultFromJson forKey:@"content"];
                [self.dataSource insertObject:content atIndex:0 ];
                [self.tableView reloadData];
                [self.tableView scrollsToTop];
                //                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataSource.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                [content saveInBackground];
            });
            
        }
        
    }
    
}

#pragma mark - pop peak
- (void)popPeak{
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        [self registerForPreviewingWithDelegate:self sourceView:self.view];
    }
}

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)context viewControllerForLocation:(CGPoint) point
{
    if (CGRectContainsPoint(_tableView.frame, point)) {
        if ([self.presentedViewController isKindOfClass:[BoardPeakViewController class]]) {
            return nil;
        } else {
            point = [self.view convertPoint:point toView:_tableView];
            NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:point];
            NSLog(@"%@", indexPath);
            
            BoardPeakViewController *displayVC = [BoardPeakViewController new];
            displayVC.board = _dataSource[indexPath.row];
            // peek预览窗口大小
            //            displayVC.preferredContentSize = CGSizeMake(300, 400);
            
            // 进入peek前不被虚化的rect
            context.sourceRect = [self.view convertRect:[_tableView cellForRowAtIndexPath:indexPath].frame fromView:_tableView];
            
            return displayVC;
        }
    }
    
    return nil;
}


-(void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit{
    [self showViewController:viewControllerToCommit sender:self];
    
}

@end
