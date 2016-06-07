//
//  TimeSliderView.m
//  Demo
//
//  Created by Maxim Makhun on 5/26/14.
//  Copyright (c) 2014 MMA. All rights reserved.
//

#import "TimeSliderView.h"

static const int MinutesStep = 5;

@interface TimeSliderView ()

@property (nonatomic) int hour;
@property (nonatomic) int minute;
@property (nonatomic) BOOL isIndicatorTouched;
@property (nonatomic) CGFloat indicatorYOffset;
@property (nonatomic, strong) NSString *splitString;

- (void)initialize;

@end

@implementation TimeSliderView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initialize];
    }
    
    return self;
}

- (id)init {
    self = [super init];
    
    if (self) {
        [self initialize];
    }
    
    return self;
}

- (void)initialize {
    self.isIndicatorTouched = NO;
    self.indicatorYOffset = 0.0f;
    _sliderValue = 0.0f;
    
    self.timeSelectorLabel = [UILabel new];
    self.timeSelectorLabel.textAlignment = NSTextAlignmentCenter;
    self.timeSelectorLabel.frame = CGRectMake(0, 0, self.bounds.size.width, 40);
    
    [self addSubview:self.timeSelectorLabel];
    
    int hour = _sliderValue * 24;
    float valFloat = _sliderValue * 24;
    int minute = (valFloat - hour) * 60;
    NSString *splitStr = @"";
    
    if (!self.is24HourFormat) {
        if (hour == 0) {
            splitStr = @"am";
            hour = 12;
        } else if ((hour > 0) && (hour < 12)) {
            splitStr = @"am";
        } else if (hour == 12) {
            splitStr = @"pm";
            hour = 12;
        } else if ((hour > 12) && (hour < 24)) {
            splitStr = @"pm";
            hour = hour - 12;
        } else if (hour == 24) {
            if (minute == 0) {
                splitStr = @"pm";
                hour = 11;
                minute = 59;
            } else {
                splitStr = @"pm";
                hour = hour - 12;
            }
        }
        
        NSString *str = [NSString stringWithFormat:@"%d:%0*d %@", hour, 2, minute, splitStr];
        
        self.timeSelectorLabel.text = str;
    } else {
        if (minute == 24) {
            if (minute == 0) {
                hour = 23;
                minute = 59;
            }
        }
        
        NSString *str = [NSString stringWithFormat:@"%0*d:%0*d", 2, hour, 2, minute];
        self.timeSelectorLabel.text = str;
    }
}

- (void)updateSlider {
    float sliderValue = _sliderValue;
    
    int currentHour = sliderValue * 24;
    float valFloat = sliderValue * 24;
    int currentMinute = (valFloat - currentHour) * 60;
    
    if (currentMinute % MinutesStep != 0) {
        currentMinute += 1;
        
        if (currentMinute == 60) {
            currentHour += 1;
            currentMinute = 0;
        }
    }
    
    self.hour = currentHour;
    self.minute = currentMinute;
    
    if (!self.is24HourFormat) {
        if (currentMinute % MinutesStep == 0) {
            self.splitString = @"";
            
            if (currentHour == 0) {
                self.splitString = @"am";
                currentHour = 12;
            } else if ((currentHour > 0) && (currentHour < 12)) {
                self.splitString = @"am";
            } else if (currentHour == 12) {
                self.splitString = @"pm";
                currentHour = 12;
            } else if ((currentHour > 12) && (currentHour < 24)) {
                self.splitString = @"pm";
                currentHour = currentHour - 12;
            } else if (currentHour == 24) {
                if (currentMinute == 0) {
                    self.splitString = @"pm";
                    currentHour = 11;
                    currentMinute = 59;
                } else {
                    self.splitString = @"pm";
                    currentHour = currentHour - 12;
                }
            }
            
            NSString *str = [NSString stringWithFormat:@"%d:%0*d %@", currentHour, 2, currentMinute, self.splitString];
            self.timeSelectorLabel.text = str;
        }
    } else {
        if (currentMinute % MinutesStep == 0) {
            if (currentHour == 24) {
                if (currentMinute == 0) {
                    currentHour = 23;
                    currentMinute = 59;
                }
            }
            
            NSString *str = [NSString stringWithFormat:@"%0*d:%0*d", 2, currentHour, 2, currentMinute];
            self.timeSelectorLabel.text = str;
        }
    }
}

