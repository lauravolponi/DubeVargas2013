# DubeVargas2013
Julia replication package for Dube & Vargas (REStud, 2013). [Full reference: Dube, O., & Vargas J.F. (2013). Commodity Price Shocks and Civil Conflict: Evidence from Colombia. The Review of Economic Studies, 80(4), 1384–1421.]

Authors: Jacopo Spagnolo (jacopo.spagnolo@carloalberto.org) & Laura Volponi (laura.volponi@carloalberto.org)

Course: Structural Econometrics with Computational Applications, Spring 2025, University of Turin - Collegio Carlo Alberto (course website: https://floswald.github.io/CompEcon/)

Paper Reference: Dube, O., & Vargas, J.F. (2013). Commodity Price Shocks and Civil Conflict: Evidence from Colombia. The Review of Economic Studies, 80(4), 1384–1421.

## Overview of the Package
This Julia package replicates the main findings of Dube & Vargas (2013), which investigates how international commodity price shocks affect civil conflict in Colombia. The replicated outputs include key empirical tables and figures from the original paper.
The original code, written in STATA, and its corresponding data can be found in the replication_package folder. This Julia version is self-contained and built to match the paper’s main results.

## Content of the Package
Description of Folders
- `./data:` Contains all raw datasetsin csv format (e.g., commodity prices, conflict data by municipality).
- `./references:` paper, original .do file from replication package.
- `./output:` stores all generated outputs.
- `./src:` contains all source files for the project, including the main script and modularized functions.
*This package also includes the file for the present `README.md`.

## Software and Package Requirements
Developed with Julia 1.11.1. Required Julia packages: 

CSV
DataFrames
GLM
FixedEffectModels
CovarianceMatrices
Plots
StatsPlots
PrettyTables
Printf
Statistics

## Instructions for Replication 
To run `DubeVargas2013.jl` in VS Code, download the file named `DubeVargas2013.jl` and also download the entire `data` folder from the same repository. Place both the Julia file and the `data` folder in the same directory on your computer.
Open VS Code and choose “Open Folder” from the File menu. Select the folder where you saved the script and the data.
Once inside VS Code, open the `DubeVargas2013.jl` file. You can run the script by pressing Alt + Enter or by right-clicking and choosing “Run File in REPL”.
If the script requires any Julia packages like `CSV` or `DataFrames`, open the Julia REPL in VS Code and run the following commands to install them:

```julia
using Pkg
Pkg.add("CSV")
Pkg.add("DataFrames")
```

Now the script should run using the data from the folder you downloaded.

## List of replicated outputs
The package replicates the following outputs from the paper:

Table 1: Summary Statistics of key variables for the 1988-2005 period. Replicated columns include Variable, Obs, Mean, Med, SD, Min, and Max.

Figure 2: The coffee price and exports of main producers (Brazil, Colombia, Vietnam, Indonesia) for the period 1988-2005. Note: coffee export data from the INternational Cofee Organization (ICO) and coffee price data from the NFCG are not available in the replication package due to the fact that data are not open access.

Figure 3: Mean violence in Colombian municipalities, 1988-2005.

Figure 4: The coffee price and mean violence in coffee and non-coffee municipalities, Colombia, 1988-2005.

Figure 5: The oil price and mean violence in oil and non-oil municipalities, Colombia, 1988-2005.

Table 2: The effect of the coffee and oil shocks on. Main results including coefficients and standard errors for the 4 regression columns.

Table 3: The opportunity cost and rapacity mechanisms. Main results including coefficients and standard errors for the 5 regression columns.

Figure 4: The effect of other natural resource price shocks. Main results including coefficients and standard errors for the 4 regression columns.

## Comments on Output Accuracy
All outputs produced by this package match exactly the results presented in the paper, with one exception: the coefficients in columns (1) and (2) of Table 3 for second-stage regressions. We believe that this discrepancy in IV regression coefficients arises from the need to manually implement the two-stage least squares (2SLS) procedure when using fixed effects in Julia. Specifically, due to current compatibility limitations, the FixedEffectModels package- which is typically used to run fixed-effects regressions - cannot be directly combined with the CovarianceMatrices package for robust standard error computation, nor does it natively support full 2SLS estimation.
As a workaround, the two stages of the IV estimation must be implemented manually, then applying fixed effects separately. This manual process may lead to slight differences in coefficient estimates, as it may not fully replicate how fixed effects and instrumented variables interact in a built-in IV-FE framework.
Importantly, these differences are minor, do not affect the qualitative conclusions of the analysis, and are consistent with the challenges of replicating IV regressions with fixed effects across different software environments.
Please note that all other outputs align perfectly with the paper’s outputs.
