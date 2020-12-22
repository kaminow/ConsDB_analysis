import argparse
import itertools as it
import numpy as np
import os
import pandas
import re

ANNOT_TYPES = ['all', 'CDS', 'exon', 'gene', 'start_codon', 'stop_codon',
    'transcript', 'UTR']
ANNOT_IDX_DICT = dict(zip(ANNOT_TYPES, range(len(ANNOT_TYPES))))

def group_files(fn_list):
    fn_groups = it.groupby(sorted(fn_list), lambda x: parse_fn(x)[:3])
    fn_groups = {k: list(v) for k,v in fn_groups}

    return(fn_groups)

def parse_file(fn):
    counts = []
    reads_fns = []
    # keep track of where in the counts/reads_fn arrays each reads file is
    fns_idx = {}
    for line in open(fn, 'r'):
        line = line.strip().split('\t')
        fn = line[-2]
        c = int(line[-1])
        try:
            idx = fns_idx[fn]
        except KeyError:
            idx = fns_idx[fn] = len(counts)
            # use a tuple to keep track of (snps,indels)
            counts.append([0,0])
            reads_fns.append(fn)

        if c == 0:
            continue

        if len(line[3]) == len(line[4]):
            counts[idx][0] += 1
        else:
            counts[idx][1] += 1

    reads_fns = ['_'.join(
        '_'.join(os.path.basename(fn).split('_')[1:]).split('.')[:-1]) \
        for fn in reads_fns]
    df = pandas.DataFrame(counts, columns=['snp', 'indel'], index=reads_fns)
    return(df)

def parse_file_dict(fn):
    """
    Return a dictionary of var -> set of error types. Skip var/error type combos
    that don't have any counts.
    """
    vars_dict = {}

    for line in open(fn, 'r'):
        line = line.strip().split('\t')
        fn = line[-2]
        err_type = '_'.join(os.path.basename(fn).split('_')[1:]).split('.')[0]
        
        c = int(line[-1])
        if c == 0: continue

        v = tuple(line[:5])
        try:
            vars_dict[v].add(err_type)
        except KeyError:
            vars_dict[v] = {err_type}


    return(vars_dict)


def parse_file_group(group_info, fn_list):
    vars_dict = {}

    ## First go through each variant in each file and set its index based on
    ##  which annotation type files it appears in
    for fn in fn_list:
        print(fn, flush=True)
        annot_type = parse_fn(fn)[-1]
        file_dict = parse_file_dict(fn)
        for v,err_types in file_dict.items():
            # Need a second level of dict to keep track of error types
            try:
                d1 = vars_dict[v]
            except KeyError:
                d1 = vars_dict[v] = {}

            for et in err_types:
                try:
                    idx = d1[et]
                except KeyError:
                    idx = d1[et] = [False]*len(ANNOT_TYPES)

                idx[ANNOT_IDX_DICT[annot_type]] = True

    ## Count all vars with the same annot type index and the same error type
    df_dict = {}
    for v,d1 in vars_dict.items():
        if len(v[3]) == len(v[4]):
            c_idx = 0
        else:
            c_idx = 1
        for et,idx in d1.items():
            # idx += [et]
            if not idx[0]:
                print(v, d1, group_info, fn_list, flush=True)
                raise ValueError
            idx = tuple(list(group_info) + idx + [et])
            try:
                df_dict[idx][c_idx] += 1
            except KeyError:
                df_dict[idx] = [0, 0]
                df_dict[idx][c_idx] += 1

    return(df_dict)

def parse_fn(fn):
    fn = re.split(r'\/+', fn)
    b = fn[-1].split('_')
    vt = b[0]
    at = '_'.join(b[1:]).split('.')[0]
    gen = fn[-2]
    ind = fn[-3]

    return(ind, gen, vt, at)

################################################################################
def get_args():
    parser = argparse.ArgumentParser(description='')

    parser.add_argument('-i', nargs='+')
    parser.add_argument('-o')

    return(parser.parse_args())

def main():
    args = get_args()

    # print(args.i)
    fn_groups = group_files(args.i)
    
    full_df = None
    for group_info,fn_list in fn_groups.items():
        df_dict = parse_file_group(group_info, fn_list)
        temp_df = pandas.DataFrame(df_dict.values(),
            index=pandas.MultiIndex.from_tuples(df_dict.keys()),
            columns=['snp', 'indel'])

        if full_df is None:
            full_df = temp_df.copy()
        else:
            full_df = pandas.concat([full_df, temp_df], axis=0)

    index_labels = ['ind', 'gen', 'var_type'] + ANNOT_TYPES + ['error_type']
    full_df.to_csv(args.o, index_label=index_labels)

    # all_counts = None
    # for fn in args.i:
    #     fn = fn.split('/')
    #     vt = fn[-1].split('_')[0]
    #     gt = '_'.join(fn[-1].split('_')[1:]).split('.')[0]
    #     gen = fn[-2]
    #     ind = fn[-3]

    #     fn = '/'.join(fn)
    #     df = parse_file(fn)
    #     df['var_type']=vt
    #     df['gen_annot']=gt
    #     df['genome']=gen
    #     df['ind']=ind
    #     if all_counts is not None:
    #         all_counts = pandas.concat((all_counts, df), axis=0)
    #     else:
    #         all_counts = df

    #     print(fn, flush=True)

    # all_counts.to_csv(args.o)

if __name__ == '__main__':
    main()