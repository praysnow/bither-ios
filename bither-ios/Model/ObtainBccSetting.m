//
//  ObtainBCCSetting.m
//  bither-ios
//
//  Created by 韩珍 on 2017/7/26.
//  Copyright © 2017年 Bither. All rights reserved.
//

#import "ObtainBccSetting.h"
#import "BTAddressManager.h"
#import "UIViewController+PiShowBanner.h"
#import "BTOut.h"
#import "BTBlockProvider.h"
#import "BTPeerManager.h"
#import "SplitCoinUtil.h"
#import "ObtainBccViewController.h"

static ObtainBccSetting *S;

@interface ObtainBccSetting ()

@property(weak) UIViewController *controller;

@end


@implementation ObtainBccSetting

+ (Setting *)getObtainBccSetting {
    if (!S) {
        S = [[ObtainBccSetting alloc] init];
    }
    return S;
}

- (instancetype)init {
    self = [super initWithName:[NSString stringWithFormat:NSLocalizedString(@"get_split_coin_setting_name", nil), [SplitCoinUtil getSplitCoinName:SplitBCC]] icon:nil];
    if (self) {
        __weak ObtainBccSetting *s = self;
        [self setSelectBlock:^(UIViewController *controller) {
            
            u_int32_t lastBlockHeight = [BTPeerManager instance].lastBlockHeight;
            uint64_t forkBlockHeight = [BTTx getForkBlockHeightForCoin:BCC];
            if (lastBlockHeight < forkBlockHeight) {
                NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"please_firstly_sync_to_block_no", nil), forkBlockHeight];
                [controller showBannerWithMessage:msg belowView:[controller.view subviews].lastObject];
            } else {
                BTAddressManager *manager = [BTAddressManager instance];
                if (![manager hasHDAccountHot] && ![manager hasHDAccountMonitored] && manager.privKeyAddresses.count == 0 && manager.watchOnlyAddresses.count == 0) {
                    [controller showBannerWithMessage:NSLocalizedString(@"no_private_key", nil) belowView:[controller.view subviews].lastObject];
                } else {
                    s.controller = controller;
                    [s show];
                }
            }
        }];
    }
    return self;
}

- (void)show {
    ObtainBccViewController *vc = [self.controller.storyboard instantiateViewControllerWithIdentifier:@"ObtainBccViewController"];
    vc.splitCoin = SplitBCC;
    [self.controller.navigationController pushViewController:vc animated:YES];
}

@end
