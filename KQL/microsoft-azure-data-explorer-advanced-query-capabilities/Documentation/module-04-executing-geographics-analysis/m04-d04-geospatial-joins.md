# Module 4 - Geoclustering

## Demo 4 - Geospatial Joins

### Overview

Geospatial joins are a technique that allow you to join data from two different data sets based on geographic data. In this demo, we'll see how to join a list of US States to the Storm Events data, so we can aggregate counts of events for each state.

### Examining the Code

We begin the query by assigning a variable with a level value. If you recall from the last demo, S2 Cell functions allow you to specify the level we want to drill down to.

```python
let s2Level = 5;
```

We now start with the first of our two data sets, the `US_States` table. The data we want is in the `features` column. It contains data in json format, we'll be using `project` to create new columns based on the data in the json.

```python
US_States
  | project State = features.properties.NAME
          , polygon = features.geometry
```

The name of the state is easy to understand, it is one of the properties in the features column. The second thing we are interested in is the geometry. Let's again refer back to the previous demo where we defined the geography for the state of California. It was a long list of lat/long coordinates. The geography for each state is stored in the `US_States` table in this geometry property.

Here we extract both properties, the name and geometry, and use `project` to move them into new columns.

Now we need to add a new column, which we'll accomplish using `extend`.

```python
  | extend covering = geo_polygon_to_s2cells(polygon, s2Level)
  | mv-expand covering to typeof(string)
```

We'll use the `geo_polygon_to_s2cells` to create an array of S2 cell values, based on the polygon that defines a state and the level we want to drill down to. This array of S2 cells will be stored in the covering column name. After creating the column we'll use `mv-expand` to convert it to a string.

Now we can setup our join.

```python
  | join kind = inner hint.strategy = broadcast
  (
    StormEvents
    | project BeginLon, BeginLat
    | extend covering = geo_point_to_s2cell(BeginLon, BeginLat, s2Level)
  ) on covering
```

We start by declaring the join type, an inner join. Using the hint will materialize the left side then broadcast it to all cluster nodes. Remember, Azure Data Explorer is processing these rows in parallel, to do so it spreads the workload across multiple nodes. By using the hint, we make sure all nodes have a full copy of the left side of the data.

For the query we are joining to, we take the storm events and limit it to just the longitude and latitude columns.

Next, we add a new column by using the `geo_point_to_s2cell` function. It will calculate the value of the S2 cell for this particular long/lat combination.

The join is made when the S2 value for this storm event is found in the S2 array for the entire state.

Next we need to apply a filter.

```python
  | where geo_point_in_polygon(BeginLon, BeginLat, polygon)
```

Sometimes you'll have an occurrence where the S2 value isn't totally accurate for our needs. Here's a simple example, let's say you have a storm event in the panhandle area of Florida, very close to the Alabama state line. While the event was in Florida, the center of the S2 cell may be across the line in Alabama. This where clause will filter out these anomalies.

Finally, we will summarize our data into counts by state, then add an order by so we get the list in alphabetical order.

```python
  | summarize NumberOfEvents = count() by tostring(State)
  | order by State asc
```

### Analyzing the Output

Looking at the output, we'll see a list of all US states, along with the number of storm events in that state.

For brevity we only show the first 5 below.

| State | NumberOfEvents |
| ----- | ----- |
| Alabama | 691 |
| Alaska | 17 |
| Arizona | 258 |
| Arkansas | 709 |
| California | 131 |

### Summary

As you can see, performing joins based on geographic locations turns out to be fairly easy, using the functions to convert your long/lat coordinates into S2 cells or points in an S2 cell.

With minor variations you can find other uses for geographic joins. In the downloadable samples we've included samples of using this technique with charts, as well as demonstrating its use at different levels such as counties instead of states.
