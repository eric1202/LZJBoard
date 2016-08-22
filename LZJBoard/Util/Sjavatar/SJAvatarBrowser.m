//
//  SJAvatarBrowser.m

#import "SJAvatarBrowser.h"
#import "UIView+Common.h"
#import "UIViewController+HUD.h"
static CGRect oldframe;

@interface SJAvatarBrowser()<UIScrollViewDelegate>
@property (nonatomic,strong) UIScrollView *scrollView;

@end

@implementation SJAvatarBrowser

+ (instancetype)shareInstance {
    static SJAvatarBrowser * _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedInstance = [[SJAvatarBrowser alloc] init];
        UIViewController *vc = [[UIViewController alloc]init];
        
        vc.view.backgroundColor = [UIColor blackColor];
        vc.view.userInteractionEnabled = YES;
        vc.view.alpha = 0;
        
        vc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        _sharedInstance.vc = vc;
        _sharedInstance.vc.view.userInteractionEnabled = YES;
        
        [_sharedInstance.vc.view addSubview:[_sharedInstance scrollView]];
        [_sharedInstance.vc.view addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)]];
    });
    return _sharedInstance;
}

#pragma mark - public

+ (void)showImage:(UIImageView *)avatarImageView{
    
    if (!avatarImageView || !avatarImageView.image) {
        return;
    }
    UIImage *image=avatarImageView.image;
    
    [SJAvatarBrowser shareInstance].image = image;
    [SJAvatarBrowser shareInstance].imageView = [[UIImageView alloc]initWithImage: avatarImageView.image];
    [SJAvatarBrowser shareInstance].imageView.userInteractionEnabled = YES;
    
    [[SJAvatarBrowser shareInstance].imageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)]];
    [[SJAvatarBrowser shareInstance].imageView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)]];
    
    [[SJAvatarBrowser shareInstance].scrollView addSubview:[SJAvatarBrowser shareInstance].imageView];
    
    oldframe = [avatarImageView convertRect:avatarImageView.bounds toView:[UIApplication sharedApplication].keyWindow];
    [SJAvatarBrowser shareInstance].imageView.frame = oldframe;
    
    [[SJAvatarBrowser shareInstance] scrollView].contentSize = [SJAvatarBrowser shareInstance].scrollView.frame.size;//CGSizeMake([UIScreen mainScreen].bounds.size.width, image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width);//image.size;
    
    UIViewController *viewController = avatarImageView.findViewController;
    if (viewController) {
        NSLog(@"avatarImageView.findViewController : %@",[viewController class]);
        [avatarImageView.findViewController presentViewController:[SJAvatarBrowser shareInstance].vc animated:NO completion:^{
            [UIView animateWithDuration:0.4 animations:^{
                [SJAvatarBrowser shareInstance].imageView.frame = CGRectMake(0,([UIScreen mainScreen].bounds.size.height-image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width)/2, [UIScreen mainScreen].bounds.size.width, image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width);
                [SJAvatarBrowser shareInstance].vc.view.alpha = 1;
            } completion:^(BOOL finished) {
                
            }];
        }];
    }
    
    
}

#pragma mark - private

+ (void)hideImage:(UITapGestureRecognizer*)tap{
    
    UIImageView *imageView = [SJAvatarBrowser shareInstance].imageView;
    NSLog(@"current frame : %@\n oldframe : %@", NSStringFromCGRect(imageView.frame) ,NSStringFromCGRect(oldframe));
    [[SJAvatarBrowser shareInstance].scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    [UIView animateWithDuration:0.4f animations:^{
        imageView.frame = oldframe;
        [SJAvatarBrowser shareInstance].vc.view.alpha = 0;
    } completion:^(BOOL finished) {
        [[SJAvatarBrowser shareInstance].vc dismissViewControllerAnimated:NO completion:^{
            [[SJAvatarBrowser shareInstance].imageView removeFromSuperview];
            [SJAvatarBrowser shareInstance].image = nil;
        }];
    }];

}

+ (void)longPress:(UILongPressGestureRecognizer *)longpress{
    
    if (longpress.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"保存图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
        UIImageWriteToSavedPhotosAlbum([SJAvatarBrowser shareInstance].image, [SJAvatarBrowser shareInstance], @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];
    
    [[[SJAvatarBrowser shareInstance] vc ]presentViewController:alertController animated:YES completion:nil];
}

//保存图片到本地
- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *message = @"hello heyz";
    if (!error) {
        message = @"成功保存到相册";
    }else{
        message = [error localizedDescription];
    }
    NSLog(@"message is %@",message);
    [[[SJAvatarBrowser shareInstance] vc] showHint:message];
}

#pragma mark - ui

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:self.vc.view.bounds];

        //设置代理scrollview的代理对象
        _scrollView.delegate=self;
        //设置最大伸缩比例
        _scrollView.maximumZoomScale=2.0;
        //设置最小伸缩比例
        _scrollView.minimumZoomScale=0.5;
    }
    
    return _scrollView;
}

#pragma mark - scroll view delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return [SJAvatarBrowser shareInstance].imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    if (scrollView.zoomScale<1) {
        [SJAvatarBrowser shareInstance].imageView.center = [SJAvatarBrowser shareInstance].vc.view.center;
    }
}

@end
