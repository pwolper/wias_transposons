# GNU parallel command to execute parameter combinations

# Run replicates of slim command

#seq 10 | parallel -j 3 -n0 --dry-run "slim -d N=5000 -d L=1 -d teJumpP=0.01 -d teDeathRate=0.0005 -d simTime=2000 TE_haploid_WIAS.slim" 

#parallel -j 3 --dry-run slim -d N={1} -d L=1 -d teJumpP={2} -d teDeathRate={3} -d simTime=2000 TE_haploid_WIAS.slim ::: 5000 50000 500000 ::: 0.01 0.05 0.1 ::: 0.01 0.001 0.0001
#parallel --dry-run slim -d N={1} -d L=1 -d teJumpP={2} -d teDeathRate={3} -d simTime=2000 -d replicate={4} TE_haploid_WIAS.slim ::: 10 100  ::: 0.01 0.05 ::: 0.01 0.001 ::: $(seq 10)
parallel --verbose slim -d N={1} -d L=1 -d teJumpP=0.01 -d teDeathRate={2} -d simTime=2000 -d replicate={3} TE_diploid_WIAS.slim ::: 5000 50000 ::: 0.001 0.0005 0.0001 ::: $(seq 10)
