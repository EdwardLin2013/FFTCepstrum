//
//  AudioController.h
//  TheSingingCoach
//
//  Created by Edward and Natalie on 22/7/14.
//  Copyright (c) 2014 Edward and Natalie. All rights reserved.
//
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#import "BufferManager.h"
#import "DCRejectionFilter.h"
#import "PitchInfo.h"

// Utility file includes
#import "CAXException.h"
#import "CAStreamBasicDescription.h"

@interface AudioController : NSObject
{
    AudioUnit                   _rioUnit;
    BufferManager*              _bufferManager;
    DCRejectionFilter*          _dcRejectionFilter;
    BOOL                        _audioChainIsBeingReconstructed;    //FIXME: semaphore?
    
    UInt32                      _sampleRate;
    UInt32                      _framesSize;
    Float32                     _Overlap;

    PitchInfo*                  _curPitchInfo;
    NSTimer*                    _pitchEstimatedScheduler;
    
    UInt32                      _Hz120;      // G2
    UInt32                      _Hz530;      // C5
    UInt32                      _Hz1100;     // C6
    
    NSString*                   _FileNameOriginal;      // Record the original Audio Wave
    NSString*                   _FileNameFrames;        // Record the fragmentation
    AudioFileID                 _OriginalFile;
    AudioFileID                 _FramesFile;
    BOOL                        _isRecording;   //FIXME: semaphore?
    CAStreamBasicDescription    _ioFormat;

    Float32*                     _waveData;
    Float32*                     _fftData;
    Float32*                     _cepstrumData;
    Float32*                     _fftlogcepstrumData;
    
    NSFileManager*              _fileMgr;
    NSString*                   _docsDir;
    NSString*                   _tmpDir;
}

/* -----------------------------Public Methods--------------------------------- Begin */
- (id)init:(UInt32)NewSampleRate FrameSize:(UInt32)NewFrameSize OverLap:(Float32)NewOverlap;
- (OSStatus)startIOUnit;
- (OSStatus)stopIOUnit;
- (void)EstimatePitch;

- (Float32)CurrentFreq;
- (Float32)CurrentMIDI;
- (NSString*)CurrentPitch;
- (int)CurrentBin;
- (Float32)CurrentAmp;
- (NSString*)CurrentStablePitch;

- (Float32*)CurrentwaveData;                // Caller has to free the memory
- (Float32*)CurrentfftData;
- (Float32*)CurrentcepstrumData;
- (Float32*)CurrentfftlogcepstrumData;

- (UInt32)getFrameSize;
- (double)sessionSampleRate;
- (BOOL)audioChainIsBeingReconstructed;
/* -----------------------------Public Methods--------------------------------- End */

/* -----------------------------Private Methods--------------------------------- Begin */
- (void)setupAudioChain;
- (void)setupAudioSession;
- (void)setupIOUnit;

- (void)handleInterruption:(NSNotification *)notification;
- (void)handleRouteChange:(NSNotification *)notification;
- (void)handleMediaServerReset:(NSNotification *)notification;

// Audio Recording
- (void)startRecording;
- (void)stopRecording;
- (BOOL)isRecording;
- (void)GetFFTOutput:(Float32*)outFFTData;

// File Management
- (void)removeTmpFiles;
- (void)saveRecording:(NSString *)SongName;
/* -----------------------------Private Methods--------------------------------- End */

@end
