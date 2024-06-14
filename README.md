# Brick Breaker Game

Implementation of the popular Brick Breaker Game in MASM615 compatible Assembly Language for the semester project of Computer Organization and Assembly Language Course , designed to run on DOSBox.

## Description

Brick Breaker is a classic game where the player controls a paddle to hit a ball, aiming to eliminate bricks at the top of the screen. The game ends if the ball hits the bottom enclosure. The objective is to clear all bricks with 3 lives and within a 4-minute time limit. Points are scored for each brick hit.


## Gameplay

(Add video here)

## Features

- **Gameplay:**
  - Move the paddle with arrow keys to keep the ball in play and hit bricks.
  - Different bricks require varying numbers of hits to break.
  - Display lives and score on the screen.

- **Bonuses:**
  - Special bricks drop objects that grant bonuses:
    1. Duplicate the ball into more than three balls.
    2. Increase paddle size.
    3. Convert ball into a special ball that breaks any brick in one hit for 10+ seconds.

- **File Handling:**
  - Stores player scores and names in a file.
  - Updates and displays the highest scores.

- **Technology:**
  - Developed in MASM615 Assembly Language.
  - Runs on DOSBox.

## How to Run

1. Install [DOSBox](https://www.dosbox.com/).
2. Load the game files into DOSBox.
3. Compile the game using MASM615.
4. Run the compiled game executable within DOSBox.



## Team

- [@arfatkh](https://www.github.com/arfatkh)
- [@BeastMasterGrinder](https://www.github.com/BeastMasterGrinder)
