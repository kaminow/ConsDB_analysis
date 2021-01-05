################################################################################
####### Replace these paths with their actual locations on your machine ########

# STAR binary
star=../STAR/bin/Linux_x86_64/STAR
# ConsDB main Python script
consdb=../ConsDB/consdb/ConsDB.py

# Location for the consensus VCF files
vcf_dir=./vcfs/
# Location for the variant type VCF files
map_dir=./mapping/
# Location for RSEM results
rsem_dir=./rsem/

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

# Reference genome
ref_tx_gen=${gen_dir}/ref/
# Pan genome
pan_snp_gen=${gen_dir}/pan/
# SNP HG00512 STAR genome
snp_hg00512_gen=${gen_dir}/hg00512/

all: make_vcfs make_star_genomes make_rsem_genomes map_all split_bam_all \
rsem_all diff_exp_all extract_all plot_hgsv_hg00512
make_vcfs: make_pan_snp_vcf make_snp_hg00512_vcf
make_star_genomes: make_ref_genome make_pan_snp_genome make_snp_hg00512_genome
make_rsem_genomes: make_ref_rsem_genome make_pan_snp_rsem_gen \
make_snp_hg00512_rsem_genome
map_all: map_tx_hg00512_ref map_tx_hg00512_pan_snp map_tx_hg00512_pers
split_bam_all: split_bam_hg00512_ref split_bam_hg00512_pan_snp \
split_bam_hg00512_pers
rsem_all: rsem_hg00512_ref rsem_hg00512_pan_snp rsem_hg00512_pers \
rsem_hg00512_ref_split rsem_hg00512_pan_snp_split rsem_hg00512_pers_split
diff_exp_all: diff_exp_rsem_hg00512_pan_pers_tx \
diff_exp_rsem_hg00512_pan_ref_tx diff_exp_rsem_hg00512_ref_pers_tx
extract_all: extract_bam_reg_hg00512_aldh3a2_tx extract_gtf_annots_aldh3a2 \
extract_pan_snp_vars_aldh3a2 extract_HG00512_vars_aldh3a2

.PHONY: all make_vcfs make_star_genomes make_rsem_genomes map_all \
split_bam_all rsem_all diff_exp_all extract_all make_pan_snp_vcf \
make_snp_hg00512_vcf make_ref_genome make_pan_snp_genome \
make_snp_hg00512_genome make_ref_rsem_genome make_pan_snp_rsem_gen \
make_snp_hg00512_rsem_genome map_tx_hg00512_ref map_tx_hg00512_pan_snp \
map_tx_hg00512_pers split_bam_hg00512_ref split_bam_hg00512_pan_snp \
split_bam_hg00512_pers rsem_hg00512_ref rsem_hg00512_pan_snp rsem_hg00512_pers \
rsem_hg00512_ref_split rsem_hg00512_pan_snp_split rsem_hg00512_pers_split \
diff_exp_rsem_hg00512_pan_pers_tx diff_exp_rsem_hg00512_pan_ref_tx \
diff_exp_rsem_hg00512_ref_pers_tx extract_bam_reg_hg00512_aldh3a2_tx \
extract_gtf_annots_aldh3a2 extract_pan_snp_vars_aldh3a2 \
extract_HG00512_vars_aldh3a2 plot_hgsv_hg00512

make_pan_snp_vcf: ../vcfs/pan/pan.vcf
	mkdir -p ${vcf_dir}/pan_snp/
	awk 'substr($$1,1,1)=="#" || length($$4)==length($$5)' $< \
	> ${vcf_dir}/pan_snp/pan_snp.vcf
	bgzip -c ${vcf_dir}/pan_snp/pan_snp.vcf > ${vcf_dir}/pan_snp/pan_snp.vcf.gz
	bcftools index ${vcf_dir}/pan_snp/pan_snp.vcf.gz

make_snp_hg00512_vcf: ../vcfs/homoz/HG00512/HG00512.vcf
	mkdir -p ${vcf_dir}/HG00512_snp/
	awk 'substr($$1,1,1)=="#" || length($$4)==length($$5)' $< \
	> ${vcf_dir}/HG00512_snp/HG00512_snp.vcf
	bgzip -c ${vcf_dir}/HG00512_snp/HG00512_snp.vcf \
	> ${vcf_dir}/HG00512_snp/HG00512_snp.vcf.gz
	bcftools index ${vcf_dir}/HG00512_snp/HG00512_snp.vcf.gz

