# Running Tests

## Set up

To set up, first enter the Vanguard nix shell
```
cd /to/vanguard/dir
nix develop '.?submodules=1#withCircom'
```
Then, come back to this directory and run
```
poetry install
```

## Running Tests

To run the vanguard tests, run
```
python3 test_runner ../tests/vulnerabilities vanguard
```
This will produce an output CSV, and print a summary of the results.

