# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Project FIND IT aims to centralize and streamline the psychology department data identification, storage, and retrieval method to facilitate long-term data analysis studies. This is an R-based data processing pipeline that crawls file systems, inventories data files (particularly SAS datasets), and extracts metadata including unique patient identifiers (MRN counts).

## Technology Stack

- **Language**: R
- **Key Libraries**:
  - `tidyverse` - Data manipulation and transformation
  - `haven` - Reading SAS (.sas7bdat) files
  - `data.table` - High-performance data operations
  - `parallel` - Multi-core processing for large datasets
  - `tools` - File extension handling
  - `fs` - File system operations
  - `ggtree`, `ape` - Tree visualization for directory structures

## Core Architecture

### File Crawler Pipeline (file_crawler.Rmd)

The main data processing workflow consists of three stages:

1. **File Inventory Creation**
   - Recursively scans directory trees starting from a configurable path
   - Extracts file metadata: modification time, size, type, path
   - Categorizes files by size (greater/less than 1GB threshold)

2. **Parallel Data Processing**
   - Uses `parallel::makeCluster()` to process files across multiple CPU cores
   - For SAS files (.sas7bdat): reads data and counts unique MRN values (Medical Record Numbers) from first column
   - Exports results showing which datasets contain unique patient identifiers

3. **Data Consolidation**
   - Combines file metadata, type information, and MRN counts
   - Outputs structured CSV: `../data/processed_data/file_inventory_updated.csv`
   - Schema: folder_name, file_name, unique_mrn_count, mtime, file_type, file_size

### Directory Visualization (test_ggtree.R)

- Generates directory tree visualizations using `fs::dir_tree()`
- Outputs tree structure to log files for documentation

## Data Flow

```
Raw Data Directory (../data/raw_data/YYYYMMDD)
    |
    v
File Crawler (parallel processing)
    |
    v
Processed Output (../data/processed_data/file_inventory_updated.csv)
```

## Development Commands

### Running the File Crawler

```r
# In R console or RStudio
rmarkdown::render("file_crawler.Rmd")
```

Or open in RStudio and knit the R Markdown document.

### Running Directory Visualization

```r
# In R console
source("test_ggtree.R")
```

### Running Individual Chunks

When working with file_crawler.Rmd, execute chunks sequentially as they have dependencies. The pipeline expects:
- `start_path` variable set to data directory
- `all_files` list created before processing
- Parallel cluster properly started and stopped

## Important Implementation Details

### Parallel Processing Pattern

The codebase uses a specific parallel processing pattern:
```r
cl <- makeCluster(detectCores() - 1)
clusterEvalQ(cl, { library(...) })
clusterExport(cl, c("variables", "functions"))
results <- parLapply(cl, data, function)
stopCluster(cl)
```

Always ensure:
- Libraries are loaded on worker nodes via `clusterEvalQ()`
- Required variables/functions exported via `clusterExport()`
- Cluster is stopped after processing

### Data Assumptions

- SAS files have MRN (patient identifier) in the **first column**
- File size threshold is 100MB (despite variable naming suggesting 1GB)
- Raw data organized in dated folders (YYYYMMDD format)

### Path Structure

- Raw data expected at: `../data/raw_data/YYYYMMDD/`
- Processed output goes to: `../data/processed_data/`
- Paths are relative to script location

## Testing Approach

This is a data processing pipeline without formal unit tests. When modifying:
1. Test on small subset of files first
2. Verify output CSV structure matches expected schema
3. Check parallel processing doesn't cause memory issues
4. Validate MRN counts match manual inspection

## Common Gotchas

- **Memory Usage**: Large SAS files can consume significant memory during parallel processing. Monitor RAM when processing datasets >1GB
- **Column Assumptions**: Code assumes first column contains MRN - verify this for new data sources
- **Cluster Management**: Failing to `stopCluster()` can leave zombie R processes
- **Path Dependencies**: Scripts use relative paths - run from repository root or adjust `start_path`
