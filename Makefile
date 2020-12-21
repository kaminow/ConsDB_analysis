################################################################################
####### Replace these paths with their actual locations on your machine ########

# STAR binary
star=./STAR/bin/Linux_x86_64/STAR
# ConsDB main Python script
consdb=./ConsDB/consdb/ConsDB.py

# Location for the variant database files
db_dir=./db_files/
# Location for the parse ConsDB files
consdb_dir=./consdb_files/
# Location for the consensus VCF files
vcf_dir=./vcfs/
# Location for the variant type VCF files
vt_vcf_dir=./vt_vcfs/
# Location for the full personal genomes
pers_vcf_dir=./pers_full_vcfs/
# Location for STAR genome directories
gen_dir=./genomes/
# Location for reads to map
reads_dir=./reads/
# Location for mapping results
map_dir=./mapping/
# Location for all other scripts
scripts_dir=./scripts/

# Location for masked reference FASTA file
h38_fa=${gen_dir}/h38/ref.maskPAR.fa
# Location for masked reference FASTA file
h38_fa_mask=${gen_dir}/h38/ref.maskPAR.fa
# Location for GTF file
h38_gtf=${gen_dir}/h38/genes.gtf
################################################################################

# All individuals used in this analysis
individuals=HG00512 HG00513 HG00731 HG00732 HG00733 NA19238 NA19239 NA19240

all: mask_ref make_all_vcfs make_all_genomes map_everyone \
make_pers_full_vcf_all split_vcfs_to_hom_het find_read_var_overlap \
compare_mapping_all metrics_all metrics_print_all find_et_vt_overlap_all \
get_all_overlap_reads calc_norm_values count_read_categories_all \
make_all_paper_figs

.PHONY: all mask_ref make_all_vcfs make_all_genomes map_everyone \
make_pers_full_vcf_all split_vcfs_to_hom_het find_read_var_overlap \
compare_mapping_all metrics_all metrics_print_all find_et_vt_overlap_all \
get_all_overlap_reads calc_norm_values count_read_categories_all \
make_all_paper_figs

mask_ref:
	betools maskfasta -fi ${h38_fa} -bed ${gen_dir}/h38/par_pos.bed \
	-fo ${h38_fa_mask}

make_all_vcfs:
	${scripts_dir}/make_all_vcf.sh ./id_table.csv ${db_dir} \
	${vcf_dir} ${consdb} ${consdb_dir}

make_all_genomes:
	${scripts_dir}/make_all_genomes.sh ${star} ${h38_fa_mask} ${h38_gtf} \
	${gen_dir} $$(find ${vcf_dir} -name *.vcf)

map_everyone:
	for ind in ${individuals}; do \
		${scripts_dir}/map_individ.sh ${star} $$ind ./id_table.csv \
		${reads_dir} ${gen_dir} ${map_dir}/$${ind}/ && echo $$ind; \
	done

make_pers_full_vcf_all:
	for ind in ${individuals}; do \
		${scripts_dir}/make_full_pers_vcfs.sh $$ind ./id_table.csv \
		${pers_vcf_dir} ${scripts_dir}/make_pers.awk && echo $$ind; \
	done

split_vcfs_to_hom_het:
	${scripts_dir}/split_vcf_to_hom_het_all.sh ./id_table.csv \
	${pers_vcf_dir} ${vcf_dir} ${vt_vcf_dir} \
	${scripts_dir}/split_vcf_to_hom_het.sh \
	${scripts_dir}/split_vcf_to_hom_het.py

find_read_var_overlap:
	for ind in ${individuals}; do \
		${scripts_dir}/find_read_var_overlaps.sh ${vt_vcf_dir}/$${ind}/ \
		${map_dir} $$ind hh_overlap && echo $$ind; \
	done

compare_mapping_all:
	mkdir -p ./sam_frags
	for ind in ${individuals}; do \
		${scripts_dir}/compare_aln_individ_parallel.sh \
		${map_dir}/$${ind}/ ${scripts_dir}/compareAligns.awk \
		./sam_frags/frag_ && echo $$ind; \
	done

metrics_all:
	for ind in ${individuals}; do \
		${scripts_dir}/metrics.sh ${map_dir}/$${ind}/ all_reads_aln_comp_ \
		all_reads_comp_summary_ && echo $$ind; \
	done

metrics_print_all:
	for ind in ${individuals}; do \
		${scripts_dir}/metrics_print.sh ${map_dir}/$${ind}/ \
		all_reads_aln_comp_ reads && echo $$ind; \
	done

find_et_vt_overlap_all:
	for ind in ${individuals}; do \
		${scripts_dir}/err_type_var_type_overlap_hom_het.sh \
		${map_dir}/$${ind}/ reads hh_vt_overlap hh_overlap && echo $$ind; \
	done

get_all_overlap_reads:
	for ind in ${individuals}; do \
		cat ${map_dir}/$${ind}/*/*.hh_overlap | sort -n | \
		uniq > ${map_dir}/$${ind}/all_mapped_overlapping_reads.csv && \
		echo $$ind; \
	done

calc_norm_values:
	${scripts_dir}/calc_paper_norm_values.sh ${map_dir} ${individuals}

count_read_categories_all: $(wildcard ${map_dir}/*/*/*.hh_vt_overlap)
	for ind in ${individuals}; do \
		python ${scripts_dir}/count_read_categories.py \
		-i ${map_dir}/$${ind}/*/*.hh_vt_overlap && echo $$ind & \
	done && wait

make_all_paper_figs:
	python ${scripts_dir}/make_all_paper_figs.py \
	-i ${map_dir}/*/*/[^a]*_var_type_counts.csv \
	-pop ./id_table.csv -norm ${map_dir}/paper_fig_norms.csv \
	-o ./paper_figs/fig
