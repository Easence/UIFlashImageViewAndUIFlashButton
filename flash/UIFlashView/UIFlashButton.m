//
//  UIFlashButton.m
//  flash
//
//  Created by zhiyun.huang on 5/5/14.
//  Copyright (c) 2014 ZhangWei. All rights reserved.
//

#import "UIFlashButton.h"

@interface UIFlashButton ()

@property(nonatomic,retain)UIImageView *imgFalsh;

@end

@implementation UIFlashButton

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        self.clipsToBounds = NO;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.clipsToBounds = NO;
    }
    return self;
}

- (void)startFlashAnimation
{
    if(!self.imageFlashing)
        return;
    
    [self removeFlashView];
    
    if(!_imgFalsh)
    {
        _imgFalsh = [[UIImageView alloc]initWithImage:self.imageFlashing];
        
        if(self.imageView)
        {
            [self insertSubview:_imgFalsh belowSubview:self.imageView];
        }
        else if(self.titleLabel)
        {
            [self insertSubview:_imgFalsh belowSubview:self.titleLabel];
        }
    }
    
    _imgFalsh.frame = CGRectMake(self.bounds.origin.x + self.flashEdgeInsets.left, self.bounds.origin.y + self.flashEdgeInsets.top, self.bounds.size.width -(self.flashEdgeInsets.left + self.flashEdgeInsets.right), self.bounds.size.height - (self.flashEdgeInsets.top + self.flashEdgeInsets.bottom));
    
    [UIView animateWithDuration:1.0f delay:0.0f options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat animations:^{
        _imgFalsh.alpha = 0;
    } completion:^(BOOL finished) {
        _imgFalsh.alpha = 1;
    }];
    
    _isFlashing = YES;
    
}

- (void)startFlashWithImage:(UIImage*)img
{
    if(!img)
        return;
    
    self.imageFlashing = img;
    
    [self startFlashAnimation];
    
}

- (void)stopFlash
{
    [UIView animateWithDuration:1.0f animations:^{
        _imgFalsh.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFlashView];
    }];
    
//    _isFlashing = NO;
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [super addTarget:target action:action forControlEvents:controlEvents];

    [super removeTarget:self action:@selector(removeFlashView) forControlEvents:UIControlEventTouchUpInside];
    
    [super addTarget:self action:@selector(removeFlashView) forControlEvents:UIControlEventTouchUpInside];
}

- (void)removeFlashView
{
    if(_imgFalsh)
    {
        [_imgFalsh removeFromSuperview];
        [_imgFalsh release];
        _imgFalsh = nil;
    }
    _isFlashing = NO;
}

- (void)dealloc
{
    if(_imgFalsh)
    {
        [_imgFalsh release];
        _imgFalsh = nil;
    }
    [self.imageFlashing release];
    
    [super dealloc];
}

@end
