//
//  CXHLoginViewModel.h
//  RAC_Test
//
//  Created by UCS on 2018/1/31.
//  Copyright © 2018年 UCS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Account.h"
#import <ReactiveCocoa/RACSignal.h>
#import <ReactiveCocoa/RACCommand.h>

@interface CXHLoginViewModel : NSObject
@property (nonatomic, strong) Account *account;
@property (nonatomic, strong) NSString *pass;

// 是否允许登录的信号
@property (nonatomic, strong, readonly) RACSignal *enableLoginSignal;

@property (nonatomic, strong, readonly) RACCommand *LoginCommand;



@property (nonatomic, strong) CXHLoginViewModel *loginModel;

@end
