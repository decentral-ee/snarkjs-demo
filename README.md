# Prepare

```
$ npm install
```

# Demos and circuits

Circuits are available under demos/ directory.

## Build and setup circuit

```
$ make CIRCUIT_NAME=multiplier
```

To reset the build and setup use `clean` target

```
$ make CIRCUIT_NAME=multiplier clean all
```

## Test the circuit

Test cases to test the circuit are under demos/CIRCUIT_NAME/samples.

To test the good case, use the following command:

```
make CIRCUIT_NAME=multiplier CASE=case1 test
```

To test the bad case, use the following command:
```
make CIRCUIT_NAME=multiplier CASE=case1 testbad
```

# Explanation of the BankBalancesProver2 demo

## User story

Bob has two bank accounts. Bob wants to prove to the service A that he has at least 100,000 in total from two banks. In the process of proving, Bob doesn't want to disclose to the service A the exact amount he has in either banks, and Bob doesn't want other banks to know his balance at other banks neither.

## Proving Process

0. Setup circuit

Firstly, it should be the service A to setup the circuit:

```
make CIRCUIT_NAME=BankBalancesProver2
```

1. Create bank balance proof request

Bob should request bank balance proof from both banks.

The utility that demonstrates the steps can be run like this:

```
$ node demos/BankBalancesProver/create-bank-balance-proof-request.js 
```

Example outputs of the program is saved at:

- demos/BankBalancesProver2/samples/case1/bank-balance-proof-request-a.txt
- demos/BankBalancesProver2/samples/case1/bank-balance-proof-request-b.txt

Read their content to understand how to use it.

2. Create input.json using values from `bank-balance-proof-request-*.txt`, and set `minimalBalanceRequirement` to the amount that needs to be proved to the service A.

For example:

```
{
    "salt": [
        "75377115362767675398804261478976631160530926418020745369265946171",
        "8285850810832089737398707183975940188304664047117344218896039294"
    ],
    "balances": [
        "32456",
        "88231"
    ],
    "minimalBalanceRequirement": "100000"
}
```

3. Generate proof

```
$ make CIRCUIT_NAME=BankBalancesProver2 CASE=case1 proof
```

It generates the proof.json and public.json

The public.json:
```
[
 "0",
 "59804956490061966944605624366197118549841129766369488852863629470",
 "91132670338900799114655264849154309799544195799933936652932270563",
 "100000"
]
```

[0] element proves if the total balance is less (1) or not-less (0) than the minimal balance requirement.
[1,2] elements are the hash values of the balances used in the proof.
[3] is the minimal balance requirement used in the proof.


4. Verify the proof

For the service A, it should be able to see the public.json and proof.json, and use them to verify the proof.

```
$ make CIRCUIT_NAME=BankBalancesProver2 CASE=case1 test
```

5. Check against bank statement

The hash values in public.json should match the hash in the bank statements.

6. Try to cheat

Several bad public json files are created to test if one can detect fraud.

public.bad1.json - minimalBalanceRequirement is raised more than the proof
public.bad2.json - hash from bank A is altered

To test bad inputs, try:

```
$ make CIRCUIT_NAME=BankBalancesProver2 CASE=case1 testbad
```

## Conclusion

Bank statements can be validated either through digital signatures or paper signatures, together with the zkSNARK proof, it meets the requirement described in the user story.
