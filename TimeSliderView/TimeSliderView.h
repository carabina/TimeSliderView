//
//  TimeSliderView.h
//  Demo
//
//  Created by maxim.makhun on 5/26/14.
//  Copyright (c) 2014 MMA. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TimeSliderView;

@protocol TimeSliderViewDelegate <NSObject>

//TODO: rework delegate methods, extend
@optional
- (void)timeSliderViewDidChangeValue:(TimeSliderView *)sliderView;
- (void)timeSliderViewWillStartMoving:(TimeSliderView *)sliderView;
- (void)timeSliderViewDidStopMoving:(TimeSliderView *)sliderView;

@end

@interface TimeSliderView : UIView

@property (nonatomic, retain) id<TimeSliderViewDelegate> delegate;
@property (nonatomic) CGFloat sliderValue;
@property (nonatomic, strong) UILabel *timeSelectorLabel;
@property (nonatomic) BOOL is24HourFormat;
//TODO: Create accessor fields to get current hour and minutes (as int values) and as date/time

// public methods
- (void)setSliderValue:(CGFloat)value animated:(BOOL)animated;
- (void)placeIndicatorViewWithHour:(NSUInteger)hour andMinute:(NSUInteger)minute;
- (void)placeIndicatorWithDate:(NSDate *)date;

@end
