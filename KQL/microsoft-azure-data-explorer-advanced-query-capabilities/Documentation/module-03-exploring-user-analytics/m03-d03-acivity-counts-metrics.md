# Module 3 - Exploring User Analytics

## Demo 3 - Activity Counts Metrics

### Overview

The `activity_counts_metrics` plugin provides both a count and a distinct count for activity in a time period. In addition, it provides two other key metrics. One is an aggregated distinct count for the current time period plus all previous time periods. The second is a new distinct count. This has a count of activities that are new in the time period being analyzed, in other words rows that have not appeared in previous time periods.

### Examining the Code - Example 1 - Basic Output

We start our query with our data source, as we did in previous demos. We create a datatable with user IDs and dates.

```python
let T = datatable(UserId:string, Timestamp:datetime)
[
  // June 1
  'Bob',   datetime(2020-06-01),
  'John',  datetime(2020-06-01),
  // June 2
  'Cindy', datetime(2020-06-02),
  'John',  datetime(2020-06-02),
  'Ted',   datetime(2020-06-02),
  // June 3
  'Bob',   datetime(2020-06-03),
  'John',  datetime(2020-06-03),
  'Todd',  datetime(2020-06-03),
  'Todd',  datetime(2020-06-03),
  'Sam',   datetime(2020-06-03),
  // June 5
  'Sam',   datetime(2020-06-05),
];
```

Next, we setup a few basic variables.

```python
let start=datetime(2020-06-01);
let end=datetime(2020-06-05);
let window=1d;
```

As with previous demos, `start` and `end` are used to mark the date range we want to analyze.

The `window` variable is how we want to bin, or group our results. Here we are using a single day, but other values such as weeks, months, minutes, hours, and more are valid.

In the final line of the query we call the `activity_counts_metrics` plugin.

```python
T | evaluate activity_counts_metrics(UserId, Timestamp, start, end, window)
```

As in other demos we use the datatable being held in the variable T and pipe it through the `evaluate`, needed as we are calling a plugin. Then is the plugin itself.

In the first parameter we pass in the column with the unique key for this datatable. Here we are using a user ID, but it could be anything you want to analyze. Product ID, error message, and more.

The last three are straight forward. The start and end range for the dates to analyze, and the way we want to group the output, in this case our window of 1 day.

### Analyzing the Output

Before we look at the output, for easy reference, here is our data nicely formatted. To make it easier to read, repeating dates are suppressed.

| Timestamp | UserID |
| ----- | ----- |
| 2020-06-01  | Bob   |
|    | John  |
| 2020-06-02  | Cindy |
|    | John  |
|    | Ted   |
| 2020-06-03  | Bob   |
|    | John  |
|    | Todd  |
|    | Todd  |
|    | Sam   |
| 2020-06-05  | Sam   |

Running our query, let's look at the output.

| Timestamp | count | dcount | new_dcount | aggregated_dcount |
| ----- | ----: | ----: | ----: | ----: |
| 2020-06-01 00:00:00.0000000 | 2 | 2 | 2 | 2 |
| 2020-06-02 00:00:00.0000000 | 3 | 3 | 2 | 4 |
| 2020-06-03 00:00:00.0000000 | 5 | 4 | 2 | 6 |
| 2020-06-05 00:00:00.0000000 | 1 | 1 | 0 | 6 |

On the first row of output, we have a count of 2, representing the two rows in the data source for June 1. We also have two distinct users for this day, Bob and John, so our distinct count is also 2.

Because there are no previous rows, the new distinct count and aggregated distinct count are both 2 as well.

In the second row of output, for June 2, we start to see how this plugin works. Count is straight forward, there are 3 rows on this date so the count is 3.

Additionally we have three distinct users on this day, Cindy John and Ted, so the distinct count is 3.

For the new distinct count, we have 2, Cindy and Ted as they did not appear in any previous day. John appeared on the 1st, so he is not counted in this value.

The aggregated distinct count represents a grand total of unique users for this and previous days, giving us a value of 4. Bob and John on the 1st, Cindy and Ted on the 2nd.

On June 3rd we have five rows, so the count is 5. In those 5 rows we only have 4 unique users, as Todd had two activities logged on that date, so our distinct count is 4.

Of these users, Todd and Sam are new, the other users appeared on previous dates. Thus the new distinct count is again 2.

Finally we have the aggregated distinct count. For the third we are adding in Todd and Sam to the activities of Bob, Cindy, John, and Ted from previous dates, giving us a total of 6.

Note that we don't have a row for June 4th, this is because we have no data on that date. Like the previous demo, rows with 0 values are not returned. We'll see how to handle that in a moment, but for now let's look at that last row of data.

Sam appears on June 5th, and is the only user on that date. So, both count and dcount are 1.

As Sam appeared on previous days there are no new distinct users on this date, so new dcount is going to be 0. Likewise, as there are no new users being active, the aggregated distinct count will remain at 6.

If this is the output you want, and you aren't worried about the missing row for June 4th, great! You're done. If however you want to include that row of zero data in your output, read on.

### Examining the Code - Example 2 - Adding Missing Days

Now let's add a few lines to the query so we can let users know we had no activity on a missing date.

```python
| join kind=rightouter (print Timestamp = range (start, end, window)
| mv-expand Timestamp to typeof(datetime)) on Timestamp
| project Timestamp=coalesce(Timestamp, Timestamp1)
        , count=coalesce(['count'], 0)
        , dcount=coalesce(dcount, 0)
        , new_dcount=coalesce(new_dcount, 0)
        , aggregated_dcount=coalesce(aggregated_dcount, 0)
```

The first two lines are the same as our previous demo. They create a small table, with one row for each date in our start to end date range. This is then joined to the output of the `activity_counts_metrics` plugin.

The `project` command, beginning in line 3, is all one command. We just wrap it onto new lines to make it easier to read. For each column, we are again using coalesce to compare the output from the `activity_counts_metrics` plugin to null, and if null fill in with either the timestamp generated using the range, or a value of 0.

Note one minor formatting convention within the statement `coalesce(['count'], 0)`. Count is the name of an operator in KQL. In order to let our query know we want to use this as a column name, and not call the count operator, we surround it with ['']. This then gives us our output to include our missing date of June 4th.

| Timestamp | count | dcount | new_dcount | aggregated_dcount |
| ----- | ----: | ----: | ----: | ----: |
| 2020-06-01 00:00:00.0000000 | 2 | 2 | 2 | 2 |
| 2020-06-02 00:00:00.0000000 | 3 | 3 | 2 | 4 |
| 2020-06-03 00:00:00.0000000 | 5 | 4 | 2 | 6 |
| 2020-06-04 00:00:00.0000000 | 0 | 0 | 0 | 0 |
| 2020-06-05 00:00:00.0000000 | 1 | 1 | 0 | 6 |

### Summary

The `activity_counts_metrics` plugin provides a great way to calculate not just counts for individual days, but to keep a running aggregated distinct count across a range of dates.
