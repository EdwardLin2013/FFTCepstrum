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
        _sampleRate = 22050;
        //_sampleRate = 44100;
        //_framesSize = 4096;
        //_framesSize = 8192;
        _framesSize = 16384;
        //_overlap = 0;
        _overlap = 50;
        
        _audioController = [[AudioController alloc] init:_sampleRate FrameSize:_framesSize OverLap:_overlap];
        _bufferManager = [_audioController getBufferManagerInstance];
        _l_fftData = (Float32*) calloc(_framesSize, sizeof(Float32));
        _l_cepstrumData = (Float32*) calloc(_framesSize, sizeof(Float32));
        _l_fftcepstrumData = (Float32*) calloc(_framesSize, sizeof(Float32));
        
        CGMutablePathRef wavePath;
        
        /* Setup UI for Audio Wave */
        _waveLine = [SKShapeNode node];
        wavePath = CGPathCreateMutable();
        CGPathMoveToPoint(wavePath, NULL, 20, 507);
        _waveLine.path = wavePath;
        CGPathRelease(wavePath);
        _waveLine.lineWidth = 0.5;
        [_waveLine setStrokeColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]];
        [self addChild:_waveLine];
        
        _waveInterval = 300/(float)(_framesSize);
        _waveLength = _framesSize;
        _sampleStep = _waveLength/1024;
        
        /* Setup UI for FFT */
        _fftLine = [SKShapeNode node];
        wavePath = CGPathCreateMutable();
        CGPathMoveToPoint(wavePath, NULL, 20, 304);
        _fftLine.path = wavePath;
        CGPathRelease(wavePath);
        [_fftLine setStrokeColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:1]];
        [self addChild:_fftLine];

        /* Setup UI for Cepstrum */
        _cepstrumLine = [SKShapeNode node];
        wavePath = CGPathCreateMutable();
        CGPathMoveToPoint(wavePath, NULL, 20, 162);
        _cepstrumLine.path = wavePath;
        CGPathRelease(wavePath);
        [_cepstrumLine setStrokeColor:[UIColor colorWithRed:0 green:1 blue:0 alpha:1]];
        [self addChild:_cepstrumLine];

        /* Setup UI for FFTCepstrum */
        _fftcepstrumLine = [SKShapeNode node];
        wavePath = CGPathCreateMutable();
        CGPathMoveToPoint(wavePath, NULL, 20, 20);
        _fftcepstrumLine.path = wavePath;
        CGPathRelease(wavePath);
        [_fftcepstrumLine setStrokeColor:[UIColor colorWithRed:0 green:0 blue:1 alpha:1]];
        [self addChild:_fftcepstrumLine];
        
        _sampleRate = [_audioController sessionSampleRate];
        
        _Hz30 = floor(30*(float)_framesSize/(float)_sampleRate);
        _Hz70 = floor(70*(float)_framesSize/(float)_sampleRate);
        _Hz95 = floor(95*(float)_framesSize/(float)_sampleRate);
        _Hz100 = floor(100*(float)_framesSize/(float)_sampleRate);
        _Hz120 = floor(120*(float)_framesSize/(float)_sampleRate);
        _Hz530 = floor(530*(float)_framesSize/(float)_sampleRate);
        _Hz1000 = floor(1000*(float)_framesSize/(float)_sampleRate);
        _Hz1200 = floor(1200*(float)_framesSize/(float)_sampleRate);
        _Interval = 300/(float)_Hz1200;
        
        _lowestPitchThreshold = _Hz95;
        _highestPitchThreshold = _Hz530;
        
        _currentTotalFreq = 0;
        _currentNum = 0;
        
        NSLog(@"_frameSize/_sampleRate: %f", (float)_framesSize/(float)_sampleRate);
        NSLog(@"_Hz30: %ld; _Hz70: %ld; _Hz95: %ld; _Hz100: %ld; _Hz120: %ld; _Hz530: %ld; _Hz1000: %ld; _Hz1200: %ld", _Hz30, _Hz70, _Hz95, _Hz100, _Hz120, _Hz530, _Hz1000, _Hz1200);
        
        /* Turn on the microphone */
        [_audioController startIOUnit];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    /* Called when a touch begins */
    if( [_audioController isRecording])
        [_audioController stopRecording];
    else
        [_audioController startRecording];
    
}

