
download_data: data/pacbio.fasta data/nanopore.fasta

data:
	mkdir data

data/pacbio.tar.gz: data
	curl https://s3.amazonaws.com/files.pacb.com/datasets/secondary-analysis/e-coli-k12-P6C4/p6c4_ecoli_RSII_DDR2_with_15kb_cut_E01_1.tar.gz > data/pacbio.tar.gz

data/pacbio.fasta: data/pacbio.tar.gz
	tar xvfz data/pacbio.tar.gz -C data/
	dextract data/E01_1/Analysis_Results/*.bax.h5
	cat data/E01_1/Analysis_Results/*.fasta > data/pacbio.fasta

data/nanopore.fasta: data
	curl https://nanopore.s3.climb.ac.uk/MAP006-1_2D_pass.fasta https://nanopore.s3.climb.ac.uk/MAP006-2_2D_pass.fasta >> data/nanopore.fasta

mapping: pacbio.paf pacbio.long.sam nanopore.paf nanopore.long.sam

pacbio.paf:
	minimap2 -x ava-pb data/pacbio.fasta data/pacbio.fasta > pacbio.paf
pacbio.long.sam:
	minimap2 -x ava-pb -a data/pacbio.fasta data/pacbio.fasta > pacbio.sam
nanopore.paf:
	minimap2 -x ava-ont data/nanopore.fasta data/nanopore.fasta > nanopore.paf
nanopore.long.sam:
	minimap2 -x ava-ont -a data/nanopore.fasta data/nanopore.fasta > nanopore.sam

%.gz: %
	gzip -9 -kf $<

%.bz2: %
	bzip2 -9 -kf $<

%.xz: %
	xz -9 -kf $<

%.bam: %.sam
	samtools view -O bam -o $@ $<

%.cram: %.sam
	samtools view -O cram,no_ref -o $@ $<

%.baf %.baf.gz %.baf.bz2 %.baf.xz: %.paf
	./paf2jpaf.py $< $@

%.short.sam: %.long.sam
	awk -F '\t' '{$9="*"}' -o $@ $<

nanopore.lst: nanopore.paf nanopore.paf.gz nanopore.paf.bz2 nanopore.paf.xz nanopore.baf nanopore.baf.gz nanopore.baf.bz2 nanopore.baf.xz #nanopore.short.sam nanopore.short.bam nanopore.short.cram nanopore.long.sam nanopore.long.bam nanopore.long.cram
	ls -lh $^ > nanopore.lst

pacbio.lst: pacbio.paf pacbio.paf.gz pacbio.paf.bz2 pacbio.paf.xz pacbio.baf pacbio.baf.gz pacbio.baf.bz2 pacbio.baf.xz #pacbio.short.sam pacbio.short.bam pacbio.short.cram pacbio.long.sam pacbio.long.bam pacbio.long.cram
	ls -lh $^ > pacbio.lst

run: nanopore.lst pacbio.lst

.PHONY = clean
clean:
	rm ./pacbio.*
	rm ./nanopore.*

