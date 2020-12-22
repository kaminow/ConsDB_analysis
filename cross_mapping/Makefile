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
vcf_dir=../vcfs/
# Location for the variant type VCF files
vt_vcf_dir=./vt_vcfs/
# Location for the pers variant type VCF files
pers_vt_vcf_dir=./pers_vt_vcfs/
# Location for the full personal genomes
pers_vcf_dir=./pers_full_vcfs/
# Location for mapping results
map_dir=./mapping/
# Location for pers genome mapping results
pers_map_dir=./pers_mapping/

# Location for masked reference FASTA file
h38_fa=${gen_dir}/h38/ref.maskPAR.fa
# Location for masked reference FASTA file
h38_fa_mask=${gen_dir}/h38/ref.maskPAR.fa
# Location for GTF file
h38_gtf=${gen_dir}/h38/genes.gtf
################################################################################

# Location for STAR genome directories
gen_dir=./genomes/
# Location for reads to map
reads_dir=./reads/
# Location for all other scripts
scripts_dir=./scripts/

# All individuals used in this analysis
individuals=HG00512 HG00513 HG00731 HG00732 HG00733 NA19238 NA19239 NA19240

all: cons pers

cons: map_cross_all split_to_hom_het_all_cross \
find_read_var_overlap_all_cross_auto_hom_het \
compare_mapping_all_parallel_cross_auto_hom_het metrics_all_cross_auto \
metrics_print_all_all_reads_cross_auto \
find_et_vt_overlap_all_reads_all_cross_auto_hom_het \
get_all_overlap_reads_cross_auto_all count_hom_het_cross_auto_all

pers: map_cross_pers_all split_to_hom_het_all_cross_pers \
find_read_var_overlap_all_cross_pers_auto_hom_het \
compare_mapping_all_parallel_cross_pers_auto_hom_het \
metrics_all_cross_pers_auto metrics_print_all_all_reads_cross_pers_auto \
find_et_vt_overlap_all_reads_all_cross_pers_auto_hom_het \
get_all_overlap_reads_cross_pers_auto_all \
count_hom_het_cross_pers_auto_all

.PHONY: all cons pers map_cross_all split_to_hom_het_all_cross \
find_read_var_overlap_all_cross_auto_hom_het \
compare_mapping_all_parallel_cross_auto_hom_het metrics_all_cross_auto \
metrics_print_all_all_reads_cross_auto \
find_et_vt_overlap_all_reads_all_cross_auto_hom_het \
get_all_overlap_reads_cross_auto_all count_hom_het_cross_auto_all \
map_cross_pers_all split_to_hom_het_all_cross_pers \
find_read_var_overlap_all_cross_pers_auto_hom_het \
compare_mapping_all_parallel_cross_pers_auto_hom_het \
metrics_all_cross_pers_auto metrics_print_all_all_reads_cross_pers_auto \
find_et_vt_overlap_all_reads_all_cross_pers_auto_hom_het \
get_all_overlap_reads_cross_pers_auto_all \
count_hom_het_cross_pers_auto_all

map_cross_all:
	${scripts_dir}/map_cross_all.sh ${scripts_dir}/cross_map.sh ${star} \
	${reads_dir} ${gen_dir} ${map_dir} ./id_table.csv \
	../mapping/ AFR AMR EAS AFR_YRI AMR_PUR EAS_CHS

split_to_hom_het_all_cross:
	${scripts_dir}/split_vcf_to_hom_het_cross.sh \
	${scripts_dir}/split_vcf_to_hom_het.sh ${pers_vcf_dir} ${vt_vcf_dir} \
	${scripts_dir}/split_vcf_to_hom_het.py ${vcf_dir} \
	./id_table.csv ../vt_vcfs/

find_read_var_overlap_all_cross_auto_hom_het:
	${scripts_dir}/find_read_var_overlaps_hom_het_cross.sh \
	${scripts_dir}/find_read_var_overlaps_hom_het.sh ${vt_vcf_dir} \
	${map_dir} ./id_table.csv

compare_mapping_all_parallel_cross_auto_hom_het:
	${scripts_dir}/compare_aln_individ_parallel_cross.sh \
	${scripts_dir}/compare_aln_individ_parallel.sh ${map_dir} \
	${scripts_dir}/compareAligns.awk ./sam_frags/frag_ ./id_table.csv

