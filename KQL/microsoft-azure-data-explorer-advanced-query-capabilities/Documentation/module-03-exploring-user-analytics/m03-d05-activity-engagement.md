# Module 3 - Exploring User Analytics

## Demo 5 - Activity Engagement

### Overview

Using the `activity_engagement` plugin, you can determine the number of distinct active users on a particular date. In addition, you can determine the number of active users in a sliding window for the specified time period prior to that date. Finally, it will produce a ratio of distinct active users on a date compared to the number in the sliding window.

Let's look at a simple example. On June 7 your data shows 2 active users. You specified a sliding window of 7 days, so the plugin will aggregate the total number of distinct users from June 1 to June 7. For our example, let's say the total is 10. On June 7th then, 2 active users out of 10 total yields a ratio of 0.2, or 20%.

### Examining the Code - Example 1 - Basic Query

We'll start by creating a datatable, and storing in the variable `T`.

```python
let T =  datatable(User:string, Timestamp:datetime)
[
    "Bob",      datetime(2020-06-01),
    "Jim",      datetime(2020-06-02),
    "Jim",      datetime(2020-06-03),
    "Ted",      datetime(2020-06-03),
    "Sue",      datetime(2020-06-04),
    "Bob",      datetime(2020-06-04),
    "Jim",      datetime(2020-06-04),
    "Ann",      datetime(2020-06-05),
    "Mac",      datetime(2020-06-06),
    "Lee",      datetime(2020-06-07),
    "Bob",      datetime(2020-06-08),
    "Sue",      datetime(2020-06-09),
    "Jim",      datetime(2020-06-10),
    "Bob",      datetime(2020-06-11),
    "Jim",      datetime(2020-06-11),
    "Ted",      datetime(2020-06-12),
    "Sue",      datetime(2020-06-12),
    "Bob",      datetime(2020-06-12),
    "Hal",      datetime(2020-06-12),
    "Bob",      datetime(2020-06-12)
];
```

Next, we'll set a few variables. First, we'll store the start and end dates to examine our data for.

```python
let Start = datetime(2020-06-01);
let End = datetime(2020-06-30);
```

Next, we set the inner and outer activity windows.

```python
let InnerActivityWindow = 1d;
let OuterActivityWindow = 7d;
```

The inner activity window indicates how we should group data for purposes of comparison. Here we use 1d (1 day), thus activity will be aggregated on a daily basis.

The second variable, OuterActivityWindow, is the length of time to use for our sliding scale. Here we use 7d (7 days). When we process a record for June 7th, for example, the plugin will look back 7 days and total the distinct users for the time range of June 1 to June 7.

Finally we are ready to call the plugin.

```python
T | evaluate activity_engagement(User, Timestamp, Start, End, InnerActivityWindow, OuterActivityWindow)
```

As with calling other plugins, we pass our datatable into the evaluate, which will let KQL know this is a plugin.

For the first parameter we pass in the User column name, which will be used as the key for determining distinctness. Next is the Timestamp, used for the date evaluation.

The start and end parameters are pretty obvious. Finally we pass in the value to use for our inner bin value, and the value for the length of time to look back.

### Analyzing the Output

Running the query using the above data returns the following data. Note that since we selected 1d for our InnerActivityWindow, the data is broken down at one row per day.

| Timestamp | dcount_activities_inner | dcount_activities_outer | activity_ratio |
| ----- | ----: | ----: | ----: |
| 2020-06-01 00:00:00.0000000 | 1 | 1 | 1 |
| 2020-06-02 00:00:00.0000000 | 1 | 2 | 0.5 |
| 2020-06-03 00:00:00.0000000 | 2 | 3 | 0.666666666666667 |
| 2020-06-04 00:00:00.0000000 | 3 | 4 | 0.75 |
| 2020-06-05 00:00:00.0000000 | 1 | 5 | 0.2 |
| 2020-06-06 00:00:00.0000000 | 1 | 6 | 0.166666666666667 |
| 2020-06-07 00:00:00.0000000 | 1 | 7 | 0.142857142857143 |
| 2020-06-08 00:00:00.0000000 | 1 | 7 | 0.142857142857143 |
| 2020-06-09 00:00:00.0000000 | 1 | 7 | 0.142857142857143 |
| 2020-06-10 00:00:00.0000000 | 1 | 6 | 0.166666666666667 |
| 2020-06-11 00:00:00.0000000 | 2 | 6 | 0.333333333333333 |
| 2020-06-12 00:00:00.0000000 | 4 | 7 | 0.571428571428571 |

Let's look at the data in the output for June 7. It shows 1 distinct user on this date. Referring to our input data, we see that Lee was indeed active on the 7th, and the only person to have data recorded on that date.

Now we need to look back 7 days, the length of time indicated in the OuterActivityWindow variable. During that time, June 1 to June 7, the following users were active: Bob, Jim, Ted, Sue, Ann, Mac, and Lee. Seven users, which is the value in the dcount_activities_outer column of the output.

Finally we need to calculate the ratio of distinct users for a day to the distinct user count for the sliding window. 1 divided by 7 is 0.142857142857143, or roughly 14%.

This same logic applies to all rows in the output. Note that if there is no data previous to the start date, it uses a value of 0. Thus you may wish to include a few extra rows of data for dates prior to the start date in order to get accurate data for the first few rows, as we did in the `active_users_count` demo.

### Examining the Code - Example 2 - Formatting the Output

As with the previous demo, let's take a moment to format the output. Add the following lines to the bottom of the query.

```python
  | project TimePeriod=format_datetime(Timestamp, 'yyyy-MM-dd')
          , ActiveUsersToday = dcount_activities_inner
          , ActiveUsersInTimePeriod = dcount_activities_outer
          , ActivityPercent = round((activity_ratio * 100), 2)
  | order by TimePeriod asc
```

We'll reformat the time, this time we'll use the yyyy-MM-dd format. The two counts we simply use project to rename. We then take the activity_ratio, multiply by 100 to turn it into a percentage, round it to just two decimal places, and give it a nice name.

Finally we pipe it to an order command in order to ensure the output is sorted in the order we need.

| TimePeriod | ActiveUsersToday | ActiveUsersInTimePeriod | ActivityPercent |
| ----- | ----: | ----: | ----: |
| 2020-06-01 | 1 | 1 | 100 |
| 2020-06-02 | 1 | 2 | 50 |
| 2020-06-03 | 2 | 3 | 66.67 |
| 2020-06-04 | 3 | 4 | 75 |
| 2020-06-05 | 1 | 5 | 20 |
| 2020-06-06 | 1 | 6 | 16.67 |
| 2020-06-07 | 1 | 7 | 14.29 |
| 2020-06-08 | 1 | 7 | 14.29 |
| 2020-06-09 | 1 | 7 | 14.29 |
| 2020-06-10 | 1 | 6 | 16.67 |
| 2020-06-11 | 2 | 6 | 33.33 |
| 2020-06-12 | 4 | 7 | 57.14 |

### Summary

The 'activity_engagement` plugin provides a simple way to compare activity on a particular slice of time to a sliding window of periods up to and including the time being examined. In this demo, we compared activity for a day to the window of 7 days.
