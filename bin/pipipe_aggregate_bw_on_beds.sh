
# ChIP-Seq pipeline from pipipe: https://github.com/bowhan/pipipe.git
# pipipe: https://github.com/bowhan/pipipe.git
# An integrated pipeline for small RNA analysis 
# from small RNA Seq, RNASeq, CAGE/Degradome, ChIP-Seq and Genomic-Seq
# Wei Wang (wei.wang2@umassmed.edu)
# Bo W Han (bo.han@umassmed.edu, bowhan@me.com)
# the Zamore lab and the Weng lab
# University of Massachusetts Medical School

OUTDIR=$1
EXT_LEN=$2
BIGWIG_FILES="$3"
SEED=${RANDOM}${RANDOM}${RANDOM}${RANDOM} # random name
para_file=$OUTDIR/$INTERSECT_OUTDIR/${SEED}.intersect.para
. $COMMON_FOLDER/genomic_features # reading the information to intersect with, as well as some other annotation files
if [ "$#" == "3" ]; 
then
	for t in ${TARGETS[@]}
	do \
		echo "bwtool agg ${EXT_LEN}:${EXT_LEN} -starts -long-form=${t}start,'Poisson Pvalue,Fold Enriched,logLR' ${!t} $BIGWIG_FILES $OUTDIR/${t}.starts.txt && Rscript --slave ${PIPELINE_DIRECTORY}/bin/pipipe_draw_aggregate.R $OUTDIR/${t}.starts.txt $PDF_DIR/${t}.starts $t" >> $para_file
		echo "bwtool agg ${EXT_LEN}:${EXT_LEN} -ends -long-form=${t}end,'Poisson Pvalue,Fold Enriched,logLR' ${!t} $BIGWIG_FILES $OUTDIR/${t}.ends.txt && Rscript --slave ${PIPELINE_DIRECTORY}/bin/pipipe_draw_aggregate.R $OUTDIR/${t}.ends.txt $PDF_DIR/${t}.ends $t" >> $para_file
		echo "bwtool agg ${EXT_LEN}:${EXT_LEN}:${EXT_LEN} -long-form=${t}meta,'Poisson Pvalue,Fold Enriched,logLR' ${!t} $BIGWIG_FILES $OUTDIR/${t}.meta.txt && Rscript --slave ${PIPELINE_DIRECTORY}/bin/pipipe_draw_aggregate.R $OUTDIR/${t}.meta.txt  $PDF_DIR/${t}.meta $t" >> $para_file
	done
	ParaFly -c $para_file -CPU $CPU -failed_cmds ${para_file}.failedCommands 1>&2 && \
	rm -rf ${para_file}*

	PDFs=""
	for t in ${TARGETS[@]}
	do \
			PDFs=${PDFs}" "$PDF_DIR/${t}.starts.pdf" "$PDF_DIR/${t}.ends.pdf" "$PDF_DIR/${t}.meta.pdf
	done

	gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=$PDF_DIR/${PREFIX}.features.pdf ${PDFs} && \
	rm -rf ${PDFs} || \
	echo2 "Failed to merge pdf from features intersecting... check gs... Or use your favorarite pdf merge tool by editing line$LINENO in $0" "warning"

