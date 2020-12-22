BEGIN {
    stderr = "/dev/stderr";

    if (reads_fn == "") {
        print "No reads file given." > stderr;
        exit;
    };

    IFS=","
    while (getline < reads_fn) {
        if ($1 != "") {
            reads[$1]=0;
            c++
        };
    };
    print c " total read ids" > stderr;
    IFS="\t"
}

{
    if ($1 in reads) {
        print
    }
}