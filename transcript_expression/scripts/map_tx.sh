#!/bin/bash

star=$1
reads_dir=$2
reads_base=$3
gen_dir=$4
out_dir=$5

# | sort | tr '\n' , | sed 's/.$//')
# reads=($(ls ${reads_dir}/*${reads_base}*Rd1Rep*.fastq.gz))
paired=1
reads=($(ls -d ${reads_dir}/* | \
    grep -P ".*?${reads_base}.*?Rd1Rep.*?\.fastq\.gz"))
if [[ ${#reads[@]} -eq 0 ]]; then
    reads=($(ls -d ${reads_dir}/* | \
        grep -P ".*?${reads_base}.*?Rep.*?\.fastq\.gz"))
    paired=0
fi

echo ${reads[@]}

n_reps=${#reads[@]}

# --scoreInsOpen 0 --scoreDelOpen 0 
# --sjdbGTFfeatureExon gene --sjdbGTFfile $gtf_file
star_base="--readFilesCommand zcat --outSAMreadID Number --runThreadN 40
--quantMode GeneCounts TranscriptomeSAM --genomeDir ${gen_dir}
--outSAMtype BAM Unsorted SortedByCoordinate"

for i in $(seq 0 $(($n_reps - 1))); do
    r1=${reads[$i]}

    rep=${r1%.fastq.gz}
    
    if [[ $paired -eq 1 ]]; then
        r2=$(sed 's/Rd1/Rd2/' <<< $r1)
        reads_pair="$r1 $r2"
        rep=${rep##*Rd1}
    else
        reads_pair=$r1
        rep=${rep##*Fastq}
    fi

    out_tmp=${out_dir}/${rep}/
    mkdir -p $out_tmp

    star_args="${star_base} --outFileNamePrefix ${out_tmp}
    --readFilesIn $reads_pair"
    $star $star_args &> ${out_tmp}/out && echo $rep
done

## Wait 30 seconds for files to sync
sleep 30