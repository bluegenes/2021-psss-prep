import os
import sys
import pandas as pd


basename = config.get('basename', 'psss-test')
data_dir = config.get('data_dir', "./")
metagenome_dir = config.get('metagenome_dir', "./")
out_dir = config.get('outdir', "output.psss")
logs_dir = os.path.join(out_dir, 'logs')

tool_name = "sourmash"

rule all:
    input:


rule index_metagenome:
    input: os.path.join(metagenome_dir, "{metagenome}.fna.gz")
    output: os.path.join(out_dir, tool_name, "metagenomes", "{metagenome}.sig")
    log: os.path.join(logs_dir, tool_name, "index-metagenome", "{metagenome}.log")
    benchmark: os.path.join(logs_dir, tool_name, "index-metagenome", "{metagenome}.benchmark")
    conda: "conf/env/sourmash4.yml"
    shell:
        """
        sourmash sketch -p k=21,31,51,scaled=1000,abund {input} -o {output} 2> {log}
        """

rule prepare_query:
    input: os.path.join(data_dir, "{sample}.fna.gz")
    output: os.path.join(out_dir, tool_name, "queries", "{sample}.sig")
    log: os.path.join(logs_dir, tool_name, "prepare_query", "{sample}.log")
    benchmark: os.path.join(logs_dir, tool_name, "prepare_query", "{sample}.benchmark")
    conda: "conf/env/sourmash4.yml"
    shell:
        """
        sourmash sketch -p k=21,31,51,scaled=1000,abund {input} -o {output} 2> {log}
        """

rule search_query_x_metagenome:
    input: 
        query= rules.prepare_query.output,
        metagenome = rules.index_metagenome.output
    output: os.path.join(out_dir, tool_name, "search",  "{sample}-x-{metagenome}.sig")
    log: os.path.join(logs_dir, tool_name, "search", "{sample}-x-[metagenome].log")
    benchmark: os.path.join(logs_dir, tool_name, "search", "{sample}-x-{metagenome}.benchmark")
    conda: "conf/env/sourmash4.yml"
    shell:
        """
        sourmash ...
        """

rule aggregate_benchmark_data:
    input: 
        index=expand(os.path.join(logs_dir, tool_name, "index-metagenome", "{metagenome}.benchmark"), metagenome=METAGENOMES),
        prepare=expand(os.path.join(logs_dir, tool_name, "prepare_query", "{sample}.benchmark"), sample=SAMPLES),
        search=expand(os.path.join(logs_dir, tool_name, "search", "{sample}-x-{metagenome}.benchmark"), sample=SAMPLES, metagenome=METAGENOMES)
    output:
        os.path.join(out_dir, tool_name, "benchmark-data.csv")
    # maybe aggreagate these in an ordered fashion instead, adding a label of which step they are (index, prepare, search, etc)
    shell:
        """
        """

# if we're running sar, we might be able to extract sar info right here? Not sure if we need to have this be separate or not..

#rule extract_process_info_sartre:
#    input: 
#    output:
#    conda: "conf/env/sar.yml"
#    shell:
#        """
#        python extract.py  ....
#        """
#
