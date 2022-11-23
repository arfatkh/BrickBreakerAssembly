
# Brick Breaker Game 
```
Implementation of the popular Brick Breaker Game in MASM615 compaitable Assembly Language

```


## Game Description

In the brick breaker game, the player moves a paddle from side to side to hit a **ball**. 

The game objective is to eliminate all of the **bricks** at the top of the screen by hitting them with the **ball**.But if the ball hit the bottom ENCLOSURE, the player loses and the game ends! 

To win the game, all the **bricks** must be eliminated. The game is split into many levels, which must be completed in sequence. There will be a time limit of 4 minutes and the remaining time will be shown with the counter. The purpose of this game is to complete all the levels without losing all lives. The player will have a maximum of 3 lives.


## Levels

#### Level 1

```



- First of all, a title page should appear that displays the name of     the game. It must also take
the name of the user as input and the name is to be displayed on the screen.

- The second page should be menu driven.

- Third page should be your game. The user must be able to navigate back and forth from these screens.
```
The basic game will consist of hitting the ball to direct it toward hitting the bricks above. When the ball comes into contact with a brick, the brick will “break” and disappear. The player moves the paddle from left to right to keep the ball from falling. Life is used when the player fails to hit the ball. You have to display the number of lives left for the player on the screen. Display the
remaining lives on the screen with a HEART SHAPE. For the interaction with your game, you will be using arrow keys on your keyboard (you can use a mouse and other keys as well). 
To move the paddle, you will check for the pressed key if the pressed key is left arrow key then you will move the paddle left and if key is right arrow key is pressed you will move the paddle to right (change its position). The ball will bounce back from the paddle and the screen boundary walls.

When a brick breaks, a SCORE is awarded. The score depends upon the type of brick that will break as each brick has different score. All the bricks with the same color will have same score. Score should be displayed on screen.

#### Level 2

You are required to change into following:

```

 1. Increase the speed of the ball and
 2. Shorten the length of the paddle.
 3. Each brick will require two hits to disappear and after the first hit, the brick should change color to a lighter one.

```
#### Level 3

You are required to change into following:

```

 1. Some of the bricks are fixed (hitting them should bounce the ball
    back).
 2. Normal bricks will now require 3 hits to disappear.
 3. Make one random brick a special brick. When this special brick is hit, 5 random bricks (or all the remaining bricks if less than 5) should disappear.
 4. Increase the speed of the ball in this level.

```
## File Handling

You are required to store all the score of all the players that have played the game. For this you will use file handling. You need to store the name and updated highest score in a file.


## BONUSES

When the ball hit one random special type of brick, it breaks into any random object you like to
make which will fall down. If the paddle consumes the random object, it will do 3 different things:

```

 1. Duplicate the ball into more than 3 balls.
 2. Increase the size of the paddle
 3. It converts your original ball into a special ball for 10 or more seconds that can break any brick in 1 hit.
```
You are required to use sound features for your game.

## Screens

The following screens are given as an example. You can create your own screens which would
include:

```

 1. Welcome Screen that takes your name input
 2. Game Menu screen
 3. Main Screen for GamePlay
 4. Pause Screen/Functionality
 5. Instructions Screen
 6. High Score and Players Names Display
```

#### Game Menu screen

#### Main Screen for GamePlay





