//
//  CMGameResultViewController.m
//  
//
//  Created by luck-mac on 15/6/25.
//
//

#import "CMGameResultViewController.h"
#import "CMMenuViewController.h"
#import "CMGameViewController.h"
#import "CMScoreView.h"
#import "CMGameCenterHelper.h"

@interface CMGameResultViewController ()<UIPopoverControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *homeBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UIButton *replayBtn;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *highScoreLabel;
@property (nonatomic, strong) UIPopoverController *shareController;
@end

@implementation CMGameResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_replayBtn cm_setToRounded];
    [_shareBtn cm_setToRounded];
    [_homeBtn cm_setToRounded];
    _homeBtn.layer.borderColor = _homeBtn.titleLabel.textColor.CGColor;
    _homeBtn.layer.borderWidth = 2.0;
    [_scoreLabel setText:[NSString stringWithFormat:@"Score: %ld",(long)self.score]];
    NSInteger highestScore = [[[NSUserDefaults standardUserDefaults] objectForKey:self.gameMode == classicMode ? kClassicHighScoreKey : kFantasyHighScoreKey] integerValue];
    [_highScoreLabel setText:[NSString stringWithFormat:@"Best: %ld",(long)highestScore]];
    [CMGameCenterHelper submitScore:highestScore
                           category:self.gameMode == classicMode ? kClassicRankIdentifier : kFantasyRankIdentifier];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (self.shareController) {
        [self.shareController dismissPopoverAnimated:NO];
        [self.shareController presentPopoverFromRect:CGRectMake(self.view.frame.size.width / 2, self.shareBtn.frame.size.height + self.shareBtn.frame.origin.y , 0, 0)inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}

#pragma mark - ButtonAction
- (IBAction)onReplayButtonClicked:(id)sender {
    [MobClick event:@"Replay"];
    CMGameViewController *gameViewController = [[CMGameViewController alloc] initWithGameMode:_gameMode];
    [self.navigationController pushViewController:gameViewController animated:YES];
    self.navigationController.viewControllers = @[self.navigationController.childViewControllers[0], self.navigationController.topViewController];
}

- (IBAction)onShareButtonClicked:(id)sender {
    [MobClick event:@"Share"];
    CMScoreView *scoreView = [[CMScoreView alloc] initWithScore:self.score];
    UIImage *imageToShare = [UIImage cm_captureImageFromView:scoreView];
    NSString *stringToShare = [NSString stringWithFormat:@"I scored %ld in the %@ mode, play #Co!orMix with me: %@", (long)self.score, self.gameMode == classicMode ? @"classic" : @"fantasy" , kAppStoreUrl ];
    NSArray *activityItems = [[NSArray alloc] initWithObjects:imageToShare,stringToShare, nil];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityVC.excludedActivityTypes = @[UIActivityTypeSaveToCameraRoll];
    if (IS_IPAD) {
        UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:activityVC];
        self.shareController = popup;
        popup.delegate = self;
        [popup presentPopoverFromRect:CGRectMake(self.view.frame.size.width / 2, self.shareBtn.frame.size.height + self.shareBtn.frame.origin.y , 0, 0)inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    } else {
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}

- (IBAction)onHomeButtonClicked:(id)sender {
    [MobClick event:@"Home"];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    self.shareController = nil;
}
@end
