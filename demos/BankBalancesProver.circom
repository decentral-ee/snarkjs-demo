include "../node_modules/circom/circuits/comparators.circom";
include "../node_modules/circom/circuits/sha256/sha256_2.circom";

template Sha256() {
    signal input value
    signal output out;

    component sha256_2 = Sha256_2();
    sha256_2.a <-- 0;
    sha256_2.b <-- value;

    out <== sha256_2.out;
}

template BankBalancesProver(nBanks) {
    signal private input balances[nBanks];
    signal input minimalBalanceRequirement;
    signal output out;
    signal output expectedBalanceHashes[nBanks];

    var i;

    component sha256[nBanks];
    for (i = 0; i < nBanks; ++i) {
        sha256[i] = Sha256();
    }

    component lessthan = LessThan(32);
    var totalBalance = 0;
    for (i = 0; i < nBanks; ++i) {
        sha256[i].value <-- balances[i];
        expectedBalanceHashes[i] <== sha256[i].out;
        totalBalance += balances[i];
    }
    lessthan.in[0] <-- totalBalance;
    lessthan.in[1] <-- minimalBalanceRequirement;

    out <== lessthan.out;
}
