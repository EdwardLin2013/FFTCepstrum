//
//  PitchInfo.h
//  FFTCepstrum
//
//  Created by Edward on 16/8/14.
//  Copyright (c) 2014 Edward. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PitchInfo : NSObject

@property Float32 _maxAmp;
@property int _bin;
@property Float32 _frequency;
@property Float32 _midiNum;
@property NSString* _pitch;
@property NSString* _pitchAboveNoise;

-(id)init;
-(void)resetParameters;

+ (Float32)freqToMIDI:(Float32)frequency;
+ (NSString*)midiToPitch:(Float32)midiNote;

@end
