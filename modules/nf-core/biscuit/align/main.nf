process BISCUIT_ALIGN {
    tag "$meta.id"
    label 'process_high'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-3f58ec2bbcefe75f55f36cf5defe6d77c8803de5:e34531e20dd2ff3fb3a8b1aa9ab20a205bbdd7e1-0':
        'biocontainers/mulled-v2-3f58ec2bbcefe75f55f36cf5defe6d77c8803de5:e34531e20dd2ff3fb3a8b1aa9ab20a205bbdd7e1-0' }"

    input:
    tuple val(meta), path(reads)
    path index

    output:
    tuple val(meta), path("*.bam"), emit: bam
    tuple val(meta), path("*.bai"), emit: bai
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def args2 = task.ext.args2 ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def biscuit_cpus = (int) Math.max(Math.floor(task.cpus*0.9),1)
    def samtools_cpus = Math.max(task.cpus-biscuit_cpus, 1)
    """
    INDEX=`find -L ./ -name "*.bis.amb" | sed 's/\\.bis.amb\$//'`

    biscuit align \\
        $args \\
        -@ $biscuit_cpus \\
        \$INDEX \\
        $reads \\
        | samtools sort $args2 --threads $samtools_cpus --write-index -o ${prefix}.bam##idx##${prefix}.bam.bai -


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        biscuit: \$( biscuit version |& sed '1!d; s/^.*BISCUIT Version: //' )
        samtools: \$( samtools --version |& sed '1!d; s/^.*samtools //' )
    END_VERSIONS
    """
}