else
	shift; shift; shift
	
	t=`basename $1` 
	echo "bwtool agg ${EXT_LEN}:${EXT_LEN} -starts -long-form=\"condition1_starts,${SAMPLE_A_NAME}_Poisson_Pvalue,${SAMPLE_A_NAME}_Fold_Enriched,${SAMPLE_A_NAME}_logLR,${SAMPLE_B_NAME}_Poisson_Pvalue,${SAMPLE_B_NAME}_Fold_Enriched,${SAMPLE_B_NAME}_logLR\" ${1} $BIGWIG_FILES $OUTDIR/${t%.bed}.starts.txt && Rscript --slave ${PIPELINE_DIRECTORY}/bin/pipipe_draw_aggregate.R   $OUTDIR/${t%.bed}.starts.txt $PDF_DIR/${t%.bed}.starts. ${t}.TSS" >> $para_file
	echo "bwtool agg ${EXT_LEN}:${EXT_LEN} -ends -long-form=\"condition1_ends,${SAMPLE_A_NAME}_Poisson_Pvalue,${SAMPLE_A_NAME}_Fold_Enriched,${SAMPLE_A_NAME}_logLR,${SAMPLE_B_NAME}_Poisson_Pvalue,${SAMPLE_B_NAME}_Fold_Enriched,${SAMPLE_B_NAME}_logLR\" ${1} $BIGWIG_FILES $OUTDIR/${t%.bed}.ends.txt && Rscript --slave ${PIPELINE_DIRECTORY}/bin/pipipe_draw_aggregate.R       $OUTDIR/${t%.bed}.ends.txt   $PDF_DIR/${t%.bed}.ends ${t}.TES" >> $para_file
	echo "bwtool agg ${EXT_LEN}:${EXT_LEN}:${EXT_LEN} -long-form=\"condition1_meta,${SAMPLE_A_NAME}_Poisson_Pvalue,${SAMPLE_A_NAME}_Fold_Enriched,${SAMPLE_A_NAME}_logLR,${SAMPLE_B_NAME}_Poisson_Pvalue,${SAMPLE_B_NAME}_Fold_Enriched,${SAMPLE_B_NAME}_logLR\" ${1} $BIGWIG_FILES $OUTDIR/${t%.bed}.meta.txt && Rscript --slave ${PIPELINE_DIRECTORY}/bin/pipipe_draw_aggregate.R  $OUTDIR/${t%.bed}.meta.txt   $PDF_DIR/${t%.bed}.meta ${t}.mega" >> $para_file
	
	t=`basename $2`
	echo "bwtool agg ${EXT_LEN}:${EXT_LEN} -starts -long-form=\"condition2_starts,${SAMPLE_A_NAME}_Poisson_Pvalue,${SAMPLE_A_NAME}_Fold_Enriched,${SAMPLE_A_NAME}_logLR,${SAMPLE_B_NAME}_Poisson_Pvalue,${SAMPLE_B_NAME}_Fold_Enriched,${SAMPLE_B_NAME}_logLR\" ${2} $BIGWIG_FILES $OUTDIR/${t%.bed}.starts.txt && Rscript --slave ${PIPELINE_DIRECTORY}/bin/pipipe_draw_aggregate.R   $OUTDIR/${t%.bed}.starts.txt $PDF_DIR/${t%.bed}.starts. ${t}.TSS" >> $para_file
	echo "bwtool agg ${EXT_LEN}:${EXT_LEN} -ends -long-form=\"condition2_ends,${SAMPLE_A_NAME}_Poisson_Pvalue,${SAMPLE_A_NAME}_Fold_Enriched,${SAMPLE_A_NAME}_logLR,${SAMPLE_B_NAME}_Poisson_Pvalue,${SAMPLE_B_NAME}_Fold_Enriched,${SAMPLE_B_NAME}_logLR\" ${2} $BIGWIG_FILES $OUTDIR/${t%.bed}.ends.txt && Rscript --slave ${PIPELINE_DIRECTORY}/bin/pipipe_draw_aggregate.R       $OUTDIR/${t%.bed}.ends.txt   $PDF_DIR/${t%.bed}.ends ${t}.TES" >> $para_file
	echo "bwtool agg ${EXT_LEN}:${EXT_LEN}:${EXT_LEN} -long-form=\"condition2_meta,${SAMPLE_A_NAME}_Poisson_Pvalue,${SAMPLE_A_NAME}_Fold_Enriched,${SAMPLE_A_NAME}_logLR,${SAMPLE_B_NAME}_Poisson_Pvalue,${SAMPLE_B_NAME}_Fold_Enriched,${SAMPLE_B_NAME}_logLR\" ${2} $BIGWIG_FILES $OUTDIR/${t%.bed}.meta.txt && Rscript --slave ${PIPELINE_DIRECTORY}/bin/pipipe_draw_aggregate.R  $OUTDIR/${t%.bed}.meta.txt   $PDF_DIR/${t%.bed}.meta ${t}.mega" >> $para_file

	ParaFly -c $para_file -CPU $CPU -failed_cmds ${para_file}.failedCommands 1>&2 && \
	rm -rf ${para_file}*
	
fi