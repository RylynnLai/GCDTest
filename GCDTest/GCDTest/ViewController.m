//
//  ViewController.m
//  GCDTest
//
//  Created by LLZ on 2018/2/23.
//  Copyright © 2018年 LLZ. All rights reserved.
//

#import "ViewController.h"
#define ROW_COUNT 5

@interface ViewController ()
@property (nonatomic, strong) NSMutableArray <UIImageView *>*imageViews;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    self.imageViews = [NSMutableArray arrayWithCapacity:ROW_COUNT];
    for (int i = 0; i < ROW_COUNT; i ++) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 110 * i, width, 100)];
        [self.view addSubview:imgView];
        [self.imageViews addObject:imgView];
    }
 
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn1.frame = CGRectMake(20, height - 50, 50, 30);
    [btn1 setTitle:@"串行" forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(btn1Action) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeSystem];
    btn2.frame = CGRectMake(70, height - 50, 50, 30);
    [btn2 setTitle:@"并行" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(btn2Action) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(width - 50, height - 50, 50, 30);
    [btn setTitle:@"clear" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clearAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

/*
 01 异步函数+并发队列：开启多条线程，并发执行任务
 02 异步函数+串行队列：开启一条线程，串行执行任务
 03 同步函数+并发队列：不开线程，串行执行任务
 04 同步函数+串行队列：不开线程，串行执行任务
 05 异步函数+主队列：不开线程，在主线程中串行执行任务
 06 同步函数+主队列：不开线程，串行执行任务（注意死锁发生）
 
 同步函数（dispatch_sync）和异步函数（dispatch_async）的差别在于是否开启新线程
 同步函数（dispatch_sync）会造成线程阻塞，直到block执行完才会返回，异步函数（dispatch_async）不会造成阻塞，会马上返回
 只有并行队列并且使用异步函数执行时才能在多个线程中执行。
 */

- (void)btn1Action
{
    [self test2];
}

- (void)btn2Action
{
    [self test4];
}

- (void)test0
{
    //因为dispatch_sync是在当前queue调用的，就是dispatch_get_main_queue，所以dispatch_sync会把block放在dispatch_get_main_queue队末，并阻塞当前线程（当前queue），知道block执行完才返回，但是block永远没有执行的机会，所以造成了死锁
    //如果手动创建了一个串行队列，在当前queue执行新的串行队列就不会出问题，如test1
    dispatch_queue_t queue = dispatch_get_main_queue();//获取主线程
    
    dispatch_sync(queue, ^{
        NSData *data = [self imageDataWithIndex:0];
        [self updateImageViewWithData:data index:0];
    });
}

- (void)test1
{
    //创建串行队列
    dispatch_queue_t queue = dispatch_queue_create("SERIAL_QUEUE", DISPATCH_QUEUE_SERIAL);
    
    //因为在当前queue调用dispatch_sync，会阻塞当前queue，即dispatch_get_main_queue
    dispatch_sync(queue, ^{
        NSData *data = [self imageDataWithIndex:0];
        [self updateImageViewWithData:data index:0];
        NSLog(@"0----%@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSData *data = [self imageDataWithIndex:1];
        [self updateImageViewWithData:data index:1];
        NSLog(@"1----%@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSData *data = [self imageDataWithIndex:4];
        [self updateImageViewWithData:data index:4];
        NSLog(@"4----%@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSData *data = [self imageDataWithIndex:2];
        [self updateImageViewWithData:data index:2];
        NSLog(@"2----%@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSData *data = [self imageDataWithIndex:3];
        [self updateImageViewWithData:data index:3];
        NSLog(@"3----%@",[NSThread currentThread]);
    });
}

- (void)test2
{
    //创建串行队列
    dispatch_queue_t queue = dispatch_queue_create("SERIAL_QUEUE", DISPATCH_QUEUE_SERIAL);
    
    //因为在当前queue调用dispatch_sync，会阻塞当前queue，即dispatch_get_main_queue
    //无论使用同步函数还是并发函数，串行队列的任务都会顺序执行，必须一个执行完，才执行下一个
    dispatch_sync(queue, ^{
        NSData *data = [self imageDataWithIndex:0];
        [self updateImageViewWithData:data index:0];
        NSLog(@"0----%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{//开启线程
        NSData *data = [self imageDataWithIndex:1];
//        dispatch_queue_t mainQueue= dispatch_get_main_queue();
//        dispatch_sync(mainQueue, ^{
//            [self updateImageViewWithData:data index:1];
//        });//死锁了
        NSLog(@"1----%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{//开启线程
        NSData *data = [self imageDataWithIndex:4];
//        dispatch_queue_t mainQueue= dispatch_get_main_queue();
//        dispatch_sync(mainQueue, ^{
//            [self updateImageViewWithData:data index:4];
//        });//死锁了
        NSLog(@"4----%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{//开启线程
        NSData *data = [self imageDataWithIndex:2];
//        dispatch_queue_t mainQueue= dispatch_get_main_queue();
//        dispatch_sync(mainQueue, ^{
//            [self updateImageViewWithData:data index:2];
//        });//死锁了
        NSLog(@"2----%@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSData *data = [self imageDataWithIndex:3];
        [self updateImageViewWithData:data index:3];
        NSLog(@"3----%@",[NSThread currentThread]);
    });
}

- (void)test3
{
    //创建并行队列，但实际一般不会自己创建并行队列，而是使用系统的全局并行队列
//    dispatch_queue_t queue = dispatch_queue_create("SERIAL_QUEUE", DISPATCH_QUEUE_CONCURRENT);
    
    /*
     #define DISPATCH_QUEUE_PRIORITY_HIGH 2
     #define DISPATCH_QUEUE_PRIORITY_DEFAULT 0
     #define DISPATCH_QUEUE_PRIORITY_LOW (-2)
     #define DISPATCH_QUEUE_PRIORITY_BACKGROUND INT16_MIN
     */
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_sync(queue, ^{
        NSData *data = [self imageDataWithIndex:0];
        [self updateImageViewWithData:data index:0];
        NSLog(@"0----%@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSData *data = [self imageDataWithIndex:1];
        [self updateImageViewWithData:data index:1];
        NSLog(@"1----%@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSData *data = [self imageDataWithIndex:4];
        [self updateImageViewWithData:data index:4];
        NSLog(@"4----%@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSData *data = [self imageDataWithIndex:2];
        [self updateImageViewWithData:data index:2];
        NSLog(@"2----%@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSData *data = [self imageDataWithIndex:3];
        [self updateImageViewWithData:data index:3];
        NSLog(@"3----%@",[NSThread currentThread]);
    });
}


- (void)test4
{
    //创建并行队列，但实际一般不会自己创建并行队列，而是使用系统的全局并行队列
    //    dispatch_queue_t queue = dispatch_queue_create("SERIAL_QUEUE", DISPATCH_QUEUE_CONCURRENT);
    
    /*
     #define DISPATCH_QUEUE_PRIORITY_HIGH 2
     #define DISPATCH_QUEUE_PRIORITY_DEFAULT 0
     #define DISPATCH_QUEUE_PRIORITY_LOW (-2)
     #define DISPATCH_QUEUE_PRIORITY_BACKGROUND INT16_MIN
     */
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        NSData *data = [self imageDataWithIndex:0];
        dispatch_queue_t mainQueue= dispatch_get_main_queue();
        dispatch_sync(mainQueue, ^{
            [self updateImageViewWithData:data index:0];
        });
        NSLog(@"0----%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSData *data = [self imageDataWithIndex:1];
        dispatch_queue_t mainQueue= dispatch_get_main_queue();
        dispatch_sync(mainQueue, ^{
            [self updateImageViewWithData:data index:1];
        });
        NSLog(@"1----%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSData *data = [self imageDataWithIndex:4];
        dispatch_queue_t mainQueue= dispatch_get_main_queue();
        dispatch_sync(mainQueue, ^{
            [self updateImageViewWithData:data index:4];
        });
        NSLog(@"4----%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSData *data = [self imageDataWithIndex:2];
        dispatch_queue_t mainQueue= dispatch_get_main_queue();
        dispatch_sync(mainQueue, ^{
            [self updateImageViewWithData:data index:2];
        });
        NSLog(@"2----%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSData *data = [self imageDataWithIndex:3];
        dispatch_queue_t mainQueue= dispatch_get_main_queue();
        dispatch_sync(mainQueue, ^{
            [self updateImageViewWithData:data index:3];
        });
        NSLog(@"3----%@",[NSThread currentThread]);
    });
}

- (void)clearAction
{
    [self.imageViews enumerateObjectsUsingBlock:^(UIImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.image = nil;
    }];
}

- (NSData *)imageDataWithIndex:(int)index
{
    NSURL *url = [NSURL URLWithString:@"http://www.ucsmy.com/images/banner.jpg"];
    return [NSData dataWithContentsOfURL:url];//下载jpg，耗时操作
}

- (void)updateImageViewWithData:(NSData *)data index:(int)index
{
    [self.imageViews[index] setImage:[UIImage imageWithData:data]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
