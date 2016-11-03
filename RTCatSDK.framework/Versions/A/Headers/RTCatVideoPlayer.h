//
//  VideoPlayer.h
//  RTCatSDK
//
//  Created by cong chen on 9/7/16.
//  Copyright © 2016 cong chen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

/**
 * 视频播放器
 */
@interface RTCatVideoPlayer: NSObject

/**
 *  初始化播放器
 *
 *  @param frame CGRect
 *
 *  @return RTCatVideoPlayer
 */
-(instancetype)initWithFrame:(CGRect)frame;

/**
 *  播放器的 video
 */
@property (nonatomic, strong) UIView *view;

@end
