//
//  Canvas2ImagePlugin.m
//  Canvas2ImagePlugin PhoneGap/Cordova plugin
//
//  Created by Tommy-Carlos Williams on 29/03/12.
//  Copyright (c) 2012 Tommy-Carlos Williams. All rights reserved.
//  MIT Licensed
//

#import "Canvas2ImagePlugin.h"
#import <Cordova/CDV.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

@implementation Canvas2ImagePlugin
@synthesize callbackId;

//-(CDVPlugin*) initWithWebView:(UIWebView*)theWebView
//{
//    self = (Canvas2ImagePlugin*)[super initWithWebView:theWebView];
//    return self;
//}

/*
 保存图片
 */
-(void) savaImg:(CDVInvokedUrlCommand*)command{
    self.callbackId = command.callbackId;
    NSData* imageData = [[NSData alloc] initWithBase64EncodedString:[command.arguments objectAtIndex:0] options:0];

    UIImage* image = [[[UIImage alloc] initWithData:imageData] autorelease];
    //保存到相册
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromImage:image];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        //保存之后需要做的事情
        if (error) {
            // Show error message...
            NSLog(@"ERROR: %@",error);
            CDVPluginResult* result = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString:error.description];
            [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
        } else {
            // Show message image successfully saved
            NSLog(@"IMAGE SAVED!");
            CDVPluginResult* result = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
        }
    }];
}
- (void)saveImageDataToLibrary:(CDVInvokedUrlCommand*)command
{
    self.callbackId = command.callbackId;
    PHAuthorizationStatus photoStatus = [PHPhotoLibrary authorizationStatus];
    if (photoStatus==PHAuthorizationStatusAuthorized ) {
        [self savaImg:command];
    }else{
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(),^{
                NSString *errorMsg=nil;
                switch (status) {
                    case PHAuthorizationStatusAuthorized: //已获取权限
                        [self savaImg:command];
                        break;
                    case PHAuthorizationStatusDenied:
                    { //用户已经明确否认了这一照片数据的应用程序访问
                        errorMsg=@"访问权限受限，请到设置里设置权限";
                    }
                        break;
                    case PHAuthorizationStatusRestricted:
                    {
                        errorMsg=@"此应用程序没有被授权访问的照片数据。可能是家长控制权限";
                    } break;
                    default://其他。。。
                        errorMsg=@"未知错误";
                        break;
                }
                if(errorMsg!=nil){
                    CDVPluginResult* result = [CDVPluginResult resultWithStatus: CDVCommandStatus_ERROR messageAsString:@"访问权限受限，请到设置里设置权限"];
                    [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
                }
            });
        }];
    }
}

- (void)dealloc
{   
    [callbackId release];
    [super dealloc];
}


@end
