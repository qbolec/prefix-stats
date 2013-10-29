Prefix Stats
============

Summary
-------
This tool was created to help analyze which URLs are most popular in access.log, but could be used for any cases, 
where prefixes provide meaningfull grouping criterion, for example to tell which of directories on your drive take up most space.

The input should contain key-value pairs, where key is a string, and value is an integer.
Imagine that all keys are aranged in a Trie, so that each unique key corresponds to a unique leaf in the tree 
(for example \0 byte ends each key), and the corresponding value is stored in that leaf.
Each internal node corresponds to a prefix, and can be naturally associated with a sum of values in all leafes underneath it.
This tool computes this aggregated values and reports all nodes which have large enought sum.

For example, suppose that input file consists of:

    /user  1
    /user/123 2
    /user/123/gallery 1
    /user/111 2
    /user/200 5
    /item/13 3

Which is a relatively short history of 1+2+1+2+5+3=14 requests. Suppose, that you are only concerned about places visited at least 3 times, then the summary could look like that:
This could be summarized as

    /user.*  11
    /user/.* 10
    /user/123.* 3
    /user/1.* 5
    /item/13 3

and could be easily achieved by running 

    sort input | prefix-stats -d ' ' -l 3 

Details
-------
Input provided to the prefix-stats should be sorted. I would write "must" instead of "should", but it wouldn't be entirely true -- 
a weaker property is required, namely that if X is a longest common prefix of any two lines, then it is also a prefix of all lines between them.
This means that you should be able to run it on a recursive directory listing no matter how directories are sorted on each level, for example.
Basically, this property makes sure that the input file describes a DFS traversal of the Trie, and thus the program does not have to
build the whole Trie in memory (which would be impractical) but just the path from the root to the current node, and can produce output
line-by-line whenever the DFS makes step upward.

Each line should contain key and pair separated by the delimiter, which defaults to \t, and can be changed using -d option.

If a line does not contain a value it is assumed to have value 1, which makes it easier to use this tool for a single column files.

The format of output is affected by other options:
* `-s` SEP specifies separator used in output to be SEP instead of the one used in the input
* `-l` LOWERBOUND suppresses output of nodes which have cummulative value lower than LOWERBOUND, by default 1
* `-v` activates verbose mode, in which nodes which have only a single non-zero child are also reported (for example node "/us" and "/use")

