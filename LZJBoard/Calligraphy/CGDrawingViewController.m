//
//  CGDrawingViewController.m
//  LZJBoard
//
//  Created by Heyz on 2017/12/28.
//  Copyright © 2017年 LZJ. All rights reserved.
//

#import "CGDrawingViewController.h"
@interface KouZi:UIImageView

@end


@implementation KouZi

- (instancetype)init{
    self = [super init];

    self.contentMode = UIViewContentModeScaleAspectFit;
    self.layer.borderWidth = 3;
    self.layer.masksToBounds = YES;

    return self;
}
/**
 设置口字状态

 @param stage 0 为空 1为左竖 2为折 3为收回
 */
- (void)setKouView:(NSInteger)stage{

    self.image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld",stage]];

}

- (void)setFrameColor:(UIColor *)color{
    self.layer.borderColor = color.CGColor;
}

@end

@interface CGDrawingViewController ()
@property (weak, nonatomic) IBOutlet UIButton *actionBtn;

@property (nonatomic,assign)NSInteger stage;
@property (nonatomic,assign)CGPoint touchPoint;
@property (nonatomic,strong)KouZi *big;
@property (nonatomic,strong)UIImageView *drawBoard;

@property NSArray <KouZi*>*uppers;

@end

@implementation CGDrawingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self renderUpper];
    [self renderMiddle];

    UIBarButtonItem *barItem = [[UIBarButtonItem alloc]initWithTitle:@"清除" style:(UIBarButtonItemStyleDone) target:self action:@selector(clean:)];
    self.navigationItem.rightBarButtonItem = barItem;

}

- (void)teachingFlag:(BOOL)isStart{
    
}

- (void)clean:(id)sender{
    self.drawBoard.image = nil;
}

- (void)renderUpper{
    KouZi *k = [[KouZi alloc]init];
    [k setKouView:0];
    k.frame = CGRectMake(10, 80, 80, 80);

    KouZi *k1 = [[KouZi alloc]init];
    [k1 setKouView:1];
    k1.frame = CGRectMake(100, 80, 80, 80);

    KouZi *k2 = [[KouZi alloc]init];
    [k2 setKouView:2];
    k2.frame = CGRectMake(190, 80, 80, 80);

    KouZi *k3 = [[KouZi alloc]init];
    [k3 setKouView:3];
    k3.frame = CGRectMake(280, 80, 80, 80);

    [self.view addSubview:k];
    [self.view addSubview:k1];
    [self.view addSubview:k2];
    [self.view addSubview:k3];

    _uppers = @[k1,k2,k3];

}

- (void)renderMiddle{
    _big = [[KouZi alloc]init];

    _big.frame = CGRectMake((self.view.bounds.size.width-200)/2, (self.view.bounds.size.height-200)/2, 200, 200);
    [_big setKouView:0];
    [self.view addSubview:_big];

    self.drawBoard = [[UIImageView alloc]initWithFrame:_big.frame];
    self.drawBoard.userInteractionEnabled = YES;
    [self.view addSubview:self.drawBoard];


}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    _touchPoint = [touch locationInView:_drawBoard];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:_drawBoard];
    
    UIGraphicsBeginImageContext(_drawBoard.frame.size);
    [_drawBoard.image drawInRect:_drawBoard.bounds];
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

- (IBAction)click:(id)sender {

    for (KouZi *k in _uppers) {
        [k setFrameColor:[UIColor clearColor]];
    }
    if (_stage==3) {
        _stage=0;
        [_uppers[_stage] setFrameColor:[UIColor yellowColor]];

        //should show 3stars
    }else{
        _stage++;
        if (_stage<_uppers.count) {

            [_uppers[_stage] setFrameColor:[UIColor yellowColor]];
        }

    }
    [_big setKouView:_stage];

}


@end






