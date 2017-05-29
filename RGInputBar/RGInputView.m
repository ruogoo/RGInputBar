//
//  RGInputView.m
//
//  Created by HyanCat on 16/4/16.
//  Copyright © 2016年 HyanCat. All rights reserved.
//

#import "RGInputView.h"
@import UITextView_Placeholder;

@interface RGInputView () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *inputPanelView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *replyTipButton;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;

@end

@implementation RGInputView

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.contentTextView.delegate = self;
}

- (void)setContent:(NSString *)content
{
    _content = content;
    self.contentTextView.text = content;
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    self.contentTextView.placeholder = self.placeholder;
}

- (void)setCancelActionTitle:(NSString *)cancelActionTitle
{
    _cancelActionTitle = cancelActionTitle;
    [self.cancelButton setTitle:self.cancelActionTitle forState:UIControlStateNormal];
    [self.cancelButton sizeToFit];
}

- (void)setSendActionTitle:(NSString *)sendActionTitle
{
    _sendActionTitle = sendActionTitle;
    [self.sendButton setTitle:self.sendActionTitle forState:UIControlStateNormal];
    [self.sendButton sizeToFit];
}

- (void)setReplyTipTitle:(NSString *)replyTipTitle
{
    _replyTipTitle = replyTipTitle;
    [self.replyTipButton setTitle:replyTipTitle forState:UIControlStateNormal];
    [self.replyTipButton sizeToFit];
}

- (void)clear
{
    self.content = nil;
    self.replyTipTitle = nil;
}

- (void)show
{
    self.hidden = NO;
    if (self.inputDelegate && [self.inputDelegate respondsToSelector:@selector(rg_inputViewWillShow:)]) {
        [self.inputDelegate rg_inputViewWillShow:self];
    }
    [self.contentTextView becomeFirstResponder];
}

- (void)dismiss
{
    if (self.inputDelegate && [self.inputDelegate respondsToSelector:@selector(rg_inputViewWillDismiss:)]) {
        [self.inputDelegate rg_inputViewWillDismiss:self];
    }
    [self.contentTextView resignFirstResponder];
}

- (IBAction)cancelButtonTouched:(id)sender
{
    if (self.inputDelegate && [self.inputDelegate respondsToSelector:@selector(rg_inputView:didTouchedCancelButton:)]) {
        [self.inputDelegate rg_inputView:self didTouchedCancelButton:sender];
    }
}
- (IBAction)sendButtonTouched:(id)sender
{
    if (self.inputDelegate && [self.inputDelegate respondsToSelector:@selector(rg_inputView:didTouchedSendButton:)]) {
        [self.inputDelegate rg_inputView:self didTouchedSendButton:sender];
    }
}
- (IBAction)replyTipButtonTouched:(id)sender
{
    if (self.inputDelegate && [self.inputDelegate respondsToSelector:@selector(rg_inputView:didTouchedReplyTipButton:)]) {
        [self.inputDelegate rg_inputView:self didTouchedReplyTipButton:sender];
    }
}

- (IBAction)backgroundTapped:(UITapGestureRecognizer *)sender
{
    [self dismiss];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardEndFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:[userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                     animations:^{
                         CGRect frame = self.inputPanelView.frame;
                         frame.origin.y = CGRectGetMinY(keyboardEndFrame) - frame.size.height;
                         self.inputPanelView.frame = frame;
                         self.backgroundView.alpha = 0.5f;
                     }
                     completion:^(BOOL finished) {
                         if (self.inputDelegate && [self.inputDelegate respondsToSelector:@selector(rg_inputViewDidShow:)]) {
                             [self.inputDelegate rg_inputViewDidShow:self];
                         }
                     }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardEndFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:[userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]
                     animations:^{
                         CGRect frame = self.inputPanelView.frame;
                         frame.origin.y = CGRectGetMaxY(keyboardEndFrame);
                         self.inputPanelView.frame = frame;
                         self.backgroundView.alpha = 0.f;
                     }
                     completion:^(BOOL finished) {
                         self.hidden = YES;
                         if (self.inputDelegate && [self.inputDelegate respondsToSelector:@selector(rg_inputViewDidDismiss:)]) {
                             [self.inputDelegate rg_inputViewDidDismiss:self];
                         }
                     }];
}

- (void)textViewDidChange:(UITextView *)textView
{
    if ([self.content isEqualToString:textView.text]) {
        return;
    }
    self.content = textView.text;
}

@end
