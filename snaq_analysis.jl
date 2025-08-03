#!/usr/bin/env julia

###############################################################################
# Script: snaq_analysis.jl
# Description: Run SNaQ to infer species networks from gene trees and CFs
# Requirements: PhyloNetworks.jl, SNaQ.jl, DataFrames.jl, CSV.jl
###############################################################################

using PhyloNetworks
using SNaQ
using DataFrames
using CSV

# === Input files ===
gene_tree_file = "data/gene_trees/gene.trees_chenopodium_cleaned"
species_tree_file = "data/species_tree/species_tree_disco_chenopodium_ca.tre"

# === Parameters ===
hmax_values = 0:3                       # Number of hybridization events to explore
n_replicates = 2                        # Replicates per h
output_dir = "results/snaq_runs"       # Output directory
mkpath(output_dir)

# === Read gene trees and compute CFs ===
trees = readMultiTopology(gene_tree_file)
q, t = countquartetsintrees(trees)
nt = tablequartetCF(q, t)
df = DataFrame(nt, copycols=false)
CSV.write(joinpath(output_dir, "snaq_quartets.csv"), df)

astraltree = readTopology(species_tree_file)
raxmlCF = readtableCF(df)

# === Define SNaQ wrapper ===
function run_snaq_hmax(h::Int, reps::Int, tree, cf, outdir::String)
    best_net = nothing
    best_ll = Inf

    for r in 1:reps
        seed = 1000 * h + r
        fname = joinpath(outdir, "net_h$(h)_r$(r)")
        println("Running h=$h replicate $r → $fname")

        try
            net = snaq!(tree, cf, hmax=h, filename=fname, seed=seed)
            current_ll = net.loglik
            println("   logL = $current_ll")

            if current_ll < best_ll
                best_ll = current_ll
                best_net = net
            end
        catch e
            println("ERROR in h=$h, run=$r → $e")
        end
    end

    if best_net !== nothing
        outtree = joinpath(outdir, "best_net_h$(h).tre")
        writenewick(best_net, outtree)
        return (h=h, loglik=best_ll, net=best_net)
    else
        return (h=h, loglik=missing, net=nothing)
    end
end

# === Run serial SNaQ execution ===
results = []
for h in hmax_values
    push!(results, run_snaq_hmax(h, n_replicates, astraltree, raxmlCF, output_dir))
end

# === Print summary ===
for result in results
    if result.net !== nothing
        println("Best network found for h=$(result.h), logL=$(result.loglik)")
    else
        println("No successful network for h=$(result.h)")
    end
end
