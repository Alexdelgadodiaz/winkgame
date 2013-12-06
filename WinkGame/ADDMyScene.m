//
//  ADDMyScene.m
//  WinkGame
//
//  Created by Alejandro Delgado Diaz on 02/12/13.
//  Copyright (c) 2013 Alejandro Delgado Diaz. All rights reserved.
//

#import "ADDMyScene.h"

@implementation ADDMyScene{
    
    SKSpriteNode *_leftFace;
    SKSpriteNode *_rightFace;
    SKAction *_leftFaceAnimation;
    SKAction *_rightFaceAnimation;
    CGPoint _lastPointLeft;
    NSMutableArray *_actionsEyeLeft;
    NSMutableArray *_actionsEyeRight;
    SKSpriteNode *_leftEye;
    SKSpriteNode *_rightEye;
    
    SKAction *_removeActionsFromEyes;

    NSMutableArray *_texturesLeft;
    NSMutableArray *_texturesRight;
    
    SKSpriteNode *_circleChanging;
    SKSpriteNode *_circleTarget;
    SKSpriteNode *_circleTarget2;

    
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;
    
    double _levelTimeLimit;
    SKLabelNode * _timerLabel;
    SKLabelNode * _scoreLabel;
    
    BOOL _readyToContinue;
    BOOL _bestMoment;
    BOOL _tapedPoint;
    
    int score;
    
    double _currentTime;
    double _startTime;
    double _elapsedTime;
    double _timeLeft;
    
    PCGameState _gameState;
    
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        _gameState = PCGameStateStartingLevel;

        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        SKSpriteNode *leftFace = [[SKSpriteNode alloc]initWithImageNamed:@"faceWithout"];
        _leftFace = leftFace;
        _leftFace.position = CGPointMake(85, 400);
        [_leftFace setScale:0.2];
        
        [self addChild:_leftFace];
        
        NSString *textureEyeLeftString =[NSString stringWithFormat:@"eyesOnly"];
        SKTexture *textureEyeLeft = [SKTexture textureWithImageNamed:textureEyeLeftString];
        
        _leftEye = [[SKSpriteNode alloc]initWithTexture:textureEyeLeft];
        
        _leftEye.position = CGPointMake(85, 450);
        _lastPointLeft = _leftEye.position;
        
        [_leftEye setScale:0.8];
        
        [self addChild:_leftEye];
        
        
        SKSpriteNode *rightFace = [[SKSpriteNode alloc]initWithImageNamed:@"faceWithout"];
        _rightFace = rightFace;
        _rightFace.position = CGPointMake(235, 400);
        [_rightFace setScale:0.2];
        
        [self addChild:_rightFace];
        
        NSString *textureEyeRigthString =[NSString stringWithFormat:@"eyesOnly"];
        SKTexture *textureEyeRight = [SKTexture textureWithImageNamed:textureEyeRigthString];
        
        _rightEye = [[SKSpriteNode alloc]initWithTexture:textureEyeRight];
        
        _rightEye.position = CGPointMake(235, 450);
        _lastPointLeft = _rightEye.position;
        
        [_rightEye setScale:0.8];
        
        [self addChild:_rightEye];

        
        _circleTarget = [[SKSpriteNode alloc]initWithImageNamed:@"circleSmall"];
        _circleTarget.position = CGPointMake(160, POSITION_Y_TARGET_CIRCLE_UP);
        [_circleTarget setScale:0.1];
        
        [self addChild:_circleTarget];
        
        _circleTarget2 = [[SKSpriteNode alloc]initWithImageNamed:@"circleSmall"];
        _circleTarget2.position = CGPointMake(160, POSITION_Y_TARGET_CIRCLE_DOWN);
        [_circleTarget2 setScale:0.1];
        
        [self addChild:_circleTarget2];
        
        _circleChanging = [[SKSpriteNode alloc]initWithImageNamed:@"circleChanging"];
        _circleChanging.position = CGPointMake(160, 200);
        
        [self addChild:_circleChanging];
        
        _levelTimeLimit = GAME_TIME_LIMIT;
        _timerLabel = [SKLabelNode labelNodeWithFontNamed:@"MarkerFelt-Wide"];
        _timerLabel.text =
        [NSString stringWithFormat:@"Time Remaining: %2.0f", _levelTimeLimit];
        _timerLabel.fontSize = 18;
        _timerLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        _timerLabel.position = CGPointMake(0, 30);
        
        [self addChild:_timerLabel];
        
        score = 0;
        _scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"MarkerFelt-Wide"];
        _scoreLabel.text = [NSString stringWithFormat:@"Score %i", abs(score)];
        _scoreLabel.fontSize = 18;
        _scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        _scoreLabel.position = CGPointMake(200, 30);
        
        [self addChild:_scoreLabel];
        
        [self createUserInterfaceStart];
        
        _readyToContinue = NO;
        _tapedPoint = NO;
        _timeLeft = GAME_TIME_LIMIT;
    
    }
    return self;
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    if (_gameState == PCGameStatePlaying) {
        
        static dispatch_once_t once;
        dispatch_once(&once, ^ {
            
            _startTime = currentTime;
            
        });
        
        if (_lastUpdateTime) {
            _dt=currentTime - _lastUpdateTime;
        } else {
            _dt=0;
        }
        
        _lastUpdateTime =currentTime;
        _currentTime = currentTime;
        _elapsedTime = _timeLeft - (_currentTime - _startTime);
        _levelTimeLimit = _elapsedTime;
        _timerLabel.text = [NSString stringWithFormat:@"Time Remaining: %2.0f", fabsf(_levelTimeLimit)];
        _scoreLabel.text = [NSString stringWithFormat:@"Score %i", abs(score)];
        
        if (_levelTimeLimit <=0) {
            
            static dispatch_once_t once;
            dispatch_once(&once, ^ {
                
                _levelTimeLimit =0;
                //[NSString stringWithFormat:@"Time Remaining: %2.0f", _levelTimeLimit];
                _gameState = PCGameStateOver;
                [_leftEye removeAllActions];
                [_rightEye removeAllActions];
                [_circleChanging removeAllActions];
                [self createUserInterfaceGameOver];

            });
        }
        
        
        
        if ((![_rightEye hasActions]) && (![_leftEye hasActions])){
            
            if (_readyToContinue) {
               
                [self gameStarts];
                _readyToContinue=NO;
            
            }else{
                
                [self pushMoment];
                
            }
            
        }
        
        CGRect smallPointUp = CGRectMake(160, POSITION_Y_TARGET_CIRCLE_UP, 1, 1);
        CGRect smallPointDown = CGRectMake(160, POSITION_Y_TARGET_CIRCLE_DOWN, 1, 1);
        
        if ((CGRectIntersectsRect(smallPointUp, _circleChanging.frame))&&
            !(CGRectIntersectsRect(smallPointDown, _circleChanging.frame))) {
            
            _bestMoment = 1;
        }else{
            
            _bestMoment = 0;
            _tapedPoint = NO;
        }
        
    } //if PCGameStateGamePlaying
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    switch (_gameState) {

        case PCGameStateStartingLevel: {
            [self childNodeWithName:@"msgLabel"].hidden = YES;
            _gameState = PCGameStatePlaying;
            [self gameStarts];
            
            SKAction *scaleDown = [SKAction scaleTo:0.2 duration:TIME_DURATION_SCALING_CIRCLE];
            SKAction *scaleUp= [SKAction scaleTo:1.0 duration:TIME_DURATION_SCALING_CIRCLE];
            SKAction *fullScale = [SKAction repeatActionForever:[SKAction sequence:@[scaleDown, scaleUp, scaleDown, scaleUp]]];

            [_circleChanging runAction:fullScale];
            //Intentionally omitted break
        }
            
        case PCGameStatePlaying: {
            
            if (_readyToContinue) {
                if ((_bestMoment)&&(!_tapedPoint)) {
                    score = score +2;
                    _tapedPoint = YES; //has been taped and you can't tap again
                    
                }else if (!_bestMoment){
                    score = score -2;
                }
            }else{
            
                if (_bestMoment) {
                    score = score -1;
                }else{
                    score = score -1;
                }
            }
    
            if (score <0) {
                score =0;
            }
        }
            break;
        
        case PCGameStateOver:{
            
            break;
        }
            
    }
}


