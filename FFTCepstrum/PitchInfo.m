//
//  PitchInfo.m
//  FFTCepstrum
//
//  Created by Edward on 16/8/14.
//  Copyright (c) 2014 Edward. All rights reserved.
//

#import "PitchInfo.h"

@implementation PitchInfo

@synthesize _maxAmp;
@synthesize _bin;
@synthesize _frequency;
@synthesize _midiNum;
@synthesize _pitch;
@synthesize _pitchAboveNoise;

-(id)init
{
    if ([super init])
        [self resetParameters];
    
    return self;
}

-(void)resetParameters
{
    _maxAmp = -INFINITY;
    _bin = 0;
    _frequency = 0;
    _midiNum = 0;
    _pitch = @"nil";
    _pitchAboveNoise = @"nil";
}

+ (Float32)freqToMIDI:(Float32)frequency
{
    if (frequency <=0)
        return -1;
    else
        return 12*log2f(frequency/440) + 69;
}
+ (NSString*)midiToPitch:(Float32)midiNote
{
    if (midiNote<=-1)
        return @"NIL";
    
    int midi = (int)round((double)midiNote);
    NSArray *noteStrings = [[NSArray alloc] initWithObjects:@"C", @"C#", @"D", @"D#", @"E", @"F", @"F#", @"G", @"G#", @"A", @"A#", @"B", nil];
    NSString *retval = [noteStrings objectAtIndex:midi%12];
    
    if(midi <= 23)
        retval = [retval stringByAppendingString:@"0"];
    else if(midi <= 35)
        retval = [retval stringByAppendingString:@"1"];
    else if(midi <= 47)
        retval = [retval stringByAppendingString:@"2"];
    else if(midi <= 59)
        retval = [retval stringByAppendingString:@"3"];
    else if(midi <= 71)
        retval = [retval stringByAppendingString:@"4"];
    else if(midi <= 83)
        retval = [retval stringByAppendingString:@"5"];
    else if(midi <= 95)
        retval = [retval stringByAppendingString:@"6"];
    else if(midi <= 107)
        retval = [retval stringByAppendingString:@"7"];
    else
        retval = [retval stringByAppendingString:@"8"];
    
    return retval;
}

@end
