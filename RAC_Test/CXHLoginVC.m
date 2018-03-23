//
//  CXHLoginVC.m
//  RAC_Test
//
//  Created by UCS on 2018/1/31.
//  Copyright © 2018年 UCS. All rights reserved.
//

#import "CXHLoginVC.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACReturnSignal.h>
#import "CXHLoginViewModel.h"

@interface CXHLoginVC ()
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UIButton *timeBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UITextField *codeText;
@property (nonatomic,assign) NSInteger timer;
@property (nonatomic,strong) RACDisposable *disposable;
@property (nonatomic, strong) CXHLoginViewModel *loginModel;

@property (nonatomic, strong) NSString *account;
@property (nonatomic, strong) NSString *pwd;

@end

@implementation CXHLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"登录";
    
    // 创建一个name的signal
    RACSignal *nameSignal = [self.nameText.rac_textSignal map:^id(NSString *text) {
        return @([self isValidName:text]);
    }];
    
    // 创建一个pass的signal
    RACSignal *passSignal = [self.passwordText.rac_textSignal map:^id(NSString *text) {
        return @([self isValidPassword:text]);
    }];
    
    //应用宏定义控制控件的UI
    RAC(self.nameText,backgroundColor) = [nameSignal map:^id(NSNumber *nameValid) {
        return [nameValid boolValue] ? [UIColor clearColor] : [UIColor yellowColor];
    }];
    
    RAC(self.passwordText,backgroundColor) = [passSignal map:^id(NSNumber *passwordValid) {
        return [passwordValid boolValue] ? [UIColor clearColor] : [UIColor yellowColor];
    }];
    
    //创建一个signal判断是否可以login
    RACSignal *loginEnableSignal = [RACSignal combineLatest:@[nameSignal,passSignal] reduce:^id(NSNumber *nameValid, NSNumber *passwordValid ){
        return @([nameValid boolValue] && [passwordValid boolValue]);
    }];
    
    RAC(self.loginBtn,enabled) = loginEnableSignal;
    
    //点击登录按钮
    [[[[self.loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside] doNext:^(id x) {
        [self.view endEditing:YES];
        self.loginBtn.enabled = NO;
        
    }] flattenMap:^RACStream *(id value) {//按钮信号转变为登录信号
        return  [self loginSignal];
    }] subscribeNext:^(NSNumber *result) {//获得数据流
        BOOL success = [result boolValue];
        self.loginBtn.enabled = YES;
        if (success) {
            NSLog(@"成功登录跳转新的页面！");
        }
    }];
    
    
    //发送短信验证码
    [[_timeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl *_Nullable x) {
        x.enabled = false;
        self.timer = 10;
        self.disposable = [[RACSignal interval:1.0 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSDate * _Nullable x) {
           
            self.timer --;
            NSString *title = _timer>0?[NSString stringWithFormat:@"请等待%ld秒后重试",(long)_timer]:@"发送验证码";
            [self.timeBtn setTitle:title forState:UIControlStateNormal | UIControlStateDisabled ];
            self.timeBtn.enabled = (_timer ==0)? YES:NO;
            if (_timer ==0) {
                [self.disposable dispose];
            }
        }];
    }];
    
    
    //创建信号
    RACSubject *subject = [RACSubject subject];
    
    //绑定信号
    RACSubject *signal = [subject bind:^RACStreamBindBlock _Nonnull{
        return ^RACSignal *(id _Nullable value,BOOL *stop){
            NSLog(@"x - %@",value);
            return [RACReturnSignal return:value];
        };
    }];
    
    [signal subscribeNext:^(id _Nullable x) {
        NSLog(@"收到数据%@",x);
    }];
    
    [subject sendNext:@"启动自毁程序"];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    [[tapGesture rac_gestureSignal] subscribeNext:^(id x) {
        NSLog(@"\nview被触发tap手势");
        [self.nameText resignFirstResponder];
        [self.passwordText resignFirstResponder];
        [self.codeText resignFirstResponder];
    }];
    [self.view addGestureRecognizer:tapGesture];
   
}

- (CXHLoginViewModel *)loginModel{
    if (!_loginModel) {
        _loginModel = [[CXHLoginViewModel alloc] init];
    }
    return _loginModel;
}

//视图模型绑定
- (void)bindModel{
    //给模型的属性绑定信号
    //只要账号文本框一改变，就会给account赋值
    RAC(self.loginModel,account) = _nameText.rac_textSignal;
//    RAC(self.loginModel.account,pwd)
   
}

- (RACSignal *)loginSignal{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self loginWithName:self.nameText.text password:self.passwordText.text complete:^(BOOL success) {
            [subscriber sendNext:@(success)];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

- (void)loginWithName:(NSString *)name password:(NSString *)password complete:(void (^)(BOOL))loginResult{
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds *NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        BOOL success = [name isEqualToString:@"1234567"] && [password isEqualToString:@"1234567"];
        loginResult(success);
    });
}

// 判断登录名和密码的逻辑
- (BOOL)isValidName:(NSString *)name{
    return name.length >6;
}

- (BOOL)isValidPassword:(NSString *)password{
    return password.length>6;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
