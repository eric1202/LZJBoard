//
//  SJAvatarBrowser.h


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface SJAvatarBrowser : NSObject
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UIImage *image;
@property (nonatomic,strong) UIViewController *vc;
/**
 *	@brief	浏览头像
 *
 *	@param 	oldImageView 	头像所在的imageView
 */
+(void)showImage:(UIImageView*)avatarImageView;

@end
