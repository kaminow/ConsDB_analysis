################################################################################
####### Replace these paths with their actual locations on your machine ########

# Location for the consensus VCF files
vcf_dir=./vcfs/
# Location for the variant type VCF files
vt_vcf_dir=../vt_vcfs/
# Location for the variant type VCF files
vt_vcf_pers_dir=./pers_vt_vcfs/
# Location for the full personal genomes
pers_vcf_dir=./pers_full_vcfs/
# Location for mapping results
map_dir=./mapping/
# Location for overlap information
ov_dir=./overlaps/

################################################################################

# Location for STAR genome directories
gen_dir=./genomes/
# Location for reads to map
reads_dir=./reads/
# Location for all other scripts
scripts_dir=./scripts/

# All individuals used in this analysis
individuals=HG00512 HG00513 HG00731 HG00732 HG00733 NA19238 NA19239 NA19240

all: extract_full_reads_all_het_auto rebase_all_het \
find_full_read_var_overlap_all_het_auto count_full_reads_vcf_overlap_het_auto \
plot_var_overlap_annots

.PHONY: all extract_full_reads_all_het_auto rebase_all_het \
find_full_read_var_overlap_all_het_auto count_full_reads_vcf_overlap_het_auto \
plot_var_overlap_annots

extract_full_reads_all_het_auto: \
	${scripts_dir}/extract_full_reads.sh ${map_dir} \
	${map_dir} ${scripts_dir}/extract_reads_bam.awk reads full_reads

rebase_all_het: \
$(wildcard ${vt_vcf_dir}/*/*/*.vcf)
	${scripts_dir}/rebase_all.sh ${scripts_dir} ${vt_vcf_dir} \
	${vt_vcf_pers_dir} ${individuals}

find_full_read_var_overlap_all_het_auto:
	${scripts_dir}/full_read_overlap.sh ${map_dir} \
	${vt_vcf_pers_dir} ${ov_dir} full_reads full_ov

count_full_reads_vcf_overlap_het_auto: \
$(wildcard ${ov_dir}/*/*/h*.full_ov)
	python ${scripts_dir}/count_vcf_overlaps.py -i $^ \
	-o ${ov_dir}/vcf_overlaps.csv

plot_var_overlap_annots: ${ov_dir}/vcf_overlaps.csv
	python ${scripts_dir}/annotations_plot.py -i $< \
	-o ${ov_dir}/annot_overlap.png
