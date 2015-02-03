//
//  ViewController.m
//  calc
//
//  Created by JD Elliott on 2/1/15.
//  Copyright (c) 2015 jdelliott. All rights reserved.
//

#import "ViewController.h"
#include "math.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *displayLabel;

@property BOOL entryModeForNumber;
@property BOOL errorMode;
@property NSString *errorMessage;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.entryModeForNumber = FALSE;
    self.errorMode = FALSE;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UI methods

- (IBAction)tappedButton:(UIButton *)sender
{
    if (self.entryModeForNumber) {
        self.displayLabel.text = [self.displayLabel.text stringByAppendingString:sender.currentTitle];
    } else {
        self.displayLabel.text = sender.currentTitle;
        self.entryModeForNumber = TRUE;
    }
}

- (IBAction)clear:(UIButton *)sender
{
    self.displayLabel.text = @"0";
    self.entryModeForNumber = FALSE;
}

- (IBAction)enter:(UIButton *)sender
{
    self.entryModeForNumber = FALSE;
    self.displayLabel.text = [self parseCalculations:self.displayLabel.text];
}

#pragma mark - Parsing and calculation methods

- (NSString *)parseCalculations: (NSString *)displayText
{
    // retrieve operands and operators
    NSCharacterSet *signs = [NSCharacterSet characterSetWithCharactersInString:@"+-÷✕"];
    NSCharacterSet *digits = [NSCharacterSet characterSetWithCharactersInString:@"1234567890"];
    NSArray *operands = [[displayText componentsSeparatedByCharactersInSet:signs]
                         filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
    NSArray *operators = [[displayText componentsSeparatedByCharactersInSet:digits]
                          filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
    
    if (operands.count < 2 || operators.count < 1 || operands.count == operators.count) {
        return @"Bad expression!";
    }
    
    // iterate through calculations
    double result = 0.0;
    NSInteger i = 0;
    NSInteger j = 0;
    while (operands.count > i) {
        if (i == 0) {
            result = [self calculate:operands[i] operator:operators[j] operand2:operands[i+1]];
            i += 2;
        } else {
            result = [self calculate:[NSString stringWithFormat:@"%f", result] operator:operators[j] operand2:operands[i]];
            i++;
        }
        j++;
        if (self.errorMode) {
            self.errorMode = FALSE;
            return self.errorMessage;
        }
    }
    return [self formatNumberForDisplay:result];
}

- (double)calculate: (NSString *)operand1 operator:(NSString *)operator operand2:(NSString *)operand2
{
    if ([operator isEqualToString:@"\u00f7"]) { // divide
        if ([operand2 isEqualToString:@"0"]) {
            self.errorMode = TRUE;
            self.errorMessage = @"Division by 0!";
            return 0;
        } else {
            return [operand1 doubleValue] / [operand2 doubleValue];
        }
    } else if ([operator isEqualToString:@"\u2715"]) { // multiply
        return [operand1 doubleValue] * [operand2 doubleValue];
    } else if ([operator isEqualToString:@"-"]) {
        return [operand1 doubleValue] - [operand2 doubleValue];
    } else if ([operator isEqualToString:@"+"]) {
        return [operand1 doubleValue] + [operand2 doubleValue];
    } else { return 0; }
}

- (NSString *)formatNumberForDisplay: (double)number
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    return [formatter stringFromNumber:[NSNumber numberWithDouble:number]];
}

@end
