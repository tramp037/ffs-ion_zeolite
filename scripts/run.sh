#!/bin/sh
#****************************************************************
#*                             FFS                              *
#*                     Single Run for t_run                     *
#*                                                              *
#*                     Author: Naomi Trampe                     *
#*                          SAMPEL Lab                          *
#*                   Last update: 09/13/2022                    *
#****************************************************************
#Run in new folder with only mdp, gro, ndx, top, and slurm files as necessary
source /home/sarupria/shared/software/load_scripts/load_gromacs-2022.sh
ROOT=${1}
SIM=${2}
MODULE=${3}
A=${4}
B=${5}
T_RUN=${6}
STEPS=$((T_RUN*500))
cd ${ROOT}${SIM}
i=1
sed 's/STEPS/'${STEPS}'/g' mdp.mdp > t_run.mdp
gmx grompp -f t_run.mdp -c ${MODULE}.gro -n index.ndx -p topol.top -o ${MODULE}_${i}.tpr
bash ${ROOT}run_scripts/md-nogpu.sh ${ROOT}${SIM} ${MODULE}_${i}
RESULT=`python3 ${ROOT}python/op_x.py "Cl" "Na" ${ROOT}${SIM}${MODULE}"_"${i}".gro" ${ROOT}${SIM}${MODULE}"_"${i}".xtc"`
echo ${RESULT}
j=2
while (( $(bc <<<"$RESULT > $A && $j < 10" ) ))
do
  echo "Repeat"
  gmx convert-tpr -s ${MODULE}_${i}.tpr -extend 2 -o ${MODULE}_${i}.tpr
  gmx mdrun -deffnm ${MODULE}_${i} -cpi ${MODULE}_${i}.cpt -noappend -nt 4
  RESULT=`python3 ${ROOT}python/op_x.py "Cl" "Na" ${ROOT}${SIM}${MODULE}"_"${i}".part000"${j}".gro" ${ROOT}${SIM}${MODULE}"_"${i}".part000"${j}".xtc"`
  echo ${RESULT}
  j=$(($j+1))
done
echo "Done"

