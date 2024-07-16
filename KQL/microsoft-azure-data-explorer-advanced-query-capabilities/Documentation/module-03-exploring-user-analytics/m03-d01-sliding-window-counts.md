# Module 3 - Exploring User Analytics

## Demo 1 - Sliding Window Counts

### Overview

The goal of the `sliding_window_counts` plugin is to count user activity over time. The nifty thing about this plugin is it can count using a sliding window.

We should mention, a plugin is a library built by the Azure Data Explorer (ADX) team that has been added to the Kusto environment in order to extend the Kusto Query Language. The `sliding_window_counts` is one such plugin, we'll look at many others during this course.

### Examining the Code

The first statement in our script creates the dataset we'll use for the demo. It has two columns, a user ID, in this case just a person's name, and a datetime value indicating the date for this row.

```python
let T = datatable(UserId:string, Timestamp:datetime)
[
  // Bin 1: 06-01
  'Bob',      datetime(2020-06-01),
  'David',    datetime(2020-06-01),
  'David',    datetime(2020-06-01),
  'John',     datetime(2020-06-01),
  'Bob',      datetime(2020-06-01),
  // Bin 2: 06-02
  'Ananda',   datetime(2020-06-02),
  'Atul',     datetime(2020-06-02),
  'John',     datetime(2020-06-02),
  // Bin 3: 06-03
  'Ananda',   datetime(2020-06-03),
  'Atul',     datetime(2020-06-03),
  'Atul',     datetime(2020-06-03),
  'John',     datetime(2020-06-03),
  'Bob',      datetime(2020-06-03),
  // Bin 4: 06-04
  'Betsy',    datetime(2020-06-04),
  // Bin 5: 06-05
  'Bob',      datetime(2020-06-05),
];
```

Each row marks user activity, who did something and when it happened. Obviously in a real world situation there would be other columns, but these two are sufficient for this demo.

Here you can see both Bob and David were active twice on the first, as they both have two entries in the data. John only performed one activity on the first of June. You can see similar activity records for the remaining days.

We'll return to this dataset momentarily, for now let's look at the rest of the script.

In the next two lines, we simply create variables to hold a start date and an end date for the data range we want to analyze. Using variables to hold these, and other values, will make it easy to reuse the script to do analysis in the future.

```python
let start = datetime(2020-06-01);
let end = datetime(2020-06-07);
```

In the next variable, we are setting the number of days for our sliding scale. Here, we are setting variable to indicate we want a window of 3 days to look back.

```python
let lookbackWindow = 3d;  
```

We now set our last variable, bin. The plugin will use the value in this variable to bin, or group our counts. Here we want to group the counts by day.

```python
let bin = 1d;
```

If the data supported it, for example if the `timestamp` column also included the time of day, we could use other time values for `lookbackWindow` and `bin` variables, such as `1h` for hour.

Now we get to the fun part, the use of the `sliding_window_counts` plugin!

```python
T | evaluate sliding_window_counts(UserId, Timestamp, start, end, lookbackWindow, bin)
```

We take our datatable, `T`, and pipe it into our `sliding_window_counts` plugin. We use the `evaluate` function to indicate we are calling a plugin.

The first value we pass into the plugin is the unique ID for a user. In this case it is the user name, found in the column `UserId`.

The next parameter represents the timeline data. Here it is the `Timestamp` column holding the date of our activity. The plugin uses this date for analysis and grouping.

The third parameter is the date to begin our analysis, represented by the `start` variable. In this simple example, the start date happens to coincide with the first row of data in our sample. It's much more likely though your data will span many days, months, or even years. This is why we need to let the plugin know where to start.

Likewise, we also need to let it know when to stop processing the data. We do so by passing in the `end` variable into the forth parameter.

A helpful hint, processing will go much faster if you limit the dataset to just the dates you need when you first read it from the source. Then you will only pipe in the limited dataset into the `sliding_window_counts` plugin.

The fifth parameter is the _look back window_, the number of days to use for our sliding scale. The plugin will look back the number of days in the `lookbackWindow` variable we are passing in.

For example, if the current date being processed is June 4th, and the look back window variable is set to three days, the plugin will aggregate the counts June 2nd, 3rd, and 4th.

The final parameter indicates how we want to bin, or group the data. In this case we pass in the variable `bin`, which is set to one day. Thus the results will aggregate totals per day.

### Analyzing the Output

Let's look at the result of the query.

Timestamp| Count| Dcount
|:-----|-----:|-----:|
2020-06-01 00:00:00.0000000| 5| 3
2020-06-02 00:00:00.0000000| 8| 5
2020-06-03 00:00:00.0000000| 13| 5
2020-06-04 00:00:00.0000000| 9| 5
2020-06-05 00:00:00.0000000| 7| 5
2020-06-06 00:00:00.0000000| 2| 2
2020-06-07 00:00:00.0000000| 1| 1

The resultant data table contains three columns. The first is the `timestamp` which is how our results are grouped.

The next column is the `count`. If you look back at the input data table, it contained five rows on June 1st. This went into the `count` value for this first row in the output.

The final column is `dcount`, short for distinct count. It counts based on the number of unique values in the ID column, in this case the `UserId`.

In the input data table, John appears once on June 1st, Bob and David twice. However, these are three distinct users, thus the `dcount` column holds the value 3.

Let's shift down, so we can get an idea of the sliding window in action. Specifically look at the output for June 4th, where we have a count of 9.

Looking back at the input data table, our sliding window goes back three days. Thus for June 4th, the three day window will cover the dates of June 2nd, 3rd, and 4th.

On June 2nd, there are 3 rows. On June 3rd, we have 5 rows. Finally we have only 1 row on June 4th, which gives a total of 9 rows. This matches the value in the `Count` column of our output for June 4th.

In that same period, we had five users appear in the rows. Ananda, Atul, John, Bob, and Betsy. This corresponds to the output's `Dcount` column.

### Summary

While simple, this example clearly illustrates how the `sliding_window_counts` plugin works in KQL.