-(void)update:(CFTimeInterval)currentTime
{
    /* Called before each frame is rendered */
    /*
    int i;
    bool nanOccur = NO;
    Float32* waveBuffers = _bufferManager->GetFFTBuffers();
    CGMutablePathRef path;
    
    // Draw the latest audio wave to prevent from dropping fps too much
    if (waveBuffers[0])
    {
		// Fill out the path
        path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, 20, 507);
        for (i=0; i<_waveLength; i+=_sampleStep)
        {
            _waveX = 20 + (i*_waveInterval);
            _waveY = 507 + (waveBuffers[i]*100);
            CGPathAddLineToPoint(path, NULL, _waveX, _waveY);
        }
        _waveLine.path = path;
        CGPathRelease(path);
    }
    
    if (_bufferManager->HasNewFFTData())
    {
        // Draw the latest fft result to prevent from dropping fps too much
        [_audioController GetFFTOutput:_l_fftData];
        
        // Fill out the path
        //_maxAmp = -INFINITY;
        //_bin = _lowestPitchThreshold;
        path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, 20, 304);
        for (i=0; i<=_Hz1200; i++)
        {
            _X = 20 + (i*_Interval);
            if (isnan(_l_fftData[i]) || i<_lowestPitchThreshold || i>_highestPitchThreshold)
                _Y = 304;
            else
                _Y = 304 + (_l_fftData[i]*2);
            CGPathAddLineToPoint(path, NULL, _X, _Y);
            
            if (isnan(_l_fftData[i])) nanOccur = YES;
            
            if (i>=_lowestPitchThreshold && i<=_highestPitchThreshold)
            {
                //NSLog(@"SearchMAX: %d %f %d %f", i, _Y, _bin, _maxAmp);
                if (_Y > _maxAmp)
                {
                    _maxAmp = _Y;
                    _bin = i;
                }
            }
        }
        _fftLine.path = path;
        CGPathRelease(path);
        
        /*
        _frequency = _bin*((float)_sampleRate/(float)_framesSize);
        _midiNum = [_audioController freqToMIDI:_frequency];
        _pitch = [_audioController midiToPitch:_midiNum];
        NSLog(@"Current: %.12f %d %.12f %@", _frequency, _bin, _midiNum, _pitch);
        */
        
        // Draw the latest cepstrum result to prevent from dropping fps too much
        _bufferManager->GetCepstrumOutput(_l_fftData, _l_cepstrumData);

        // Fill out the path
        /*
        path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, 20, 162);
        for (i=0; i<=_Hz1200; i++)
        {
            _X = 20 + (i*_Interval);
            if (isnan(_l_cepstrumData[i]) || i<_lowestPitchThreshold || i>_highestPitchThreshold)
                _Y = 162;
            else
            {
                _Y = 162 + logf(_l_cepstrumData[i])*10;
                //_Y = 162 + (_l_cepstrumData[i]*0.1);
                //_Y = 162 + (_l_cepstrumData[i]);
            }

            CGPathAddLineToPoint(path, NULL, _X, _Y);
            
            if (isnan(_l_cepstrumData[i])) nanOccur = YES;
        }
        _cepstrumLine.path = path;
        CGPathRelease(path);
        
        // Draw the latest fft*cepstrum result to prevent from dropping fps too much
        _bufferManager->GetFFTCepstrumOutput(_l_fftData, _l_cepstrumData, _l_fftcepstrumData);
        
        // Fill out the path
        _maxAmp = -INFINITY;
        _bin = _lowestPitchThreshold;
        path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, 20, 20);
        for (i=0; i<=_Hz1200; i++)
        {
            _X = 20 + (i*_Interval);
            if (isnan(_l_fftcepstrumData[i]) || i<_lowestPitchThreshold || i>_highestPitchThreshold)
                _Y = 20;
            else
            {
                //_Y = 20 + (_l_fftcepstrumData[i]*0.1);
                _Y = 20 + (_l_fftcepstrumData[i]);
            }
            CGPathAddLineToPoint(path, NULL, _X, _Y);

            if (isnan(_l_fftcepstrumData[i])) nanOccur = YES;
            
            if (i>=_lowestPitchThreshold && i<=_highestPitchThreshold)
            {
                //NSLog(@"SearchMAX: %d %f %d %f", i, _Y, _bin, _maxAmp);
                if (_Y > _maxAmp)
                {
                    _maxAmp = _Y;
                    _bin = i;
                }
            }
        }
        _fftcepstrumLine.path = path;
        CGPathRelease(path);
        
        _frequency = _bin*((float)_sampleRate/(float)_framesSize);
        _midiNum = [_audioController freqToMIDI:_frequency];
        _pitch = [_audioController midiToPitch:_midiNum];
        NSLog(@"Update(): %.12f %d %.12f %@", _frequency, _bin, _midiNum, _pitch);
        //NSLog(@"Schedular(): %.12f %d %.12f %@", [_audioController CurrentFreq], _bin, [_audioController CurrentMIDI], [_audioController CurrentPitch]);
        
        // if the result of fft or cepstrum is nan, most likely a silent has occured.
        /*
        if (_bin == _lowestPitchThreshold || nanOccur == YES)
        {
            _currentTotalFreq = 0;
            _currentNum = 0;
        }
        else
        {
            _currentTotalFreq += (Float32)_frequency;
            _currentNum++;
            
            _aveFreq = _currentTotalFreq/(Float32)_currentNum;
            _midiNum = [_audioController freqToMIDI:_aveFreq];
            _pitch = [_audioController midiToPitch:_midiNum];
            NSLog(@"Ave: %.12f %d (num:%d) %.12f %@", _aveFreq, _bin, _currentNum, _midiNum, _pitch);
        }
        */
        
        /*
        memset(_l_fftData, 0, _framesSize*sizeof(Float32));
        memset(_l_cepstrumData, 0, _framesSize*sizeof(Float32));
        memset(_l_fftcepstrumData, 0, _framesSize*sizeof(Float32));
    }
         */
    NSLog(@"Schedular(): %.12f %d %.12f %@", [_audioController CurrentFreq], _bin, [_audioController CurrentMIDI], [_audioController CurrentPitch]);
}

@end
