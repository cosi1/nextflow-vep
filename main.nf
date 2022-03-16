nextflow.enable.dsl = 2


// -- parameters:
// work directory
params.workdir = "/workspace/cosi"
// input file
params.input_file = params.workdir + "/input.txt.gz"
// output file
params.output_file = params.workdir + "/output.txt"
// Docker image with VEP
params.vep_image = "vep:latest"
// chunk size
params.chunk_size = 1000
// genome assembly
params.asembly = "GRCh37"


// -- annotate
// Annotates an input chunk.
process annotate {
    container params.vep_image
    
    input:
    tuple val(chunk_id), file("chunk_in")

    output:
    tuple val(chunk_id), file("chunk_out")

    """
    ## annotate the chunk
    vep --cache --assembly="${params.assembly}" -i chunk_in -o chunk_out
    
    ## remove VCF headers from all but the first chunk
    if [ "$chunk_id" != "1" ]; then
      sed -i '/^#/d' chunk_out
    fi
    """
}


// -- main workflow
workflow {
    // auxiliary variable: chunk number
    chunk_id = 1

    // split the input file into chunks and annotate
    Channel
	.fromPath(params.input_file)
	.splitText(by: params.chunk_size, file: true)
	.map { t -> tuple(chunk_id++, t) }
        | annotate

    // sort the chunks in the original order
    annotate.out
	.toSortedList { a, b -> a[0] <=> b[0] }
	.transpose()
	.last()
	.flatten()
	.collectFile(name: params.output_file, sort: false)
}
