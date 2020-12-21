import argparse
import itertools as it
import matplotlib
import matplotlib.pyplot as plt
import numpy as np
import pandas
import seaborn as sns
import vt_overlap_summary_hom_het as vos

GENOMES = ['ref', 'pan', 'SUP', 'POP']
GEN_LABS = ['Reference', 'Pan-human\nCons', 'Super Pop\nCons', 'Pop Cons']
ERR_TYPES = ['DiffEnds', 'Unmapped_Mapped', 'Mapped_Unmapped',
    'Multiple_Unique', 'Unique_Multiple']
ERR_LABS = ['Unique to Multiple', 'Multiple to Unique', 'Mapped to Unmapped',
    'Unmapped to Mapped', 'Different Positions']

def make_plot_df(gen, reads_dict):
    read_ids = list(reads_dict.keys())
    # Each read only has one err type, so only need to check one
    err_types = [list(info)[0][0] for info in reads_dict.values()]
    bg_idx = [any([i[1] == 'het' for i in map_list]) \
        for map_list in reads_dict.values()]
    # nonbg_idx = [any([i[1] == 'hom' for i in map_list]) \
    #     for map_list in reads_dict.values()]
    # both_idx = np.logical_and(bg_idx, nonbg_idx)

    # bg_idx = np.logical_and(bg_idx, ~both_idx)
    # nonbg_idx = np.logical_and(nonbg_idx, ~both_idx)

    # assert sum(bg_idx) + sum(nonbg_idx) + sum(both_idx) == len(read_ids)

    # lab_idx = np.zeros(len(read_ids), dtype=int)
    # lab_idx[nonbg_idx] = 1
    # lab_idx[both_idx] = 2
    # labels = ['bg', 'non-bg', 'both']
    # bg = [labels[idx] for idx in lab_idx]

    # bg = ['bg' if any(['het' in i[2] for i in map_list]) else 'non-bg' \
    #     for map_list in reads_dict.values()]
    # , 'value': bg
    plot_df = pandas.DataFrame({'ids': read_ids,
        'genome': np.repeat(gen,len(read_ids)), 'et': err_types, 'bg': bg_idx})
    return(plot_df)

def plot_bg(plot_df, fn_out, reads=None):
    sns.set()
    fig, ax = plt.subplots(figsize=(12,9))
    # fig, axes = plt.subplots(ncols=2, sharex=True, sharey=True, figsize=(12,9))

    # print(sum(np.logical_and(plot_df['genome'] == 'ref',
    #     plot_df['value'] == 'bg')))
    # print(sum(np.logical_and(plot_df['genome'] == 'ref',
    #     plot_df['value'] == 'non-bg')))
    # print(sum(np.logical_and(plot_df['genome'] == 'pan',
    #     plot_df['value'] == 'bg')))
    # print(sum(np.logical_and(plot_df['genome'] == 'pan',
    #     plot_df['value'] == 'non-bg')))

    # max_bg_idx = np.logical_or(plot_df['value'] == 'bg',
    #     plot_df['value'] == 'both')

    # Plot background
    # plot_df['value'] == 'bg'
    # palette = {bg: 'lightgray' for bg in np.unique(plot_df['bg'])}
    sns.countplot(x='genome', data=plot_df[plot_df['bg']], order=GENOMES,
        color='lightgray', ax=ax, lw=0)
    heights = [p.get_height() for p in ax.patches]
    # heights = [tuple(heights[i:i+2]) for i in range(0,len(heights),2)]
    # print(heights)

    # Plot the rest
    # palette = {bg: 'royalblue' for bg in np.unique(plot_df['bg'])}
    sns.countplot(x='genome', data=plot_df[~plot_df['bg']], order=GENOMES,
        color='royalblue', ax=ax, lw=0, bottom=heights)
    
    handles = [ax.patches[0], ax.patches[-1]]

    # Plot read numbes on bars
    for i, p in enumerate(ax.patches):
        x = p.get_x() + p.get_width() / 2
        y = p.get_y() + p.get_height() / 2
        s = f'{p.get_height():,}'
        if reads:
            s = f'{s}\n({p.get_height()/reads*100:0.1f}%)'
        ax.text(x, y, s, fontsize=20,
            ha='center', va='center')

    # # Plot ghost bars to give bar outlines
    # sns.countplot(x='genome', data=plot_df, hue='bg', fc=(0,0,0,0),
    #     lw=1, ec='black', order=['ref', 'pan'], palette=palette, ax=ax)
    
    ax.get_yaxis().set_major_formatter(
        matplotlib.ticker.FuncFormatter(lambda x, p: f'{int(x):,}'))
    ax.set_xticklabels(GEN_LABS)
    ax.tick_params(axis='both', labelsize=20)
    ax.legend(handles=handles, labels=['Background', 'Non-Background'])
    ax.set_xlabel('Genome', fontsize=20)
    ax.set_ylabel('Count', fontsize=20)

    fig.savefig(fn_out, bbox_inches='tight', dpi=200)

