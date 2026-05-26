---
title: OurDNA v1.0
date: 2025-10-10
order: 1
categories:
  - Release
authors:
  - Katie de Lange, Population Genomics team
---

We are delighted to announce the v1 release of [the OurDNA browser](https://ourdna.populationgenomics.org.au/), which summarises variant and allele frequency information from 12,882 Australians, including exome sequencing data from 10,671 individuals and genome sequencing data from 2,211 individuals. 

This initial release includes data from multiple Australian cohorts, and 89 members of the Australian Filipino community who participated in the pilot stage of the OurDNA recruitment program. This release is intended to pressure-test our processing and browser infrastructure in advance of the data that will be flowing from the OurDNA program over the coming years, which will include genome sequencing data from over 8,000 individuals from diverse Australian communities. We also hope it will provide some valuable scientific and clinical insight in its own right, especially for clinicians working with families from currently under-represented communities.

In this blog post, we will break down the technical aspects of how this v1 release dataset was generated. For more information on the OurDNA program (including our current recruitment numbers, and information on how to participate) please visit the [OurDNA website](https://ourdna.org.au/).

# Creating the OurDNA v1.0 release

## Contributing datasets

The OurDNA v1 release combines sequencing data from several Australian cohorts:

* 10,671 exomes generated from a broadly population-representative Australian cohort generated as part of the [Mackenzie's Mission](https://www.mackenziesmission.org.au/) program to implement reproductive carrier screening at population scale (led by Martin Delatycki, Edwin Kirk, and Nigel Laing);

* 1,254 genomes from the BioHEART cohort, an Australian cohort of individuals affected by cardiac conditions (led by Gemma Figtree), using data generated and analysed by the Centre for Population Genomics;

* 868 genomes from the Tasmanian Ophthalmic Biobank, a cohort of mostly European-ancestry individuals without strong ascertainment for any specific disease (led by Alex Hewitt), using data generated and analysed by the Centre for Population Genomics; and

* 89 genomes from members of the Australian Filipino community recruited into the [OurDNA program](https://www.ourdna.org.au/) (led by Daniel MacArthur), and sequenced as a pilot; many more genomes from diverse Australian communities will be coming from this program soon, with DNA samples already collected from over 2,000 individuals of Filipino and Vietnamese ancestry, and recruitment in the Eastern Mediterranean community now well underway!

## Harmonised processing

We created a harmonised callset by processing all samples through a standardised pipeline, following the DRAGEN-GATK Best Practices guidelines. This pipeline was run on Google Cloud using a hail batch implementation, and includes the alignment of FASTQs or CRAMs to GRCh38 using DRAGMAP, followed by the genotyping of SNPs and indels with GATK HaplotypeCaller.

The resulting gVCFs were combined using hail to create two VariantDataset (VDS) objects: one containing all whole genome samples, and one containing all whole exome samples. 

![The OurDNA Browser v1 pipeline](../images/2025/ourdna_browser_v1_pipeline.png)

In addition, we also reprocessed 4,143 reference samples from the Human Genome Diversity Project (HGDP) and 1000 Genomes Project using the Terra-based WDL implementation of the DRAGEN-GATK Best Practices pipeline, and combined the resulting gVCFs into a reference VDS. 

## Defining high-quality sites to use for QC

We pre-determined a set of high-quality sites to use for certain stages of sample QC, including assessing sample call rate and performing genetic ancestry inference. These were defined based on the HGDP and 1000 Genomes reference callset, with the goal of selecting sites that would include a reasonable amount of known global genetic diversity. 

First, we subsetted the reference callset to high-quality, unrelated individuals based on the filtering suggested in [gnomAD v3.1.2](https://gnomad.broadinstitute.org/news/2021-10-gnomad-v3-1-2-minor-release/), retaining **2508** individuals from the 1000 Genomes Project and **865** from the HGDP cohort. We then filter variants in this callset to select:

* Autosomal, bi-allelic SNPs in exome calling regions; which

* Pass quality control in gnomAD v4; and

* Pass the following filters in the unrelated HGDP and 1000 Genomes callset:

  * AF > 0.0005

  * Inbreeding coefficient > -0.8

  * HWE p-value > 1e-8

  * Call rate > 99%

Finally, we perform LD pruning using a window size of 500kb and a r2 threshold of 0.2, leaving us with a total of **195,161** high quality sites. 

## Quality control and allele frequency estimation

### Overview

![Overview of quality control and allele frequency estimation in OurDNA browser v1](../images/2025/ourdna_browser_v1_overview_qc.png)

### Sample QC

#### Hard sample filtering

Both the genome and exome callsets are made up of samples that were obtained and sequenced via a number of different collection pathways and processing labs, and using different exome capture sets, library preparations, and sequencing machines. As a result, we needed to apply careful sample filters to make sure we minimised batch effects, while also ensuring we were not performing this filtering in ways that would preferentially remove samples of diverse ancestry (particularly given an uneven distribution of this diversity between our contributing cohorts). 

Ultimately, we retained only high-quality samples that met the following criteria:

* No mismatch between inferred and reported sex, ambiguous sex or sex aneuploidy

* Little evidence of contamination (FREEMIX <= 1.3%, for both genomes and exomes)

* Chimera rate <= 6.3% (genomes) or 5% (exomes)

* Number of singletons < 9000 for exomes

* No excess of connectivity in relatedness estimation (linked to an observed batch effect relating to the library prep used)

The following metrics were also assessed, but no samples were identified as requiring filtering based on these:

* Insert size (average insert size > 350bp for genomes)

* Mean coverage on chr20 (>20X for genomes, >30X for exomes)

* Number of SNPs

* Number of bases with DP > 1 and DP > 20

* Het/hom ratio

* Ti/Tv ratio

* Ins/Del ratio

* Call rate across high quality sites > 90%

#### Relatedness inference

We inferred pairs of first and second degree related samples across the joint exome and genome callset using [somalier](https://github.com/brentp/somalier), setting a relatedness threshold of 0.25. Using gnomAD’s [compute_related_samples_to_drop](https://broadinstitute.github.io/gnomad_methods/api_reference/sample_qc/relatedness.html#gnomad.sample_qc.relatedness.compute_related_samples_to_drop) function, we then extracted a maximally unrelated subset, preferentially keeping the better ranked sample when ranking based on:

* Passing hard sample QC

* Prioritising genomes over exomes

* Highest mean depth on chr 20

#### Genetic ancestry inference

In order to infer genetic ancestry, we first separately subset the exome and genome datasets to just those pre-selected high-quality sites that are variant in each of the respective callsets. We then combine these with the high-quality, unrelated HGDP and 1000 Genomes reference samples at those sites, and perform a Principal Component Analysis using gnomAD’s [run_pca_with_relateds](https://broadinstitute.github.io/gnomad_methods/api_reference/sample_qc/ancestry.html#gnomad.sample_qc.ancestry.run_pca_with_relateds) function. Genetic ancestry labels for the reference population are defined based on the harmonised descriptors from Koenig et al (2024), as described for gnomAD v4 [here](https://gnomad.broadinstitute.org/news/2023-11-genetic-ancestry/#sample-metadata-labels).

We then train RandomForest classifiers for each callset using 12 PCs for exomes and 14 PCs for genomes, where the number of PCs are selected based on inspection of the variance captured, error rates, proportion of high-confidence assignments, and alignment with reported ancestries where relevant. Only RandomForest assignments with probabilities greater than 0.8 are retained, while the rest of the individuals are set to ‘Unclassified’. Ancestry groups with fewer than 25 individuals are also reassigned to ‘Unclassified’.

At this stage we also remove samples with inferred or reported Oceanic ancestry, until appropriate consultation with the relevant Indigenous Australian groups has been performed. We took a conservative approach to identifying these samples, by selecting:

* Any participant that self-identifies as Aboriginal or Torres Strait Islander in the Mackenzie’s Mission dataset

* Any participant that reports Oceanian ancestry in any dataset

* Any sample that has a probability of Oceanian ancestry > 0.05 from the RandomForest model

This results in the following breakdown of sample counts by inferred genetic ancestry:

![Breakdown of sample counts by inferred genetic ancestry in OurDNA browser v1](../images/2025/ourdna_browser_v1_ancestry_counts.png)

Note that four Australian Filipino participants with self-identified dual ancestries, also confirmed by genetic data, are currently labelled as ‘Unclassified’ pending the inclusion of local ancestry approaches in our processing pipelines. 

### Variant QC

Similar to gnomAD, we compute quasi allele-specific variant QC metrics in hail and then use the allele-specific (AS) version of GATK Variant Quality Score Recalibration (VQSR) to compute a score indicating the confidence that a variant is real as opposed to an artifact. We train both SNP and indel AS-VQSR models separately for exomes and genomes, using the default GATK bundle training resources and priors, and the following features:

* SNPs

  * **Training data**: hapmap (prior=15), omni (prior=12), 1000G (prior=10) and dbsnp (prior=7)

  * **Features**: AS_ReadPosRankSum, AS_MQRankSum, AS_QD, AS_FS, AS_SOR, AS_MQ

* Indels

  * **Training data**: mills (prior=12), axiomPoly (prior=10), and dbsnp (prior=2)

  * **Features**: AS_ReadPosRankSum, AS_MQRankSum, AS_QD, AS_FS, AS_SOR

We assess the performance of the resulting models by dividing variants (split by SNPs and indels) into 100 approximately equal-sized bins based on their VQSR AS_VQSLOD score. Lower numbered bins have higher AS_VQSLOD scores and are predicted to be more likely to be a true variant.

We then evaluate a number of quality control metrics for each of these bins, in order to choose an appropriate cutoff to use to define QC-pass and QC-fail variants. These metrics included

* Ti/Tv ratio, proportion singletons, proportion bi-allelic SNPs, number of ClinVar variants, and insertion/deletion ratio

* Precision/recall in a NA12878 control sample that was jointly sequenced and processed with our data (noting that this NA12878 control trio is removed from our final allele frequency calculations)

Based on this, we chose a bin threshold of 90 for SNPs and 80 for indels, removing variants with AS_VQSLOD scores below the thresholds defined at these bin cutoffs.

In addition to the AS-VQSR filtering, we also applied the following hard filters:

* **AS_lowqual**: remove SNPs with AS_QUALapprox < 60, and indels with AS_QUALapprox < 70

* **AC0**: no sample had a high quality genotype at this variant site (GQ>=20, DP>=10 and allele balance > 0.2 for heterozygotes)

* **InbreedingCoeff**: there was an excess of heterozygotes at the site compared to Hardy-Weinberg expectations, using a threshold of -0.3 on the InbreedingCoefficient metric

After applying these filters, we retain 57,322,471 SNPs and 4,567,608 indels.

### Frequencies estimation

Finally, allele frequencies are computed separately for the exome and genome callsets across all variants, stratified by sex and assigned genetic ancestry.

We adopt the approach taken in [gnomAD v4.1](https://gnomad.broadinstitute.org/news/2024-04-gnomad-v4-1/) to extract allele number information across all callable sites in our exome and genome VDS, even when all samples for a given data type were homozygous reference. This enables us to accurately report total allele numbers across the full exome+genome dataset for all sites where a variant is called in either data type. 

For variants that are present in both exomes and genomes, we also display a combined allele frequency. As with gnomAD v4.1, we check for highly discordant frequencies between the exome and genome callsets - either using a [contingency table test](https://hail.is/docs/0.2/functions/stats.html#hail.expr.functions.contingency_table_test) (for variants observed in a single inferred genetic ancestry group) or the [Cochran-Mantel-Haenszel test](https://hail.is/docs/0.2/functions/stats.html#hail.expr.functions.cochran_mantel_haenszel_test) (when a variant is present in multiple groups). A warning flag is displayed for variants where the p-value for this test is less than 10<sup>-4</sup>. 

# Acknowledgements

While acknowledging that the creation of this OurDNA browser release was a massive team effort, involving critical contributions from a number of teams across the Centre for Population Genomics as well as many of our key collaborators, here we would like to thank a few specific people and teams for their major contributions to the technical aspects of producing this resource.

Firstly, thank you to the participants in the OurDNA, BioHEART, Tasmanian Ophthalmic Biobank  and Mackenzie’s Mission programs who generously provided their data, and the respective program teams that enabled their inclusion in this project. 

Secondly, thank you to the gnomAD team, whose publicly available methods and code formed the basis of much of our analysis work, as well as the backbone behind the browser itself.

Bindu Swapna Madala, Caitlin Uren, and Amy Miniter were critical in managing the access to and ingestion of all the relevant datasets, and wrangling all of the associated data and metadata. Michael Harper, Michael Silk and Alex Stuckey performed the data processing, and wrote much of the code required to get everything into shape. Joshua Schmidt and Katalina Bobowik played key roles in QC and analysis, while Jennifer Piscionere kept us all on track. Miloslav Hyben did the work of adapting the gnomAD browser for our purposes, and loading in the OurDNA release.

Finally, thank you to all the staff at the Centre for Population Genomics, each and every one of who contributed to this release in some way! 