make_snp_hg00512_genome: ${vcf_dir}/HG00512_snp/HG00512_snp.vcf
	mkdir -p ${snp_hg00512_gen}
	${STAR} --runMode genomeGenerate --runThreadN 40 \
	--genomeFastaFiles ${h38_fa_mask} --genomeTransformType Haploid \
	--genomeTransformVCF $< --sjdbGTFfile ${h38_gtf} \
	--genomeDir ${snp_hg00512_gen} --outFileNamePrefix ${snp_hg00512_gen}
	[[ -d ${snp_hg00512_gen}/normalGenome ]] && \
	rmdir ${snp_hg00512_gen}/normalGenome
	ln -sf ${ref_gen} ${snp_hg00512_gen}/normalGenome
	sed -i 's/Haploid$/None/' ${snp_hg00512_gen}/genomeParameters.txt

make_snp_hg00512_rsem_genome: ${vcf_dir}/HG00512_snp/HG00512_snp.vcf \
${vcf_dir}/HG00512_snp/HG00512_snp.vcf.gz \
${vcf_dir}/HG00512_snp/HG00512_snp.vcf.gz.csi ${h38_fa_mask} ${h38_gtf}
	bcftools consensus -f ${h38_fa_mask} -o ${snp_hg00512_gen}/snp_hg00512.fa \
	$<.gz
	rsem-prepare-reference --gtf ${h38_gtf} ${snp_hg00512_gen}/snp_hg00512.fa \
	${snp_hg00512_gen}/snp_hg00512

make_ref_genome:
	mkdir -p ${ref_tx_gen}
	${STAR} --runMode genomeGenerate --runThreadN 40 \
	--genomeFastaFiles ${h38_fa_mask} --sjdbGTFfile ${h38_gtf} \
	--genomeDir ${ref_tx_gen} --outFileNamePrefix ${ref_tx_gen}

make_pan_snp_genome: ${vcf_dir}/pan_snp/pan_snp.vcf
	mkdir -p ${pan_snp_gen}
	${STAR} --runMode genomeGenerate --runThreadN 40 \
	--genomeFastaFiles ${h38_fa_mask} --genomeTransformType Haploid \
	--genomeTransformVCF $< --sjdbGTFfile ${h38_gtf} \
	--genomeDir ${pan_snp_gen} --outFileNamePrefix ${pan_snp_gen}
	[[ -d ${pan_snp_gen}/normalGenome ]] && rmdir ${pan_snp_gen}/normalGenome
	ln -sf ${ref_gen} ${pan_snp_gen}/normalGenome
	sed -i 's/Haploid$/None/' ${pan_snp_gen}/genomeParameters.txt

make_pan_snp_rsem_gen: ${vcf_dir}/pan_snp/pan_snp.vcf \
${vcf_dir}/pan_snp/pan_snp.vcf.gz \
${vcf_dir}/pan_snp/pan_snp.vcf.gz.csi ${h38_fa_mask} ${h38_gtf}
	bcftools consensus -f ${h38_fa_mask} -o ${pan_snp_gen}/pan_snp.fa $<.gz
	rsem-prepare-reference --gtf ${h38_gtf} ${pan_snp_gen}/pan_snp.fa \
	${pan_snp_gen}/pan_snp

make_ref_rsem_genome: ${h38_fa_mask}
	rsem-prepare-reference --gtf ${h38_gtf} ${h38_fa_mask} ${ref_tx_gen}/ref

map_tx_hg00512_ref: ${reads_dir}/HG00512*
	${scripts_dir}/map_tx.sh ${STAR} ${reads_dir} HG00512 \
	${ref_tx_gen} ${map_dir}/hg00512/ref_tx/

map_tx_hg00512_pan_snp: ${reads_dir}/HG00512*
	${scripts_dir}/map_tx.sh ${STAR} ${reads_dir} HG00512 \
	${pan_snp_gen} ${map_dir}/hg00512/pan_snp_tx/

