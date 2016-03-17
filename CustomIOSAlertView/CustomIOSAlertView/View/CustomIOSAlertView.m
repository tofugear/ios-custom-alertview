//
//  CustomIOSAlertView.m
//  CustomIOSAlertView
//
//  Created by Richard on 20/09/2013.
//  Copyright (c) 2013-2015 Wimagguc.
//
//  Lincesed under The MIT License (MIT)
//  http://opensource.org/licenses/MIT
//

#import "CustomIOSAlertView.h"
#import <QuartzCore/QuartzCore.h>

const static CGFloat kCustomIOSAlertViewDefaultButtonHeight       = 50;
const static CGFloat kCustomIOSAlertViewDefaultButtonSpacerHeight = 1;
const static CGFloat kCustomIOSAlertViewCornerRadius              = 7;

@implementation CustomIOSAlertView

CGFloat buttonHeight = 0;
CGFloat buttonSpacerHeight = 0;

- (id)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        _useMotionEffects = false;
        _buttonTitles = @[@"OK"];
        
        _buttonColor = [[[UIApplication sharedApplication] delegate] window].tintColor;
        if (!_buttonColor) {
            _buttonColor = [UIColor blueColor];
        }
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

// Create the dialog view, and animate opening the dialog
- (void)show
{
    _dialogView = [self createContainerView];
    
    _dialogView.layer.shouldRasterize = YES;
    _dialogView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    
    [self addSubview:_dialogView];
    
    // Can be attached to a view or to the top most window
    // Attached to a view:
    if (_parentView != NULL) {
        [_parentView addSubview:self];
        
        // Attached to the top most window
    } else {
        
        CGSize screenSize = [self countScreenSize];
        CGSize dialogSize = [self countDialogSize];
        CGSize keyboardSize = CGSizeMake(0, 0);
        
        _dialogView.frame = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - keyboardSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
        
        
        [[[[UIApplication sharedApplication] windows] firstObject] addSubview:self];
    }
    
    _dialogView.layer.opacity = 0.5f;
    _dialogView.layer.transform = CATransform3DMakeScale(1.3f, 1.3f, 1.0);
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4f];
                         _dialogView.layer.opacity = 1.0f;
                         _dialogView.layer.transform = CATransform3DMakeScale(1, 1, 1);
                     }
                     completion:NULL
     ];
    
}

// Dialog close animation then cleaning and removing the view from the parent
- (void)close
{
    if (_keepOpen){
        return;
    }
    CATransform3D currentTransform = _dialogView.layer.transform;
    _dialogView.layer.opacity = 1.0f;
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         self.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.0f];
                         _dialogView.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6f, 0.6f, 1.0));
                         _dialogView.layer.opacity = 0.0f;
                     }
                     completion:^(BOOL finished) {
                         for (UIView *v in [self subviews]) {
                             [v removeFromSuperview];
                         }
                         [self removeFromSuperview];
                     }
     ];
}

- (void)setSubView: (UIView *)subView
{
    _containerView = subView;
}

// Creates the container view here: create the dialog, then add the custom content and buttons
- (UIView *)createContainerView
{
    if (_containerView == NULL) {
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 150)];
    }
    
    CGSize screenSize = [self countScreenSize];
    CGSize dialogSize = [self countDialogSize];
    
    // For the black background
    [self setFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    
    // This is the dialog's container; we attach the custom content and the buttons to this one
    UIView *dialogContainer = [[UIView alloc] initWithFrame:CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height)];
    
    // First, we style the dialog to match the iOS7 UIAlertView >>>
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = dialogContainer.bounds;
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[[UIColor colorWithRed:218.0/255.0 green:218.0/255.0 blue:218.0/255.0 alpha:1.0f] CGColor],
                       (id)[[UIColor colorWithRed:233.0/255.0 green:233.0/255.0 blue:233.0/255.0 alpha:1.0f] CGColor],
                       (id)[[UIColor colorWithRed:218.0/255.0 green:218.0/255.0 blue:218.0/255.0 alpha:1.0f] CGColor],
                       nil];
    
    CGFloat cornerRadius = kCustomIOSAlertViewCornerRadius;
    gradient.cornerRadius = cornerRadius;
    [dialogContainer.layer insertSublayer:gradient atIndex:0];
    
    dialogContainer.layer.cornerRadius = cornerRadius;
    dialogContainer.layer.borderColor = [[UIColor colorWithRed:198.0/255.0 green:198.0/255.0 blue:198.0/255.0 alpha:1.0f] CGColor];
    dialogContainer.layer.borderWidth = 1;
    dialogContainer.layer.shadowRadius = cornerRadius + 5;
    dialogContainer.layer.shadowOpacity = 0.1f;
    dialogContainer.layer.shadowOffset = CGSizeMake(0 - (cornerRadius+5)/2, 0 - (cornerRadius+5)/2);
    dialogContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    dialogContainer.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:dialogContainer.bounds cornerRadius:dialogContainer.layer.cornerRadius].CGPath;
    
    // There is a line above the button
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, dialogContainer.bounds.size.height - buttonHeight - buttonSpacerHeight, dialogContainer.bounds.size.width, buttonSpacerHeight)];
    lineView.backgroundColor = [UIColor colorWithRed:198.0/255.0 green:198.0/255.0 blue:198.0/255.0 alpha:1.0f];
    [dialogContainer addSubview:lineView];
    // ^^^
    
    // Add the custom container if there is any
    [dialogContainer addSubview:_containerView];
    
    // Add the buttons too
    [self addButtonsToView:dialogContainer];
    
    return dialogContainer;
}

