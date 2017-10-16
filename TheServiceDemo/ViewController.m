//
//  ViewController.m
//  TheServiceDemo
//
//  Created by 范云飞 on 2017/10/13.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import "ViewController.h"

#import"GCDAsyncSocket.h"

@interface ViewController ()<GCDAsyncSocketDelegate>
@property (strong, nonatomic) IBOutlet UITextField * PortTextField;
@property (strong, nonatomic) IBOutlet UITextField * SendTextField;
@property (strong, nonatomic) IBOutlet UITextView *ResultTextView;
@property (strong, nonatomic) IBOutlet UIButton *ListenBtn;
@property (strong, nonatomic) IBOutlet UIButton *SendBtn;
@property (strong, nonatomic) IBOutlet UIButton *ReceiveBtn;


@property(nonatomic)GCDAsyncSocket*serverSocket;/* 服务器socket（开放端口，监听客户端socket的链接） */
@property(nonatomic)GCDAsyncSocket*clientSocket;/* 保护客户端socket */

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    /* 初始化服务器socket，在主线程力回调 */
    self.serverSocket= [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    self.PortTextField.text = @"8080";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - GCDAsynSocket Delegate
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket
{
    /* 保存客户端的socket */
    self.clientSocket = newSocket;
    [self showMessageWithStr:@"链接成功"];
    [self showMessageWithStr:[NSString stringWithFormat:@"服务器地址：%@ -端口：%d", newSocket.connectedHost, newSocket.connectedPort]];
    
    [self.clientSocket readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString*text = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    [self showMessageWithStr:text];
    [self.clientSocket readDataWithTimeout:-1 tag:0];
}

/* 监听端口 */
- (IBAction)listen:(id)sender
{
    /* 开放哪一个端口 */
    NSError * error =nil;
    BOOL result = [self.serverSocket acceptOnPort:self.PortTextField.text.integerValue error:&error];
    if(result && error ==nil) {
        /* 开放成功 */
        [self showMessageWithStr:@"开放成功"];
    }
}

/* 发送消息 */
- (IBAction)send:(id)sender
{
    NSData*data = [@"<xml>我喜欢你<xml>" dataUsingEncoding:NSUTF8StringEncoding];
    //withTimeout -1:无穷大，一直等
    //tag:消息标记
    [self.clientSocket writeData:data withTimeout:-1 tag:0];
}

/* 接受消息,socket是客户端socket，表示从哪一个客户端读取消息 */
- (IBAction)receive:(id)sender
{
    [self.clientSocket readDataWithTimeout:11 tag:0];
}

- (void)showMessageWithStr:(NSString*)str{
    
    self.ResultTextView.text= [self.ResultTextView.text stringByAppendingFormat:@"%@\n",str];
    
}

@end
