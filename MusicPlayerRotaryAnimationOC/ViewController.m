//
//  ViewController.m
//  MusicPlayerRotaryAnimationOC
//
//  Created by donglyu on 2020/2/19.
//  Copyright © 2020 donglyu. All rights reserved.
//

#import "ViewController.h"

// 波纹数
#define kCoverPictureRippleCount 5
#define kCoverPictureRippleMaxBorderWidth 2
#define kCoverPictureRippleCircleSize 10
#define kCoverPictureRippleDuration 4

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *albumBg;
@property (weak, nonatomic) IBOutlet UIView *albumShadow;
@property (weak, nonatomic) IBOutlet UIImageView *albumCover;



// ripple: 波纹
@property (nonatomic, strong) NSMutableArray<CALayer *> *rippleArray;
@property (nonatomic, strong) NSMutableArray<CALayer *> *rippleCircleArray;
@property (nonatomic, weak) CALayer * animationLayer;
@property (nonatomic, assign) BOOL isTiming;

@property (nonatomic, assign) BOOL isStop;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _albumBg.backgroundColor = self.albumCover.backgroundColor;
    
    // 波纹颜色和阴影颜色，最佳方式是提取图片的主要颜色！
    _albumShadow.backgroundColor = self.view.backgroundColor;
    _albumShadow.layer.cornerRadius = _albumShadow.bounds.size.width *0.5;
    _albumShadow.layer.shadowColor = [UIColor colorWithRed:41/255.0 green:106/255.0 blue:164/255.0 alpha:1].CGColor;
    _albumShadow.layer.shadowOffset = CGSizeMake(0, 10);
    _albumShadow.layer.shadowRadius = 29;
    _albumShadow.layer.shadowOpacity = 0.5;
    
    
    _albumCover.layer.cornerRadius = _albumCover.bounds.size.width * 0.5;
    _albumCover.layer.masksToBounds = YES;
    
    
    
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self addAnimation];
        [self addRippleAnimation];
        [self setupCircleColor];
    });
}


- (void)addAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.duration = 15;
    animation.repeatCount = MAXFLOAT;
    animation.removedOnCompletion = NO;
    animation.toValue = @(M_PI*2);
    [self.albumCover.layer addAnimation:animation forKey:@"rotationAnimation"];
    
}

