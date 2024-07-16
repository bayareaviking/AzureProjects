# Module 3 - Exploring User Analytics

## Demo 2 - Active User Counts

### Overview

The goal of the active user counts plugin is to help identify your "fans", in other words people who regularly use the product or service you are logging activity for. The data being analyzed must have an identifier to uniquely identify the user, as well as a date/time the activity was recorded on.

There are a few key factors to determining if someone is active within the time period. First is the period. If, for example, it is set to day, we will see if a user is active within that day. We can also use other units of time such as hours, minutes, weeks, months, and so on.

The next factor is the look back window, it is an amount of time that uses the same time unit that was used in the period. For example, if our period was set to day, the look back is how many days we want to look back from the date being analyzed. If this looks familiar it should, in the previous demo the sliding window counts used the concept as well.

Finally we need to tell the plugin how many periods a user must appear in to be counted as a "fan". It's starting to sound a bit complex, but perhaps this simple example will illustrate the rule.

If we set the period to 1 day, look back window to 5 days, and active periods to 3, it means that a user must be active 3 days out of the 5 days. Note that the user must appear on 3 separate days. If they were to appear 3 times but all on the same day, they won't be counted.

### Examining the Code - Example 1 - The Basic Query

We start the query by creating a datatable with the data to examine. Note comments were added to make it clear where the data falls into the bins we'll be using.

```python
let T =  datatable(User:string, Timestamp:datetime)
[
    // Pre-start date
    "Bob",      datetime(2020-05-29),
    "Bob",      datetime(2020-05-30),
    // Bin 1: 6-01
    "Bob",      datetime(2020-06-01),
    "Jim",      datetime(2020-06-02),
    // Bin 2: 6-08
    "Bob",      datetime(2020-06-08),
    "Bob",      datetime(2020-06-09),
    "Jim",      datetime(2020-06-10),
    "Bob",      datetime(2020-06-11),
    "Jim",      datetime(2020-06-14),
    // Bin 3: 6-15
    "Bob",      datetime(2020-06-21),
    "Jim",      datetime(2020-06-21),
    // Bin 4: 6-22
    "Jim",      datetime(2020-06-22),
    "Bob",      datetime(2020-06-22),
    "Jim",      datetime(2020-06-23),
    "Bob",      datetime(2020-06-24),
    // Bin 5: 6-29
    "Bob",      datetime(2020-06-24)
];
```

We'll return back to the data momentarily, for now let's look at the next part of the query in which we set a few additional variables.

```python
let Start = datetime(2020-06-01);
let End = datetime(2020-06-30);
let Period = 1d;
let LookbackWindow = 5d;
let ActivePeriods = 3;
let Bin = 7d;
```

The `Start` and `End` indicate the range we want to analyze within our data.

The `LookbackWindow` indicates how many days backwards the plugin should look for activity from the same user. Keep in mind that the lookback can go previous to the start date. If we refer back to the dataset, you will note Bob was active on June 1st. When the `active_user_counts` plugin analyzes that row of data, it will go back five days and look for activity for Bob in the range of May 27 to June 1st.

The next variable is the `Period`. Here it is set to 1d or 1 day. It doesn't matter how many times a user was active in that time period, Bob could have been active 1 time or 20 on a single day, it would still only be counted once when being evaluated for activity.

`ActivePeriods`, the next value, says how many time periods a user must be in to be considered active. In this example, a user must show up at least 3 days out of the last 5 days (the look back window), to be counted as active.

The final variable sets how we want to bin, or group our results. Here we set `bin` to 7 days. Since our start date is June 1, our bins will be June 1, 8, 15, 22, and 29. The 29th is the final bin as anything beyond that would exceed the end date set in the `End` variable.

Now we get to the core of this demo, the active_users_count plugin.

```python
T | evaluate active_users_count(User, Timestamp, Start, End, LookbackWindow, Period, ActivePeriods, Bin)
```

Here we take our datatable, contained in the variable T, and pipe it into the evaluate function. Evaluate is needed to let Kusto know this is a plugin we are calling and not a native KQL function.

The first parameter we pass to the `active_users_count` plugin is the unique identifier that marks a user. Here we use the User column name from our datatable.

Next we indicate what column from the datatable to use as the time. Here it comes from the appropriately named Timestamp column in the source datatable.

The remaining parameters correspond to the variables we created, since their purpose was explained in the variables section we won't reiterate here.

### Analyzing the Output

Let's run the query, and take a look at it's output.

Timestamp | dcount
----- | -----
2020-06-01 00:00:00.0000000 | 1
2020-06-08 00:00:00.0000000 | 1
2020-06-22 00:00:00.0000000 | 2

To see where these results came from, let's refer back to the input datatable.

```python
    // Pre-start date
    "Bob",      datetime(2020-05-29),
    "Bob",      datetime(2020-05-30),
    // Bin 1: 6-01
    "Bob",      datetime(2020-06-01),
    "Jim",      datetime(2020-06-02),
```

The process begins on June 1st, and will process all dates in our first bin. The bin period was set for 7 days, so the date range for bin 1 is June 1 to June 7.

The first record the plugin will examine from the first bin is Bob, on 2020-06-01. It will then look back 5 days into the data, even if those dates occur prior to the June 1 start date. Thus the two records for Bob, the 29th and 30th, will be evaluated.

Since the active periods was set to 3, and Bob has been active three times in the five day window (May 27 to June 1), he is counted.

