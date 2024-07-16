# Module 3 - Exploring User Analytics

## Demo 4 - Activity Metrics

### Overview

The plugin `activity_metrics` will return valuable information about user activity for a period as compared to the previous time period. The first two are basic distinct counts. One is simply the number of distinct users that appear in the time period being examined. The second is the number of new users, in other words users that appear in the time period under examination who were not found in the previous period.

The next two are ratios in the value of 0 to 1. The retention rate indicates how many users from the last period returned for this period. For example if 2 of 3 users in the previous period returned, that ratio would be 2/3 or 0.66666667 (i.e. 66.67%).

Churn rate is a ratio of how many people are lost compared to the previous time period, and is calculated similarly. If 1 out of 3 users in the previous period did not return for the current period, the rate is 1/3 or 0.33333333 (or 33.33%).

### Examining the Code - Demo 1 - Basic Query

As usual with a query you should start with data. Here we generate a datatable and store in a variable, `T`.

```python
let T =  datatable(User:string, Timestamp:datetime)
[
    // Bin 1: 6-01
    "Bob",      datetime(2020-06-01),
    "Jim",      datetime(2020-06-02),
    "Jim",      datetime(2020-06-03),
    // Bin 2: 6-08
    "Bob",      datetime(2020-06-08),
    "Sue",      datetime(2020-06-09),
    "Jim",      datetime(2020-06-10),
    // Bin 3: 6-15
    "Bob",      datetime(2020-06-21),
    "Jim",      datetime(2020-06-21),
    // Bin 4: 6-22
    "Ted",      datetime(2020-06-22),
    "Sue",      datetime(2020-06-22),
    "Bob",      datetime(2020-06-23),
    "Hal",      datetime(2020-06-24),
    // Bin 5: 6-29
    "Bob",      datetime(2020-06-29)
];
```

Next, we will create a few simple variables to hold the start and end dates for the range of data we want to examine. In addition we will declare a bin value, in other words how to group our data. This is set to 7d for 7 days.

```python
let Start = datetime(2020-06-01);
let End = datetime(2020-06-30);
let bin = 7d;
```

Finally we call the `activity_metrics` plugin.

```python
T | evaluate activity_metrics(User, Timestamp, Start, End, bin)
```

The values being passed in are pretty obvious. The first is the value we can use for a key to uniquely identify a row of data, here we use the `User` column from the datatable. Next is the datetime data column to analyze on, here called `Timestamp`.

Next up is the start and end date to indicate the range to use for analysis. Finally is the value to be used to group our data, `bin`.

### Analyzing the Output - Example 1

| Timestamp | dcount_values | dcount_newvalues | retention_rate | churn_rate |
| ----- | ----: | ----: | ----: | ----: |
| 2020-06-01 00:00:00.0000000 | 2 | 2 | 1 | 0 |
| 2020-06-08 00:00:00.0000000 | 3 | 1 | 1 | 0 |
| 2020-06-15 00:00:00.0000000 | 2 | 0 | 0.666666666666667 | 0.333333333333333 |
| 2020-06-22 00:00:00.0000000 | 4 | 3 | 0.5 | 0.5 |
| 2020-06-29 00:00:00.0000000 | 1 | 0 | 0.25 | 0.75 |

The first output row contains the data for bin 1, which began on June 1st. Looking at the data we have one entry for Bob, and two for Jim. Remember the d in dcount stands for distinct, so the first column has a value of 2.

As this is the first row, we have no previous row to compare to, so both are counted as new distinct users. Likewise, with no previous data the retention rate is set to 1, or 100%, and the churn to 0.

In the next bin of June 8, Bob and Jim return and are joined by a new user, Sue giving a distinct count of 3. We have one new user, Sue, so dcount_newvalues has a value of 1.

As both Bob and Jim returned, we have 2 of 2 coming back so the retention rate is 2/2 or 1 (100%). Likewise, as we didn't lose anyone the churn rate is 0.

Now we move to the data for June 15th. Once again Bob and Jim are back, but Sue did not return. By now you can guess the dcount_values will be 2, and with no new users the dcount_newvalues is 0.

For the retention rate, 2 of our 3 users came back, divided out becomes 0.666666667 (or 66.67%).

In the previous time period of June 8, we had 3 users. One of those users, Sue, did not return. 1/3 is 0.33333333 or 33.33%.

Looking at the fourth bin, for June 22nd, we have four users. Three of these are brand new. Of the two users from the last time period, Jim and Bob, only Bob returned. 1 returning of 2 yields a retention of 0.5. 1 leaving of the 2 also yields 0.5 for the churn rate.

Moving to the last bin, for June 29, we had one user, with no new ones. As only one of the four returned, the retention was 0.25 or 25%. We lost three of the four, making our churn rate 0.75.

### Examining the Code - Demo 2 - Formatting the Output

Our previous work is perfect for piping into the next part of the query, or exporting for further analysis. However, it is not very easy to read. Should you wish, you can format the output to make it easier for people to refer to.

We'll do so via the `project` command. Add these few lines to the bottom of the query from example 1.

```python
  | project TimePeriod=format_datetime(Timestamp, 'MM/dd/yyyy')
          , ActiveUsers = dcount_values
          , NewUsers = dcount_newvalues
          , RetentionPercent = round((retention_rate * 100), 2)
          , ChurnPercent = round((churn_rate * 100), 2)
```

Using `project` we can take our original set of output columns from the query and reformat them. The KQL function `format_datetime` is used to format out timestamp to a readable value. Note the use of capital M's for the month.

We opted not to format the active and new user distinct counts, although we do rename them for the output. To make the rates easy to read, we start by multiplying both by 100 in order to convert them to percentages. The `round` function is then use to round them off to just two decimal places. Finally, they are renamed to add the word _Percent_ to the end to make it clear these are now percentage values.

| TimePeriod | ActiveUsers | NewUsers | RetentionPercent | ChurnPercent |
| ----- | ----: | ----: | ----: | ----: |
| 06/08/2020 | 3 | 1 | 100 | 0 |
| 06/15/2020 | 2 | 0 | 66.67 | 33.33 |
| 06/22/2020 | 4 | 3 | 50 | 50 |
| 06/29/2020 | 1 | 0 | 25 | 75 |
| 06/01/2020 | 2 | 2 | 100 | 0 |

### Summary

As you can see from this demo, the `activity_metrics` plugin makes it easy to create row over row comparisons for new user counts, as well as retention / churn values.
