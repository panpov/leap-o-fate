; CS-240 Project 5: Final Game Draft
; @file graphics.asm
; @author Pan Pov and Jun Seo
; @date November 20, 2024

include "graphics/graphics.inc"
include "sprites/sprites.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "vblank_interrupt", rom0[$0040]
    reti

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "graphics", rom0

init_graphics:
    ; init the palettes
    ld a, DEFAULT_PALETTE
    ld [rBGP], a
    ld [rOBP0], a
    Invert a
    ld [rOBP1], a

    ; init graphics data
    LoadGraphicsDataIntoVRAM

    ; enable the vblank interrupt
    ld a, IEF_VBLANK
    ld [rIE], a
    ei

    ; place the window at the bottom of the LCD
    ld a, WINDOW_X
    ld [rWX], a
    ld a, WINDOW_START_Y
    ld [rWY], a

    ; set the background position to 0,0
    xor a
    ld [rSCX], a
    ld [rSCY], a
    ret

update_graphics:
    call scroll_horizontal
    call scroll_vertical
    ret

scroll_horizontal:
    ; check if player is within the leftmost 48 pixels
    ld a, [SPRITE_0_ADDRESS + OAMA_X]
    cp a, WINDOW_LEFT_SCROLL
    jr nc, .scroll_right

    ; don't scroll if leftmost tile is already displayed
    ld a, [rSCX]
    cp a, WINDOW_LEFT_EDGE
    jr z, .scroll_done

    ; scroll left
    AddBetter [rSCX], -WINDOW_SCROLL_SPEED
    AddBetter [SPRITE_0_ADDRESS + OAMA_X], WINDOW_SCROLL_SPEED
    AddBetter [SPRITE_1_ADDRESS + OAMA_X], WINDOW_SCROLL_SPEED
    AddBetter [SPRITE_2_ADDRESS + OAMA_X], WINDOW_SCROLL_SPEED
    jr .scroll_done

    ; check if player is within the rightmost 48 pixels
    .scroll_right
        ld a, [SPRITE_0_ADDRESS + OAMA_X]
        cp a, WINDOW_RIGHT_SCROLL
        jr c, .scroll_done
    
    ; don't scroll if rightmost tile is already displayed
    ld a, [rSCX]
    cp a, WINDOW_RIGHT_EDGE
    jr z, .scroll_done

    ; scroll right
    AddBetter [rSCX], WINDOW_SCROLL_SPEED
    AddBetter [SPRITE_0_ADDRESS + OAMA_X], -WINDOW_SCROLL_SPEED
    AddBetter [SPRITE_1_ADDRESS + OAMA_X], -WINDOW_SCROLL_SPEED
    AddBetter [SPRITE_2_ADDRESS + OAMA_X], -WINDOW_SCROLL_SPEED
    .scroll_done
    ret

scroll_vertical:
    ; check if player is within the topmost 40 pixels
    ld a, [SPRITE_0_ADDRESS + OAMA_Y]
    cp a, WINDOW_TOP_SCROLL
    jr nc, .scroll_down

    ; check if the topmost tile is already displayed
    ld a, [rSCY]
    cp a, WINDOW_TOP_EDGE
    jr z, .scroll_done

    ; scroll up
    AddBetter [rSCY], -WINDOW_SCROLL_SPEED
    AddBetter [SPRITE_0_ADDRESS + OAMA_Y], WINDOW_SCROLL_SPEED
    AddBetter [SPRITE_1_ADDRESS + OAMA_Y], WINDOW_SCROLL_SPEED
    AddBetter [SPRITE_2_ADDRESS + OAMA_Y], WINDOW_SCROLL_SPEED
    jr .scroll_done

    ; check if player is within the bottommost 40 pixels (including bottom window HUD)
    .scroll_down
        ld a, [SPRITE_0_ADDRESS + OAMA_Y]
        cp a, WINDOW_BOTTOM_SCROLL
        jr c, .scroll_done
    
    ; check if the bottommost tile is already displayed
    ld a, [rSCY]
    cp a, WINDOW_BOTTOM_EDGE
    jr z, .scroll_done

    ; scroll_down
    AddBetter [rSCY], WINDOW_SCROLL_SPEED
    AddBetter [SPRITE_0_ADDRESS + OAMA_Y], -WINDOW_SCROLL_SPEED
    AddBetter [SPRITE_1_ADDRESS + OAMA_Y], -WINDOW_SCROLL_SPEED
    AddBetter [SPRITE_2_ADDRESS + OAMA_Y], -WINDOW_SCROLL_SPEED
    .scroll_done
    ret

export init_graphics, update_graphics

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "graphics_data", rom0[GRAPHICS_DATA_ADDRESS_START]
incbin "tiles/tileset.chr"

GAME_BACKGROUND:
    incbin "tiles/game_background.tlm"

START_SCREEN:
    incbin "tiles/start_screen.tlm"

NEXT_LEVEL_WINDOW:
    incbin "tiles/next_level_window.tlm"

GAME_OVER_WINDOW:
    incbin "tiles/game_over_window.tlm"

WIN_LEVEL:
    incbin "tiles/win_level.tlm"

export GAME_BACKGROUND, START_SCREEN, NEXT_LEVEL_WINDOW, GAME_OVER_WINDOW, WIN_LEVEL