# COVIDalignmentPhylogeny

Takes the consensus fasta SARS-CoV-2 genome assembly outputs of IlluminaPreprocessAssembly.wdl and NanoporeGuppyAssembly.wdl and a reference genome which should be stored in your Terra workspace data and does the following:

1. concatenates the input fasta genome and the references into a multifasta
2. aligns the sequences using mafft
3. generates a pairwise distance matrix with snp-dists
4. generates a phylogeny with iqtree
5. exports the outputs to your chosen google bucket

The google bucket to which the outputs should be sent should be set as a Terra input as a String in double quotes
