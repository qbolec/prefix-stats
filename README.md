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

    sort input | ./prefix-stats lower_bound=2 

Details
-------
Input provided to the prefix-stats should be sorted. I would write "must" instead of "should", but it wouldn't be entirely true -- 
a weaker property is required, namely that if X is the longest common prefix of any two lines, then it is also a prefix of all lines between them.
For example, this implies that you should be able to run prefix-stats on a recursive directory listing no matter how directories are sorted on each level.
Basically, this property makes sure that the input file describes a DFS traversal of the Trie, and thus the program does not have to
build the whole Trie in memory (which would be impractical) but just the path from the root to the current node, and can produce output
line-by-line whenever the DFS makes step upward.

Each line should contain key and pair separated by the delimiter, which defaults to any whitespace sequence, and can be changed using `FS` variable, 
as usual for AWK programs. For example to use the tool on comma separated values, use 

    sort input.csv | ./prefix-stats FS=";"

If a line does not contain a value it is assumed to have value 1, which makes it easier to use this tool for a single column files.

The format of output is affected by other variables:
* `OFS` specifies separator used in output, defaults to a single space
* `lower_bound` suppresses output of nodes which have cummulative value lower than `lower_bound`, by default 1
* `verbose` activates verbose mode if set to 1, in which nodes which have only a single non-zero child are also reported (for example node "/us" and "/use")

For example:
    
    sort input.csv | ./prefix-stats FS=";' OFS=";" verbose=1 lower_bound=10

will output comma separated list of all nodes in the tree (including parents of single nodes) which have cummulative sum greater than 10.

Another (more useful?) example, which reports directories which use more than 20 blocks of space:

    $ du  --max-depth=4 | awk '{print $2,$1}' | prefix-stats.awk lower_bound=20
    ./.subversion 32
    ./.subversion.* 48
    ./.s.* 49
    ./..* 50
    ./prefix_stats/.git/hooks 31
    ./prefix_stats/.git/objects 24
    ./prefix_stats/.git/objects.* 44
    ./prefix_stats/.git/.* 85
    ./prefix_stats/.git 70
    ./prefix_stats/.git.* 155
    ./prefix_stats 84
    ./prefix_stats.* 239
    ./sc2/.git/hooks 31
    ./sc2/.git/objects/.* 23
    ./sc2/.git/objects 27
    ./sc2/.git/objects.* 50
    ./sc2/.git/.* 91
    ./sc2/.git 73
    ./sc2/.git.* 164
    ./sc2 149
    ./sc2.* 313
    ./.* 602
    . 351
    ..* 953

