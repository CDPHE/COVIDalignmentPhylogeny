# COVIDalignmentPhylogeny

Takes the consensus fasta SARS-CoV-2 genome assembly outputs of IlluminaPreprocessAssembly.wdl and NanoporeGuppyAssembly.wdl and a reference genome which should be stored in your Terra workspace data and does the following:

1. concatenates the input fasta genome and the references into a multifasta
2. aligns the sequences using mafft
3. generates a pairwise distance matrix with snp-dists
4. generates a phylogeny with iqtree
5. exports the outputs to your chosen google bucket

The google bucket to which the outputs should be sent should be set as a Terra input as a String in double quotes

External tools used in this workflow were from publicly available Docker images:
1. General utilities docker images: ubuntu and theiagen/utility:1.0
2. mafft: Katoh, Misawa, Kuma, Miyata 2002 (Nucleic Acids Res. 30:3059-3066)
MAFFT: a novel method for rapid multiple sequence alignment based on fast Fourier transform.
(describes the FFT-NS-1, FFT-NS-2 and FFT-NS-i strategies)
  docker image: staphb/mafft:7.475
3. snp-dists: https://github.com/tseemann/snp-dists
  docker image: staphb/snp-dists:0.6.2
4. iqtree: Olga Chernomor, Arndt von Haeseler, Bui Quang Minh, Terrace Aware Data Structure for Phylogenomic Inference from Supermatrices, Systematic Biology, Volume 65, Issue 6, November 2016, Pages 997–1008, https://doi.org/10.1093/sysbio/syw037
  docker image: staphb/iqtree:1.6.7
