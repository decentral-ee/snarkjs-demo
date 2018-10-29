CIRCUIT_NAME=multiplier
CASE=case1

CIRCUIT_DIR=circuits/$(CIRCUIT_NAME)
CASE_DIR=$(CIRCUIT_DIR)/samples/$(CASE)

CIRCOM=npx --node-arg "--max-old-space-size=12000" circom
SNARKJS=npx --node-arg "--max-old-space-size=12000" snarkjs


all: $(CIRCUIT_DIR)/circuit.json $(CIRCUIT_DIR)/proving_key.json $(CIRCUIT_DIR)/verification_key.json $(CIRCUIT_DIR)/verifier.sol

$(CIRCUIT_DIR)/circuit.json: $(CIRCUIT_DIR)/$(CIRCUIT_NAME).circom
	(cd $(CIRCUIT_DIR); $(CIRCOM) $(CIRCUIT_NAME).circom)

$(CIRCUIT_DIR)/proving_key.json $(CIRCUIT_DIR)/verification_key.json: $(CIRCUIT_DIR)/circuit.json
	(cd $(CIRCUIT_DIR); $(SNARKJS) setup)

$(CIRCUIT_DIR)/verifier.sol: $(CIRCUIT_DIR)/proving_key.json $(CIRCUIT_DIR)/verification_key.json
	(cd $(CIRCUIT_DIR); $(SNARKJS) generateverifier)

clean:
	(cd $(CIRCUIT_DIR); rm -f *.json *.sol)

.PHONY: all clean

$(CASE_DIR)/witness.json: $(CIRCUIT_DIR)/circuit.json $(CASE_DIR)/input.json
	$(SNARKJS) calculatewitness -c $(CIRCUIT_DIR)/circuit.json -i $(CASE_DIR)/input.json -w $@

$(CASE_DIR)/public.json $(CASE_DIR)/proof.json: $(CIRCUIT_DIR)/proving_key.json $(CASE_DIR)/witness.json
	$(SNARKJS) proof -w $(CASE_DIR)/witness.json --pk $(CIRCUIT_DIR)/proving_key.json -p $(CASE_DIR)/proof.json --pub $(CASE_DIR)/public.json

test: $(CASE_DIR)/public.json $(CASE_DIR)/proof.json
	cat $(CASE_DIR)/public.json;echo
	$(SNARKJS) verify --vk $(CIRCUIT_DIR)/verification_key.json -p $(CASE_DIR)/proof.json --pub $(CASE_DIR)/public.json

testbad: $(CASE_DIR)/public.bad.json $(CASE_DIR)/proof.json
	$(SNARKJS) verify --vk $(CIRCUIT_DIR)/verification_key.json -p $(CASE_DIR)/proof.json --pub $(CASE_DIR)/public.bad.json;test $$? != 0

.PHONY: test testbad
