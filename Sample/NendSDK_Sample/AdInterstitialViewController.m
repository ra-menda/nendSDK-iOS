//
//  AdInterstitialViewController.m
//  NendSDK_Sample
//
//  Created by ADN on 2014/07/11.
//  Copyright (c) 2014年 F@N Communications. All rights reserved.
//

#import "AdInterstitialViewController.h"

#import <NendAd/NADInterstitial.h>

@interface AdInterstitialViewController () <NADInterstitialDelegate>

@property (nonatomic, weak) IBOutlet UIButton *showButton;

- (IBAction)show:(id)sender;

@end

@implementation AdInterstitialViewController

- (void)dealloc
{
    // 解放時、デリゲートにnilを設定します
    [NADInterstitial sharedInstance].delegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.title = @"Interstitial";

    // デリゲートを設定します
    [NADInterstitial sharedInstance].delegate = self;

    // 広告の読み込みを行います
    [[NADInterstitial sharedInstance] loadAdWithApiKey:@"308c2499c75c4a192f03c02b2fcebd16dcb45cc9" spotId:@"213208"];

    self.showButton.enabled = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
#ifdef ONLY_PORTRAIT
    // 端末回転を縦向きのみに限定します
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
#elif ONLY_LANDSCAPE
    // 端末回転を横向きのみに限定します
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
#else
    return YES;
#endif
}

- (IBAction)show:(id)sender
{
    NADInterstitialShowResult result = [[NADInterstitial sharedInstance] showAdFromViewController:self];
    self.showButton.enabled = result != AD_SHOW_SUCCESS;
    // 広告を表示します
    NSLog(@"+++++ %@ +++++", [self stringForShowResult:result]);
}

- (NSString *)stringForStatusCode:(NADInterstitialStatusCode)code
{
    switch (code) {
        case SUCCESS:
            return @"SUCCESS";
        case FAILED_AD_DOWNLOAD:
            return @"FAILED_AD_DOWNLOAD";
        case FAILED_AD_REQUEST:
            return @"FAILED_AD_REQUEST";
        case INVALID_RESPONSE_TYPE:
            return @"INVALID_RESPONSE_TYPE";
        default:
            return @"UNKNOWN";
    }
}

- (NSString *)stringForClickType:(NADInterstitialClickType)type
{
    switch (type) {
        case DOWNLOAD:
            return @"DOWNLOAD";
        case CLOSE:
            return @"CLOSE";
        case INFORMATION:
            return @"INFORMATION";
        default:
            return @"UNKNOWN";
    }
}

- (NSString *)stringForShowResult:(NADInterstitialShowResult)result
{
    switch (result) {
        case AD_SHOW_SUCCESS:
            return @"AD_SHOW_SUCCESS";
        case AD_DOWNLOAD_INCOMPLETE:
            return @"AD_DOWNLOAD_INCOMPLETE";
        case AD_FREQUENCY_NOT_REACHABLE:
            return @"AD_FREQUENCY_NOT_REACHABLE";
        case AD_LOAD_INCOMPLETE:
            return @"AD_LOAD_INCOMPLETE";
        case AD_REQUEST_INCOMPLETE:
            return @"AD_REQUEST_INCOMPLETE";
        case AD_SHOW_ALREADY:
            return @"AD_SHOW_ALREADY";
        case AD_CANNOT_DISPLAY:
            return @"AD_CANNOT_DISPLAY";
        default:
            return @"UNKNOWN";
    }
}

- (void)didFinishLoadInterstitialAdWithStatus:(NADInterstitialStatusCode)status
{
    // 広告のロード結果を受け取ります
    NSLog(@"+++++ %@ +++++", [self stringForStatusCode:status]);
    self.showButton.enabled = SUCCESS == status;
}

- (void)didClickWithType:(NADInterstitialClickType)type
{
    // 広告上のクリックイベントを受け取ります
    NSLog(@"+++++ %@ +++++", [self stringForClickType:type]);
}

@end