// Helper function: add buttons to container
- (void)addButtonsToView: (UIView *)container
{
    if (_buttonTitles==NULL) { return; }
    
    CGFloat buttonWidth = container.bounds.size.width / [_buttonTitles count];
    
    for (int i=0; i<[_buttonTitles count]; i++) {
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [closeButton setFrame:CGRectMake(i * buttonWidth, container.bounds.size.height - buttonHeight, buttonWidth, buttonHeight)];
        
        [closeButton setTitleColor:_buttonColor forState:UIControlStateNormal];
        [closeButton setTitleColor:[_buttonColor colorWithAlphaComponent:0.7] forState:UIControlStateHighlighted];
        
        [closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setTag:i];
        
        [closeButton setTitle:[_buttonTitles objectAtIndex:i] forState:UIControlStateNormal];
        [closeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
        [closeButton.layer setCornerRadius:kCustomIOSAlertViewCornerRadius];
        
        [container addSubview:closeButton];
    }
}

// Helper function: count and return the dialog's size
- (CGSize)countDialogSize
{
    CGFloat dialogWidth = _containerView.frame.size.width;
    CGFloat dialogHeight = _containerView.frame.size.height + buttonHeight + buttonSpacerHeight;
    
    return CGSizeMake(dialogWidth, dialogHeight);
}

// Helper function: count and return the screen's size
- (CGSize)countScreenSize
{
    if (_buttonTitles!=NULL && [_buttonTitles count] > 0) {
        buttonHeight       = kCustomIOSAlertViewDefaultButtonHeight;
        buttonSpacerHeight = kCustomIOSAlertViewDefaultButtonSpacerHeight;
    } else {
        buttonHeight = 0;
        buttonSpacerHeight = 0;
    }
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    return CGSizeMake(screenWidth, screenHeight);
}

- (void)dealloc
{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

// Rotation changed, on iOS8
- (void)changeOrientationForIOS8: (NSNotification *)notification {
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         CGSize dialogSize = [self countDialogSize];
                         CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
                         self.frame = CGRectMake(0, 0, screenWidth, screenHeight);
                         _dialogView.frame = CGRectMake((screenWidth - dialogSize.width) / 2, (screenHeight - keyboardSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
                     }
                     completion:nil
     ];
    
    
}

// Handle device orientation changes
- (void)deviceOrientationDidChange: (NSNotification *)notification
{
    // If dialog is attached to the parent view, it probably wants to handle the orientation change itself
    if (_parentView != NULL) {
        return;
    }
    
    [self changeOrientationForIOS8:notification];
}

// Handle keyboard show/hide changes
- (void)keyboardWillShow: (NSNotification *)notification
{
    CGSize screenSize = [self countScreenSize];
    CGSize dialogSize = [self countDialogSize];
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         _dialogView.frame = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - keyboardSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
                     }
                     completion:nil
     ];
}

- (void)keyboardWillHide: (NSNotification *)notification
{
    CGSize screenSize = [self countScreenSize];
    CGSize dialogSize = [self countDialogSize];
    
    [UIView animateWithDuration:0.2f delay:0.0 options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         _dialogView.frame = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
                     }
                     completion:nil
     ];
}

@end
