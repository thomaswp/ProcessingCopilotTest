/**
 *  In this program, there are three types of objects:
 *  1. A ball the moves with semi-realistic physics
 *  2. A paddle that the user can move with the mouse, which bounces the ball and moves in circle around the outside of the screen
 *  3. Bricks are stationary in the middle of the screen that the ball can bounce off of
 *
 */

 // Create the variables we will need
float ballX, ballY, ballXSpeed, ballYSpeed;
// Ball base speed = 2.5
float ballBaseSpeed = 2.5;


// Create variables to control the angle of the paddle along the circle
float paddleAngle = 0;

// Create a variable for the paddle's width and height
float paddleWidth = 50;
float paddleHeight = 20;
// Create a vairable for the radius of the paddle's movement
float paddleRadius = 180;

int points = 0;

// Create an array of bricks
Brick[] bricks;


void setup() {
    // Set the size of the window to 400x400 pixels
    size(400, 400);


    // The ball start moving slowly to the right
    ballXSpeed = ballBaseSpeed;
    resetBall();

    // Create a 4 by 4 grid of size 30 bricks in the center of the screen with a gap of 10 between them
    bricks = new Brick[16];
    // the center of the grid is 200, 200
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            // Create a new brick at the correct position
            bricks[i * 4 + j] = new Brick(200 + (i - 1.5) * 40, 200 + (j - 1.5) * 40, 30, 30, color(255, 0, 0));
        }
    }

}

void resetBall() {
    // Position the ball at a radius of 160 from the center at a random angle
    float angle = random(TWO_PI);
    // If the angle overlaps the paddle's angle closely, we rotate it by 180 degrees
    if (abs(angle - paddleAngle) < PI / 4) {
        angle += PI;
    }

    ballX = 200 + cos(angle) * 160;
    ballY = 200 + sin(angle) * 160;

    // The ball moves toward the center at its starting speed
    ballXSpeed = cos(angle + PI) * ballBaseSpeed;
    ballYSpeed = sin(angle + PI) * ballBaseSpeed;
}

void update() {
    // Update the position of the ball based on its speed
    ballX += ballXSpeed;
    ballY += ballYSpeed;

    // Update the angle of the paddle based on the mouse X position
    paddleAngle = map(mouseX, 50, width - 100, 0, TWO_PI);

    // Calculate the position of the rectangle, based on its angle at a radius of 200
    float paddleX = 200 + cos(paddleAngle) * paddleRadius;
    float paddleY = 200 + sin(paddleAngle) * paddleRadius;

    // Check if the ball is touching the paddle
    if (dist(ballX, ballY, paddleX, paddleY) < 25) {

        // Calculate the angle the ball is moving at
        float ballAngle = atan2(ballYSpeed, ballXSpeed);
        // reverse the angle
        ballAngle += PI;
        // Find the normal of the paddle, which is the opposite of its angle
        float paddleNormal = paddleAngle + PI;

        // Update the ball's angle to bounce off the paddle normal
        float newBallAngle = ballAngle + (paddleNormal - ballAngle) * 2;
        // Calculate the new speed of the ball based on the new angle
        ballXSpeed = cos(newBallAngle) * ballBaseSpeed;
        ballYSpeed = sin(newBallAngle) * ballBaseSpeed;

        // And move it forward a bit to get it clear of the paddle
        // until it's no longer touching the paddle
        while (dist(ballX, ballY, paddleX, paddleY) < 25) {
            ballX += ballXSpeed * 0.1;
            ballY += ballYSpeed * 0.1;
        }
    }

    // If the ball is touching any of the bricks, damage that brick and reverse the direction of the ball
    for (int i = 0; i < bricks.length; i++) {
        if (bricks[i].hit(ballX, ballY, 10)) {

            // Check if it's hitting the ball on a horizontal or vertical side
            // If it's hitting the ball on a horizontal side, reverse the X speed
            // If it's hitting the ball on a vertical side, reverse the Y speed
            if (abs(ballX - bricks[i].x) < bricks[i].w / 2) {
                ballYSpeed *= -1;
            } else {
                ballXSpeed *= -1;
            }

            // Increase points by 1
            points++;

            // Stop looking
            break;
        }
    }

    // If the ball goes off the screen, reset it to the center with a random angle and a speed of 2.5
    if (ballX < 0 || ballX > width || ballY < 0 || ballY > height) {
        resetBall();


        // Increase ball starting speed
        ballBaseSpeed *= 1.05;

        // decrease points by 1
        points--;
    }
}

void draw() {
    update();

    // Draw the background
    background(255);

    // Shapes should be draw in gray with a black outline
    fill(128);
    stroke(0);

    // Draw the ball at its position
    ellipse(ballX, ballY, 20, 20);

    // Draw the paddle as a rectangle that moves along a circle or radius 180 based on its angle
    // With the paddle rotated so its long side faces the center of the screen
    rectMode(CENTER);
    pushMatrix();
    translate(200, 200);
    rotate(paddleAngle);
    rect(180, 0, paddleHeight, paddleWidth);
    popMatrix();

    // Draw the numbe of points in the top-right corner in black with a medium font
    textAlign(RIGHT);
    fill(0);
    textFont(createFont("Arial", 24));
    text(points, width - 10, 30);


    // Draw all the bricks but only if they haven't been destroyed
    for (int i = 0; i < bricks.length; i++) {
        if (!bricks[i].isDestroyed()) {
            bricks[i].draw();
        }
    }
}

/*
*  The Brick class has an x and y position, a width and a height, and a color.
*  It also has a method to draw itself, and a method to check if it's being hit by a ball of a given radius.
*/
class Brick {
    float x, y, w, h;
    int c;
    // bricks can be hit multiple times
    int hits = 0;

    // max hits is 3
    int maxHits = 3;

    Brick(float x, float y, float w, float h, int c) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
        this.c = c;
    }

    void draw() {
        // Create a new color that gets darker based on how many times the brick has been hit
        int c = color(red(this.c) - hits * 20, green(this.c) - hits * 20, blue(this.c) - hits * 20);

        fill(c);
        stroke(0);
        rect(x, y, w, h);

        // If the brick has been hit, draw cracks in the brick, increased based on how many times it's been hit
        if (hits > 0) {
            fill(0);
            noStroke();
            for (int i = 0; i < hits; i++) {
                rect(x - w / 2 + 5 + i * 5, y - h / 2 + 5, 2, 2);
                rect(x + w / 2 - 5 - i * 5, y - h / 2 + 5, 2, 2);
                rect(x - w / 2 + 5 + i * 5, y + h / 2 - 5, 2, 2);
                rect(x + w / 2 - 5 - i * 5, y + h / 2 - 5, 2, 2);
            }
        }
    }

    // Retrun true if the brick has been destroyed
    boolean isDestroyed() {
        // If the brick has been hit 3 times, return true
        if (hits >= maxHits) {
            return true;
        }
        // Otherwise, return false
        return false;
    }

    boolean hit(float ballX, float ballY, float ballRadius) {
        // don't hit if it's already destroyed
        if (isDestroyed()) {
            return false;
        }

        // Check if any part of the ball is within the brick's rectangle
        if (ballX + ballRadius > x - w / 2 && ballX - ballRadius < x + w / 2 && ballY + ballRadius > y - h / 2 && ballY - ballRadius < y + h / 2) {
            // Get hit
            hits++;

            // If it is, return true
            return true;

        }
        // If it's not, return false
        return false;
    }
}