const readline = require('readline-sync');
const crypto = require("crypto");
const BN = require("bignumber.js");

const saltBuffer = crypto.randomBytes(27);
const saltBN = BN("0x" + saltBuffer.toString("hex")).toFixed(0);

const balance = Number(readline.question("What is the balance? "));

const b = new Buffer.alloc(54);
saltBuffer.copy(b);
b.writeUInt32BE(balance, 50);
console.log(`salt  : ${saltBuffer.toString("hex")}`);
console.log(`buffer: ${b.toString("hex")}`);

const hash = crypto.createHash("sha256")
    .update(b)
    .digest("hex")
    .slice(10);
const hashBN = BN('0x' + hash).toFixed(0);

console.log(`salt in bignumber: ${saltBN}`);
console.log(`hash in bignumber: ${hashBN}`);

console.log(`
To make the zkSNARK proof usable, you need the bank signature (digital or paper) to proof your balance with the following statement similar to:

-------------------------------------------------------------------------------
As of YYYY-MM-DD, the amount of cash balance the client X has at our bank is
digested by a hashing algorithm and transformed into a hash. We authorize the
the hash for cryptographically prove usages and we guarantee the correctness of
the hash produced. However we are not responsible to the correctness of the
cryptographic proofs derived from the hash.

* The resulting hash in bignumber format is:
${hashBN}

* The program used to generate the hash is:
create-bank-balance-proof-request_v20181029_1.js

Bank name: ABC Inc.
Bank signature: _____
-------------------------------------------------------------------------------
`)