- (void)addRippleAnimation {
    self.rippleArray = [@[] mutableCopy];
    self.rippleCircleArray = [@[] mutableCopy];
    
    CALayer * animationLayer = [CALayer layer];
    CGFloat maxRadius = [[UIScreen mainScreen] bounds].size.width / 2;
    
    for (int i = 0; i<kCoverPictureRippleCount; i++) {
        CALayer * pulsingLayer = [CALayer layer];
        pulsingLayer.frame = CGRectMake(0, 0, maxRadius*2, maxRadius*2);
        pulsingLayer.position = self.albumCover.center;
        pulsingLayer.backgroundColor = [UIColor clearColor].CGColor;
        pulsingLayer.cornerRadius = maxRadius;
        pulsingLayer.borderWidth = kCoverPictureRippleMaxBorderWidth;
        pulsingLayer.opacity = 0;// need be 0 when start.
        
        CALayer *lay = [CALayer layer];
        lay.frame = CGRectMake(0, 0, kCoverPictureRippleCircleSize, kCoverPictureRippleCircleSize);
        lay.cornerRadius = kCoverPictureRippleCircleSize/2;
        lay.masksToBounds = YES;
        lay.position = CGPointMake(maxRadius*2 * sin(45), maxRadius*2 * sin(45));
        [pulsingLayer addSublayer:lay];
        
        CAMediaTimingFunction * defaultCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        
//        CAAnimationGroup * animationGroup = [CAAnimationGroup animation];
//        animationGroup.fillMode = kCAFillModeBackwards;
//        animationGroup.beginTime = CACurrentMediaTime() + i * kCoverPictureRippleDuration / kCoverPictureRippleCount;
//        animationGroup.duration = kCoverPictureRippleDuration;
//        animationGroup.repeatCount = HUGE;
//        animationGroup.timingFunction = defaultCurve;
        
        CABasicAnimation * scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scaleAnimation.fromValue = @0.622;//0.66666// @(2/3.0); // should match the albumCover's width.
        scaleAnimation.toValue = @1.0;
        scaleAnimation.beginTime = CACurrentMediaTime() + i * kCoverPictureRippleDuration / kCoverPictureRippleCount;
        scaleAnimation.fillMode = kCAFillModeBackwards;
        scaleAnimation.timingFunction = defaultCurve;
        scaleAnimation.duration = kCoverPictureRippleDuration;
        scaleAnimation.repeatCount = HUGE;
        scaleAnimation.removedOnCompletion = NO;
        scaleAnimation.fillMode = kCAFillModeForwards;
        
        
        CABasicAnimation *animation = [CABasicAnimation new];
        animation.keyPath = @"transform.rotation.z";
        animation.beginTime = CACurrentMediaTime() + i * kCoverPictureRippleDuration / kCoverPictureRippleCount;
        animation.fromValue = [NSNumber numberWithFloat:i *(M_PI/2)]; // 起始角度
        animation.toValue = [NSNumber numberWithFloat:i *(M_PI/2) + 2*M_PI]; // 终止角度
        animation.duration = 20;
        animation.repeatCount = HUGE;
        animation.timingFunction = defaultCurve;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        
        CAKeyframeAnimation * opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.beginTime = CACurrentMediaTime() + i * kCoverPictureRippleDuration / kCoverPictureRippleCount;
        
        opacityAnimation.values = @[@0.3, @0.5, @0];
        opacityAnimation.keyTimes = @[@0, @0.3, @1];
        opacityAnimation.duration = kCoverPictureRippleDuration;
        opacityAnimation.repeatCount = HUGE;
        opacityAnimation.timingFunction = defaultCurve;
        opacityAnimation.removedOnCompletion = NO;
        
        opacityAnimation.fillMode = kCAFillModeForwards;

        //        animationGroup.animations = @[scaleAnimation, opacityAnimation,animation];
        //        [pulsingLayer addAnimation:animationGroup forKey:@"animmm"];
        [pulsingLayer addAnimation:scaleAnimation forKey:@"plulsing"];
        [pulsingLayer addAnimation:animation forKey:@"dsdasdasd"];
        [pulsingLayer addAnimation:opacityAnimation forKey:@"plulsidsadang"];
        
        [animationLayer addSublayer:pulsingLayer];
        [self.rippleArray addObject:pulsingLayer];
        [self.rippleCircleArray addObject:lay];
    }
    _animationLayer = animationLayer;
    [self.albumBg.layer addSublayer:animationLayer];
}

- (void)setupCircleColor{
    
    for (CALayer *layer in self.rippleArray) {
        layer.borderColor = self.albumShadow.layer.shadowColor;
    }
    for (CALayer *layer in self.rippleCircleArray) {
        layer.backgroundColor = self.albumShadow.layer.shadowColor;
    }
}

- (void)UpdateCoverRotating{
    
    if (_isStop) {
        // 停止动画
        CFTimeInterval pausedTime = [self.albumCover.layer convertTime:CACurrentMediaTime() fromLayer:nil];
        self.albumCover.layer.speed = 0.0;
        self.albumCover.layer.timeOffset = pausedTime;
        _animationLayer.hidden = YES;
        
    }else{
        CFTimeInterval pausedTime = [self.albumCover.layer timeOffset];
        self.albumCover.layer.speed = 1.0;
        self.albumCover.layer.timeOffset = 0.0;
        self.albumCover.layer.beginTime = 0.0;
        CFTimeInterval timeSincePause = [self.albumCover.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
          self.albumCover.layer.beginTime = timeSincePause;
        _animationLayer.hidden = NO;
    }
    
}





@end
