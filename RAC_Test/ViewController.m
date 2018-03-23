//
//  ViewController.m
//  RAC_Test
//
//  Created by UCS on 2018/1/24.
//  Copyright © 2018年 UCS. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "CXHLoginVC.h"


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textfiled;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (strong,nonatomic) NSString * name;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"RAC的基础使用";
    
    //RAC 常用方法
    
    
    //1、按钮点击
    // 把按钮点击事件转换为信号，点击按钮，就会发送信号
    [[self.textfiled rac_signalForControlEvents:UIControlEventEditingChanged] subscribeNext:^(id x) {
        NSLog(@"change");
    }];
    
    self.name = @"women";
    
    //2/KVO监听
    //监听对象的属性值改变，转换成信号，只要值改变就会发送信号
    [[self rac_valuesForKeyPath:@"name" observer:nil] subscribeNext:^(id x) {
        self.textfiled.text =[NSString stringWithFormat:@"%@",self.name];
        NSLog(@"age=%@",self.name);
    }];
    
    //3、手势信号
    // 监听手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    [[tapGesture rac_gestureSignal] subscribeNext:^(id x) {
        NSLog(@"\nview被触发tap手势");
    }];
    [self.view addGestureRecognizer:tapGesture];
    
    //4、过滤器filter方法的使用
    // 过滤器
    [[self.textfiled.rac_textSignal filter:^BOOL(NSString *value) {
        return value.length >= 3;
    }] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    //5、通知
    //键盘弹出
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] subscribeNext:^(id x) {
        NSLog(@"键盘弹出");
    }];
    
    //6、监听文本框的文字改变
    // 监听文本框的文字改变
    [[self.textfiled rac_textSignal] subscribeNext:^(NSString *x) {
        NSLog(@"文本框文字发生了改变：%@",x);
    }];
    //通过RAC提供的宏快速实现textSingel的监听
    // RAC(TARGET, [KEYPATH, [NIL_VALUE]]):用于给某个对象的某个属性绑定。
    // 当textField的文字发生改变时，label的文字也发生改变
    RAC(self.textLabel,text) = self.textfiled.rac_textSignal;
    
    [self rac_sequence];
    
    RACSignal *validPasswordSignal =  [self.textfiled.rac_textSignal
                                       map:^id(NSString *text) {
                                           return [self isValidUsername:text];
                                       }];
    
    
    RAC(self.textfiled, backgroundColor) =
    [validPasswordSignal
     map:^id(NSNumber *passwordValid){
         return[passwordValid boolValue] ? [UIColor clearColor]:[UIColor yellowColor];
     }];
    
    
    //使用rac_signalForControlEvents方法跳转下一个页面
    [[self.btnNext rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        CXHLoginVC *vc = [[CXHLoginVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];

    }];
}

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.name = @"new people";
}

- (NSString *)isValidUsername:(NSString *)text{
    return text;
}

////字典转模型
//- (void)flagItemDict{
//    
//    //OC写法
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"flag.plist" ofType:nil];
//    NSArray *dictArr = [NSArray arrayWithContentsOfFile:filePath];
//    NSMutableArray *items = [NSMutableArray array];
//    for (NSDictionary *dict in dictArr) {
////        FLagItem
//        
//        
//    }
//}

- (void)rac_sequence{
    
    //遍历数组
    NSArray *numbers = @[@"45",@"23",@"54",@"65"];
    [numbers.rac_sequence.signal subscribeNext:^(id x) {
        NSLog(@"遍历后的数组%@",x);
    }];
    
    
    //遍历字典
    NSDictionary *dict = @{@"name":@"xomg",@"age":@"18"};
    [dict.rac_sequence.signal subscribeNext:^(id x) {
        RACTupleUnpack_(NSString *key,NSString *value) = x;
        NSLog(@"key=%@ value=%@",key,value);
    }];
    
    
    //处理多个请求，都返回结果的时候，统一做处理.
    RACSignal *request1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
      
        [subscriber sendNext:@"发送请求1"];
        return nil;
    }];
    
    RACSignal *request2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"发送请求2"];
        return nil;
    }];
    
    [self rac_liftSelector:@selector(updateUIWithR1:R2:) withSignalsFromArray:@[request1,request2]];

    
    //常见宏
    RAC(self.textfiled,text) = _textfiled.rac_textSignal;
    
    //监听某个对象的某个属性，返回的是信号
    [RACObserve(self.textfiled, center) subscribeNext:^(id x) {
        NSLog(@"返回的是信号：%@",x);
    }];
    
    //定时器 延时执行
    [[RACScheduler mainThreadScheduler] afterDelay:5 schedule:^{
        NSLog(@"5秒后执行一次");
    }];
    
}

- (void)updateUIWithR1:(id)data1 R2:(id)data2{
    NSLog(@"\n输出更新后的数据:%@     %@",data1,data2);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
