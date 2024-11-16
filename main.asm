; CS-240 Project 5: First Game Draft
; @file main.asm
; @author Pan Pov and Jun Seo
; @date November 6, 2024

; CITE: 8x8 1bit Dungeon Tilemap by PixelHole (https://pixelhole.itch.io/8x8dungeontilemap)
; DESC: We used this free tileset to create our tilemap and window.

; CITE: Paper Pixels by VEXED (https://v3x3d.itch.io/paper-pixels)
; DESC: We used the letter and number tiles from this free tileset in our own tileset.

include "game/game.inc"
include "joypad/joypad.inc"
include "graphics/graphics.inc"
include "sprites/sprites.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "header", rom0[$0100]
entrypoint:
    di
    jp main
    ds ($0150 - @), 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section "main", rom0
main:
    ; initialize everything
    DisableLCD
    InitOAM
    call init_game_states
    call init_joypad
    call init_graphics
    call init_sprites
    EnableLCD

    .loop
        halt

        ; counter
        AddBetter [GAME_COUNTER], 1
        and COUNTER_SPEED
        jp nz, .skip

        call update_joypad

        ; start game whenSTART is pressed
        call check_start
        jp nz, .skip

        ; update only when game is started
        call update_graphics
        call update_sprites
        ; call check_next_level

        .skip
        jp .loop