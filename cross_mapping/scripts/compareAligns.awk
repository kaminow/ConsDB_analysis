BEGIN {
    stderr="/dev/stderr";

    OFS="\t";
    if (nReads=="")
       nReads=1000000000;
    #print nReads > "/dev/stderr";

    if (readFile!="")
        while (getline < readFile) R[$1]=0;

    print readFile, length(R) > stderr;

    print "#_Mappers", "#_Mappers", "Chrom", "Chrom", "Pos", "Pos", "Length", \
    "Length", "Mismatch_per_Aln", "Mismatch_per_Aln";
}

BEGINFILE {
    #print "Length of M=", length(M) > stderr;
}

{
    if (substr($1,1,1)=="@")
        next;
    if ($1 > nReads)
        nextfile;
    if ($9<0 || $3=="*")
        next;
    if (length(R)!=0 && !($1 in R))
        next;


    # M[$1][ARGIND]=substr($12,6);
    M[$1][ARGIND]++;
    C[$1][ARGIND]=$3;
    S[$1][ARGIND]=$4;
    I[$1][ARGIND]=$9;
    H[$1][ARGIND]=substr($NF,6);

    #if ($1%10000000==0)
    #    print FILENAME, ARGIND, $1, C[$1][1], C[$1][2] > "/dev/stderr";

}

END {
    print "Length of M=", length(M) > stderr;
    for (r in M) {
        print M[r][1]+0,M[r][2]+0,C[r][1],C[r][2],S[r][1],S[r][2],I[r][1],I[r][2], H[r][1],H[r][2], r;
    };
}
