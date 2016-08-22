//
//  PictureRecordCreateController.m
//  LZJBoard
//
//  Created by Heyz on 16/8/22.
//  Copyright © 2016年 LZJ. All rights reserved.
//

#import "PictureRecordCreateController.h"
#import <AVOSCloud/AVOSCloud.h>
@interface PictureRecordCreateController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation PictureRecordCreateController

- (void)viewDidLoad {
    [super viewDidLoad];
    _imageView.image = self.image;
    self.title = @"图文记录";
    UIBarButtonItem *btn = [[UIBarButtonItem alloc]initWithTitle:@"发送" style:(UIBarButtonItemStyleDone) target:self action:@selector(send:)];
    
    self.navigationItem.rightBarButtonItem = btn;
    
}

- (void)send:(id)sender{
    AVFile *file = [AVFile fileWithData:UIImageJPEGRepresentation(self.image, 0.01)];
    [file.metaData setDictionary:@{@"width":@(self.image.size.width),@"height":@(self.image.size.height)}];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            //save to table
            AVObject *object = [AVObject objectWithClassName:@"board"];
            [object setObject:file.objectId forKey:@"fileObjectId"];
            [object setObject:file.url forKey:@"fileURL"];
            [object setObject:_textField.text?_textField.text:@"" forKey:@"content"];
            [object save];
            NSLog(@"send OK");
            UIAlertController *alt = [UIAlertController alertControllerWithTitle:nil message:@"操作成功" preferredStyle:(UIAlertControllerStyleAlert)];
            [alt addAction:[UIAlertAction actionWithTitle:@"返回" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }]];
            [self presentViewController:alt animated:YES completion:nil];
            
        }
    }];
    

}




@end
