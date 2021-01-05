import argparse
import numpy as np
import matplotlib as mpl
from matplotlib.lines import Line2D
from matplotlib.patches import Patch
import matplotlib.pyplot as plt
import pandas
from scipy.stats import pearsonr
import seaborn as sns

def calc_pearson(df):
    cutoffs = [1, 5, 10, 25, 50, 100, 500, 1000]
    comp_pairs = [('pers', 'ref'), ('pers', 'pan_snp'), ('ref', 'pan_snp')]
    comp_keys = np.repeat([f'{x},{y}' for (x,y) in comp_pairs], len(cutoffs))

    df.loc[:,['ref', 'pan_snp', 'pers']] += 0.1
    pearson_rs = []
    for (x,y) in comp_pairs:
        for c in cutoffs:
            idx = np.asarray(df[x] <= c) | np.asarray(df[y] <= c)
            r = pearsonr(np.log10(df.loc[idx,x]), np.log10(df.loc[idx,y]))[0]
            pearson_rs.append(r)

    # use str for cutoffs so seaborn doesn't try to plot them as numbers
    pearson_df = pandas.DataFrame({'pearson_r': pearson_rs,
        'cutoff': np.tile(cutoffs, len(comp_pairs)), 'id': comp_keys})
    return(pearson_df)

def load_data(in_dir):
    file_bases = ['ref', 'pan_snp', 'pers']
    fns = [f'{in_dir}/{fb}_tx/Rep1/Rep1.isoforms.results' for fb in file_bases]
    df = None
    for i,fb in enumerate(file_bases):
        df_new = pandas.read_csv(fns[i], index_col=0, sep='\t')
        if df is None:
            df_new[f'{fb}'] = df_new['TPM']
            df = df_new[['gene_id', f'{fb}']].copy()
        else:
            df[f'{fb}'] = df_new['TPM']

    return(df)

def load_data_split(in_dir):
    file_bases = ['ref', 'pan_snp', 'pers']
    fns = [f'{in_dir}/{fb}_tx/Rep1/Rep1.isoforms.results' for fb in file_bases]
    df = None
    for fb in file_bases:
        gen_fns = [f'{in_dir}/{fb}_tx_split/Rep{i}/Rep{i}.isoforms.results' \
            for i in range(1, 3)]
        dfs = [pandas.read_csv(fn, index_col=0, sep='\t').rename(
            columns={'TPM': f'{fb}_{i+1}'}) for i,fn in enumerate(gen_fns)]
        df_new = pandas.concat([dfs[0][f'{fb}_1'], dfs[1][f'{fb}_2']], axis=1)
        df_new[f'{fb}'] = df_new.mean(axis=1)
        df_new['gene_id'] = dfs[0]['gene_id']

        if df is None:
            df = df_new[['gene_id', f'{fb}', f'{fb}_1', f'{fb}_2']].copy()
        else:
            df[f'{fb}'] = df_new[f'{fb}']
            df[f'{fb}_1'] = df_new[f'{fb}_1']
            df[f'{fb}_2'] = df_new[f'{fb}_2']

    return(df)

