# Automated_testing_coreutils

This tools tests three functionalitites simultaneously:
1) ROP Gadget Count
2) Correctness Test Cases
3) Total Memory Usage (using valgrind)


#Usage

1) In the bins folder of every coreutil folder, add the respective binares with the format {utilname}{flag} i-e gzip-c
2) In any coreutil folder, run ./test_score.sh


#Requirements Installation

1. pip3 install capstone
2. pip3 install ropgadget
3. sudo apt install valgrind 
