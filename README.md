# Automated testing tool for coreutils

This tool tests the following functionalitites:
1) ROP Gadget Count
2) Correctness Test Cases
3) Total Memory Usage (using valgrind)


# Usage

1) In the bins folder of every coreutil folder, add the respective binares with the format ``` {utilname}{flag} i-e gzip-c ```
2) In any coreutil folder, run ``` ./test_score.sh ```


# Requirements Installation

  ``` $ pip3 install capstone ```

  ``` $ pip3 install ropgadget ```

  ``` $ sudo apt install valgrind ```
# Demo Usage

<img src="https://github.com/pawnsac/Automated_testing_coreutils/blob/main/demo/pic_1.jpeg?raw=true" alt="alt text" width="400" height="400">

