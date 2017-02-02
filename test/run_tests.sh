#!/bin/bash
commands+=("./test_pair_lj_cut lj_sample.inp")
commands+=("./test_pair_lj_sf lj_sample.inp")
commands+=("./test_pair_softcore_cut lj_sample.inp")
commands+=("./test_verlet 2 lj_sample.inp")
commands+=("./testfortran 2 lj_sample.inp")
#commands+=("./test_kspace_ewald water.inp")
#commands+=("")
#commands+=("")
#commands+=("")

for i in "${!commands[@]}"; do
  echo "====================================================================================="
  echo ${commands[$i]}
  echo "-------------------------------------------------------------------------------------"
  eval ${commands[$i]}
  if [ "$?" == "0" ]; then
    echo -e "\n> Passed"
  else
    echo -e "\n> FAILED!"
  fi 
  echo "====================================================================================="
  echo
done

