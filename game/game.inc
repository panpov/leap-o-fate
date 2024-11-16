if !def(GRAPHICS_RGBINC)
def GAME_RGBINC equ 1
include "inc/utils.inc"

rsset _RAM
def GAME_COUNTER                  rb 1
def GAME_STATE                    rb 1
def HEART_COUNT                   rb 1

def COUNTER_SPEED                 equ (%00000001)

; flags for game state
def GAMEF_STARTING                equ ($0002)
def GAMEF_START_SCREEN            equ ($0001)

; bit for game state
def GAMEB_STARTING                equ ($0001)
def GAMEB_START_SCREEN            equ ($0000)

; hearts
def MAX_HEARTS                    equ ($0003)
def HEART_TILE_INDEX              equ ($0038)
def HEART_LOCATION_ADDRESS        equ ($9C21)
def BLANK_TILE_INDEX              equ ($000F)

; strings
def GAME_OVER_STRING_LOCATION     equ ($9DA5)
def PRINT_BLANK_STRING_LOCATION   equ ($9DC5)
def PLAY_AGAIN_STRING_LOCATION    equ ($9DE5)
def LEVELS_STRING_LOCATION        equ ($9C24)

; level 2
def DOOR_1_X                      equ (136)
def DOOR_1_Y                      equ (184)
def LVL2_SCR_X                    equ (96)
def LVL2_SCR_Y                    equ (136)
def LVL2_INIT_X                   equ (152)
def LVL2_INIT_Y                   equ (72)


endc