- (void)setSliderValue:(CGFloat)value {
    [self setSliderValue:value animated:NO];
}

- (void)setSliderValue:(CGFloat)value animated:(BOOL)animated {
    _sliderValue = value;
    
    CGFloat height = self.frame.size.height - self.timeSelectorLabel.frame.size.height;
    CGRect newFrame = self.timeSelectorLabel.frame;
    newFrame.origin.y = value * height;
    
    if ([self.delegate respondsToSelector:@selector(timeSliderViewWillStartMoving:)]) {
        [self.delegate timeSliderViewWillStartMoving:self];
    }
    
    if (animated) {
        [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn animations:^{
            self.timeSelectorLabel.frame = newFrame;
        } completion:^(BOOL finished) {
            if ([self.delegate respondsToSelector:@selector(timeSliderViewDidStopMoving:)]) {
                [self.delegate timeSliderViewDidStopMoving:self];
            }
        }];
    } else {
        self.timeSelectorLabel.frame = newFrame;
        
        if ([self.delegate respondsToSelector:@selector(timeSliderViewDidStopMoving:)]) {
            [self.delegate timeSliderViewDidStopMoving:self];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(timeSliderViewDidChangeValue:)]) {
        [self.delegate timeSliderViewDidChangeValue:self];
    }
    
    [self updateSlider];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchCoord = [touch locationInView:self];
    
    if (CGRectContainsPoint(self.timeSelectorLabel.frame, touchCoord)) {
        self.isIndicatorTouched = YES;
        
        CGPoint touchCoordInIndicator = [touch locationInView:self.timeSelectorLabel];
        self.indicatorYOffset = touchCoordInIndicator.y;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.isIndicatorTouched = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.isIndicatorTouched) {
        UITouch *touch = [touches anyObject];
        CGPoint touchCoord = [touch locationInView:self];
        
        CGFloat height = self.frame.size.height - self.timeSelectorLabel.frame.size.height;
        touchCoord.y -= self.indicatorYOffset;
        touchCoord.y = MIN(touchCoord.y, height);
        touchCoord.y = MAX(touchCoord.y, 0);
        
        [self setSliderValue:touchCoord.y / height animated:NO];
        
        if ([self.delegate respondsToSelector:@selector(timeSliderViewDidChangeValue:)]) {
            [self.delegate timeSliderViewDidChangeValue:self];
        }
        
        [self updateSlider];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.isIndicatorTouched) {
        UITouch *touch = [touches anyObject];
        CGPoint touchCoord = [touch locationInView:self];
        CGFloat trueHeight = self.frame.size.height - self.timeSelectorLabel.frame.size.height;
        touchCoord.y = MIN(touchCoord.y, trueHeight);
        CGFloat sliderY = self.timeSelectorLabel.frame.origin.y;
        
        CGFloat divHeight = trueHeight / (24 * 12);
        long hr = self.hour * 12;
        
        if (touchCoord.y > sliderY) { // press was made below time indicator
            long min = (self.minute + MinutesStep) / 5;
            sliderY = (divHeight * (hr + min)) / trueHeight;
        } else { // press was made above time indicator
            long min = (self.minute - MinutesStep) / 5;
            sliderY = divHeight * (hr + min) / trueHeight;
        }
        
        [self setSliderValue:sliderY animated:YES];
    }
    
    self.isIndicatorTouched = NO;
}

- (CGFloat)calculatePositionWithHour:(NSUInteger)hour minute:(NSUInteger)minute {
    CGFloat trueHeight = self.frame.size.height - self.timeSelectorLabel.frame.size.height;
    CGFloat divHeight = trueHeight / (24 * 12);
    long hr = hour * 12;
    long min = minute / 5;
    
    return (divHeight * (hr + min)) / trueHeight;
}

- (void)placeIndicatorViewWithHour:(NSUInteger)hour minute:(NSUInteger)minute {
    [self setSliderValue:[self calculatePositionWithHour:hour minute:minute] animated:YES];
}

- (void)placeIndicatorWithDate:(NSDate *)date {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:date];
    
    [self setSliderValue:[self calculatePositionWithHour:dateComponents.hour minute:dateComponents.minute] animated:YES];
}

@end
