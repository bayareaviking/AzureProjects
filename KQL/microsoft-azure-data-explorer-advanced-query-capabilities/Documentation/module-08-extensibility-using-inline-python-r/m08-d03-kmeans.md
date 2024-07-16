# Module 8 - Extensibility Using inline Python and R

## Demo 3 - K-Means Clustering

### Overview

In this demo, we'll clusterize a dataset by the well known K-Means  algorithm. Using the data in StormEvents, we'll look at the start and end locations of the reported events and try to find distinct groups, each containing many events that occurred in approximately the same location.

In data science terminology, each group is called a cluster and is characterized by its size and centroid (the average location of each coordinate). Our KQL query will run K-Means and return the clusters' size and centroids.

You can find more information on K-Means Clustering at: [K-Means Clustering on Wikipedia](https://en.wikipedia.org/wiki/K-means_clustering).

The K-Means algorithm is included in the [scikit-learn](https://scikit-learn.org) package. scikit-learn is the main machine learning package on Python. For this demo, we are using [sklearn.cluster.KMeans](https://scikit-learn.org/stable/modules/generated/sklearn.cluster.KMeans.html) class.

### Examining the Code

As is our standard, we'll begin by declaring the variable to hold our Python code.

```python
let pyCode = 'from sklearn.cluster import KMeans\n'
             'k = kargs["k"]\n'
               //  instantiate the KMeans object for calculating k clusters
             'km = KMeans(n_clusters=k)\n'
               //  the actual clustering is done here
             'km.fit(df)\n'
               //  copy the centroids to the output dataframe
             'result = pd.DataFrame(km.cluster_centers_, columns=df.columns)\n'
               //  count the number of items in each cluster and copy it
             'result.insert(df.shape[1], "size", pd.DataFrame(km.labels_, columns=["n"]).groupby("n").size())\n'
               //  set sequential numbers for cluster id
             'result.insert(df.shape[1], "cluster_id", range(k))\n';
```

Briefly, the code imports the KMeans class from scikit-learn package, calculates our clusters and copies the clusters' centroids and size to the output dataframe.

Next is our dataset.

```python
StormEvents
  | where isnotnull(BeginLat)
  | project BeginLat, BeginLon, EndLat, EndLon
```

Pretty simple stuff by now. We simply filter out the rows with a missing `BeginLat`, then reduce the output to only the four columns we need using `project`.

Next we call the python plugin.

```python
  | evaluate python( typeof(*, cluster_id:int, size:long)
                   , pyCode
                   , pack('k', 5)
                   )
```

The call to the python plugin should be comfortable to you by now. We first declare the schema of the output. For storing the centroids we can just use the input schema that includes the beginning and ending longitude and latitude columns, as indicated by the `*`.

In addition, we'll need to extend it with two new columns. The first will store the cluster ID, the second will store the cluster size. We then pass in the Python code to execute, and finally the dictionary of parameters. Here it contains a single parameter, `k`, to indicate the number of clusters we want, and we set it to `5`.

Finally we just sort our output top down by cluster size:

```python
  | order by size
```

Running this code, we get back the following output.

| BeginLat | BeginLon | EndLat | EndLon | cluster_id | size |
| ----- | ----- | ----- | ----- | ----- | ----- |
| 34.796871923447 | -98.5346490537796 | 34.7977185715813 | -98.52499762643 | 2 | 9361 |
| 42.578856478889 | -93.2791174039646 | 42.5762450106395 | -93.2708919363871 | 0 | 8926 |
| 33.4056244668625 | -84.2177226024774 | 33.4042755331375 | -84.2091818413996 | 3 | 7825 |
| 40.9578664281455 | -77.3498180679785 | 40.9566293231962 | -77.3425573196185 | 1 | 6708 |
| 41.6982654347061 | -109.937147835269 | 41.7000902851109 | -109.929269904963 | 4 | 2842 |

We can use these results for drawing the centroids on a map, each with its respective size or for any further analysis.

### Summary

In the module Performing Diagnostic and Root Cause Analysis, we reviewed the built in clustering plugins including autocluster and basket. However, there are plenty of clustering algorithms. In this demo we have seen how to use Python's scikit-learn package for clustering by the well known K-Means algorithm. Using the python() plugin you can apply dozens of machine learning algorithms from a variety of Python packages including scikit-learn, TensorFlow, PyTorch and many more.
