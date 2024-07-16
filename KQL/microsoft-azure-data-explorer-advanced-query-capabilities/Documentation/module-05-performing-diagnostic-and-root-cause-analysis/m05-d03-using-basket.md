# Module 5 - Performing Diagnostic and Root Cause Analysis

## Demo 3 - Using Basket

### Overview

Basket analysis is similar to autocluster, in that it looks for patterns in the data. The difference is in the pattern mining algorithm as well as in the amount of data returned. Autocluster is based on a proprietary clustering algorithm, and typically returns a very small set of output patterns. It looks for distinct groups of patterns, returning the most occurring combination in each group.

Basket, on the other hand, is based on the known Apriori algorithm. It returns many more patterns, as it extracts all patterns that contain at least, by default 5% although this is user settable, of the records set.

### Examining the Code

```python
let min_peak_t=datetime(2016-08-23 15:00);
let max_peak_t=datetime(2016-08-23 15:02);
demo_clustering1
  | where PreciseTimeStamp between(min_peak_t..max_peak_t)
  | evaluate basket()
```

As you can see, the code is almost identical to the autocluster example, the difference being we call basket instead.

### Analyzing the Output

| SegmentId | Count | Percent | PreciseTimeStamp | Region | ScaleUnit | DeploymentId | Tracepoint | ServiceHost |
| ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- |
| 0 | 639 | 65.7407407407407 |  | eau | su7 | b5d1d4df547d4a04ac15885617edba57 |  | e7f60c5d-4944-42b3-922a-92e98a8e7dec |
| 1 | 642 | 66.0493827160494 |  | eau | su7 | b5d1d4df547d4a04ac15885617edba57 |  |  |
| 2 | 324 | 33.3333333333333 |  | eau | su7 | b5d1d4df547d4a04ac15885617edba57 | 0 | e7f60c5d-4944-42b3-922a-92e98a8e7dec |
| 3 | 315 | 32.4074074074074 |  | eau | su7 | b5d1d4df547d4a04ac15885617edba57 | 16108 | e7f60c5d-4944-42b3-922a-92e98a8e7dec |
| 4 | 328 | 33.7448559670782 |  |  |  |  | 0 |  |
| 5 | 94 | 9.67078189300411 |  | scus | su5 | 9dbd1b161d5b4779a73cf19a7836ebd6 |  |  |
| 6 | 82 | 8.43621399176955 |  | ncus | su1 | e24ef436e02b4823ac5d5b1465a9401e |  |  |
| 7 | 68 | 6.99588477366255 |  | scus | su3 | 90d3d2fc7ecc430c9621ece335651a01 |  |  |
| 8 | 167 | 17.1810699588477 |  | scus |  |  |  |  |
| 9 | 55 | 5.65843621399177 |  | weu | su4 | be1d6d7ac9574cbc9a22cb8ee20f16fc |  |  |
| 10 | 92 | 9.46502057613169 |  |  |  |  | 10007007 |  |
| 11 | 90 | 9.25925925925926 |  |  |  |  | 10007006 |  |
| 12 | 57 | 5.8641975308642 |  |  |  |  |  | 00000000-0000-0000-0000-000000000000 |

Our output is similar to what we got with autocluster, although here basket found many more patterns, including very similar ones. Interestingly, though using different mining algorithms, both basket and autocluster identified the same top pattern, containing 639 records, 65.74% of the data.

### Summary

Basket provides an alternative to autocluster. Autocluster was designed for ad-hoc interactive analysis so it intentionally returns a smaller set of divergent patterns, to avoid "flooding" the user with too many patterns to further investigate.

Basket is the classical implementation of the Apriori algorithm, returning plenty of patterns and better suited for automatic analysis, where all patterns can be further processed by some heuristic or business logic.
