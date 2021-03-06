//
//  ViewController.m
//  iPhone Calculator
//
//  Created by SS D on 10/23/1394 AP.
//  Copyright © 1394 SS D. All rights reserved.
//

#import "ViewController.h"
#import "CalculatorFSMModel.h"
//#import <QuartzCore/QuartzCore.h>
int const stringLimit = 11;
int const limit = 9;
int const scientificLimit = 7;

@interface ViewController ()
-(void)setResultLabelText:(NSString*) number;
-(void)addCharacterToResultLabelText:(NSString*) number;
-(void)addPointToResultLabel;
-(void)addOperator:(CalculatorOperator) calculatorOperator fromSender:(UIButton *) sender;
-(int)digitCount:(NSString *)input;
@property NSNumberFormatter * numberFormatter;

typedef NS_ENUM(NSUInteger, CalculatorViewState) {
    CalculatorViewInitial,
    CalculatorViewEnteringNumber,
    CalculatorViewOperatorDidSelect,
    CalculatorViewEqualDidPress
};
@property CalculatorViewState viewState;

-(void)resetButtonBorderWidths;
-(void)deleteFromResultLabelText;

@end

@implementation ViewController

-(int)digitCount:(NSString *)input{
    uint count = 0;
    for (NSUInteger i = 0 ; i < input.length; ++i) {
        unichar uni = [input characterAtIndex:i];
        if ('0' <= uni && uni <= '9') {
            ++count;
        }
    }
    return count;
}
//- (BOOL)shouldAutorotate
//{
//    return NO;
//}
//
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations
//{
//    return UIInterfaceOrientationMaskPortrait;
//}

- (IBAction)clearResultLabel:(UIButton *)sender {
    self.resultLabel.text = @"0";
    [self.clearButton setTitle:@"AC" forState:UIControlStateNormal];
    [self.calculatorFSMModel resetAll];
    self.viewState = CalculatorViewInitial;
}

-(void)addCharacterToResultLabelText:(NSString *)labelText{
    
    NSString * temporaryString = self.resultLabel.text;
    if ([self.resultLabel.text isEqualToString:@"0"] || [self.resultLabel.text isEqualToString:@"Error"] || self.viewState == CalculatorViewEqualDidPress || self.viewState == CalculatorViewOperatorDidSelect){
        temporaryString = labelText;
    }
//    else if (self.resultLabel.text.length < stringLimit)
    else
    {
        temporaryString = [temporaryString stringByAppendingString:labelText];
    }
    
    if ([self digitCount:temporaryString] > limit)
        return;
    NSNumber * number = [self.numberFormatter numberFromString:temporaryString];
//    NSString * anotherTemporaryString = [self.numberFormatter stringFromNumber:number];
//    
//    
    if ([labelText isEqualToString:@"0"] && [self.resultLabel.text containsString:@"."]) {
        self.resultLabel.text = temporaryString;
        }
    else{
//        NSNumber * number = [self.numberFormatter numberFromString:temporaryString];
        self.resultLabel.text = [self.numberFormatter stringFromNumber:number];
    }
    


    
}

-(void)addPointToResultLabel{
    NSString * temporaryString = self.resultLabel.text;
//    if (self.resultLabel.text.length >= stringLimit - 1)
//        return;
    if (! [self.resultLabel.text containsString:@"."]){
        temporaryString = [self.resultLabel.text stringByAppendingString:@"."];
    }
//    NSNumber* number = [self.numberFormatter numberFromString:temporaryString];
//    self.resultLabel.text = [self.numberFormatter stringFromNumber:number];
    self.resultLabel.text = temporaryString;
}

-(void)deleteFromResultLabelText{
    unsigned long length = self.resultLabel.text.length;
    NSString * temporaryString = self.resultLabel.text;
    if (self.viewState == CalculatorViewOperatorDidSelect || self.viewState == CalculatorViewEqualDidPress)
        return;
    if (length > 1){
        temporaryString = [self.resultLabel.text substringToIndex:length - 1];
    }
    else{
        temporaryString = @"0";
    }
    NSNumber* number = [self.numberFormatter numberFromString:temporaryString];
    if ([number isEqualToNumber:@(0)]){
        self.resultLabel.text = temporaryString;
    }
    else{
        self.resultLabel.text = [self.numberFormatter stringFromNumber:number];
    }

}