def plot_error_hists(df, fn_out, cutoffs=[0.2,1,5]):
    fig, axes = plt.subplots(nrows=2, figsize=(18,20))

    plot_df = None
    for c in cutoffs:
        cutoff_idx = (df['pers'].to_numpy() >= c) | \
            (df['ref'].to_numpy() >= c) | (df['pan_snp'].to_numpy() >= c)
        df_new = df.loc[cutoff_idx,:].copy()

        df_new.loc[:,['pers', 'ref', 'pan_snp']] += 0.001

        pers_zero = df_new['pers'].to_numpy() == 0
        ref_zero = df_new['ref'].to_numpy() == 0
        pan_zero = df_new['pan_snp'].to_numpy() == 0

        ref_only_neg_inf = ref_zero & ~pers_zero & ~pan_zero
        pan_only_neg_inf = pan_zero & ~pers_zero & ~ref_zero

        all_nz = ~(ref_zero | pan_zero | pers_zero)

        ref_lfc = np.log2(df_new.loc[all_nz,'ref'] / df_new.loc[all_nz,'pers'])
        pan_lfc = np.log2(
            df_new.loc[all_nz,'pan_snp'] / df_new.loc[all_nz,'pers'])
        err = np.abs(pan_lfc) - np.abs(ref_lfc)
        pos = np.repeat('Positive', len(err))
        pos[err<0] = 'Negative'

        if plot_df is None:
            plot_df = pandas.DataFrame({'err': err, 'cutoff': c, 'pos': pos})
        else:
            plot_df = pandas.concat([plot_df,
                pandas.DataFrame({'err': err, 'cutoff': c, 'pos': pos})],
                axis=0)

    hue_order = sorted(cutoffs, reverse=True)
    sns.histplot(x='err', hue='cutoff', multiple='stack', data=plot_df,
        fill=True, bins=75, ax=axes[0], palette='tab10', hue_order=hue_order)
    axes[0].set_yscale('log')
    ax_max = max(np.abs(axes[0].get_xlim()))
    axes[0].set_xlim(-ax_max, ax_max)
    axes[0].set_xlabel((r'$\left| '
        r'\log_2 \left( \frac{\mathrm{TPM}_{\mathrm{pan}}}'
        r'{\mathrm{TPM}_{\mathrm{pers}}} \right) \right| - '
        r'\left| \log_2 \left( \frac{\mathrm{TPM}_{\mathrm{ref}}}'
        r'{\mathrm{TPM}_{\mathrm{pers}}} \right) \right|$'))
    axes[0].set_ylabel('Number of Transcripts')
    
    ## "Proxy artists" for the legend
    colors = sns.color_palette('tab10')[:3]
    handles = [Patch(ec='black', fc=colors[i], label=f'{c:0.1f}') \
        for i,c in enumerate(hue_order)]
    axes[0].legend(handles=handles, title='TPM Cutoff')


    pos_idx = plot_df['err'].to_numpy() > 0
    plot_df.loc[:,'err'] = np.abs(plot_df.loc[:,'err'])
    err_idx = plot_df['err'].to_numpy() >= 1

    ## Make bin edges so that both pos and neg use the same ones
    # 75 bins, so need 76 points
    bins = np.linspace(1, max(plot_df['err']), 76)
    ## Plot positive
    sns.histplot(x='err', hue='cutoff', data=plot_df.loc[pos_idx&err_idx,:],
        bins=bins, cumulative=True, fill=False, element='step', ax=axes[1],
        ls='--', palette='tab10', hue_order=hue_order, legend=False, lw=3)
    ## Plot negative
    sns.histplot(x='err', hue='cutoff', data=plot_df.loc[(~pos_idx)&err_idx,:],
        bins=bins, cumulative=True, fill=False, element='step', ax=axes[1],
        palette='tab10', hue_order=hue_order, legend=False, lw=3)

    axes[1].set_xlabel((r'$\left| \left| '
        r'\log_2 \left( \frac{\mathrm{TPM}_{\mathrm{pan}}}'
        r'{\mathrm{TPM}_{\mathrm{pers}}} \right) \right| - '
        r'\left| \log_2 \left( \frac{\mathrm{TPM}_{\mathrm{ref}}}'
        r'{\mathrm{TPM}_{\mathrm{pers}}} \right) \right| \right| $'))
    axes[1].set_ylabel('Cumulative Number of Transcripts')

    ## "Proxy artists" for the legend
    handles = []
    colors = sns.color_palette('tab10')[:3][::-1]
    ## Negative lines
    handles.extend([Line2D([], [], color=colors[i], marker='',
        label=f'Diff < 0, TPM Cutoff: {c:0.1f}') \
        for i,c in enumerate(cutoffs)])
    ## Positive lines
    handles.extend([Line2D([], [], color=colors[i], marker='', ls='--',
        label=f'Diff > 0, TPM Cutoff: {c:0.1f}') \
        for i,c in enumerate(cutoffs)])
    axes[1].legend(handles=handles)

    ## Manually set max y-lim so legend will fit
    axes[1].set_ylim(0, 150)

    fig.savefig(fn_out, dpi=200, bbox_inches='tight')