def plot_bg_dist(plot_df, fn_out):
    temp_df = plot_df[~plot_df['bg']]

    sns.set()
    fig, ax = plt.subplots(figsize=(12,9))

    # Keep a list of one patch per error type to make the legend later
    patches = []
    bottom = np.zeros(len(GENOMES), dtype=int)

    for i, et in enumerate(ERR_TYPES):
        sns.countplot(x='genome', data=temp_df[temp_df['et'] == et],
            color=sns.color_palette()[i%len(sns.color_palette())],
            order=GENOMES, ax=ax, lw=0, bottom=bottom)
        # print(ax.patches)
        # print([p.get_height() for p in ax.patches[i*len(GENOMES):]])
        print(et, temp_df[temp_df['et'] == et].shape)
        bottom += [p.get_height() for p in ax.patches[i*len(GENOMES):]]
        patches.append(ax.patches[-1])

    for i, p in enumerate(ax.patches):
        x = p.get_x() + p.get_width() / 2
        y = p.get_y() + p.get_height() / 2
        ax.text(x, y, f'{p.get_height():,}', fontsize=20,
            ha='center', va='center')

    ax.get_yaxis().set_major_formatter(
        matplotlib.ticker.FuncFormatter(lambda x, p: f'{int(x):,}'))
    ax.set_xticklabels(GEN_LABS)
    ax.tick_params(axis='both', labelsize=20)
    ax.legend(handles=patches[::-1], labels=ERR_LABS, title='Error Type')
    ax.set_xlabel('Genome', fontsize=20)
    ax.set_ylabel('Count', fontsize=20)

    fig.savefig(fn_out, bbox_inches='tight', dpi=200)

def write_table(plot_df, fn_out):
    with open(fn_out, 'w') as fp_out:
        fp_out.write('genome,bg,nonbg\n')
        # for g in GENOMES:
        for g in np.unique(plot_df['genome']):
            temp_df = plot_df[plot_df['genome'] == g]
            fp_out.write(f'{g},{sum(temp_df["bg"])},{sum(~temp_df["bg"])}\n')

def write_table_dist(plot_df, fn_out):
    with open(fn_out, 'w') as fp_out:
        fp_out.write(f'genome,{",".join(ERR_TYPES)}\n')
        # for g in GENOMES:
        for g in np.unique(plot_df['genome']):
            temp_df = plot_df[plot_df['genome'] == g]
            fp_out.write(f'{g}')
            for et in ERR_TYPES:
                fp_out.write(f',{sum(temp_df["et"]==et)}')
            fp_out.write('\n')

################################################################################
def get_args():
    parser = argparse.ArgumentParser(
        description='Plot reads overlapping het/non-het alleles.')

    parser.add_argument('-i', nargs='+', required=True)
    parser.add_argument('-o')
    parser.add_argument('-dist_o')
    parser.add_argument('-tab', help='CSV table output for main plot.')
    parser.add_argument('-dist_tab', help='CSV table output for dist plot.')
    parser.add_argument('-r', help='File with all reads (normalize by # lines)')


    return(parser.parse_args())

def main():
    args = get_args()
    # print(args.i)

    fns_dict = {k: list(v) for k,v in it.groupby(sorted(args.i),
        key=lambda fn: fn.split('/')[-2])}

    print(fns_dict.keys(), flush=True)

    reads_dicts = {k: {} for k in fns_dict}
    for k,v in reads_dicts.items():
        for fn in fns_dict[k]:
            v = vos.parse_file(fn, v)[0]

    plot_df = pandas.concat([make_plot_df(gen, reads_dict) \
        for gen,reads_dict in reads_dicts.items()])
    print(plot_df.shape)

    if args.r:
        reads = len(open(args.r, 'r').readlines())
    else:
        reads = None

    if args.o:
        plot_bg(plot_df, args.o, reads)
    if args.dist_o:
        plot_bg_dist(plot_df, args.dist_o)

    if args.tab:
        write_table(plot_df, args.tab)
    if args.dist_tab:
        write_table_dist(plot_df[~plot_df['bg']], args.dist_tab)


if __name__ == '__main__':
    main()