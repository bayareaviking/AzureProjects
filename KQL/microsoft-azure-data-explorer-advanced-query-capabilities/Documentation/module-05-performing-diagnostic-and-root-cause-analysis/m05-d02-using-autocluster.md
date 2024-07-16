# Module 5 - Performing Diagnostic and Root Cause Analysis

## Demo 2 - Using Autocluster

### Overview

The autocluster plugin is deceptively simple and incredibly powerful. It will analyze a large dataset, and return a short list of patterns, where each pattern is a combination of attributes sharing the same values that were found in this dataset. Let's see how effective it is by analyzing the exceptions’ spike from the previous demo, as it is easier to explain when we see the output.

### Examining the Code

As mentioned, the query is very simple.

```python
let min_peak_t=datetime(2016-08-23 15:00);
let max_peak_t=datetime(2016-08-23 15:02);
demo_clustering1
  | where PreciseTimeStamp between(min_peak_t..max_peak_t)
  | evaluate autocluster()
```

We start as we did in the last demo, only now we pipe it to `evaluate autocluster()`, which will automatically extract interesting patterns for us.

### Analyzing the Output

Here is the output of the query.

| SegmentId | Count | Percent | PreciseTimeStamp | Region | ScaleUnit | DeploymentId | Tracepoint | ServiceHost |
| ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- | ----- |
| 0 | 639 | 65.7407407407407 |  | eau | su7 | b5d1d4df547d4a04ac15885617edba57 |  | e7f60c5d-4944-42b3-922a-92e98a8e7dec |
| 1 | 94 | 9.67078189300411 |  | scus | su5 | 9dbd1b161d5b4779a73cf19a7836ebd6 |  |  |
| 2 | 82 | 8.43621399176955 |  | ncus | su1 | e24ef436e02b4823ac5d5b1465a9401e |  |  |
| 3 | 68 | 6.99588477366255 |  | scus | su3 | 90d3d2fc7ecc430c9621ece335651a01 |  |  |
| 4 | 55 | 5.65843621399177 |  | weu | su4 | be1d6d7ac9574cbc9a22cb8ee20f16fc |  |  |

Under the count column we see there are 639 rows that are contained in the pattern of eau Region, su7 ScaleUnit, DeploymentId b5d1d4df547d4a04ac15885617edba57, and ServiceHost of e7f60c5d-4944-42b3-922a-92e98a8e7dec. This pattern represents 65.74% of the rows in our data. Likewise, subsequent rows represent additional patterns.

Be aware that some rows might be represented in few (partially overlapping) patterns , and some rows are not represented in any pattern. The goal of autocluster is to transform a big table to a very small list of informative and divergent patterns, thus presenting the user significant multi-dimensional patterns for quick and efficient drill down and further investigation for the root cause.

If you see data that looks interesting, you could refine the query to focus in on those attributes. For example you may want to add a `where ServiceHost = 'e7f60c5d-4944-42b3-922a-92e98a8e7dec'` clause prior to the autocluster to look for a new clustering pattern within that one service host.

### Summary

As you can see, while simple, autocluster allows you to easily find non-trivial patterns, which are combinations of commonly occurring attributes, within your data.
