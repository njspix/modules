process BISCUIT_INDEX {
    tag "$fasta"
    label 'process_long'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/biscuit:1.4.0.20240108--h0be9327_0':
        'biocontainers/biscuit:1.4.0.20240108--h0be9327_0' }"

    input:
    path fasta, stageAs: "BiscuitIndex/*"

    output:
    path "BiscuitIndex/*.fa*", emit: index, includeInputs: true
    path "versions.yml"      , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    biscuit \\
        index \\
        $args \\
        $fasta

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        biscuit: \$( biscuit version |& sed '1!d; s/^.*BISCUIT Version: //' )
    END_VERSIONS
    """
}