map_tx_hg00512_pers: ${reads_dir}/HG00512*
	${scripts_dir}/map_tx.sh ${STAR} ${reads_dir} HG00512 \
	${snp_hg00512_gen} ${map_dir}/hg00512/pers_tx/

rsem_hg00512_ref: \
$(wildcard ${map_dir}/hg00512/ref_tx/*/Aligned.toTranscriptome.out.bam)
	for fn in $^; do \
		r=$$(basename $$(dirname $$fn)); \
		out_dir=${rsem_dir}/hg00512/ref_tx/$${r}; \
		mkdir -p $$out_dir; \
		rsem-calculate-expression --bam --paired-end $$fn ${ref_tx_gen}/ref \
		$${out_dir}/$${r} && echo $$r; \
	done

rsem_hg00512_pan_snp: \
$(wildcard ${map_dir}/hg00512/pan_snp_tx/*/Aligned.toTranscriptome.out.bam)
	#$$ -l m_mem_free=100G
	for fn in $^; do \
		r=$$(basename $$(dirname $$fn)); \
		out_dir=${rsem_dir}/hg00512/pan_snp_tx/$${r}; \
		mkdir -p $$out_dir; \
		rsem-calculate-expression --bam --paired-end $$fn \
		${pan_snp_gen}/pan_snp $${out_dir}/$${r} && echo $$r; \
	done

rsem_hg00512_pers: \
$(wildcard ${map_dir}/hg00512/pers_tx/*/Aligned.toTranscriptome.out.bam)
	#$$ -l m_mem_free=100G
	for fn in $^; do \
		r=$$(basename $$(dirname $$fn)); \
		out_dir=${rsem_dir}/hg00512/pers_tx/$${r}; \
		mkdir -p $$out_dir; \
		rsem-calculate-expression --bam --paired-end $$fn \
		${snp_hg00512_gen}/snp_hg00512 $${out_dir}/$${r} && echo $$r; \
	done

split_bam_hg00512_ref: \
${map_dir}/hg00512/ref_tx/Rep1/Aligned.toTranscriptome.out.bam
	${scripts_dir}/split_hgsv_bam.sh $< ${map_dir}/hg00512/ref_tx_split \
	${scripts_dir}/split_bam.py

split_bam_hg00512_pan_snp: \
${map_dir}/hg00512/pan_snp_tx/Rep1/Aligned.toTranscriptome.out.bam
	${scripts_dir}/split_hgsv_bam.sh $< ${map_dir}/hg00512/pan_snp_tx_split \
	${scripts_dir}/split_bam.py

split_bam_hg00512_pers: \
${map_dir}/hg00512/pers_tx/Rep1/Aligned.toTranscriptome.out.bam
	${scripts_dir}/split_hgsv_bam.sh $< ${map_dir}/hg00512/pers_tx_split \
	${scripts_dir}/split_bam.py

rsem_hg00512_ref_split: \
$(wildcard ${map_dir}/hg00512/ref_tx_split/*/Aligned.toTranscriptome.out.bam)
	for fn in $^; do \
		r=$$(basename $$(dirname $$fn)); \
		out_dir=${rsem_dir}/hg00512/ref_tx_split/$${r}; \
		mkdir -p $$out_dir; \
		rsem-calculate-expression --bam --paired-end $$fn ${ref_tx_gen}/ref \
		$${out_dir}/$${r} && echo $$r; \
	done

rsem_hg00512_pan_snp_split: \
$(wildcard ${map_dir}/hg00512/pan_snp_tx_split/*/Aligned.toTranscriptome.out.bam)
	for fn in $^; do \
		r=$$(basename $$(dirname $$fn)); \
		out_dir=${rsem_dir}/hg00512/pan_snp_tx_split/$${r}; \
		mkdir -p $$out_dir; \
		rsem-calculate-expression --bam --paired-end $$fn \
		${pan_snp_gen}/pan_snp $${out_dir}/$${r} && echo $$r; \
	done

rsem_hg00512_pers_split: \
$(wildcard ${map_dir}/hg00512/pers_tx_split/*/Aligned.toTranscriptome.out.bam)
	#$$ -l m_mem_free=100G
	for fn in $^; do \
		r=$$(basename $$(dirname $$fn)); \
		out_dir=${rsem_dir}/hg00512/pers_tx_split/$${r}; \
		mkdir -p $$out_dir; \
		rsem-calculate-expression --bam --paired-end $$fn \
		${snp_hg00512_gen}/snp_hg00512 $${out_dir}/$${r} && echo $$r; \
	done