metrics_all_cross_auto:
	${scripts_dir}/metrics_cross.sh ${scripts_dir}/metrics.sh \
	${map_dir} all_reads_aln_comp_ all_reads_comp_summary_ ./id_table.csv

metrics_print_all_all_reads_cross_auto:
	${scripts_dir}/metrics_cross.sh ${scripts_dir}/metrics_print.sh \
	${map_dir} all_reads_aln_comp_ reads ./id_table.csv

find_et_vt_overlap_all_reads_all_cross_auto_hom_het:
	for ind in ${individuals}; do \
		${scripts_dir}/err_type_var_type_overlap_hom_het.sh \
		${map_dir}/$${ind}/ reads hh_vt_overlap hh_overlap && echo $$ind; \
	done

get_all_overlap_reads_cross_auto_all:
	for ind in ${individuals}; do \
		cat ${map_dir}/$${ind}/*/*.hh_overlap | sort -n | \
		uniq > ${map_dir}/$${ind}/all_mapped_overlapping_reads.csv && \
		echo $$ind; \
	done

count_hom_het_cross_auto_all:
	for ind in ${individuals}; do \
		time -p python ${scripts_dir}/plot_bg_nonbg_hom_het.py \
		-i ${map_dir}/$${ind}/*/*.hh_vt_overlap \
		-tab ${map_dir}/$${ind}/bg_nonbg_hom_het.csv \
		-dist_tab ${map_dir}/$${ind}/bg_nonbg_hom_het_dist.csv && \
		echo $$ind; \
	done

map_cross_pers_all:
	${scripts_dir}/map_cross_pers_all.sh ${scripts_dir}/cross_map.sh ${star} \
	${reads_dir} ${gen_dir} ${pers_map_dir} ../mapping/ \
	${individuals}

split_to_hom_het_all_cross_pers:
	${scripts_dir}/split_vcf_to_hom_het_cross_pers.sh \
	${scripts_dir}/split_vcf_to_hom_het.sh ${pers_vcf_dir} \
	${pers_vt_vcf_dir} ${scripts_dir}/split_vcf_to_hom_het.py \
	${vcf_dir} ${vt_vcf_dir} ${individuals}

find_read_var_overlap_all_cross_pers_auto_hom_het:
	${scripts_dir}/find_read_var_overlaps_hom_het_cross_pers.sh \
	${scripts_dir}/find_read_var_overlaps_hom_het.sh ${pers_vt_vcf_dir} \
	${pers_map_dir} ${individuals}

compare_mapping_all_parallel_cross_pers_auto_hom_het:
	${scripts_dir}/compare_aln_individ_parallel_cross_pers.sh \
	${scripts_dir}/compare_aln_individ_parallel.sh ${pers_map_dir} \
	${scripts_dir}/compareAligns.awk ./sam_frags/frag_ ${individuals}

metrics_all_cross_pers_auto:
	${scripts_dir}/metrics_cross_pers.sh ${scripts_dir}/metrics.sh \
	${pers_map_dir} all_reads_aln_comp_ all_reads_comp_summary_ ${individuals}

metrics_print_all_all_reads_cross_pers_auto:
	${scripts_dir}/metrics_cross_pers.sh ${scripts_dir}/metrics_print.sh \
	${pers_map_dir} all_reads_aln_comp_ reads ${individuals}

find_et_vt_overlap_all_reads_all_cross_pers_auto_hom_het:
	for ind in ${individuals}; do \
		${scripts_dir}/err_type_var_type_overlap_hom_het.sh \
		${pers_map_dir}/$${ind}/ reads hh_vt_overlap hh_overlap && echo $$ind; \
	done

get_all_overlap_reads_cross_pers_auto_all:
	for ind in ${individuals}; do \
		cat ${pers_map_dir}/$${ind}/*/*.hh_overlap | sort -n | uniq \
		> ${pers_map_dir}/$${ind}/all_mapped_overlapping_reads.csv \
		&& echo $$ind; \
	done

count_hom_het_cross_pers_auto_all:
	for ind in ${individuals}; do \
		python ${scripts_dir}/plot_bg_nonbg_hom_het.py \
		-i ${pers_map_dir}/$${ind}/*/*.hh_vt_overlap \
		-tab ${pers_map_dir}/$${ind}/bg_nonbg_hom_het.csv \
		-dist_tab ${pers_map_dir}/$${ind}/bg_nonbg_hom_het_dist.csv \
		&& echo $$ind; \
	done
