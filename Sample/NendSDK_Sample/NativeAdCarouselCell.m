//
//  NativeAdCarouseCell.m
//  NendSDK_Sample
//
//  Copyright © 2016年 F@N Communications. All rights reserved.
//

#import "NativeAdCarouselCell.h"
#import "NADNativeClient.h"
#import "NativeAdCarouselView.h"

#define cellWidth   [UIScreen mainScreen].bounds.size.width

static const int adCount = 5; // 最大5枚
static const float adPortraitWidth = 320.f; // 立て向き　広告横幅
static const float adPortraitHeight = 325.f; // 立て向き 広告高さ
static const float adLandscapeWidth = 580.f; // 横向き　広告横幅
static const float adLandscapeHeight = 200.f; // 横向き　広告高さ

@interface NativeAdCarouselCell ()<NADNativeDelegate, UIScrollViewDelegate>

@property (nonatomic) NADNativeClient *client;
@property (nonatomic) NSMutableArray *adViewsP;
@property (nonatomic) NSMutableArray *adViewsL;
@property (nonatomic) NSMutableArray *ads;
@property (nonatomic) UIScrollView *scrollView;

@property (nonatomic) float adLandscapeWidth; // 横向き　広告横幅

@end

@implementation NativeAdCarouselCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.directionalLockEnabled = YES;
    self.scrollView.pagingEnabled = NO;
    self.scrollView.bounces = NO;
    self.scrollView.decelerationRate = 0.3;
    [self addSubview:self.scrollView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layoutUpdate:) name:@"layoutUpdate" object:nil];
    
    return self;
}

- (void) initAd {
    if (self) {
        self.client = [[NADNativeClient alloc] initWithSpotId:@"485504" apiKey:@"30fda4b3386e793a14b27bedb4dcd29f03d638e5" advertisingExplicitly:NADNativeAdvertisingExplicitlyPR];
        self.client.delegate = self;
        self.ads = [NSMutableArray array];
        self.adViewsP = [NSMutableArray array];
        self.adViewsL = [NSMutableArray array];
        
        // 5ページ分の広告を先にまとめて取得
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        __weak typeof(self) weakSelf = self;
        dispatch_group_t group = dispatch_group_create();
        dispatch_apply(adCount, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t i) {
            dispatch_group_enter(group);
            [self.client loadWithCompletionBlock:^(NADNative *ad, NSError *error) {
                if (ad) {
                    UINib *nibP = [UINib nibWithNibName:@"NativeAdCarouselPortraitView" bundle:nil];
                    UINib *nibL = [UINib nibWithNibName:@"NativeAdCarouselLandscapeView" bundle:nil];
                    UIView<NADNativeViewRendering> *viewP = [[nibP instantiateWithOwner:nil options:nil] objectAtIndex:0];
                    UIView<NADNativeViewRendering> *viewL = [[nibL instantiateWithOwner:nil options:nil] objectAtIndex:0];
                    
                    [weakSelf.ads addObject:ad];
                    [weakSelf.adViewsP addObject:viewP];
                    [weakSelf.adViewsL addObject:viewL];
                } else {
                    NSLog(@"%@", error);
                }
                dispatch_group_leave(group);
            }];
        });
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            for (int i = 0; i < self.adViewsP.count; i ++) {
                NativeAdCarouselView *viewP = [self.adViewsP objectAtIndex:i];
                viewP.frame = CGRectMake(i * adPortraitWidth, 0, adPortraitWidth, adPortraitHeight);
                
                double delayInSeconds = 0.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    NADNative *ad = [self.ads objectAtIndex:i];
                    [ad intoView:(UIView<NADNativeViewRendering> *)viewP];
                });
            }
            
            for (int i = 0; i < self.adViewsL.count; i ++) {
                NativeAdCarouselView *viewL = [self.adViewsL objectAtIndex:i];
                viewL.frame = CGRectMake(i * self.adLandscapeWidth, 0, self.adLandscapeWidth, adLandscapeHeight);
                
                double delayInSeconds = 0.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    NADNative *ad = [self.ads objectAtIndex:i];
                    [ad intoView:(UIView<NADNativeViewRendering> *)viewL];
                });
            }
            
            [self layoutUpdate];
        });
    }
}

#pragma mark UIScrollView

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self animation];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)_scrollView{
    [self animation];
}

- (void) animation {
    int distance = self.scrollView.contentOffset.x;
    float adWidth;
    if ([self.direction integerValue] == 1) {
        adWidth = adPortraitWidth;
    } else {
        adWidth = self.adLandscapeWidth;
    }
    
    if (distance + cellWidth/2 < adWidth) {
        distance = 0;
    } else if (distance + cellWidth/2 < adWidth * 2) {
        distance = adWidth * 1.5 - cellWidth / 2;
    } else if (distance + cellWidth/2 < adWidth * 3) {
        distance = adWidth * 2.5 - cellWidth / 2;
    } else if (distance + cellWidth / 2 < adWidth * 4) {
        distance = adWidth * 3.5 - cellWidth / 2;
    } else {
        distance = adWidth * 5 - cellWidth;
    }
    
    [self.scrollView setContentOffset:CGPointMake(distance, 0) animated:YES];
}

- (void) layoutUpdate:(NSNotification*) notification {
    self.direction = [notification object];
    [self layoutUpdate];
}

- (void) layoutUpdate {
    float width;
    float height;
    
    for (UIView *subview in self.scrollView.subviews) {
        [subview removeFromSuperview];
    }
    
    if ([self.direction integerValue] == 1) {
        self.adLandscapeWidth = adPortraitWidth;
        width = self.adLandscapeWidth;
        height = adPortraitHeight;
        
        for (int i = 0; i < self.adViewsP.count; i ++) {
            NativeAdCarouselView *adViewP = [self.adViewsP objectAtIndex:i];
            adViewP.index = i;
            [adViewP frameUpdate:self.direction];
            [self.scrollView addSubview:adViewP];
            
        }
    } else {
        if (cellWidth < adLandscapeWidth) {
            self.adLandscapeWidth = cellWidth - 20;
        } else {
            self.adLandscapeWidth = adLandscapeWidth;
        }
        width = self.adLandscapeWidth;
        height = adLandscapeHeight;
        
        for (int i = 0; i < self.adViewsL.count; i ++) {
            NativeAdCarouselView *adViewL = [self.adViewsL objectAtIndex:i];
            adViewL.index = i;
            [adViewL frameUpdate:self.direction];
            [self.scrollView addSubview:adViewL];
        }
    }
    
    self.scrollView.frame = CGRectMake(0.f, 0.f, cellWidth, height);
    self.scrollView.contentSize =  CGSizeMake(width * adCount, 0);
}

@end