diff_exp_rsem_hg00512_pan_pers_tx:
	Rscript ${scripts_dir}/rsem_deseq.R ${rsem_dir}/hg00512/ \
	${rsem_dir}/hg00512/deseq_pan_pers_tx.csv \
	pers_tx_split pan_snp_tx_split Rep1 Rep2 isoforms.results && \
	Rscript ${scripts_dir}/filt_deseq_res.R \
	${rsem_dir}/hg00512/deseq_pan_pers_tx.csv \
	${rsem_dir}/hg00512/deseq_pan_pers_sig_tx.csv \
	${scripts_dir}/deseq_utils.R

diff_exp_rsem_hg00512_pan_ref_tx:
	Rscript ${scripts_dir}/rsem_deseq.R ${rsem_dir}/hg00512/ \
	${rsem_dir}/hg00512/deseq_pan_ref_tx.csv \
	ref_tx_split pan_snp_tx_split Rep1 Rep2 isoforms.results && \
	Rscript ${scripts_dir}/filt_deseq_res.R \
	${rsem_dir}/hg00512/deseq_pan_ref_tx.csv \
	${rsem_dir}/hg00512/deseq_pan_ref_sig_tx.csv \
	${scripts_dir}/deseq_utils.R

diff_exp_rsem_hg00512_ref_pers_tx:
	Rscript ${scripts_dir}/rsem_deseq.R ${rsem_dir}/hg00512/ \
	${rsem_dir}/hg00512/deseq_ref_pers_tx.csv \
	pers_tx_split ref_tx_split Rep1 Rep2 isoforms.results && \
	Rscript ${scripts_dir}/filt_deseq_res.R \
	${rsem_dir}/hg00512/deseq_ref_pers_tx.csv \
	${rsem_dir}/hg00512/deseq_ref_pers_sig_tx.csv \
	${scripts_dir}/deseq_utils.R

extract_bam_reg_hg00512_aldh3a2_tx: \
$(wildcard ${map_dir}/hg00512/*tx/Rep1/Aligned.out.sortedByCoord.out.bam)
	mkdir -p ${map_dir}/hg00512/gene_analysis/aldh3a2
	for fn in $^; do \
		IFS="/" read -ra fn_split <<< $$fn; \
		l=$${#fn_split[@]}; \
		gen=$${fn_split[$$(($$l - 3))]}; \
		gen=$$(sed 's/_tx/_gen/' <<< $$gen); \
		out_fn=${map_dir}/hg00512/gene_analysis/aldh3a2/$${gen}_full.bam; \
		echo $$fn $$out_fn; \
		samtools view -h -b -o $$out_fn $$fn chr17:19648136-19685760 && \
		samtools index $$out_fn; \
	done

extract_gtf_annots_aldh3a2:
	grep -F 'ENST00000582991.5' ${gtf} > \
	${map_dir}/hg00512/gene_analysis/aldh3a2/transcripts.gtf
	grep -F 'ENST00000472059.5' ${gtf} >> \
	${map_dir}/hg00512/gene_analysis/aldh3a2/transcripts.gtf

extract_pan_snp_vars_aldh3a2:
	bcftools view ${vcf_dir}/pan_snp/pan_snp.vcf.gz chr17:19648136-19685760 \
	> ${vcf_dir}/pan_snp/aldh3a2.vcf

extract_HG00512_vars_aldh3a2:
	bcftools view ${vcf_dir}/HG00512_snp/HG00512_snp.vcf.gz chr17:19648136-19685760 \
	> ${vcf_dir}/HG00512_snp/aldh3a2.vcf

plot_hgsv_hg00512:
	python ${scripts_dir}/hgsv_lfc.py -i ${rsem_dir}/hg00512/ \
	-plt_o ${rsem_dir}/hg00512/tpm_comp_error_{}.png \
	-o ${rsem_dir}/hg00512/tpm_comp.csv
