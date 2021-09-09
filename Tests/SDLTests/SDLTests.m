//
//  SDLTests.m
//  SDLTests
//
//  Created by Patrick Beard on 9/8/21.
//

@import CSDL2;
@import XCTest;

@interface SDLTests : XCTestCase
@end

@implementation SDLTests {
    NSMutableDictionary<NSNumber *, NSValue *> *controllers;
}

- (void)setUp {
    int rv = SDL_Init(SDL_INIT_VIDEO | SDL_INIT_GAMECONTROLLER);
    XCTAssertEqual(rv, 0);
    
    controllers = [NSMutableDictionary new];
}

- (void)tearDown {
    for (NSValue *value in controllers.allValues) {
        SDL_GameController *controller = value.pointerValue;
        if (controller != NULL) {
            SDL_GameControllerClose(controller);
        }
    }
    [controllers removeAllObjects];
    SDL_Quit();
}

- (void)addController:(SDL_ControllerDeviceEvent)deviceEvent {
    Sint32 deviceIndex = deviceEvent.which;
    if (SDL_IsGameController(deviceIndex) == SDL_TRUE) {
        SDL_GameController *controller = SDL_GameControllerOpen(deviceIndex);
        if (controller != NULL) {
            SDL_JoystickID deviceID = SDL_JoystickGetDeviceInstanceID(deviceIndex);
            controllers[@(deviceID)] = [NSValue valueWithPointer:controller];
            SDL_Log("attached controller:  %s", SDL_GameControllerName(controller));
        }
    }
}

- (void)waitForControllers {
    SDL_Event event;
    while (controllers.count == 0) {
        while (SDL_PollEvent(&event)) {
            if (event.type == SDL_CONTROLLERDEVICEADDED) {
                SDL_Log("SDL_CONTROLLERDEVICEADDED");
                [self addController:event.cdevice];
            }
        }
    }
}

- (NSArray<NSNumber *> *)waitForButtons:(NSUInteger)count {
    NSMutableArray<NSNumber *> *buttons = [NSMutableArray new];
    SDL_Event event;
    while (buttons.count < count) {
        while (SDL_PollEvent(&event)) {
            if (event.type == SDL_CONTROLLERBUTTONDOWN) {
                SDL_GameControllerButton button = event.cbutton.button;
                SDL_Log("%s", SDL_GameControllerGetStringForButton(button));
                [buttons addObject:@(button)];
            }
        }
    }
    return buttons;
}

- (void)testShoulderButtons {
    [self waitForControllers];
    SDL_Log("Press left then right shoulder buttons.");
    NSArray<NSNumber *> *buttons = [self waitForButtons:2];
    NSArray<NSNumber *> *expected = @[@(SDL_CONTROLLER_BUTTON_LEFTSHOULDER), @(SDL_CONTROLLER_BUTTON_RIGHTSHOULDER)];
    XCTAssertEqualObjects(buttons, expected);
}

@end
