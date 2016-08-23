//
//  DrawingViewController.m
//  LZJBoard
//
//  Created by Heyz on 16/8/23.
//  Copyright © 2016年 LZJ. All rights reserved.
//

#import "DrawingViewController.h"
#import <AVOSCloud/AVOSCloud.h>
#import "User.h"
@interface DrawingViewController ()

@property (nonatomic,assign)CGFloat lineWidth;
@property (nonatomic,assign)CGPoint touchPoint;
@property (nonatomic,strong)UIImageView *drawBoard;
@end

@implementation DrawingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"手绘记录";
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.drawBoard = [[UIImageView alloc]initWithFrame:self.view.frame];
    self.drawBoard.userInteractionEnabled = YES;
    [self.view addSubview:self.drawBoard];
    
    UIBarButtonItem *sendBtn = [[UIBarButtonItem alloc]initWithTitle:@"发送" style:(UIBarButtonItemStyleDone) target:self action:@selector(send:)];
    sendBtn.tintColor = [UIColor blackColor];
    
    [self.navigationItem setRightBarButtonItem:sendBtn];
    
}

- (void)send:(UIBarButtonItem *)sender{
    sender.enabled = false;
    AVFile *file = [AVFile fileWithData:UIImageJPEGRepresentation(self.drawBoard.image, 0.01)];
    [file.metaData setDictionary:@{@"width":@(self.drawBoard.image.size.width),@"height":@(self.drawBoard.image.size.height)}];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        sender.enabled = true;
        if (succeeded) {
            //save to table
            AVObject *object = [AVObject objectWithClassName:@"board"];
            [object setObject:file.objectId forKey:@"fileObjectId"];
            [object setObject:file.url forKey:@"fileURL"];
            [object setObject:@"手绘记录" forKey:@"content"];
            [object setObject:[User currentUser].name forKey:@"fromUserName"];
            
            [object save];
            NSLog(@"send OK");
            UIAlertController *alt = [UIAlertController alertControllerWithTitle:nil message:@"操作成功" preferredStyle:(UIAlertControllerStyleAlert)];
            [alt addAction:[UIAlertAction actionWithTitle:@"返回" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:YES];

            }]];
            [self presentViewController:alt animated:YES completion:nil];
            
        }
    }];
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    _touchPoint = [touch locationInView:_drawBoard];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:_drawBoard];
    
    UIGraphicsBeginImageContext(_drawBoard.frame.size);
    [_drawBoard.image drawInRect:_drawBoard.frame];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    
    float lineWidth = 10.0f;
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        lineWidth *= touch.force;
    }
    
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), lineWidth);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.1, 0.1, 0.1, 1.0);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), _touchPoint.x, _touchPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    _drawBoard.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    _touchPoint = currentPoint;
}

@end
