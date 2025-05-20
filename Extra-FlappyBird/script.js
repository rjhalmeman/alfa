const canvas = document.getElementById('gameCanvas');
const ctx = canvas.getContext('2d');

canvas.width = 400;
canvas.height = 600;

const bird = {
    x: 50,
    y: 150,
    size: 20,
    gravity: 0.5,
    lift: -10,
    velocity: 0,
};

const pipes = [];
const pipeWidth = 50;
const pipeGap = 150;
let frame = 0;
let score = 0;
let gameOver = false;

function drawBird() {
    ctx.fillStyle = 'yellow';
    ctx.fillRect(bird.x, bird.y, bird.size, bird.size);
}

function drawPipes() {
    ctx.fillStyle = 'green';
    pipes.forEach(pipe => {
        ctx.fillRect(pipe.x, 0, pipeWidth, pipe.top);
        ctx.fillRect(pipe.x, canvas.height - pipe.bottom, pipeWidth, pipe.bottom);
    });
}

function updatePipes() {
    if (frame % 90 === 0) {
        const top = Math.floor(Math.random() * (canvas.height - pipeGap - 50)) + 20;
        const bottom = canvas.height - top - pipeGap;
        pipes.push({ x: canvas.width, top, bottom });
    }

    pipes.forEach(pipe => {
        pipe.x -= 2;
        if (pipe.x + pipeWidth < 0) {
            pipes.shift();
            score++;
        }

        if (
            bird.x < pipe.x + pipeWidth &&
            bird.x + bird.size > pipe.x &&
            (bird.y < pipe.top || bird.y + bird.size > canvas.height - pipe.bottom)
        ) {
            gameOver = true;
        }
    });
}

function drawScore() {
    ctx.fillStyle = 'white';
    ctx.font = '20px Arial';
    ctx.fillText(`Score: ${score}`, 10, 25);
}

function updateBird() {
    bird.velocity += bird.gravity;
    bird.y += bird.velocity;

    if (bird.y + bird.size > canvas.height || bird.y < 0) {
        gameOver = true;
    }
}

function resetGame() {
    bird.y = 150;
    bird.velocity = 0;
    pipes.length = 0;
    score = 0;
    gameOver = false;
    frame = 0;
}

function gameLoop() {
    if (gameOver) {
        alert(`Game Over. Score: ${score}`);
        resetGame();
    } else {
        frame++;
        ctx.clearRect(0, 0, canvas.width, canvas.height);
        drawBird();
        updateBird();
        drawPipes();
        updatePipes();
        drawScore();
        requestAnimationFrame(gameLoop);
    }
}

document.addEventListener('keydown', event => {
    if (event.code === 'Space') {
        bird.velocity = bird.lift;
    }
});

gameLoop();
