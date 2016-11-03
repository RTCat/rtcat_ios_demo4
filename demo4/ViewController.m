//
//  ViewController.m
//  demo4
//
//  Created by spacetime on 10/31/16.
//  Copyright © 2016 cong chen. All rights reserved.
//

#import "ViewController.h"
#import <RTCatSDK/RTCat.h>
#import <RTCatSDK/RTCatSender.h>
#import <RTCatSDK/RTCatReceiver.h>
@interface ViewController(SessionDelegate)<RTCatSessionDelegate>

@end

@interface ViewController(ReceiverDelegate)<RTCatReceiverDelegate>

@end

@interface ViewController(SenderDelegate)<RTCatSenderDelegate>

@end

@interface ViewController (){
    RTCat *cat;
    RTCatSession *session;
    NSString *tokenId;
    NSMutableArray *senders;
}

@property (weak, nonatomic) IBOutlet UITextField *txtInput;
@property (weak, nonatomic) IBOutlet UIButton *btSend;
@property (weak, nonatomic) IBOutlet UITextView *txtDisplay;


@end

@implementation ViewController
- (IBAction)onSendClick:(UIButton *)sender {
    if([senders count]){
        NSString *mes = _txtInput.text;
        [_txtDisplay setText:[NSString stringWithFormat:@"%@ : %@\n%@",@"self",mes,_txtDisplay.text]];
        [_txtInput setText:@""];
        for (RTCatSender *sender in senders) {
            NSLog(@"send message  %@ to %@ ",mes,[sender getReceiverToken]);
            [sender sendMessage:mes];
        }
        
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    cat = [RTCat shareInstance];
    
    senders = [NSMutableArray array];
    
    NSString *sessionId = @"";
    NSString *apiKey = @"";
    NSString *apiSecret = @"";
    NSString *url = [NSString stringWithFormat:@"https://api.realtimecat.com/v0.3/sessions/%@/tokens",sessionId];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [request setValue:apiKey forHTTPHeaderField:@"X-RTCAT-APIKEY"];
    [request setValue:apiSecret forHTTPHeaderField:@"X-RTCAT-SECRET"];
    
    NSString *dataString = [NSString stringWithFormat:@"session_id=%@&type=%@",sessionId,@"pub"];
    NSData *data = [dataString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[data length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:data];
    
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if(conn) {
        NSLog(@"Connection Successful");
    } else {
        NSLog(@"Connection could not be made");
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data{
    
    NSError *error = nil;
    id object = [NSJSONSerialization
                 JSONObjectWithData:data
                 options:0
                 error:&error];
    
    if([object isKindOfClass:[NSDictionary class]]){
        
        NSDictionary *results = object;
        tokenId = [results objectForKey:@"uuid"];
        NSLog(@"my token is %@",tokenId);
        
        
        session = [cat createSessionWithToken:tokenId];
        [session addDelegate:self];
        [session connect];
    }
    else{
    }
    
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"error %@",[error localizedDescription]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
}
@end


@implementation ViewController(SessionDelegate)

-(void)sessionIn:(NSString *)token{
    NSLog(@"%@ is in",token);
    
    [session sendStream:nil to:token data:true attr:@{@"test":@"test"}];
    
}

-(void) sessionOut:(NSString *)token{
    NSLog(@"%@ is out",token);
    
    for (RTCatSender *sender in senders) {
        if([[sender getReceiverToken]isEqualToString:token]){
            [senders removeObject:sender];
        }
    }
}

-(void)sessionConnected:(NSArray *)tokens{
    NSLog(@"connected");
    
    [session sendStream:nil data:true attr:@{@"test":@"test"} ];
    
}

-(void)sessionClose{
    
}

-(void)sessionError:(NSError *)error{
    NSLog(@"session error -> %@",error);
}

-(void)sessionLocal:(RTCatSender *)sender{
    sender.delegate = self;
    NSLog(@"add sender");
    [senders addObject:sender];
    
}

-(void)sessionRemote:(RTCatReceiver *)receiver{
    receiver.delegate = self;
    [receiver response];
}

-(void)sessionMessage:(NSString *)message from:(NSString *)tokenId{
}


@end




@implementation ViewController(ReceiverDelegate)
-(void)receiverClose:(RTCatReceiver *)receiver{
    
}
-(void)receiver:(RTCatReceiver *)receiver Stream:(RTCatRemoteStream *)stream{
    
}

-(void)receiver:(RTCatReceiver *)receiver Error:(NSError *)error{
    
}

-(void)receiver:(RTCatReceiver *)receiver Message:(NSString *)message{
    NSLog(@"recevie message %@ from %@",message,[receiver getSenderToken]);
    dispatch_async(dispatch_get_main_queue(), ^{
        [_txtDisplay setText:[NSString stringWithFormat:@"%@ : %@\n%@",[[receiver getSenderToken] substringToIndex:4],message,_txtDisplay.text]];
    });
}


-(void)receiver:(RTCatReceiver *)receiver Log:(NSDictionary *)log{
    
}


-(void)receiver:(RTCatReceiver *)receiver FilePath:(NSString *)filePath{
    
}
@end

@implementation ViewController(SenderDelegate)

-(void)senderClose:(RTCatSender *)sender{
    
}

-(void)sender:(RTCatSender *)sender error:(NSError *)error{
    
}


-(void)sender:(RTCatSender *)sender Log:(NSDictionary *)log{
    
}

@end




