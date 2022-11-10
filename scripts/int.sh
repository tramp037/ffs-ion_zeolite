#!/bin/sh
#****************************************************************
#*                             FFS                              *
#*                  Initiate all interface runs                 *
#*                                                              *
#*                     Author: Naomi Trampe                     *
#*                          SAMPEL Lab                          *
#*                   Last update: 11/08/2022                    *
#****************************************************************
source /home/sarupria/shared/software/load_scripts/load_gromacs-2022.sh
ROOT=${1}
STDNAME=${2}
INT=${3}
SIM=simulations/int_${INT}/
N=${4}
M=${5}
p=${6}
A=${7}
B=${8}
T_RUN=${9}
cd ${ROOT}${SIM}
#Create new directory for each interface run
for (( i=0; i<${N}; i++ ))
do
  mkdir sim_${i}
done
ENT_NUM=0
ENTRIES=()
#Read the filenames for each configuration and count them
for ENTRY in ${STDNAME}*
do
  ENTRIES+=(${ENTRY})
  ENT_NUM=$(($ENT_NUM+1))
done
mkdir ../int_$(($INT+1))
#run desired exploring scouts
for (( i=0; i<${M}; i++ ))
do
  NUM=$(($i%ENT_NUM))
  FILENAME=${STDNAME}_${INT}_${i}
  cp ${ENTRIES[${NUM}]} sim_${i}/${FILENAME}.gro
  cp ../index.ndx sim_${i}
  cp ../mdp.mdp sim_${i}
  cp ../topol.top sim_${i}
  ~/ffs-ion_zeolite/scripts/run.sh ${ROOT} ${STDNAME} ${INT} ${i} ${A} ${B} ${B} ${T_RUN} y &
done
wait
#analyze exploring scouts, write the configurations, and read the next interface value
l=`python3 ${ROOT}python/op_ex.py "Cl" "Na" ${STDNAME} ${M} ${p} ${INT}`
echo ${l}
