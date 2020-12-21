BEGIN {
    stderr = "/dev/stderr"
    print "Making personal VCF for", samp > stderr;
}

{
    if (substr($1,1,2) == "##") {
        print;
        next;
    };
    if (substr($1,1,1) == "#") {
        for (i=1; i <= NF; i++) {
            if ($i == samp) {
                samp_id = i;
                break;
            };
        };
        print samp_id > stderr;
    };
    var_id = $1 " " $2
    if (var_id in seen) {
        next;
    }
    seen[var_id] = 0;
    l = ""
    for (i=1; i <= 9; i++) {
        l = l $i "\t"
    };
    l = l $samp_id;
    print l;
}