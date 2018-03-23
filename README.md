# RAC

##一、RAC简介
ReactiveCocoa（简称为RAC）,是由Github开源的一个应用于iOS和OS开发的新框架 。



##二、RAC的使用
 2.1 、如何导入ReactiveCocoa框架。

2.1.1、CocoaPods导入，注：我使用第一种导入方法。
```
source 'https://github.com/CocoaPods/Specs.git'

platform:ios,'7.0'

target 'RAC_Test' do
    
pod 'ReactiveCocoa'

end

```
2.1.2、手动导入
 因为开发过程中有些人习惯直接手动导入，但是ReactiveCocoa在GitHub上并没有说明需要哪些依赖库，所以直接把将下载的RactiveCocoa整个文件夹拖到工程，build后，哪里报错修改哪里，最后手动导入成功。注：开发过程中主要选择pod导入，方便管理。
      
##三、RAC常见类
######3.1   RACSignal,在RAC中最核心的类
  信号类，一般表示将来有数据传递，只要有数据改变，信号内部接收到数据，就会马上发出数据。

注意：
```
·信号类(RACSiganl)，只是表示当数据改变时，信号内部会发出数据，它本身不具备发送信号的能力，而是交给内部一个订阅者去发出。

·默认一个信号都是冷信号，也就是值改变了，也不会触发，只有订阅了这个信号，这个信号才会变为热信号，值改变了才会触发。

·如何订阅信号：调用信号RACSignal的subscribeNext就能订阅。
```
###### 3.2  RACSubscriber:
   表示订阅者的意思，用于发送信号，这是一个协议，不是一个类，只要遵守这个协议，并且实现方法才能成为订阅者。通过create创建的信号，都有一个订阅者，帮助他发送数据。
            
######3.3   RACDisposable:
 用于取消订阅者或者清理资源，当信号发送完成或者发送错误的时间，都会自动触发它。
  ```  使用场景：不想监听某个信号时，可以通过它主动取消订阅信号。```
######3.4  RACSubject:
信号提供者，自己可以充当信号，又能发送信号。
```使用场景：通常用来代替代理，有了它，就不必要定义代理了。```

##四、RAC 开发者常用方法

·rac_signalForSelector : 代替代理
·rac_valuesAndChangesForKeyPath: KVO
·rac_signalForControlEvents:监听事件
·rac_addObserverForName 代替通知
·rac_textSignal：监听文本框文字改变
·rac_liftSelector:withSignalsFromArray:Signals:当传入的Signals(信号数组)，每一个signal都至少sendNext过一次，就会去触发第一个selector参数的方法。

使用的时候先导入#import <ReactiveCocoa/ReactiveCocoa.h>

######4.1. Event（按钮点击）
rac_signalForControlEvents：用于监听某个事件。
```
// 把按钮点击事件转换为信号，点击按钮，就会发送信号
    [[self.textfiled rac_signalForControlEvents:UIControlEventEditingChanged] subscribeNext:^(id x) {
        NSLog(@"change");
    }];
```

######4.2.KVO观察着
rac_valuesAndChangesForKeyPath：用于监听某个对象的属性改变。
```
//监听对象的属性值改变，转换成信号，只要值改变就会发送信号
    [[self rac_valuesForKeyPath:@"name" observer:nil] subscribeNext:^(id x) {
        self.textfiled.text =[NSString stringWithFormat:@"%@",self.name];
        NSLog(@"age=%@",self.name);
    }];
```
######4.3.Notification通知
rac_addObserverForName:用于监听某个通知。
```
//键盘弹出
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] subscribeNext:^(id x) {
        NSLog(@"键盘弹出");
    }];
```

######4.4.textField的文字信号
rac_textSignal:只要文本框发出改变就会发出这个信号。
```
   // 监听文本框的文字改变
    [[self.textfiled rac_textSignal] subscribeNext:^(NSString *x) {
        NSLog(@"文本框文字发生了改变：%@",x);
    }];
    //通过RAC提供的宏快速实现textSingel的监听
    // RAC(TARGET, [KEYPATH, [NIL_VALUE]]):用于给某个对象的某个属性绑定。
    // 当textField的文字发生改变时，label的文字也发生改变
    RAC(self.textLabel,text) = self.textfiled.rac_textSignal;
```

######4.5.手势信号
rac_gestureSignal] subscribeNext:用于监听手势
```
 // 监听手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    [[tapGesture rac_gestureSignal] subscribeNext:^(id x) {
        NSLog(@"\nview被触发tap手势");
    }];
    [self.view addGestureRecognizer:tapGesture];
    
```

######4.6.过滤filter方法的使用
过滤信号，使用它可以获取满足条件的信号.
```
// 过滤:
// 每次信号发出，会先执行过滤条件判断.
[_textField.rac_textSignal filter:^BOOL(NSString *value) {
        return value.length > 3;
}];
```

######4.7.ignore:忽略完某些值的信号.
 ``` // 内部调用filter过滤，忽略掉ignore的值
[[_textField.rac_textSignal ignore:@"1"] subscribeNext:^(id x) {
    
    NSLog(@"%@",x);
}];
```


######4.8.RACSequence:RAC中的集合类，用于代替NSArray,NSDictionary,可以使用它来快速遍历数组和字典。
```
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
```
######4.9.需要几个地方数据请求都完成以后再刷新界面的需求
```
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

- (void)updateUIWithR1:(id)data1 R2:(id)data2{
    NSLog(@"\n输出更新后的数据:%@     %@",data1,data2);
}
```
######

##五、ReactiveCocoa常见宏

·RAC(TARGET, [KEYPATH, [NIL_VALUE]])：用于给某个对象的某个属性绑定
·RACObserve(self, name) ：监听某个对象的某个属性,返回的是信号。
·@weakify(Obj)和@strongify(Obj)
·RACTuplePack ：把数据包装成RACTuple（元组类）
·RACTupleUnpack：把RACTuple（元组类）解包成对应的数据
·RACChannelTo 用于双向绑定的一个终端

5.1RAC(TARGET, [KEYPATH, [NIL_VALUE]]):用于给某个对象的某个属性绑定。
```
 //常见宏只要文本框文字改变，就会修改label的文字
    RAC(self.textfiled,text) = _textfiled.rac_textSignal;
```

5.2RACObserve(self, name):监听某个对象的某个属性,返回的是信号。
```
 //监听某个对象的某个属性，返回的是信号
    [RACObserve(self.textfiled, center) subscribeNext:^(id x) {
        NSLog(@"返回的是信号：%@",x);
    }];
```
