//
//  UIFlashButton.h
//  flash
//
//  Created by zhiyun.huang on 5/5/14.
//  Copyright (c) 2014 ZhangWei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFlashImageView : UIImageView

@property (nonatomic,assign) UIEdgeInsets flashEdgeInsets;
@property (nonatomic,retain) UIImage *imageFlashing;
@property (nonatomic,readonly) BOOL isFlashing;

- (void)startFlashAnimation;
- (void)startFlashWithImage:(UIImage*)img;
- (void)stopFlash;

@end