The next row that is read is for Jim on June 2. Looking back, Jim has no other records during the bin or in the five days before it, so he won't be included in the results.

This yields the first row in our output. It shows the starting date for the bin, 2020-06-01, and the distinct count. Please note this is a _distinct_ count.

Bob could also have been active on June 3rd, 4th, and 5th. However because he was already showing up in the results for his activity of May 29 to June 1, he would not be counted a second time.

Let's look now at bin 2, for June 8. In the output it shows 1 distinct active user.

```python
    // Bin 2: 6-08
    "Bob",      datetime(2020-06-08),
    "Bob",      datetime(2020-06-09),
    "Jim",      datetime(2020-06-10),
    "Bob",      datetime(2020-06-11),
    "Jim",      datetime(2020-06-14),
```

This uses the same logic pattern already described, and Bob was the only user who qualified under those rules. Hence we have the 2020-06-08 bin in the output with a distinct count of 1.

Next up is bin 3, for June 15. As you can it only has two rows. Neither has any data that occur in our five day lookback window.

```python
    // Bin 3: 6-15
    "Bob",      datetime(2020-06-21),
    "Jim",      datetime(2020-06-21),
```

Now if you look at the output you'll see.... oh, wait, actually you _won't_ see. You won't see a row for this bin date, that is.

This is a very important detail to note. If the active_users_count plugin does not find any distinct users, in other words the distinct count is zero, then it does not return any rows.

There may be instances where you want to note that a particular bin date had zero active users, and we'll see how to solve that dilemma in a moment.

Before we get to that solution, let's examine bin 4.

```python
    // Bin 3: 6-15
    "Bob",      datetime(2020-06-21),
    "Jim",      datetime(2020-06-21),
    // Bin 4: 6-22
    "Jim",      datetime(2020-06-22),
    "Bob",      datetime(2020-06-22),
    "Jim",      datetime(2020-06-23),
    "Bob",      datetime(2020-06-24),
```

You may think a copy/paste error occurred as bin 3 is also appearing, but that was done on purpose. Both Bob an Jim have two records each in the fourth bin. However, the two rows in bin 3 fall into the five day lookback window. As a result, they meet the criteria for three active entries in the five day period, and are included in the output for June 22nd.

Finally, we have data for the final bin.

```python
    // Bin 5: 6-29
    "Bob",      datetime(2020-06-29)
```

As there is only one row here, and the data for it does not meet our criteria for inclusion no row appears for this bin in the output.

### Examining the Code - Example 2 - Adding in Missing Bin Dates

In the previous section we mentioned how to fill in the missing bin dates into our output. The first step is to add two lines of code to the bottom of our query.

```python
| join kind=rightouter (print Timestamp = range (Start, End, Bin)
| mv-expand Timestamp to typeof(datetime)) on Timestamp
```

The first row uses the range command to create a small table of dates for the bin dates and joins it to the output, the second line then converts the joined output to be all datetimes. Let's look at the output.

Timestamp | dcount | Timestamp1
----- | ----- | -----
|  |  | 2020-06-15 00:00:00.0000000 |
|  |  | 2020-06-29 00:00:00.0000000 |
| 2020-06-01 00:00:00.0000000 | 1 | 2020-06-01 00:00:00.0000000 |
| 2020-06-08 00:00:00.0000000 | 1 | 2020-06-08 00:00:00.0000000 |
| 2020-06-22 00:00:00.0000000 | 2 | 2020-06-22 00:00:00.0000000 |

As you can see, it added a new column `TimeStamp1` to the output. For the two rows that represent the missing bins, it has placed nulls (where you see the empty columns) for the original `Timestamp` and `dcount` columns.

Progress, but not very appealing to the end user. But we can tidy it up easily, and will do so in the next section.

### Examining the Code - Example 3 - Cleaning up the Output

Here is the final line in our query that will clean up the output.

```python
| project Timestamp=coalesce(Timestamp, Timestamp1), dcount=coalesce(dcount, 0)
```

In it, we are using the `project` command to create two new columns in our output stream. Both of these use the `coalesce` function. Coalesce works by taking the first value being passed in, and comparing it to null. If it is not null, it uses the value in that first parameter. If on the other hand it is null, then it moves onto the second parameter and repeats.

In our code we only need to use two parameters with coalesce, but you can actually have a long list. It will just repeat the logic of null checking as described above until it either finds a non-null value or runs out of parameters.

After checking the timestamp, it then repeats with the dcount, either returning the dcount value from the active_users_count plugin or the value of 0.

Let's see how this looks in our output.

| Timestamp | dcount |
| ----- | -----: |
| 2020-06-01 00:00:00.0000000 | 1 |
| 2020-06-08 00:00:00.0000000 | 1 |
| 2020-06-15 00:00:00.0000000 | 0 |
| 2020-06-22 00:00:00.0000000 | 2 |
| 2020-06-29 00:00:00.0000000 | 0 |

Much better! As you can see, our original 3 rows for June 1, 8, and 22 are present. In addition, we now have rows for the bins of June 15 and 29, where the dcount was 0.

### Summary

Although it can seem a bit confusing at first, once you understand the logic behind the `active_users_count` plugin it becomes straight forward. In addition, despite the name it can be used for other applications beyond just users.

For example instead of counting the unique users, you could count the number of frequently occurring, unique error messages that occur during a period.

Now that you understand how it works, you can use it for many applications in your environment.
