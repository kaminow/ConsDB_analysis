import argparse
import re

def get_args():
    parser = argparse.ArgumentParser(
        description='Split VCF into hom and het VCF based on pers VCF.')

    parser.add_argument('-pers_full', required=True)
    parser.add_argument('-gen', required=True)
    parser.add_argument('-o', required=True)

    return(parser.parse_args())

def main():
    args = get_args()

    vcf_dict = {}
    snp_dict = {}

    # Find whether variants are hom or het in the individual
    for line in open(args.pers_full, 'r'):
        if line[0] == '#':
            continue

        line = line.strip().split('\t')
        try:
            gt = re.split('[|/]', line[9])
        except IndexError as e:
            print(line)
            raise e
            
        line = tuple(line[:5])

        if gt[0] == gt[1]:
            vt = 'hom'
        else:
            vt = 'het'

        try:
            vcf_dict[line].add(vt)
        except KeyError:
            vcf_dict[line] = {vt}

        if len(line[3]) != len(line[4]):
            snp_dict[line] = 'indel'
        else:
            snp_dict[line] = 'SNP'


    for line in open(args.gen, 'r'):
        if line[0] == '#':
            continue

        line = line.strip().split('\t')
        line = tuple(line[:5])

        try:
            vcf_dict[line].add('gen')
        except KeyError:
            # print(f'WARNING: {line} in gen file but not pers_full, skipping.')
            pass
            # vcf_dict[line] = {'gen'}

    fp_list = [open(f'{args.o}/snp_hom.vcf', 'w'),
        open(f'{args.o}/indel_hom.vcf', 'w'),
        open(f'{args.o}/snp_het.vcf', 'w'),
        open(f'{args.o}/indel_het.vcf', 'w')]

    header = ['##fileformat=VCFv4.3',
    '##FILTER=<ID=PASS,Description="All filters passed">',
    '#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO']

    for fp in fp_list:
        fp.write('\n'.join(header) + '\n')

    for line, vt in vcf_dict.items():
        if len(vt) == 1:
            continue
        elif len(vt) == 2:
            if 'gen' not in vt:
                # shouldn't happen
                continue
            if 'hom' in vt:
                if snp_dict[line] == 'SNP':
                    fp = fp_list[0]
                else:
                    fp = fp_list[1]
            else:
                if snp_dict[line] == 'SNP':
                    fp = fp_list[2]
                else:
                    fp = fp_list[3]
        else:
            # shouldn't happen
            continue

        line = list(line)
        line.extend(['.', 'PASS', '.'])
        line = '\t'.join(line)
        fp.write(f'{line}\n')

    for fp in fp_list:
        fp.close()

if __name__ == '__main__':
    main()