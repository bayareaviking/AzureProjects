# Module 8 - Extensibility Using inline Python and R

## Demo 1 - Calling the Python Plugin

### Prerequisites

In this demo we will see how to call both Python and R from within a KQL query. Due to security considerations, the Python and R plugins are not enabled in the Microsoft public cluster and samples database we've been using. As such, if you want to try the following demos, you will need to use your own cluster, within your own Azure environment. If you setup your own Dev cluster, the cost is very reasonable, at the time of this writing approximately $ 0.21 (yes, 21 cents in United States currency) per hour.

In addition, you will need to make sure that the python() and r() plugins are enabled in your development cluster, as it is disabled by default.

As this course focuses exclusively on the Kusto Query Language, setting up a cluster and enabling the Python/R plugins are outside the scope of this course. However Microsoft has provided some excellent guides.

First, there are several guides for using scripting languages to creating a cluster. This particular guide uses Azure Resource Manager templates.

[Creating ADX Clusters and Databases Using ARM templates]([http://](https://docs.microsoft.com/en-us/azure/data-explorer/create-cluster-database-resource-manager))

In this same area are other How To guides using other languages, such as Azure CLI, PowerShell, Python, and more.

Once you've created your cluster, you can enable Python or R using the instructions here.

[Manage Language Extensions in Your ADX Cluster]([http://](https://docs.microsoft.com/en-us/azure/data-explorer/language-extensions))

It is also assumed you are familiar with the Python and/or R languages, as we will not attempt to explain the Python code here. Pluralsight has many excellent courses on Python and R should you need a refresher course.

Finally, in order to keep this module consistent with the rest of the course, several of the tables in the Microsoft public samples have been cloned into the private cluster used for this particular module. You can easily clone the needed tables to your private cluster by running

```python
.set tbl < cluster('help').database('Samples').tbl
```

from the context of your personal database, replacing `tbl` with the name of the required table to clone.

### Overview

As awesome as the Kusto Query Language is, there are times when you need functionality not native to KQL. To enable this type of extensibility, the Azure Data Explorer team has created plugins for the Python and R languages, enabling you to embed Python/R code in your KQL query. We'll begin by seeing how to execute Python code from within a Kusto query.

A quick formatting note, when we use Python, with a capital P, we are referring to the Python language. When we use python(), with a lower case p and parenthesis, we are referring to the python plugin.

### Examining the Code

The first thing to understand is that you cannot simply type in Python code into the Kusto query window, as I've done here. If I run this, it will result in a 'recognition error' which is essentially a syntax error. Instead, you have to place your code in a formatted multi-line string, then pass that string into the python plugin.

To help you out, there is a key combination you can use that will format your Python code into a string. Highlight the block of code you want to convert, and press Ctrl+K, then Ctrl+S.

You can now see my code has been wrapped in single quotation marks, making them a string. Additionally the line feed character of `\n` has been added to the end of each line.

Note this key combination works in both the ADX website as well as the Kusto desktop application.

OK, lets start looking deeper into the use of Python in your Kusto queries.

Here is a simple example.

```python
range sourceNumber from 1 to 10 step 1
| evaluate python( typeof(*, powNumber:int)
                 , 'exp = kargs["exp"]\n'
                   'result = df\n'
                   'result["powNumber"] = df["sourceNumber"].pow(exp)\n'
                 , pack('exp', 4)
                 )
```

We'll explain this in a moment, but note that we have embedded the Python code directly into the query. As we said, you must format the Python code as a multi-line string by enclosing each line in quotes and end it with explicit newline: '...\n'. You can select the Python block in the query editor and use a keyboard shortcut Ctrl+K,Ctrl+S to automate this formatting for the full Python block.

To increase readability we can also put our Python code into a variable, and use that in our call.

```python
let sourceDataset = range sourceNumber from 1 to 10 step 1;
let pyCode = 'exp = kargs["exp"]\n'
             'result = df\n'
             'result["powNumber"] = df["sourceNumber"].pow(exp)\n';
sourceDataset
| evaluate python( typeof(*, powNumber:int)
                 , pyCode
                 , pack('exp', 4)
                 )
```

As we've done in so many examples, we start by creating our source dataset. Here we've named it simply `sourceDataset`, and use the `range` command to generate a list of values, from 1 to 10, and store them in a column named `sourceNumber`.

Now let's talk about the mechanics. The Python code is run on a 'Python sandbox', a secure and isolated Python environment, based on Anaconda distribution, that is running on the same existing ADX compute nodes. We need to send to the sandbox the data set to work on, the Python script and also parameters for the script.  

The data set is essentially an ADX table, that is sent to the sandbox and is mapped to a Pandas DataFrame which is named 'df', in the context of the Python environment.

The code is sent as formatted multi-line string as discussed above. The parameters are sent as a dictionary containing key/value pairs, which is mapped to a Python dictionary named 'kargs' in the Python environment.

Finally, the output of the Python script should be stored in another DataFrame, named 'result', that is sent back to ADX. So just like native operators, you can pipe a table to the python() plugin, and continue piping the resulting table to additional operators.

Back to our demo, reviewing the Python script, we can see that first we extract a parameter named `'exp'` from the dictionary of parameters. Then, we just copy the input DataFrame `df` to the output `result`. Finally we append a new column, `powNumber` which is calculated for each line by raising the number in the source column `sourceNumber` to the specific `exp` power.

With the dataset created, and Python code written, we now take our source, `sourceDataset` and pipe it to `evaluate` in order to call the `python` plugin.

The python plugin requires three parameters. The first is the output schema of the data. Note that ADX needs to know the output schema for every operator, to be able to perform the query planning phase (which optimize the query before its actual execution).

It should always use the `typeof` function to format it. In this example the first parameter to `typeof` is an asterisk `*`. This is a shortcut for the schema of the input table, in this case it's only `sourceNumber` of type `int`. Still, this shortcut is very handy for tables with dozens of columns, avoiding the need to explicitly type them one by one. Keeping all input columns is optional of course, you don't have to output whatever is input, but it's quite common that you just want to add few calculated columns.

In our example, in the second parameter to `typeof`, we create a new column name for our exponent output `powNumber` with its `int` type. This is the same column name that we appended in the `result` DataFrame in our Python script.

With the `typeof` being our first parameter, the second parameter is obviously our block of Python code. Storing it in a variable makes our query more readable, and much easier to work with and update later if needed.

The final parameter to the python plugin is dictionary of the key/value pairs (that was mapped to `kargs` in the Python environment). The KQL `pack` function will create a key/value dictionary. In our case it contains a single key named `exp`, whose value is 4, meaning that our Python script will raise the source numbers to the 4th power.

### Analyzing the Output

The output is pretty much what you expect.

| sourceNumber | powNumber |
| ----- | ----- |
| 1 | 1 |
| 2 | 16 |
| 3 | 81 |
| 4 | 256 |
| 5 | 625 |
| 6 | 1296 |
| 7 | 2401 |
| 8 | 4096 |
| 9 | 6561 |
| 10 | 10000 |

Because we used the `*` as the first parameter in the `typeof`, our `sourceNumber` column from the source is present. In addition, our Python calculated column `powNumber` is also in the output.

### Summary

The purpose of this demo was not to show how to create a complex calculation in Python, but rather to explain the 'python sandbox' environment and show the basic mechanics of calling the python() plugin. With this you should now have an understanding of:

* How the data from our dataset flows into the plugin
* How to declare the output of the plugin
* How to pass our Python code into the plugin
* And finally, how to pass parameters into the plugin

In future demos we will no longer elaborate on the mechanics of the plugin, nor will we dive into the composition of the supplied Python code. Instead we will be showing two popular use cases for combining KQL with Python, after which we'll do a quick demonstration of using R with ADX.
