//
//  MyScene.m
//  FFTCepstrum
//
//  Created by Edward on 13/7/14.
//  Copyright (c) 2014 Edward. All rights reserved.
//

#import "MyScene.h"

@implementation MyScene

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        /* Setup your scene here */
        NSLog(@"SKScene:initWithSize %f x %f", size.width, size.height);
        
        self.backgroundColor = [SKColor whiteColor];
        
        SKTextureAtlas *backgroundAtlas = [SKTextureAtlas atlasNamed:@"background"];
        
        /* Setup UI for 4 Graphs */
        _graph = [SKSpriteNode spriteNodeWithTexture:[backgroundAtlas textureNamed:@"axis"]];
        _graph.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        [self addChild:_graph];
        
        /* Setup Microphone, Buffer Manager and FFTCepstrum mechanism */
        _sampleRate = 44100;
        _framesSize = 4096;
        _overlap = 0.5;
        
        _audioController = [[AudioController alloc] init:_sampleRate FrameSize:_framesSize OverLap:_overlap];
        
        CGMutablePathRef path;
        
        /* Setup UI for Audio Wave */
        _waveLine = [SKShapeNode node];
        path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, 20, 507);
        _waveLine.path = path;
        CGPathRelease(path);
        _waveLine.lineWidth = 0.5;
        [_waveLine setStrokeColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
        [self addChild:_waveLine];
        
        _waveInterval = 300/(float)(_framesSize);
        _waveLength = _framesSize;
        _sampleStep = _waveLength/1024;
        
        /* Setup UI for FFT */
        _fftLine = [SKShapeNode node];
        path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, 20, 304);
        _fftLine.path = path;
        CGPathRelease(path);
        [_fftLine setStrokeColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:1]];
        [self addChild:_fftLine];

        /* Setup UI for Cepstrum */
        _cepstrumLine = [SKShapeNode node];
        path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, 20, 162);
        _cepstrumLine.path = path;
        CGPathRelease(path);
        [_cepstrumLine setStrokeColor:[UIColor colorWithRed:0 green:1 blue:0 alpha:1]];
        [self addChild:_cepstrumLine];

        /* Setup UI for FFTCepstrum */
        _fftlogcepstrumLine = [SKShapeNode node];
        path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, 20, 20);
        _fftlogcepstrumLine.path = path;
        CGPathRelease(path);
        [_fftlogcepstrumLine setStrokeColor:[UIColor colorWithRed:0 green:0 blue:1 alpha:1]];
        [self addChild:_fftlogcepstrumLine];
        
        _sampleRate = [_audioController sessionSampleRate];
        
        _Hz1200 = floor(1200*(float)_framesSize/(float)_sampleRate);
        _Interval = 300/_Hz1200;
        
        NSLog(@"_Hz1200: %.12f; _Interval: %.12f", _Hz1200, _Interval);
        
        //NSLog(@"_frameSize/_sampleRate: %f", (float)_framesSize/(float)_sampleRate);
        //NSLog(@"_Hz30: %ld; _Hz70: %ld; _Hz95: %ld; _Hz100: %ld; _Hz120: %ld; _Hz530: %ld; _Hz1000: %ld; _Hz1200: %ld", _Hz30, _Hz70, _Hz95, _Hz100, _Hz120, _Hz530, _Hz1000, _Hz1200);
        
        /* Turn on the microphone */
        [_audioController startIOUnit];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    /* Called when a touch begins */
    /*
    if( [_audioController isRecording])
        [_audioController stopRecording];
    else
        [_audioController startRecording];
    */
}

-(void)update:(CFTimeInterval)currentTime
{
    CGMutablePathRef path;
    int i;
    
    // Draw audio wave
    Float32* waveBuffers = [_audioController CurrentwaveData];
    path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 20, 507);
    for (i=0; i<_waveLength; i+=_sampleStep)
    {
        _waveX = 20 + (i*_waveInterval);
        _waveY = 507 + (waveBuffers[i]*300);
        CGPathAddLineToPoint(path, NULL, _waveX, _waveY);
    }
    _waveLine.path = path;
    CGPathRelease(path);
    free(waveBuffers);
    waveBuffers = NULL;
    
    // Draw fft wave
    Float32* fftBuffers = [_audioController CurrentfftData];
    path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 20, 304);
    for (i=0; i<=_Hz1200; i++)
    {
        _X = 20 + (i*_Interval);
        //if (isnan(fftBuffers[i]) || i<_lowestPitchThreshold || i>_highestPitchThreshold)
        if (isnan(fftBuffers[i]))
            _Y = 304;
        else
            _Y = 304 + (fftBuffers[i]);
        CGPathAddLineToPoint(path, NULL, _X, _Y);
    }
    _fftLine.path = path;
    CGPathRelease(path);
    
    // Draw cepstrum wave
    Float32* cepBuffers = [_audioController CurrentcepstrumData];
    path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 20, 162);
    for (i=0; i<=_Hz1200; i++)
    {
        _X = 20 + (i*_Interval);
        //if (isnan(cepBuffers[i]) || i<_lowestPitchThreshold || i>_highestPitchThreshold)
        if (isnan(cepBuffers[i]))
            _Y = 162;
        else
            _Y = 162 + log(cepBuffers[i]);
        CGPathAddLineToPoint(path, NULL, _X, _Y);
    }
    _cepstrumLine.path = path;
    CGPathRelease(path);

    // Draw fft * log(cepstrum) wave
    Float32* fftLogCepBuffers = [_audioController CurrentfftlogcepstrumData];
    path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 20, 20);
    for (i=0; i<=_Hz1200; i++)
    {
        _X = 20 + (i*_Interval);
        //if (isnan(cepBuffers[i]) || i<_lowestPitchThreshold || i>_highestPitchThreshold)
        if (isnan(fftLogCepBuffers[i]))
            _Y = 20;
        else
            _Y = 20 + (fftLogCepBuffers[i]*0.1);
        CGPathAddLineToPoint(path, NULL, _X, _Y);
    }
    _fftlogcepstrumLine.path = path;
    CGPathRelease(path);
    
    NSLog(@"SpriteKit Update(): %.12f %d %.12f %@", [_audioController CurrentFreq], [_audioController CurrentBin], [_audioController CurrentMIDI], [_audioController CurrentPitch]);
}

@end
