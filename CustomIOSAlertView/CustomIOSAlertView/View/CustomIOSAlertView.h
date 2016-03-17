//
//  CustomIOSAlertView.h
//  CustomIOSAlertView
//
//  Created by Richard on 20/09/2013.
//  Copyright (c) 2013-2015 Wimagguc.
//
//  Lincesed under The MIT License (MIT)
//  http://opensource.org/licenses/MIT
//

#import <UIKit/UIKit.h>

@interface CustomIOSAlertView : UIView

@property (nonatomic, retain) UIView *parentView;    // The parent view this 'dialog' is attached to
@property (nonatomic, retain) UIView *dialogView;    // Dialog's container view
@property (nonatomic, retain) UIView *containerView; // Container within the dialog (place your ui elements here)

@property (nonatomic, retain) NSArray *buttonTitles;
@property (nonatomic, assign) BOOL useMotionEffects;
@property (nonatomic, assign) BOOL keepOpen;
@property (nonatomic, assign) UIColor* buttonColor;

@property (copy) void (^onButtonTouchUpInside)(CustomIOSAlertView *alertView, int buttonIndex) ;

- (id)init;

- (void)show;
- (void)close;

- (void)setOnButtonTouchUpInside:(void (^)(CustomIOSAlertView *alertView, int buttonIndex))onButtonTouchUpInside;

- (void)deviceOrientationDidChange: (NSNotification *)notification;
- (void)dealloc;

@end
