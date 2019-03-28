
export default class Vector {
  constructor(x, y) {
    this.x = x;
    this.y = y;
  }

  scalarMultiply(scalar) {
    return new Vector(this.x * scalar, this.y * scalar);
  }

  add(vector) {
    return new Vector(this.x + vector.x, this.y + vector.y);
  }

  negate() {
    return new Vector(-this.x, -this.y);
  }

  fastDistance(vector) {
    return this.add(vector.negate()).length();
  }

  fastLength() {
    return this.x * this.x + this.y * this.y;
  }

  distance(vector) {
    Math.sqrt(this.fastDistance(vector));
  }

  length() {
    return Math.sqrt(this.fastLength());
  }

  angle() {
    return Math.atan2(this.y, this.x);
  }
}
