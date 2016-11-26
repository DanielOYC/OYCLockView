//
//  OYCLockView.m
//  Quartz2D
//
//  Created by cao on 16/11/26.
//  Copyright © 2016年 daniel. All rights reserved.
//

#import "OYCLockView.h"

@interface OYCLockView ()
@property(nonatomic,strong)NSMutableArray *selectedBtns;
@property(nonatomic,assign)CGPoint curP;
@property(nonatomic,copy)NSString *pathColor;
@end

@implementation OYCLockView

-(NSMutableArray *)selectedBtns{
    if (!_selectedBtns) {
        _selectedBtns = [NSMutableArray array];
    }
    return _selectedBtns;
}

- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib{

    [self setup];
}

//初始化
- (void)setup{
    
    //给当前视图添加9个按钮
    NSInteger count = 9;
    for (NSInteger i = 0; i < count; i++) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[UIImage imageNamed:@"gesture_node_normal"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"gesture_node_highlighted"] forState:UIControlStateSelected];
        [btn setBackgroundImage:[UIImage imageNamed:@"gesture_node_highlighted"] forState:UIControlStateHighlighted];
        //绑定tag用来验证密码
        btn.tag = i;
        [self addSubview:btn];
    }
    
    //设置路径颜色
    self.pathColor = @"绿色";
    
    //给当前视图添加滑动手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(move:)];
    [self addGestureRecognizer:pan];
    
}

//布局按钮
- (void)layoutSubviews{
    [super layoutSubviews];
    
    NSInteger cols = 3;  //列数
    CGFloat btnX = 0;   //按钮X,Y,宽高，间距
    CGFloat btnY = 0;
    CGFloat margin = 27;
    CGFloat btnWH = (self.bounds.size.width - (cols - 1) * 2 * margin) / cols;
    
    //布局按钮
    for (NSInteger i = 0; i < self.subviews.count; i++) {
        UIButton *btn = self.subviews[i];
        btnX = i % cols * (btnWH + margin) + margin;
        btnY = i / cols * (btnWH + margin) + margin;
        btn.frame = CGRectMake(btnX, btnY, btnWH, btnWH);
    }
}

//监听滑动
- (void)move:(UIPanGestureRecognizer *)pan{

    _curP = [pan locationInView:self];
    
    for (UIButton *btn in self.subviews) {
        if(CGRectContainsPoint(btn.frame, _curP) && !btn.selected){  //点在不在按钮范围内，且按钮没有被选中
            btn.selected = YES;
            btn.userInteractionEnabled = NO;    //在选中的状态下再点击不会显示高亮状态
            [self.selectedBtns addObject:btn];  //把当前按钮添加到选中按钮数组中
        }
    }
    //重绘
    [self setNeedsDisplay];
    
    //手指抬起的时候验证密码，并且清除视图
    if (pan.state == UIGestureRecognizerStateEnded) {
        
        NSMutableString *password = [NSMutableString string];
        for (UIButton *btn in self.selectedBtns) {
            [password appendFormat:@"%ld",btn.tag];
            btn.selected = NO;
            btn.userInteractionEnabled = YES;
        }
        
        if (![password isEqualToString:@"012543"]) {
            self.pathColor = @"红色";
            [self setNeedsDisplay];
        }else{
            [self.selectedBtns removeAllObjects];
            [self setNeedsDisplay];
        }
    }
}

//重绘视图
- (void)drawRect:(CGRect)rect{
   
    if (!self.selectedBtns.count) return;
    
    //创建路径，以及设置路径的一些属性
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = 20;
    path.lineJoinStyle = kCGLineJoinRound;
    path.lineCapStyle = kCGLineCapRound;
    
    for (NSInteger i = 0; i < self.selectedBtns.count; i++) {
        UIButton *btn = self.selectedBtns[i];
        if (i == 0) {
            [path moveToPoint:btn.center];
        }else{
            [path addLineToPoint:btn.center];
        }
    }
    
    [path addLineToPoint:_curP];
    
    if ([self.pathColor isEqualToString:@"绿色"]) {
        [[UIColor greenColor] set];
    }else{
        [[UIColor redColor] set];
        [self.selectedBtns removeAllObjects];
        self.pathColor = @"绿色";
        //延时一下再重绘
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //必须在主线程执行才能重绘制
            [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
        });
    }
    
    [path stroke];
    
}


@end
