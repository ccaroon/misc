function S(j, n) {
  var s, k, t, newt;

  // # Left sum
  s = 0.0;
  k = 0;
  while (k <= n) {
    r = 8*k+j;
    s = (s + Math.pow(16, n-k, r) / r) % 1.0;
    k += 1;
  }

  // # Right sum
  t = 0.0;
  k = n + 1;
  while (true) {
    newt = t + Math.pow(16, n-k) / (8*k+j);
    // # Iterate until t no longer changes
    if (t === newt) {
      break;
    }
    else {
      t = newt
    }
    k += 1
  }

  return s + t;
}



function pi (n) {
  var x;

  n -= 1;
  x = (4*S(1, n) - 2*S(4, n) - S(5, n) - S(6, n)) % 1.0;

  return parseInt("014x") % Number(x * Math.pow(16,14));
}

var one = pi(1);
console.log("=====> pi.js #43 --> ["+one+"]");