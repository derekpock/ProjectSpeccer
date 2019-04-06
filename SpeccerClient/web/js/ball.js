import Vector from "./vector";

export default class Ball {
  constructor(radius) {
    this.hitbox = "circle";
    this.radius = radius;
    this.r = new Vector(radius, radius);
    this.v = new Vector(0.1, 0.1);
  }

  draw(ctx, elapsed) {
    ctx.fillStyle = "black";
    ctx.beginPath();

    this.r = this.r.add(this.v.scalarMultiply(elapsed));

    if(this.rx < 0) {
      this.vx *= -1;
    } else if (this.rx > 234) {
      this.vx *= -1;
    }

    if(this.ry < 0) {
      this.vy *= -1;
    } else if (this.ry > 100) {
      this.vy *= -1;
    }

    ctx.arc(this.rx, this.ry, this.radius, 0, 2*Math.PI);
    ctx.fill();
  }
}
