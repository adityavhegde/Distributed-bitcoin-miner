# Project1

**Overview**

# Group Members: 
- Kumar Rohit Malhotra (5697-1748)
- Aditya Hegde (0211-3121)

# Project Design

The code is organised to detect if the running Node is a Client or a Server on the basis of the arguments passed.

**Assumptions:** It is assumed that the first ip detected by :inet.getif() on a linux-based OS is the host IP. Similar measures have been taken for windows-based operating system.

**When the code is run as the Server:**
- The boss(or the main) process running at the Server Node spawns _N_ processes/workers(here 16) on its own node.
- The boss assigns tasks to each of the worker and receives messages from any process when that process ends. Upon receiving the end message from a worker, the boss process spawns a new worker on the corresponding node and assigns it a new task. The node on which the new worker is spawned may be the Server itself or any of the connected Clients --- whichever node a worker has finished a task on.
- When a new client connects to this server, the boss process spawns _N_ processes(here 16) on its node and assigns tasks to each of them.
- A new task refers to assigning the generation of _W_ work units to a newly spawned process, where _W_ is the number of random strings to be generated and checked. The length of strings to be generated is different for each process where as the number of random strings to be generated is fixed for each process.
- The process is continued similarly for client, by the server, as explained in point 2 above for the server.

**When the code is run as the Client:** 
- The server spawns _N_ processes/workers(here 16) on this new client.
- The monitoring of tasks ending, spawning new workers on the client, and assigning a task to a process is all handled by the boss process running on the main server.

# Notes

**Size of the work unit**

Each worker process is assigned a work unit of `1,000,000`. This means that each process is given a different suffix length and it generates `1,000,000` random strings of that length, computes their SHA-256 value and it checks for the expected number of leading zeros. Each random generated string is concatenated with UFID for uniqueness.

Upon trial and errors with different work unit sizes, it was observed that reducing the work unit size from `1,000,000` would not cover as many strings that need to be checked, especially when looking for a higher number of leading zeros. This leads to longer time in finding a string that would give a required number of leading zeros. Increasing the number of work units beyond this, at times, leads to generation and checking of redundant strings thereby resulting in a longer time in finding a required string for the given number of leading zeros. 

**Results for running ./project1 4**

Given below are first 10 results for ./project1 4. Results after that have been skipped in this Readme.

`adityavhegde;5Bl     0000eb267d82a067611d3a091e6eed940fe6240e1a3a41dcf45a1ff9dae98593` <br/>
`adityavhegde;Js6Y    0000e1c58a963f1dbbed3086c98d162abeefab15ed2ab27449633db65a8b7515` <br/>
`adityavhegde;FaZLha1tzuLIR    0000c65d572fcb16aec8e5e357996dc4409688cb491eddb52328792c4f50883b` <br/>
`adityavhegde;zyjCYs    00007b4f4219aef4698d3336aef1a1779568046f4846cc69f3574e06367be64a` <br/>
`adityavhegde;iEWF4q927NJ5    000024d305729a2e3e724c878f641414a12ae889aa7de39da4bc352b211ac1cb` <br/>
`adityavhegde;Dv4    0000f75d27b9266d4986a05667b9b1bb5b57eed3a48ef468c83e95bcaaaf47cb` <br/>
`adityavhegde;fPaOxGM    00005754faf5dbc000a0a1c8523ef5b0917bbc9abc9beef9e1754d33f179e0bc` <br/>
`adityavhegde;PMAO    0000e3280cec667f5fe0288c05921d9bc2bf63c7def6458ba64eeaeb8845a336` <br/>
`adityavhegde;YSC88vGJGZjb    0000981f2652686ecfdffaebf627a9db9da966472dec92cca97b80fa7055091a` <br/>
`adityavhegde;xR31PPnH14J6    00007f8196c1c5e10d0fad3a3a517463b107da4946c00aa7fba11daa87e81139` <br/>


**Ratio of CPU Time to Real Time**

Upon running on an 8 core machine, the CPU to Real Time ratio of `7.9` was obtained.


**Coin with most 0s mined**

Coins with a maximum of 7 leading zeros were found. Below are the coins:

`adityavhegde;2VWFQsJ848v    0000000e081cbf5d5fe9a4f33bbb77024fb1ea3286bcc0dba326a4adf0d74cee` <br/>
`adityavhegde;g3IC5iKqt    000000034173f2867556ce1db4b5f945021750ccc4b7a24c9f4155abb90b92af` <br/>
`adityavhegde;tgludaaaaaaaaaaaaaaaaaaaaa    000000078f4a503bc821c0f17556c38ff346781a90277ee18a4eb79718c00efa` <br/>



**Largest number of working machines the code was run on**

The code was successfully run on 4 working machines simultaneously, with one machine working as the Server and the rest as clients.
