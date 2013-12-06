//
//  ADDMyScene.h
//  WinkGame
//

//  Copyright (c) 2013 Alejandro Delgado Diaz. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

static const int GAME_TIME_LIMIT = 15;
static const float LOOKING_EACH_OTHER = 3.0;
static const float DURATION_EYES_MOVEMENT = 5.0;
static const int TIMES_THEY_MOVE_EYES_MINIMUM = 3;
static const int TIMES_THET_MOVE_EYES_MAX = 8;
static const int TIME_WAITING_BETWEEN_EYE_MIN = 3;
static const int TIME_WAITING_BETWEEN_EYE_MAX = 8;
static const float TIME_DURATION_SCALING_CIRCLE = 1.75;
static const int POSITION_Y_TARGET_CIRCLE_UP = 155;
static const int POSITION_Y_TARGET_CIRCLE_DOWN = 135;


@interface ADDMyScene : SKScene



typedef NS_ENUM(int32_t, PCGameState) {
    PCGameStateStartingLevel,
    PCGameStatePlaying,
    PCGameStateOver,
};

@end
