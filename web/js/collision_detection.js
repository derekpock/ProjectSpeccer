
export default class CollisionDetection {
  static checkHitboxes(a, list) {
    if(a.hitbox === "circle") {
      list.forEach(function(b) {
        if(a !== b) {
          if(b.hitbox === "circle") {
            if(a.r.fastDistance(b.r) < (a.r.length() + b.r.length())) {}
          }
        }
      });
    }
  }
}
