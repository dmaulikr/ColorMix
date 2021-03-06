//
//  CMSettingViewController.m
//  
//
//  Created by luck-mac on 15/6/25.
//
//

#import "CMSettingViewController.h"
#import "CMMenuViewController.h"
#import "CMTutorialViewController.h"
#import "CMScoreView.h"

@interface CMSettingViewController ()<UIPopoverControllerDelegate>
@property (nonatomic, strong) UIButton *shareBtn;
@property (nonatomic, strong) UIPopoverController *shareController;
@property (weak, nonatomic) IBOutlet UIButton *vibrateBtn;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@end

@implementation CMSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.alpha = 0;
    [self.vibrateBtn setSelected:[[NSUserDefaults standardUserDefaults] boolForKey:kVibrateSwitchKey]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.shareController) {
        [self.shareController dismissPopoverAnimated:NO];
        [self.shareController presentPopoverFromRect:CGRectMake(self.view.frame.size.width / 2, self.shareBtn.frame.size.height +self.shareBtn.frame.origin.y , 0, 0) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:NO];
    }
}

#pragma mark - ButtonAction
- (IBAction)onTutorialButtonClicked:(id)sender {
    [MobClick event:@"Setting_Tutorial"];
    WS(weakSelf);
    CMTutorialViewController *tutorialViewController = [[CMTutorialViewController alloc] initWithMode:classicMode completeBlock:^(BOOL completed) {
        CMTutorialViewController *tutorialViewController = [[CMTutorialViewController alloc] initWithMode:fantasyMode completeBlock:nil];
        tutorialViewController.view.frame = self.view.bounds;
        [weakSelf.view addSubview:tutorialViewController.view];
        [weakSelf addChildViewController:tutorialViewController];
    }];
    tutorialViewController.view.frame = self.view.bounds;
    [self.view addSubview:tutorialViewController.view];
    [self addChildViewController:tutorialViewController];
    tutorialViewController.view.alpha = 0.0;
    [UIView animateWithDuration:0.3 animations:^{
        tutorialViewController.view.alpha = 1.0;
    } completion:nil];
}

- (IBAction)onShareButtonClicked:(id)sender {
    [MobClick event:@"Setting_Share"];
    CMScoreView *scoreView = [[CMScoreView alloc] initWithScore:-1];
    UIImage *imageToShare = [UIImage cm_captureImageFromView:scoreView];
    NSString *stringToShare = [NSString stringWithFormat:@"Think you know color? Come and play #Co!orMix, a game about color and your reflection. And please be nice to your phone. %@" , kAppStoreUrl ];
    NSArray *activityItems = [[NSArray alloc] initWithObjects:imageToShare,stringToShare, nil];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypeSaveToCameraRoll];
    if (IS_IPAD) {
        UIButton *shareBtn = (UIButton*)sender;
        self.shareBtn = shareBtn;
        UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:activityVC];
        self.shareController = popup;
        self.shareController.delegate = self;
        [popup presentPopoverFromRect:CGRectMake(self.view.frame.size.width / 2, shareBtn.frame.size.height +shareBtn.frame.origin.y , 0, 0) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    } else {
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}

- (IBAction)onRateUsButtonClicked:(id)sender {
    [MobClick event:@"Setting_Rate"];
    NSString *reviewURL = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", kAppId];
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:reviewURL]];
}

- (IBAction)onAboutUsButtonClicked:(id)sender {
    
}

- (IBAction)onVibrateButtonClicked:(UIButton *)sender {
    [MobClick event:@"Setting_Vibrate"];
    [sender setSelected:!sender.selected];
    [[NSUserDefaults standardUserDefaults] setBool:sender.selected forKey:kVibrateSwitchKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [((CMMenuViewController*)self.parentViewController) removeBlurView];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromParentViewController];
        [self.view removeFromSuperview];
    }];
}

#pragma mark - UIPopoverViewController 
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    self.shareController = nil;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
