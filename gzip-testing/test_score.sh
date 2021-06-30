#!/bin/bash

#add binares to this folder formatted as gzip{{flag}} i-e gzip-c
BIN_DIR="bins" 
FLAGS=("-c" "-d" "-f" "-t")
TOTAL=0
SCORE=0
LOG=""


function test-d() {

  TOTAL=$((TOTAL+1))
  TEST_DIR=$2
  gzip -c <$TEST_DIR > temp2 > temp2
  { timeout -k 3 3 "$BIN_DIR/gzip$1" $1 <temp2 > temp1 ; } >& /dev/null
  { timeout -k 3 3 valgrind --tool=massif --stacks=yes "$BIN_DIR/gzip$1" $1 <temp2 > val-tmp ; } >& /dev/null 
  cmp temp1 $TEST_DIR  >& /dev/null
  if [[ $? == 0 ]]; then 
   SCORE=$((SCORE+1))
  else
    rm -rf temp1 temp2 
    return 1
  fi
  rm -rf temp1 temp2
 return 0
}
function test-f() {

  TOTAL=$((TOTAL+1))
  TEST_DIR=$2
  { timeout -k 3 3 "$BIN_DIR/gzip$1" $1 $TEST_DIR  ; } >& /dev/null
  { timeout -k 3 3 valgrind --tool=massif --stacks=yes "$BIN_DIR/gzip$1" $1 $TEST_DIR >& val-tmp ; } >& /dev/null 
  gzip -t $TEST_DIR.gz  >& /dev/null
  if [[ $? == 0 ]]; then 
   SCORE=$((SCORE+1))
  else
    rm -rf temp1 temp2 
    return 1
  fi
  rm -rf temp1 temp2
 return 0

}
function test-c() {
  TOTAL=$((TOTAL+1))
  TEST_DIR=$2
  { timeout -k 3 3 "$BIN_DIR/gzip$1" $1 <$TEST_DIR > temp1 ; } >& /dev/null
  { timeout -k 3 3 valgrind --tool=massif --stacks=yes "$BIN_DIR/gzip$1" $1 <$TEST_DIR > val-tmp ; } >& /dev/null 
  gzip -t  temp1 >& /dev/null
  if [[ $? == 0 ]]; then 
   SCORE=$((SCORE+1))
  else
    rm -rf temp1 temp2 
    return 1
  fi
  rm -rf temp1 temp2
 return 0
}
function test-t() {
  TOTAL=$((TOTAL+1))
  TEST_DIR=$2
  gzip -c <$TEST_DIR > temp2 > temp2 
  { timeout -k 2 2 "$BIN_DIR/gzip$1" $1 <temp2 > temp1 ; } >& /dev/null
  if [[ $? -ne 0 ]]; then  
    return 1
  fi
  { timeout -k 2 2 valgrind --tool=massif --stacks=yes "$BIN_DIR/gzip$1" $1 <temp2 > val-tmp ; } >& /dev/null 
 touch empt  
  cmp empt temp1  >& /dev/null
  if [[ $? == 0 ]]; then 
   SCORE=$((SCORE+1))
  else
    rm -rf temp1 temp2 
    return 1
  fi
  rm -rf temp1 temp2
 return 0
}

function flags_check() {
  for flag in "${FLAGS[@]}"; do
    LOCAL_SCORE=33
    LOCAL_TESTS=0
    LOCAL_MEM=0
    for file in $( ls test/* ) ; do
      test$flag $flag $file|| LOCAL_SCORE=$(($LOCAL_SCORE-1))
  done;
  for massif in $(ls massif*); do
  LOCAL_TESTS=$(($LOCAL_TESTS+1))
  grep -E mem_ $massif | cut -d '=' -f 2 > vals.txt
  t_mem=0
  for val in $(cat vals.txt); do
      t_mem=$(($t_mem+$val))
    done;
  LOCAL_MEM=$(($t_mem+$LOCAL_MEM))
  done;
  if [[ $LOCAL_TESTS -ne 0 ]]; then
    LOCAL_MEM=$(($LOCAL_MEM/$LOCAL_TESTS))
  fi;
  echo "ROP gadget count for $flag flag:" > rop_w.txt
  ROPgadget --binary $BIN_DIR/gzip$flag | grep -E Unique | cut -d ':' -f 2 > rop.txt
  rm -rf massif*
  echo "Memory used for $flag flag: $LOCAL_MEM bytes"
  echo "$LOCAL_SCORE/33 tests passed for $flag flag"
  cat rop_w.txt rop.txt | tr '\n' ' '
  echo -e '\n'
  cd test && rm -rf *.gz && cd - >& /dev/null
  rm -rf vgc* 
done

}
function main() {
echo "############### AUTOMATED TESTING #################"
echo "########### gzip-1.2.4 testing starting ###########"
echo "###################################################"
echo -e "Memory used is the average total memeory used in all \nsnapshots for all test runs of a variant"
echo "###################################################"
rm -rf massif*
flags_check
echo "$SCORE/$TOTAL tests passed for all variants"
rm -rf temp1 temp2 *.txt

}

main
