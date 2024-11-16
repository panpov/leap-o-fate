include "game/game.inc"
include "joypad/joypad.inc"
include "graphics/graphics.inc"
include "sprites/sprites.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "game", rom0

GAME_OVER_STRING_ADDRESS:
    db "GAME OVER!\0"

PLAY_AGAIN_STRING_ADDRESS:
    db "PLAY AGAIN\0"

PRINT_BLANK_STRING_ADDRESS:
    db "        \0"

LEVEL_1_STRING_ADDRESS:
    db "  LEVEL 1  \0"

LEVEL_2_STRING_ADDRESS:
    db "  LEVEL 2  \0"

init_game_states:
    Copy [GAME_COUNTER], 0
    Copy [GAME_STATE], $FF
    Copy [HEART_COUNT], MAX_HEARTS
    ret

check_start:
    ; check if game is on start screen
    ld a, [GAME_STATE]
    bit GAMEB_START_SCREEN, a
    jp z, .done

    ; check if game is starting
    bit GAMEB_STARTING, a
    jp z, .start

    ; check if start button is pressed
    ld a, [JOYPAD_PRESSED_ADDRESS]
    and PADF_START
    jp nz, .done

    ; toggle game starting if start button is pressed
    ld a, [GAME_STATE]
    xor GAMEF_STARTING
    ld [GAME_STATE], a

    .start
        call start

    .done
    ret

start:
    ; pull window down
    AddBetter [rWY], START_PULL_DOWN_SPEED

    ; initalize sprite positions and reset lives when window is pulled all the way down
    cp a, WINDOW_GAME_Y
    jp c, .continue_pulling

    ; set game start screen on, game starting off
    ld a, [GAME_STATE]
    xor GAMEF_START_SCREEN
    xor GAMEF_STARTING
    ld [GAME_STATE], a

    ; set initial sprite positions
    call init_sprites_pos

    ; print level 1 on bottom window
    call reset_hearts
    PrintText LEVEL_1_STRING_ADDRESS, LEVELS_STRING_LOCATION
    
    .continue_pulling
    ret

lose_heart:
    ; get location index of one tile left of heart and current heart count
    ld hl, HEART_LOCATION_ADDRESS
    dec hl
    ld a, [HEART_COUNT]

    ; get location index of the heart to erase
    .find_curr_heart
        inc hl
        dec a
        jp nz, .find_curr_heart

    ; erase the heart
    ld a, BLANK_TILE_INDEX
    ld [hl], a

    ; decrement heart count 
    ld a, [HEART_COUNT]
    dec a
    ld [HEART_COUNT], a

    ; check if game is over
    cp a, 0
    jp nz, .not_game_over

    call game_over

    .not_game_over
    ret

reset_hearts:
    ; get number of hearts to print, where to start printing, and what to print
    ld c, MAX_HEARTS
    ld a, HEART_TILE_INDEX
    ld hl, HEART_LOCATION_ADDRESS

    ; prints a heart starting at the left and incrementing index to the right (3x)
    .print_heart
        ld [hli], a
        dec c
        jp nz, .print_heart

    ; reset hearts back to MAX_HEARTS
    Copy [HEART_COUNT], MAX_HEARTS
    ret

game_over:
    ; reset window and background
    xor a
    ld [rWY], a
    ld [rSCX], a
    ld [rSCY], a

    ; re-initializes game
    call init_sprites
    call reset_hearts

    ; set starting screen on
    ld a, [GAME_STATE]
    xor GAMEF_START_SCREEN
    ld [GAME_STATE], a

    ; display message for game over
    PrintText GAME_OVER_STRING_ADDRESS, GAME_OVER_STRING_LOCATION
    PrintText PRINT_BLANK_STRING_ADDRESS, PRINT_BLANK_STRING_LOCATION
    PrintText PLAY_AGAIN_STRING_ADDRESS, PLAY_AGAIN_STRING_LOCATION

    ret

check_next_level:
    Copy b, [rSCX]
    ld a, [SPRITE_0_ADDRESS + OAMA_X]
    add a, b
    cp a, DOOR_1_X
    jp c, .no_win

    cp a, (DOOR_1_X + TILE_SIDE_LENGTH)
    jp nc, .no_win

    Copy b, [rSCY]
    ld a, [SPRITE_0_ADDRESS + OAMA_Y]
    add a, b
    cp a, DOOR_1_Y
    jp c, .no_win

    cp a, (DOOR_1_Y + TILE_SIDE_LENGTH)
    jp nc, .no_win

    call next_level

    .no_win
    ret

next_level:
    ; "hide" enemy sprites
    ld a, [SPRITE_1_ADDRESS + OAMA_FLAGS] 
    set OAMB_PAL1, a
    set OAMB_PRI, a
    ld [SPRITE_1_ADDRESS + OAMA_FLAGS], a
    ld a, [SPRITE_2_ADDRESS + OAMA_FLAGS] 
    set OAMB_PAL1, a
    set OAMB_PRI, a
    ld [SPRITE_2_ADDRESS + OAMA_FLAGS], a

    ; teleport to new location
    Copy [SPRITE_0_ADDRESS + OAMA_X], LVL2_INIT_X
    Copy [SPRITE_0_ADDRESS + OAMA_Y], LVL2_INIT_Y

    Copy [rSCX], LVL2_SCR_X
    Copy [rSCY], LVL2_SCR_Y

    ; display message for next level in the middle of the window
    PrintText LEVEL_2_STRING_ADDRESS, LEVELS_STRING_LOCATION
    
    ret

export init_game_states, check_start, lose_heart, check_next_level