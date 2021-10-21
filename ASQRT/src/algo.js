// Algorithm test

let eps = Math.pow(2, 21);
let att = 1 << 16;
let res = 0;

while (att > eps) att >>= 1;

while (eps != 0 && att != 0) {
    let delta = 2*res*att + att*att; // res*att == res << log2(att)
    if (delta <= eps){
        eps -= delta;
        res |= att;
    }
    att >>= 1;
    console.log(att, eps, res)
}
console.log(res);