#pragma mark - Game methods

//Eyes move everywhere

- (void) gameStarts{
    
    int timesWinking = [self getRandomNumberBetween:TIMES_THEY_MOVE_EYES_MINIMUM to:TIMES_THET_MOVE_EYES_MAX];
    int lastPositionLeft = -1;
    int lastPositionRight = -1;
    
    SKAction *nextAction = [SKAction new];
    SKAction *nextAction2 = [SKAction new];
    
    _actionsEyeLeft = [NSMutableArray new];
    _actionsEyeRight = [NSMutableArray new];
    

    for (int i =1; i<=timesWinking; i++) {
        
        int positionFaceLeft = [self getRandomNumberBetween:1 to:4];
        int positionFaceRight = [self getRandomNumberBetween:1 to:4];
        
        
        if ((positionFaceLeft != lastPositionLeft) && (positionFaceRight != lastPositionRight)) {
            
            lastPositionLeft = positionFaceLeft;
            lastPositionRight = positionFaceRight;
            
            float waitDuration = DURATION_EYES_MOVEMENT;
            waitDuration = waitDuration /10;

            
            switch (positionFaceLeft){
                        
                case 1:
                        
                    nextAction = [SKAction moveTo:CGPointMake(85, 470) duration:waitDuration];
                    break;
                        
                case 2:
                        
                    nextAction =  [SKAction moveTo:CGPointMake(100, 450) duration:waitDuration];
                    break;
                        
                case 3:
                        
                    nextAction =  [SKAction moveTo:CGPointMake(85, 430) duration:waitDuration];
                    break;
                        
                case 4:
                        
                    nextAction =  [SKAction moveTo:CGPointMake(70, 450) duration:waitDuration];
                    break;
                        
            }
            
            waitDuration = 5;
            waitDuration = waitDuration /10;
            
            switch (positionFaceRight){
                        
                case 1:
                        
                    nextAction2 = [SKAction moveTo:CGPointMake(235, 470) duration:waitDuration];
                    break;
                        
                case 2:
                        
                    nextAction2 =  [SKAction moveTo:CGPointMake(250, 450) duration:waitDuration];
                    break;
                        
                case 3:
                        
                    nextAction2 =  [SKAction moveTo:CGPointMake(235, 430) duration:waitDuration];
                    break;
                        
                case 4:
                        
                    nextAction2 =  [SKAction moveTo:CGPointMake(220, 450) duration:waitDuration];
                    break;
            }
            
            waitDuration = [self getRandomNumberBetween:TIME_WAITING_BETWEEN_EYE_MIN to:TIME_WAITING_BETWEEN_EYE_MAX];
            waitDuration = waitDuration /10;
            
            [_actionsEyeLeft addObject:nextAction];
            [_actionsEyeLeft addObject:[SKAction waitForDuration:waitDuration]];
            
            waitDuration = [self getRandomNumberBetween:TIME_WAITING_BETWEEN_EYE_MIN to:TIME_WAITING_BETWEEN_EYE_MAX];
            waitDuration = waitDuration /10;

            [_actionsEyeRight addObject:nextAction2];
            [_actionsEyeRight addObject:[SKAction waitForDuration:waitDuration]];

        }
        
    }//for
    
    nextAction =  [SKAction moveTo:CGPointMake(100, 450) duration:0.3];
    nextAction2 =  [SKAction moveTo:CGPointMake(220, 450) duration:0.3];
    
    [_actionsEyeLeft addObject:nextAction];
    [_actionsEyeRight addObject:nextAction2];
    
    [_rightEye runAction: [SKAction sequence:_actionsEyeRight]];
    [_leftEye runAction: [SKAction sequence:_actionsEyeLeft]];
    
    
    
}

- (void) pushMoment{
    
    SKAction *wait = [SKAction waitForDuration:LOOKING_EACH_OTHER];
    [_rightEye runAction:wait];
    [_leftEye runAction:wait];
    
    _readyToContinue = YES;
    
}


#pragma mark - help methods

-(int)getRandomNumberBetween:(int)from to:(int)to {
    
    return (int)from + arc4random() % (to-from+1);
}

- (void)createUserInterfaceStart {
    SKLabelNode* startMsg =
    [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    startMsg.name = @"msgLabel";
    startMsg.text = @"Tap Screen to start!";
    startMsg.fontSize = 25;
    startMsg.position = CGPointMake(160, 250);
    [self addChild: startMsg];
}

- (void)createUserInterfaceGameOver {
    SKLabelNode* startMsg =
    [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    startMsg.name = @"msgLabel";
    startMsg.text = [NSString stringWithFormat:@"Game Over \nScore %i", abs(score)];
    startMsg.fontSize = 25;
    startMsg.position = CGPointMake(160, 250);
    [self addChild: startMsg];
}

@end