def plot_error_scatter(df, fn_out, cutoff=0.2):
    fig, ax = plt.subplots(figsize=(12,12))

    cutoff_one = (df['pers'].to_numpy() >= cutoff) | \
        (df['ref'].to_numpy() >= cutoff) | (df['pan_snp'].to_numpy() >= cutoff)
    df = df.loc[cutoff_one,:]

    pers_zero = df['pers'].to_numpy() == 0
    ref_zero = df['ref'].to_numpy() == 0
    pan_zero = df['pan_snp'].to_numpy() == 0

    ref_only_neg_inf = ref_zero & ~pers_zero & ~pan_zero
    pan_only_neg_inf = pan_zero & ~pers_zero & ~ref_zero
    
    all_nz = ~(ref_zero | pan_zero | pers_zero)

    ref_lfc = np.log2(df.loc[all_nz,'ref'] / df.loc[all_nz,'pers'])
    pan_lfc = np.log2(df.loc[all_nz,'pan_snp'] / df.loc[all_nz,'pers'])
    err = np.abs(pan_lfc) - np.abs(ref_lfc)

    ref_max = np.max(ref_lfc)
    ref_min = np.min(ref_lfc)
    pan_max = np.max(pan_lfc)
    pan_min = np.min(pan_lfc)

    ## Plot normal points
    sns.scatterplot(x=ref_lfc, y=pan_lfc, ax=ax)

    ## no pos only inf points because if one is pos inf then the other is too

    ## Plot pan neg inf points
    ref_lfc = np.log2(
        df.loc[pan_only_neg_inf,'ref'] / df.loc[pan_only_neg_inf,'pers'])
    pan_lfc = [pan_min]*len(ref_lfc)
    sns.scatterplot(x=ref_lfc, y=pan_lfc, ax=ax, marker='v',
        color=sns.color_palette()[0])

    ## Plot ref neg inf points
    pan_lfc = np.log2(
        df.loc[ref_only_neg_inf,'pan_snp'] / df.loc[ref_only_neg_inf,'pers'])
    ref_lfc = [ref_min]*len(pan_lfc)
    sns.scatterplot(x=ref_lfc, y=pan_lfc, ax=ax, marker='<',
        color=sns.color_palette()[0])

    ## Plot y=x line and axes
    plt_max = max(ref_min, ref_max, pan_min, pan_max, key=np.abs)
    pts = np.linspace(-plt_max, plt_max)
    sns.lineplot(x=pts, y=pts, marker='', ls='--', ax=ax, color='black',
        zorder=0)

    ax.axvline(ls='--', color='black', zorder=0)
    ax.axhline(ls='--', color='black', zorder=0)

    max_ax = max(np.abs([*ax.get_xlim(), *ax.get_ylim()]))
    ax.set_xlim(-max_ax, max_ax)
    ax.set_ylim(-max_ax, max_ax)
    ax.set_aspect('equal')

    ax.set_xlabel((r'$\log_2 \left( \frac{\mathrm{TPM}_{\mathrm{ref}}}'
        r'{\mathrm{TPM}_{\mathrm{pers}}} \right)$'))
    ax.set_ylabel((r'$\log_2 \left( \frac{\mathrm{TPM}_{\mathrm{pan}}}'
        r'{\mathrm{TPM}_{\mathrm{pers}}} \right)$'))

    fig.savefig(fn_out, dpi=200, bbox_inches='tight')

def plot_pearson(pearson_df, fn_out):
    fig, ax = plt.subplots(figsize=(12,12))

    sns.pointplot(x='cutoff', y='pearson_r', hue='id', data=pearson_df, ax=ax,
        linestyles='', dodge=True, join=False)

    fig.savefig(fn_out, dpi=200, bbox_inches='tight')