-(void)setResultLabelText:(NSString *)inputNumber{
    if ([inputNumber isEqualToString:@"Error"]){
        self.resultLabel.text = inputNumber;
        return;
    }
    NSNumberFormatter * anotherNumberFormatter = [[NSNumberFormatter alloc]init];
    NSNumber* signedNumber = [self.numberFormatter numberFromString:inputNumber];
    NSNumber * number = [NSNumber numberWithDouble:fabs(signedNumber.doubleValue)];
//    NSDecimalNumber * overflow = [NSDecimalNumber decimalNumberWithMantissa:10 exponent:(limit - 1) isNegative:NO];
//    NSDecimalNumber * underflow = [NSDecimalNumber decimalNumberWithMantissa:10 exponent:(-limit) isNegative:NO];
    NSNumber * overflow = [NSNumber numberWithDouble:pow(10, limit)];
    NSNumber * underflow = [NSNumber numberWithDouble:pow(10, -limit + 1)];
    
    if ((!([number compare:underflow] == NSOrderedAscending )/*|| [number compare:underflow] == NSOrderedSame [number isEqualToNumber:underflow]*/ && [number compare:overflow] == NSOrderedAscending) || [number isEqualToNumber:@(0)]){
//    if (inputNumber.length > limit){
        
        anotherNumberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        anotherNumberFormatter.maximumSignificantDigits = limit;
    }
    else{
//        NSLog(@"%d", [number compare:underflow] == NSOrderedSame);
//        NSLog(@"%d", [number isEqualToNumber:underflow]);
        anotherNumberFormatter.numberStyle = NSNumberFormatterScientificStyle;
        anotherNumberFormatter.maximumSignificantDigits = scientificLimit;
        anotherNumberFormatter.exponentSymbol = @"e";
    }
    
    anotherNumberFormatter.lenient = YES;
    anotherNumberFormatter.locale = self.numberFormatter.locale;
    number = [anotherNumberFormatter numberFromString:inputNumber];
    self.resultLabel.text = [anotherNumberFormatter stringFromNumber:number];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //    NSExpression * expression = [NSExpression expressionWithFormat:@"sin(pi)"];
    //    NSNumber *result = [expression expressionValueWithObject:nil context:nil];
    //    NSLog(@"%@", result);
    self.viewState = CalculatorViewInitial;
    self.calculatorFSMModel = [[CalculatorFSMModel alloc]init];
    self.numberFormatter = [[NSNumberFormatter alloc]init];
    self.numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    //    self.numberFormatter.numberStyle = NSNumberFormatterScientificStyle;
    self.numberFormatter.maximumSignificantDigits = limit;
    self.numberFormatter.lenient = YES;
    NSLocale * usLocale = [[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
    self.numberFormatter.locale = usLocale;
    //    self.ACButton.layer.borderWidth = 1.0f;
    //    self.ACButton.layer.borderColor = [UIColor blackColor].CGColor;
}


-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;

}
-(void)viewDidAppear:(BOOL)animated{
    
}
-(void)viewWillAppear:(BOOL)animated{
//    NSLog(@"view will appear");
    for (UIButton * button in self.view.subviews){
        if ([button isKindOfClass:[UIButton class]]) {
            button.layer.borderWidth = 0.5f;
            button.layer.borderColor = [UIColor blackColor].CGColor;
        }
    }
}

-(void)viewDidLayoutSubviews{
    for (UIButton * button in self.view.subviews){
        if ([button isKindOfClass:[UIButton class]]) {
            if ([button.titleLabel.text isEqualToString:@"0"]){
                button.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, button.frame.size.width / 2);
            }
        }
    }
    
}

