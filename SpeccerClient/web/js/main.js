import Ball from "./ball"

console.log("test")

let topCanvas = document.getElementById("topCanvas");
let topCtx = topCanvas.getContext("2d");
window.addEventListener("resize", onResize);
onResize();
window.requestAnimationFrame(animationLoop);
topCanvas.lastDraw = 0;

let ball = new Ball(10);

function onResize() {
  topCanvas.width = window.innerWidth;
  topCanvas.height = window.innerHeight;
}

function animationLoop(timer) {
  window.requestAnimationFrame(animationLoop);

  let elapsed = timer - topCanvas.lastDraw;
  topCanvas.lastDraw = timer;

  topCtx.clearRect(0, 0, topCanvas.width, topCanvas.height);
  ball.draw(topCtx, elapsed);
}