def plot_ratio(df, fn_out):
    fig, ax = plt.subplots(figsize=(12,12))

    for i,gen in enumerate(('ref', 'pan_snp')):
        d = df[['pers', gen]].to_numpy()

        ## calculating lfc(other/pers)
        pers_zero = d[:,0] == 0
        oth_zero = d[:,1] == 0
        pos_inf_idx = pers_zero & ~oth_zero
        neg_inf_idx = oth_zero & ~pers_zero
        both_nz_idx = ~(pers_zero | oth_zero)

        ratio = np.zeros(df.shape[0])
        ratio[both_nz_idx] = np.log2(d[both_nz_idx,1] / d[both_nz_idx,0])
        ratio[pos_inf_idx] = np.max(ratio)
        ratio[neg_inf_idx] = np.min(ratio)

        max_tpm = np.max(d, axis=1)

        ## Plot normal points
        sns.scatterplot(x=max_tpm[both_nz_idx], y=ratio[both_nz_idx], ax=ax,
            label=gen, color=sns.color_palette()[i])
        ## Plot pos inf points
        sns.scatterplot(x=max_tpm[pos_inf_idx], y=ratio[pos_inf_idx], ax=ax,
            label=gen, marker='^', color=sns.color_palette()[i])
        ## Plot neg inf points
        sns.scatterplot(x=max_tpm[neg_inf_idx], y=ratio[neg_inf_idx], ax=ax,
            label=gen, marker='v', color=sns.color_palette()[i])

    ax.set_xscale('log')
    ax.set_xlabel('Max TPM')
    ax.set_ylabel('Log2 Fold Change')

    fig.savefig(fn_out, dpi=200, bbox_inches='tight')

def plot_scatter(df, fn_out):
    n_tx = df.shape[0]
    df = df.reset_index()
    df = df.melt(id_vars=['transcript_id', 'gene_id'], var_name='gen',
        value_name='TPM')

    df.loc[:,'TPM'] += 0.1

    print('Plotting', flush=True)
    fig, ax = plt.subplots(figsize=(18,12))
    sns.scatterplot(x=np.tile(range(n_tx),3), y='TPM', hue='gen', data=df,
        ax=ax, alpha=0.3)
    ax.set_yscale('log')

    print('Saving', flush=True)
    fig.savefig(fn_out, dpi=200, bbox_inches='tight')

def plot_tpm(df, fn_out):
    fig, ax = plt.subplots(figsize=(12,12))

    df.loc[:,['ref', 'pan_snp', 'pers']] += 0.1

    ## Plot ref
    sns.scatterplot(x='pers', y='ref', data=df, label='Reference', ax=ax)
    ## Plot pan
    sns.scatterplot(x='pers', y='pan_snp', data=df, label='Pan', ax=ax)

    ax.set_xlabel('Pers TPM')
    ax.set_ylabel('Ref/Pan TPM')

    ax.set_xscale('log')
    ax.set_yscale('log')

    ref_r2 = (np.corrcoef(df['pers'], df['ref'])[0,1])**2
    pan_r2 = (np.corrcoef(df['pers'], df['pan_snp'])[0,1])**2
    plt.text(x=0.25, y=0.9, s=f'Ref R2: {ref_r2}', c=sns.color_palette()[0],
        transform=ax.transAxes, ha='left')
    plt.text(x=0.25, y=0.875, s=f'Pan R2: {pan_r2}', c=sns.color_palette()[1],
        transform=ax.transAxes, ha='left')

    fig.savefig(fn_out, dpi=200, bbox_inches='tight')

################################################################################
def get_args():
    parser = argparse.ArgumentParser(description='')

    parser.add_argument('-i')
    parser.add_argument('-plt_o')
    parser.add_argument('-o')
    parser.add_argument('-split', action='store_true')

    return(parser.parse_args())

def main():
    args = get_args()

    mpl.rcParams.update({'font.size': 20})

    if args.split:
        df = load_data_split(args.i)
    else:
        df = load_data(args.i)
    plot_error_hists(df, args.plt_o.format('hists'))
    plot_error_scatter(df, args.plt_o.format('scatter'))
    df.to_csv(args.o)

if __name__ == '__main__':
    main()