-(void)resetButtonBorderWidths{
    for (UIButton * button in self.view.subviews){
        if ([button isKindOfClass:[UIButton class]]) {
            button.layer.borderWidth = 0.5f;
//            button.layer.borderColor = [UIColor blackColor].CGColor;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)deleteButtonDidTouch:(UIButton *)sender {
    [self deleteFromResultLabelText];
}


- (IBAction)numberButtonDidTouch:(UIButton *)sender {
    [self.clearButton setTitle:@"C" forState:UIControlStateNormal];
    [self addCharacterToResultLabelText:sender.titleLabel.text];
    [self.calculatorFSMModel addCharacter];
    [self resetButtonBorderWidths];
//    double textSize = [self.resultLabel.text sizeWithAttributes:nil].width;
//    NSLog(@"%lf", textSize);
//    if (self.resultLabel.frame.size.width <= textSize){
//        NSLog(@"Overflow");
//    }
    self.viewState = CalculatorViewEnteringNumber;
//    if (![sender.titleLabel.text isEqualToString:@"0"])
//        [self.clearButton setTitle:@"C" forState:UIControlStateNormal];
    
}


- (IBAction)pointButtonDidTouch:(UIButton *)sender {
    [self.clearButton setTitle:@"C" forState:UIControlStateNormal];
    
    if (self.viewState == CalculatorViewEqualDidPress || self.viewState == CalculatorViewOperatorDidSelect)
        self.resultLabel.text = @"0";
    if (! [self.resultLabel.text containsString:@"."]){
        [self addPointToResultLabel];
        [self.calculatorFSMModel addCharacter];
    }
    
    self.viewState = CalculatorViewEnteringNumber;
    [self resetButtonBorderWidths];
}


- (IBAction)negationButtonDidTouch:(UIButton *)sender {
    if ([self.resultLabel.text containsString:@"-"]) {
        self.resultLabel.text = [self.resultLabel.text substringFromIndex:1];
    }
    else{
        self.resultLabel.text = [@"-" stringByAppendingString:self.resultLabel.text];
    }
    [self.calculatorFSMModel addCharacter];
}

-(void)addOperator:(CalculatorOperator)calculatorOperator fromSender:(UIButton *)sender{
    if ([self.resultLabel.text isEqualToString:@"Error"])
        return;
    NSNumber * number = [self.numberFormatter numberFromString:self.resultLabel.text];
    @try {
        [self setResultLabelText:[self.calculatorFSMModel addOperator:calculatorOperator andLabelText:number]];
    }
    @catch (NSException *exception) {
        [self setResultLabelText:@"Error"];
        //        self.resultLabel.text = @"Error";
        self.viewState = CalculatorStateInitial;
    }
    
    self.viewState = CalculatorViewOperatorDidSelect;
    [self resetButtonBorderWidths];
    sender.layer.borderWidth = 2.0f;
}

- (IBAction)addButtonDidTouch:(UIButton *)sender {
    [self addOperator:ADD fromSender:sender];
}


- (IBAction)subtractButtonDidTouch:(UIButton *)sender {
    [self addOperator:SUBTRACT fromSender:sender];
}


- (IBAction)multiplicationButtonDidTouch:(UIButton *)sender {
    [self addOperator:MULTIPLY fromSender:sender];
}


- (IBAction)divisionButtonDidTouch:(UIButton *)sender {
    [self addOperator:DIVIDE fromSender:sender];
}


- (IBAction)equalButtonDidTouch:(UIButton *)sender {
    if ([self.resultLabel.text isEqualToString:@"Error"]){
        return;
    }
    self.viewState = CalculatorViewEqualDidPress;
    NSNumber * number = [self.numberFormatter numberFromString:self.resultLabel.text];
    @try {
[self setResultLabelText:[self.calculatorFSMModel equalEvaluateWithLabelText:number]];
    }
    @catch (NSException *exception) {
        self.resultLabel.text = @"Error";
        self.viewState = CalculatorStateInitial;
    }
    
    [self resetButtonBorderWidths];
}


@end
