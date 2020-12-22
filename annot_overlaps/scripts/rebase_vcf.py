"""
Change VCF files to have variants with respect to a different VCF file instead
of with respect to reference.
"""

import argparse

def chrom_to_int(c):
    """
    Function to use to sort chromosomes (numeric < X < Y < M)

    Parameters:
    c: Chromosome to convert
    """

    c = c.strip('chr')

    try:
        return(int(c))
    except ValueError:
        c = c.upper()
        if c == 'X':
            return(23)
        if c == 'Y':
            return(24)
        if c == 'M' or c == 'MT':
            return(25)
        else:
            raise ValueError(f'Unknown chromosome {c}.')

def load_vcf(fn):
    vcf_dict = {}
    vcf_header = []
    seen_pos = set()
    for line in open(fn, 'r'):
        if line[0] == '#':
            vcf_header.append(line.strip())
            continue

        line = line.strip().split('\t')
        chrom = line[0]
        pos = line[1]
        ref = line[3]
        alt = line[4]
        chr_pos = (chrom, pos)
        if chr_pos in seen_pos:
            continue

        seen_pos.add(chr_pos)

        vcf_dict[tuple(line[:2])] = line

    return(vcf_dict, vcf_header)

def loc_sort(loc):
    chrom = chrom_to_int(loc[0])
    pos = int(loc[1])

    return(chrom, pos)

def rebase_vcf(pers, vcf={}):
    # First remove any variants that are the same in both the pers and this vcf
    del_locs = set()
    for loc, line in vcf.items():
        # If the pers vcf (new ref) doesn't have a variant at this location,
        #  leave it as is
        if loc not in pers:
            continue
        
        ref, alt = line[3:5]

        pers_line = pers[loc]
        pers_ref, pers_alt = pers_line[3:5]

        # Remove variants that are also present in the pers
        if ref == pers_ref and alt == pers_alt:
            del_locs.add(loc)

    for loc in del_locs:    
        del vcf[loc]

    # Add any variants that are different from the pers (even if the vcf has the
    #  ref allele)
    for loc, pers_line in pers.items():
        # If the loc is in the vcf, we've already dealt with it
        if loc in vcf or loc in del_locs:
            continue

        pers_ref, pers_alt = pers_line[3:5]        
        new_line = pers_line.copy()
        new_line[3] = pers_alt
        new_line[4] = pers_ref
        vcf[loc] = new_line

    return(vcf)

def write_vcf_file(header, vcf, fn_out):
    with open(fn_out, 'w') as fp_out:
        h = '\n'.join(header)
        fp_out.write(f'{h}\n')

        for loc in sorted(vcf.keys(), key=loc_sort):
            line = '\t'.join(vcf[loc])
            fp_out.write(f'{line}\n')

################################################################################
def get_args():
    parser = argparse.ArgumentParser(description='')

    parser.add_argument('-pers')
    parser.add_argument('-i', nargs='+')
    parser.add_argument('-ref', action='store_true')
    parser.add_argument('-o')

    return(parser.parse_args())

def main():
    args = get_args()

    pers, header = load_vcf(args.pers)

    in_vcfs = [load_vcf(fn)[0] for fn in args.i]
    labs = [fn.split('/')[-2] for fn in args.i]

    if args.ref:
        in_vcfs.append(rebase_vcf(pers))
        labs.append('ref')

    for i, vcf in enumerate(in_vcfs):
        vcf = rebase_vcf(pers, vcf)
        try:
            fn_out = f'{args.o}/{labs[i]}/{args.i[i].split("/")[-1]}'
        except IndexError:
            fn_out = f'{args.o}/{labs[i]}/{args.pers.split("/")[-1]}'

        print(fn_out)
        write_vcf_file(header, vcf, fn_out)

if __name__ == '__main__':
    main()