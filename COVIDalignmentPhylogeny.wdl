version 1.0

workflow COVIDalignmentPhylogeny {

    input {
        Array[File] assembly_fastas
        File covid_genome
        String out_dir
    }

    call concatenate_add_ref {
        input:
            assembly_fastas = assembly_fastas,
            ref = covid_genome
    }

    call mafft {
        input:
            multifasta = concatenate_add_ref.cat_fastas_ref
    }

    call snp_dists {
        input:
            alignment = mafft.alignment
    }

    call iqtree {
        input:
            alignment = mafft.alignment
    }

    call transfer_outputs {
        input:
            out_dir = out_dir,
            alignment = mafft.alignment,
            snp_matrix = snp_dists.snp_matrix,
            iqtree_report = iqtree.iqtree_report,
            iqtree_treefile = iqtree.iqtree_treefile,
            iqtree_log = iqtree.iqtree_log
    }

    output {
    
        File cat_fastas_ref = concatenate_add_ref.cat_fastas_ref
        File alignment = mafft.alignment
        File snp_matrix = snp_dists.snp_matrix
        File iqtree_report = iqtree.iqtree_report
        File iqtree_treefile = iqtree.iqtree_treefile
        File iqtree_log = iqtree.iqtree_log
    }
}

task concatenate_add_ref {

    input {
        Array[File] assembly_fastas
        File ref
    }

    command <<<

        cat ~{sep=" " assembly_fastas} ~{ref} > concatenate_assemblies_ref.fasta

    >>>

    output {

        File cat_fastas_ref = "concatenate_assemblies_ref.fasta"

    }

    runtime {
        docker: "ubuntu"
        memory: "1 GB"
        cpu:    1
        disks: "local-disk 375 LOCAL"
        dx_instance_type: "mem1_ssd1_v2_x2"
    }
}

task mafft {

    input {

        File multifasta
    }

    command {

        mafft ${multifasta} > aligned_genomes.fasta

    }

    output {

        File alignment = "aligned_genomes.fasta"

    }

    runtime {
        cpu:    2
        memory:    "8 GiB"
        disks:    "local-disk 1 HDD"
        bootDiskSizeGb:    10
        preemptible:    0
        maxRetries:    0
        docker:    "staphb/mafft:7.475"
    }
}

task snp_dists {

    input {

        File alignment
    }

    command {

        snp-dists ${alignment} > snp-dists_matrix.tsv

    }

    output {

        File snp_matrix = "snp-dists_matrix.tsv"

    }

    runtime {
        cpu:    2
        memory:    "8 GiB"
        disks:    "local-disk 1 HDD"
        bootDiskSizeGb:    10
        preemptible:    0
        maxRetries:    0
        docker:    "staphb/snp-dists:0.6.2"
    }
}

task iqtree {

    input {

        File alignment
    }

    command {

        iqtree -ninit 2 -n 2 -me 0.05 -ntmax 2 -s ${alignment} -pre covid.phy -m GTR -o MN908947.3

    }

    output {

        File iqtree_report = "covid.phy.iqtree"
        File iqtree_treefile = "covid.phy.treefile"
        File iqtree_log = "covid.phy.log"

    }

    runtime {
        cpu:    2
        memory:    "8 GiB"
        disks:    "local-disk 1 HDD"
        bootDiskSizeGb:    10
        preemptible:    0
        maxRetries:    0
        docker:    "staphb/iqtree:1.6.7"
    }
}

task transfer_outputs {
    input {
        String out_dir
        File alignment
        File snp_matrix
        File iqtree_report
        File iqtree_treefile
        File iqtree_log
    }

    String outdir = sub(out_dir, "/$", "")

    command <<<
        
        gsutil -m cp ~{alignment} ~{outdir}/mafft_out/
        gsutil -m cp ~{snp_matrix} ~{outdir}/snp-dists_out/
        gsutil -m cp ~{iqtree_report} ~{outdir}/iqtree_out/
        gsutil -m cp ~{iqtree_treefile} ~{outdir}/iqtree_out/
        gsutil -m cp ~{iqtree_log} ~{outdir}/iqtree_out/
       
       transferdate=`date`
        echo $transferdate | tee TRANSFERDATE
        
    >>>

    output {
        String transfer_date = read_string("TRANSFERDATE")
    }

    runtime {
        docker: "theiagen/utility:1.0"
        memory: "1 GB"
        cpu: 1
        disks: "local-disk 10 SSD"
    }
}
