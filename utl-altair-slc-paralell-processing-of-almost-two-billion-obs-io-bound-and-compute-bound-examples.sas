%let pgm=utl-altair-slc-paralell-processing-of-almost-two-billion-obs-io-bound-and-compute-bound-examples;

%stop_submission;

Altair slc paralell processing of almost two billion obs io bound and compute bound examples

Too long to pst here, see github
https://github.com/rogerjdeangelis/utl-altair-slc-paralell-processing-of-almost-two-billion-obs-io-bound-and-compute-bound-examples

Perl and Python scripts are better suited for parallelization then sas systask?


                      1 JOB              PARALELL 8 JOBS
                      1.6 BILLION OBS    8x200 BILLION

   SORT IO BOUND        9 Minutes          4 Minutes *

   SUM COMPUTE BOUND    8 Minutes          1 Minute  **

*   to concatenate the 8 output datasets (suggest you not do this) takes 1 minute 22 seconds
**  to concatenate the 8 sums 1 hundreth of a second

CONTENTS

   1 IO BOUND
   ----------

      Sort all 1.6 billion 9 minutes 19 seconds
        real time : 9:19.001
        cpu time  : 48:30.953

      Create 8 partitions 200 million obs per partition, one partition per state

        real time : 4:05.275

        I suggest you keep the 8x200 million partitiions, because
        you can further paralellize by state for state staistics.

        If you want one 1.6 billion dataset use proc append,
        proc append base=wpde.al data=wpdf.MA;run;
        proc append base=wpde.al data=wpdf.MD;run;
        ...
        proc append base=wpde.al data=wpdf.VT;run;

        real time : 1:22.099
        cpu time  : 1:21.156

        Same output for 1.6 billion sort and 8x200 billion subset

        OUTPUT
        e:\spde\wpd.al

        Altair SLC

        Obs           STATE        RAN

         1             MA      9.313226E-10
         2             MA      1.3969839E-9
         3             MA      5.1222742E-9
         4             MA      1.4901161E-8
         5             MA      1.5832484E-8
        ...
         1599999996    VT      0.9999999846
         1599999997    VT      0.9999999865
         1599999998    VT      0.9999999953
         1599999999    VT      0.9999999958
         1600000000    VT      0.9999999972


   2 COMPUTE BOUND
   ---------------

      Sum values by state
      Sum all 1.6 billion values 8 minutes 18 seconds by state

      real time : 8:17.567
      cpu time  : 8:16.781

      Partition into 8 200 million datasets, 1 per state (TN TX UT VT MD MA MI MN)

      real time : 1:03.538

      Same output 1.6 billion and 8x200 billion

      STATEABV = MA   TOT = 174.645   200 million values summed
      STATEABV = MD   TOT = 176.315
      STATEABV = MI   TOT = 193.768
      STATEABV = MN   TOT = 175.254
      STATEABV = TN   TOT = 171.549
      STATEABV = TX   TOT = 179.123
      STATEABV = UT   TOT = 175.671
      STATEABV = VT   TOT = 194.499

Timings

Direct sort of 1.6 billion obs with one output 8:37.942  ( 8 mintes 37 seconds)
Partition sort 8 subset tables with 200 million obs per table ( 3 minutes 45 seconds)
For very large tables partitioning is often the best solution.

Random numbers have the worst locality of reference and are a worst case for a sort.

One caveat, the technique here outputs 8 sorted subset tables each with 200 million obs.
This is an avantage over one table of 1.6 billion obs, it allows futher paralleization.

If you want to materialize the sorted 1.6 billion obs just use append

Note: Dtaabase Teradata and orcle exadata do partioning dynamically even sometimes
creating indexis. Skew alalysis is key to create equal size partitions.

System

  Win 11 Pro 64bit
  Dell 7610 (very old system. I suspect your rsults will be better)
  128gb ram
  dual Nvme 1tb
  dual 3.3gz XEON cpus (twoo socket mothe board)
  three 32in monitors
  logitech G502 kero programable mouse (over two dozen actions)
  dell enhanced expanded keyboard (all function keys set (approx 36 actions)
  1200 watt power supply
  four hot swappable ssd drives , two 1tb internal NVMe drives

/*   _       _                           _
/ | (_) ___ | |__   ___  _   _ _ __   __| |
| | | |/ _ \| `_ \ / _ \| | | | `_ \ / _` |
| | | | (_) | |_) | (_) | |_| | | | | (_| |
|_| |_|\___/|_.__/ \___/ \__,_|_| |_|\__,_|
 _                   _
(_)_ __  _ __  _   _| |_
| | `_ \| `_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
*/

libname wpde wpd "e:/spde";

data wpde.inp(index=(state));
   array states[8] $2 ("TN","TX","UT","VT","MD","MA","MI","MN");
   do s=1 to dim(states);
     state=states[s];
     do i=1 to 200e6;
       ran=uniform(65432);
       output;
     end;
   end;
   drop s i states:;
 stop;
run;


/*---
inp.wpd     15,841,952KB (15.8GB 1.6 billion obs 2 variables)
inp.wpdidx   9,434,912KB

NOTE: Data set "WPDE.inp" has 1600000000 observation(s) and 2 variable(s)
NOTE: The data step took :
      real time : 7:32.997
      cpu time  : 12:03.781

Altair SLC

e:/spde/inp.wpd

          Obs STATE  RAN

            1    TN 0.8936485494
            2    TN 0.4185135525
            3    TN 0.4397846891
            4    TN 0.9810414012
            5    TN 0.9203517739
...
1,599,999,996    MN 0.8534309249
1,599,999,997    MN 0.3041245468
1,599,999,998    MN 0.0925580734
1,599,999,999    MN 0.6827331575
1,600,000,000    MN 0.2693004530
---*/

/*              _     _   __     _     _ _ _ _
 ___  ___  _ __| |_  / | / /_   | |__ (_) | (_) ___  _ __
/ __|/ _ \| `__| __| | || `_ \  | `_ \| | | | |/ _ \| `_ \
\__ \ (_) | |  | |_  | || (_) | | |_) | | | | | (_) | | | |
|___/\___/|_|   \__| |_(_)___/  |_.__/|_|_|_|_|\___/|_| |_|

*/

libname wpde wpd "e:/spde";
libname wpdf wpd "f:/spdf";

proc sort data=wpde.inp out=wpdf.all noequals;
 by state ran;
run;

NOTE: 1600,000,000 observations were read from "WPDE.inp"
NOTE: Data set "WPDF.all" has 1.600.000.000 observation(s) and 2 variable(s)
NOTE: Procedure sort step took :
      real time : 9:19.001
      cpu time  : 48:30.953

/*               _           ___      _       _
 _ __ ___   __ _| | _____   ( _ )    (_) ___ | |__  ___
| `_ ` _ \ / _` | |/ / _ \  / _ \    | |/ _ \| `_ \/ __|
| | | | | | (_| |   <  __/ | (_) |   | | (_) | |_) \__ \
|_| |_| |_|\__,_|_|\_\___|  \___/   _/ |\___/|_.__/|___/
                                   |__/
*/

/*--- subset by observation numbers ---*/

data jpbs;
 retain libs 'libname wpde wpd "e:/spde";libname wpdf wpd "f:/spdf";';
 array jobs[8] $95 (
   'proc sort data = wpde.inp(where=(state="TN")) out= wpdf.TN noequals;by state ran;run;'
   'proc sort data = wpde.inp(where=(state="TX")) out= wpdf.TX noequals;by state ran;run;'
   'proc sort data = wpde.inp(where=(state="UT")) out= wpdf.UT noequals;by state ran;run;'
   'proc sort data = wpde.inp(where=(state="VT")) out= wpdf.VT noequals;by state ran;run;'
   'proc sort data = wpde.inp(where=(state="MD")) out= wpdf.MD noequals;by state ran;run;'
   'proc sort data = wpde.inp(where=(state="MA")) out= wpdf.MA noequals;by state ran;run;'
   'proc sort data = wpde.inp(where=(state="MI")) out= wpdf.MI noequals;by state ran;run;'
   'proc sort data = wpde.inp(where=(state="MN")) out= wpdf.MN noequals;by state ran;run;'
   );
 array fyls[8] $16 (
    'd:/sas/j1.sas'
    'd:/sas/j2.sas'
    'd:/sas/j3.sas'
    'd:/sas/j4.sas'
    'd:/sas/j5.sas'
    'd:/sas/j6.sas'
    'd:/sas/j7.sas'
    'd:/sas/j8.sas'
    );
 do j=1 to 8;
   filen=fyls[j];
   file outfile filevar=filen;
   put libs;
   put jobs[j];
 end;
stop;
run;quit;

/*----

D:\SAS
    j1.sas (first 200 million )
      libname wpde wpd "e:/spde";libname wpdf wpd "f:/spdf";
      proc sort data = wpde.inp(where=(state="TN")) out= wpdf.TN noequals;by state ran;run;
    j2.sas
    j3.sas
    j4.sas
    j5.sas
    j6.sas
    j7.sas
    j8.sas

/*
 _ __  _ __ ___   ___ ___  ___ ___
| `_ \| `__/ _ \ / __/ _ \/ __/ __|
| |_) | | | (_) | (_|  __/\__ \__ \
| .__/|_|  \___/ \___\___||___/___/
|_|
*/

options set=PYTHONHOME "D:\py314";
proc python;
submit;
import subprocess
import concurrent.futures
import os
import time  # Add time module

def run_wps_job(job_name, script_path, log_path):
    """Run a single WPS job"""
    wps_exe = r"C:\Program Files\Altair\SLC\2026\bin\wps.exe"
    cmd = [wps_exe, '-sysin', script_path, '-log', log_path]

    print(f"Starting {job_name}...")

    # Time the individual job
    job_start = time.time()
    result = subprocess.run(cmd, capture_output=True, text=True)
    job_end = time.time()

    job_duration = job_end - job_start
    print(f"{job_name}: Completed in {job_duration:.2f} seconds")

    # Check if log file was created
    if os.path.exists(log_path):
        print(f"{job_name}: Log file created at {log_path}")

    return job_name, result.returncode, job_duration

# Define jobs
jobs = [
    ("Job1", r"d:\sas\j1.sas", r"d:\log\j1.log"),
    ("Job2", r"d:\sas\j2.sas", r"d:\log\j2.log"),
    ("Job3", r"d:\sas\j3.sas", r"d:\log\j3.log"),
    ("Job4", r"d:\sas\j4.sas", r"d:\log\j4.log"),
    ("Job5", r"d:\sas\j5.sas", r"d:\log\j5.log"),
    ("Job6", r"d:\sas\j6.sas", r"d:\log\j6.log"),
    ("Job7", r"d:\sas\j7.sas", r"d:\log\j7.log"),
    ("Job8", r"d:\sas\j8.sas", r"d:\log\j8.log")
]

# Time the entire parallel execution
total_start = time.time()

# Run jobs in parallel using ThreadPoolExecutor (works better within SAS)
with concurrent.futures.ThreadPoolExecutor(max_workers=8) as executor:
    # Submit all jobs
    futures = [executor.submit(run_wps_job, *job) for job in jobs]

    # Wait for all to complete and get results
    for future in concurrent.futures.as_completed(futures):
        job_name, returncode, job_duration = future.result()
        print(f"{job_name}: Completed with return code {returncode} (took {job_duration:.2f} seconds)")

total_end = time.time()
total_duration = total_end - total_start

print(f"All jobs completed in  {total_duration:.2f} seconds!")
print(f"Parallel execution saved approximately {sum([f.result()[2] for f in futures]) - total_duration:.2f} seconds compared to sequential execution")
endsubmit;
run;

/*
| | ___   __ _
| |/ _ \ / _` |
| | (_) | (_| |
|_|\___/ \__, |
         |___/
*/

NOTE: Submitted statements took :
      real time : 4:05.275
      cpu time  : 0:00.125


1                                          Altair SLC        08:16 Friday, January 23, 2026

NOTE: Copyright 2002-2025 World Programming, an Altair Company
NOTE: Altair SLC 2026 (05.26.01.00.000758)
      Licensed to Roger DeAngelis
NOTE: This session is executing on the X64_WIN11PRO platform and is running in 64 bit mode

NOTE: AUTOEXEC processing beginning; file is C:\wpsoto\autoexec.sas
NOTE: AUTOEXEC source line
1       +  ï»¿ods _all_ close;
           ^
ERROR: Expected a statement keyword : found "?"
NOTE: Library workx assigned as follows:
      Engine:        SAS7BDAT
      Physical Name: d:\wpswrkx

NOTE: Library slchelp assigned as follows:
      Engine:        WPD
      Physical Name: C:\Progra~1\Altair\SLC\2026\sashelp


LOG:  8:16:20
NOTE: 1 record was written to file PRINT

NOTE: The data step took :
      real time : 0.015
      cpu time  : 0.015


NOTE: AUTOEXEC processing completed

1         options set=PYTHONHOME "D:\py314";
2         proc python;
3         submit;
4         import subprocess
5         import concurrent.futures
6         import os
7         import time  # Add time module
8
9         def run_wps_job(job_name, script_path, log_path):
10            """Run a single WPS job"""
11            wps_exe = r"C:\Program Files\Altair\SLC\2026\bin\wps.exe"
12            cmd = [wps_exe, '-sysin', script_path, '-log', log_path]
13
14            print(f"Starting {job_name}...")
15
16            # Time the individual job
17            job_start = time.time()
18            result = subprocess.run(cmd, capture_output=True, text=True)
19            job_end = time.time()
20
21            job_duration = job_end - job_start
22            print(f"{job_name}: Completed in {job_duration:.2f} seconds")
23
24            # Check if log file was created
25            if os.path.exists(log_path):
26                print(f"{job_name}: Log file created at {log_path}")
27
28            return job_name, result.returncode, job_duration
29
30        # Define jobs
31        jobs = [
32            ("Job1", r"d:\sas\j1.sas", r"d:\log\j1.log"),
33            ("Job2", r"d:\sas\j2.sas", r"d:\log\j2.log"),
34            ("Job3", r"d:\sas\j3.sas", r"d:\log\j3.log"),

2                                                                                                                         Altair SLC

35            ("Job4", r"d:\sas\j4.sas", r"d:\log\j4.log"),
36            ("Job5", r"d:\sas\j5.sas", r"d:\log\j5.log"),
37            ("Job6", r"d:\sas\j6.sas", r"d:\log\j6.log"),
38            ("Job7", r"d:\sas\j7.sas", r"d:\log\j7.log"),
39            ("Job8", r"d:\sas\j8.sas", r"d:\log\j8.log")
40        ]
41
42        # Time the entire parallel execution
43        total_start = time.time()
44
45        # Run jobs in parallel using ThreadPoolExecutor (works better within SAS)
46        with concurrent.futures.ThreadPoolExecutor(max_workers=8) as executor:
47            # Submit all jobs
48            futures = [executor.submit(run_wps_job, *job) for job in jobs]
49
50            # Wait for all to complete and get results
51            for future in concurrent.futures.as_completed(futures):
52                job_name, returncode, job_duration = future.result()
53                print(f"{job_name}: Completed with return code {returncode} (took {job_duration:.2f} seconds)")
54
55        total_end = time.time()
56        total_duration = total_end - total_start
57
58        print(f"All jobs completed in  {total_duration:.2f} seconds!")
59        print(f"Parallel execution saved approximately {sum([f.result()[2] for f in futures]) - total_duration:.2f} seconds compared to sequential execution")
60        endsubmit;

NOTE: Submitting statements to Python:


61        run;
NOTE: Procedure python step took :
      real time : 4:05.205
      cpu time  : 0:00.031


ERROR: Error printed on page 1

NOTE: Submitted statements took :
      real time : 4:05.275
      cpu time  : 0:00.125

run;

/*--- if you want to further analysis use this view
All jobs completed in 271.80 seconds!


libname wpde wpd "e:/spde";
libname wpdf wpd "f:/spdf";

proc delete data=wpde.al;
run;

proc append base=wpde.al data=wpdf.MA;run;
proc append base=wpde.al data=wpdf.MD;run;
proc append base=wpde.al data=wpdf.MI;run;
proc append base=wpde.al data=wpdf.MN;run;
proc append base=wpde.al data=wpdf.TN;run;
proc append base=wpde.al data=wpdf.TX;run;
proc append base=wpde.al data=wpdf.UT;run;
proc append base=wpde.al data=wpdf.VT;run;

NOTE: Submitted statements took :
      real time : 1:22.099
      cpu time  : 1:21.156

/*           _               _
  ___  _   _| |_ _ __  _   _| |_
 / _ \| | | | __| `_ \| | | | __|
| (_) | |_| | |_| |_) | |_| | |_
 \___/ \__,_|\__| .__/ \__,_|\__|
                |_|
*/


e:\spde\wpd.al

Altair SLC

Obs           STATE        RAN

 1             MA      9.313226E-10
 2             MA      1.3969839E-9
 3             MA      5.1222742E-9
 4             MA      1.4901161E-8
 5             MA      1.5832484E-8
...
 1599999996    VT      0.9999999846
 1599999997    VT      0.9999999865
 1599999998    VT      0.9999999953
 1599999999    VT      0.9999999958
 1600000000    VT      0.9999999972



Altair SLC
LIST: 8:39:42

Altair SLC

The CONTENTS Procedure

Data Set Name           AL
Member Type             DATA
Engine                  WPD
Created                 23JAN2026:08:26:07
Last Modified           23JAN2026:08:27:43
Observations            1,600,000,000
Variables               2
Indexes                 0
Observation Length      10
Deleted Observations             0
Data Set Type
Label
Compressed              NO
Sorted                  NO
Data Representation     Little endian, IEEE Windows
Encoding                wlatin1 Windows-1252 Western

    Engine/Host Dependent Information

Data Set Page Size          4096
Number of Data Set Pages    3960398
First Data Page             1
Max Obs Per Page            404
Obs In First Data Page      404
Data Set Diagnostic Code    0013
File Name                   e:\spde\AL.wpd
WPD Engine Version          3
Large Data Set Support      no
Encrypted                   no

          Alphabetic List of Variables and Attributes

      Number    Variable    Type             Len             Pos
________________________________________________________________
           2    RAN         Num                8               0
           1    STATE       Char               2               8

libname wpde wpd "e:/spde";

proc print data=wpde.al(obs=5);
run;

proc print data=wpde.al(firstobs=1599999996);
run;

Altair SLC
LIST: 8:48:34

Altair SLC

The PYTHON Procedure

Starting Job1...

Starting Job2...

Starting Job3...

Starting Job4...

Starting Job5...

Starting Job6...

Starting Job7...

Starting Job8...

Job1: Completed in 165.99 seconds

Job1: Log file created at d:\log\j1.log

Job1: Completed with return code 0 (took 165.99 seconds)

Job2: Completed in 179.02 seconds

Job2: Log file created at d:\log\j2.log

Job2: Completed with return code 0 (took 179.02 seconds)

Job3: Completed in 192.94 seconds

Job3: Log file created at d:\log\j3.log

Job3: Completed with return code 0 (took 192.94 seconds)

Job4: Completed in 203.82 seconds

Job4: Log file created at d:\log\j4.log

Job4: Completed with return code 0 (took 203.82 seconds)

Job6: Completed in 236.86 seconds

Job6: Log file created at d:\log\j6.log

Job6: Completed with return code 0 (took 236.86 seconds)

Job5: Completed in 241.88 seconds

Job5: Log file created at d:\log\j5.log

Job5: Completed with return code 0 (took 241.88 seconds)

Job7: Completed in 248.93 seconds

Job7: Log file created at d:\log\j7.log

Job7: Completed with return code 0 (took 248.93 seconds)

Job8: Completed in 252.81 seconds

Job8: Log file created at d:\log\j8.log

Job8: Completed with return code 0 (took 252.81 seconds)

All jobs completed in  252.82 seconds!

Parallel execution saved approximately 1469.42 seconds compared to sequential execution


/*___                                    _        _                           _
|___ \    ___ ___  _ __ ___  _ __  _   _| |_ ___ | |__   ___  _   _ _ __   __| |
  __) |  / __/ _ \| `_ ` _ \| `_ \| | | | __/ _ \| `_ \ / _ \| | | | `_ \ / _` |
 / __/  | (_| (_) | | | | | | |_) | |_| | ||  __/| |_) | (_) | |_| | | | | (_| |
|_____|  \___\___/|_| |_| |_| .__/ \__,_|\__\___||_.__/ \___/ \__,_|_| |_|\__,_|
                            |_|
*/

data _null:;
   array states[8] $2 ("TN","TX","UT","VT","MD","MA","MI","MN");
   tot=0;
   do s=1 to dim(states);
     state=states[s];
     do rec=1 to 200e6;
        x=PDF('BETA', uniform(1254), 0.1, 0.9)/10e5;
        tot =  tot + x;
     end;
     put state= tot=;
     tot=0;
   end;
 stop;
run;

/*---
NOTE: The data step took :
      real time : 8:17.567
      cpu time  : 8:16.781

STATE=TN TOT=178.31980412
STATE=TX TOT=168.66378914
STATE=UT TOT=195.23274767
STATE=VT TOT=176.18865427
STATE=MD TOT=166.60717703
STATE=MA TOT=186.01880462
STATE=MI TOT=175.2321656
STATE=MN TOT=172.66908554
---*/

/*               _           ___      _       _
 _ __ ___   __ _| | _____   ( _ )    (_) ___ | |__  ___
| `_ ` _ \ / _` | |/ / _ \  / _ \    | |/ _ \| `_ \/ __|
| | | | | | (_| |   <  __/ | (_) |   | | (_) | |_) \__ \
|_| |_| |_|\__,_|_|\_\___|  \___/   _/ |\___/|_.__/|___/
                                   |__/
*/

data _null_;
   array states[8] $2 ("TN","TX","UT","VT","MD","MA","MI","MN");
   tot=0;
   do s=1 to dim(states);
     fyl      = cats("d:/sas/",states[s],'.sas');
     add      = cats('data ot.',states(s),';');
     stateabv = cats('stateabv="',states(s),'";');
     seed     = cats('call streaminit(',s,');');
     file outfile filevar=fyl;
       put 'libname ot wpd "e:/spde";                      ';
       put add                                              ;
       put 'tot=0;                                         ';
       put seed                                             ;
       put 'do rec=1 to 200e6;                             ';
       put '   x=PDF("BETA",rand("uniform"),0.1, 0.9)/10e5;';
       put '   tot =  tot + x;                             ';
       put 'end;                                           ';
       put stateabv                                         ;
       put 'keep stateabv tot;                             ';
       put 'output;                                        ';
       put 'stop;                                          ';
       put 'run;                                           ';
       put 'libname ot clear;                              ';
   end;
   stop;
run;

/*---

x 'tree "d:/sas" /F /A | clip';

D:\SAS
    MA.sas
      libname ot wpd "e:/spde";
      data ot.MA;
      tot=0;
      call streaminit(6);
      do rec=1 to 200e6;
         x=PDF("BETA",rand("uniform"),0.1, 0.9)/10e5;
         tot =  tot + x;
      end;
      stateabv="MA";
      keep stateabv tot;
      output;
      stop;
      run;
      libname ot clear;
    MD.sas
    MI.sas
    MN.sas
    TN.sas
    TX.sas
    UT.sas
    VT.sas
---*/

/*
 _ __  _ __ ___   ___ ___  ___ ___
| `_ \| `__/ _ \ / __/ _ \/ __/ __|
| |_) | | | (_) | (_|  __/\__ \__ \
| .__/|_|  \___/ \___\___||___/___/
|_|
*/

options set=PYTHONHOME "D:\py314";
proc python;
submit;
import subprocess
import concurrent.futures
import os
import time  # Add time module

def run_wps_job(job_name, script_path, log_path):
    """Run a single WPS job"""
    wps_exe = r"C:\Program Files\Altair\SLC\2026\bin\wps.exe"
    cmd = [wps_exe, '-sysin', script_path, '-log', log_path]

    print(f"Starting {job_name}...")

    # Time the individual job
    job_start = time.time()
    result = subprocess.run(cmd, capture_output=True, text=True)
    job_end = time.time()

    job_duration = job_end - job_start
    print(f"{job_name}: Completed in {job_duration:.2f} seconds")

    # Check if log file was created
    if os.path.exists(log_path):
        print(f"{job_name}: Log file created at {log_path}")

    return job_name, result.returncode, job_duration

# Define jobs
jobs = [
    ("Job1", r"d:\sas\TN.sas", r"d:\log\TN.log"),
    ("Job2", r"d:\sas\TX.sas", r"d:\log\TX.log"),
    ("Job3", r"d:\sas\UT.sas", r"d:\log\UT.log"),
    ("Job4", r"d:\sas\VT.sas", r"d:\log\VT.log"),
    ("Job5", r"d:\sas\MD.sas", r"d:\log\MD.log"),
    ("Job6", r"d:\sas\MA.sas", r"d:\log\MA.log"),
    ("Job7", r"d:\sas\MI.sas", r"d:\log\MI.log"),
    ("Job8", r"d:\sas\MN.sas", r"d:\log\MN.log")
]
# Time the entire parallel execution
total_start = time.time()

# Run jobs in parallel using ThreadPoolExecutor (works better within SAS)
with concurrent.futures.ThreadPoolExecutor(max_workers=8) as executor:
    # Submit all jobs
    futures = [executor.submit(run_wps_job, *job) for job in jobs]

    # Wait for all to complete and get results
    for future in concurrent.futures.as_completed(futures):
        job_name, returncode, job_duration = future.result()
        print(f"{job_name}: Completed with return code {returncode} (took {job_duration:.2f} seconds)")

total_end = time.time()
total_duration = total_end - total_start

print(f"All jobs completed in  {total_duration:.2f} seconds!")
print(f"Parallel execution saved approximately {sum([f.result()[2] for f in futures]) - total_duration:.2f} seconds compared to sequential execution")
endsubmit;
run;

libname ot wpd "e:/spde";

data states;
 set
   ot.MA
   ot.MD  /*--- manually rearange in alphabetic error ---*/
   ot.MI
   ot.MN
   ot.TN
   ot.TX
   ot.UT
   ot.VT
   ;
   put stateabv= tot=;
run;quit;

proc print data=states;
title "Totals by state";
run;quit;

/*---

NOTE: Submitted statements took :
real time : 1:03.538

proc print data=states;
title "Totals by state";
run;quit;

work.states

Obs      TOT      STATEABV

 1     174.646       MA
 2     176.315       MD
 3     193.769       MI
 4     175.255       MN
 5     171.550       TN
 6     179.124       TX
 7     175.672       UT
 8     194.500       VT

The PYTHON Procedure

Starting Job1...

Starting Job2...

Starting Job3...

Starting Job4...

Starting Job5...

Starting Job6...

Starting Job7...

Starting Job8...

Job1: Completed in 59.48 seconds

Job1: Log file created at d:\log\TN.log

Job1: Completed with return code 0 (took 59.48 seconds)

Job4: Completed in 59.76 seconds

Job4: Log file created at d:\log\VT.log

Job4: Completed with return code 0 (took 59.76 seconds)

Job2: Completed in 59.81 seconds

Job2: Log file created at d:\log\TX.log

Job2: Completed with return code 0 (took 59.81 seconds)

Job8: Completed in 62.26 seconds

Job8: Log file created at d:\log\MN.log

Job8: Completed with return code 0 (took 62.26 seconds)

Job3: Completed in 62.29 seconds

Job3: Log file created at d:\log\UT.log

Job3: Completed with return code 0 (took 62.29 seconds)

Job5: Completed in 62.43 seconds

Job5: Log file created at d:\log\MD.log

Job5: Completed with return code 0 (took 62.43 seconds)

Job6: Completed in 62.56 seconds

Job6: Log file created at d:\log\MA.log

Job6: Completed with return code 0 (took 62.56 seconds)

Job7: Completed in 62.64 seconds

Job7: Log file created at d:\log\MI.log

Job7: Completed with return code 0 (took 62.64 seconds)

All jobs completed in  62.65 seconds!

Parallel execution saved approximately 428.58 seconds compared to sequential execution
---*/

/*
| | ___   __ _
| |/ _ \ / _` |
| | (_) | (_| |
|_|\___/ \__, |
         |___/
*/

1                                          Altair SLC        14:36 Friday, January 23, 2026

NOTE: Copyright 2002-2025 World Programming, an Altair Company
NOTE: Altair SLC 2026 (05.26.01.00.000758)
      Licensed to Roger DeAngelis
NOTE: This session is executing on the X64_WIN11PRO platform and is running in 64 bit mode

NOTE: AUTOEXEC processing beginning; file is C:\wpsoto\autoexec.sas
NOTE: AUTOEXEC source line
1       +  ï»¿ods _all_ close;
           ^
ERROR: Expected a statement keyword : found "?"
NOTE: Library workx assigned as follows:
      Engine:        SAS7BDAT
      Physical Name: d:\wpswrkx

NOTE: Library slchelp assigned as follows:
      Engine:        WPD
      Physical Name: C:\Progra~1\Altair\SLC\2026\sashelp


LOG:  14:36:52
NOTE: 1 record was written to file PRINT

NOTE: The data step took :
      real time : 0.020
      cpu time  : 0.000


NOTE: AUTOEXEC processing completed

1         data _null_;
2            array states[8] $2 ("TN","TX","UT","VT","MD","MA","MI","MN");
3            tot=0;
4            do s=1 to dim(states);
5              fyl      = cats("d:/sas/",states[s],'.sas');
6              add      = cats('data ot.',states(s),';');
7              stateabv = cats('stateabv="',states(s),'";');
8              seed     = cats('call streaminit(',s,');');
9              file outfile filevar=fyl;
10               put 'libname ot wpd "e:/spde";                      ';
11               put add                                              ;
12               put 'tot=0;                                         ';
13               put seed                                             ;
14               put 'do rec=1 to 200e6;                               ';
15               put '   x=PDF("BETA",rand("uniform"),0.1, 0.9)/10e5;';
16               put '   tot =  tot + x;                             ';
17               put 'end;                                           ';
18               put stateabv                                         ;
19               put 'keep stateabv tot;                             ';
20               put 'output;                                        ';
21               put 'stop;                                          ';
22               put 'run;                                           ';
23               put 'libname ot clear;                              ';
24           end;
25           stop;
26        run;

NOTE: The file  is:
      Filename='d:\sas\TN.sas',
      Owner Name=SLC\suzie,
      File size (bytes)=0,
      Create Time=10:48:42 Jan 23 2026,
      Last Accessed=14:36:52 Jan 23 2026,
      Last Modified=14:36:52 Jan 23 2026,

2                                                                                                                         Altair SLC

      Lrecl=32767, Recfm=V

NOTE: The file  is:
      Filename='d:\sas\TX.sas',
      Owner Name=SLC\suzie,
      File size (bytes)=0,
      Create Time=10:48:42 Jan 23 2026,
      Last Accessed=14:36:52 Jan 23 2026,
      Last Modified=14:36:52 Jan 23 2026,
      Lrecl=32767, Recfm=V

NOTE: The file  is:
      Filename='d:\sas\UT.sas',
      Owner Name=SLC\suzie,
      File size (bytes)=0,
      Create Time=10:48:42 Jan 23 2026,
      Last Accessed=14:36:52 Jan 23 2026,
      Last Modified=14:36:52 Jan 23 2026,
      Lrecl=32767, Recfm=V

NOTE: The file  is:
      Filename='d:\sas\VT.sas',
      Owner Name=SLC\suzie,
      File size (bytes)=0,
      Create Time=10:48:42 Jan 23 2026,
      Last Accessed=14:36:52 Jan 23 2026,
      Last Modified=14:36:52 Jan 23 2026,
      Lrecl=32767, Recfm=V

NOTE: The file  is:
      Filename='d:\sas\MD.sas',
      Owner Name=SLC\suzie,
      File size (bytes)=0,
      Create Time=10:48:42 Jan 23 2026,
      Last Accessed=14:36:52 Jan 23 2026,
      Last Modified=14:36:52 Jan 23 2026,
      Lrecl=32767, Recfm=V

NOTE: The file  is:
      Filename='d:\sas\MA.sas',
      Owner Name=SLC\suzie,
      File size (bytes)=0,
      Create Time=10:48:42 Jan 23 2026,
      Last Accessed=14:36:52 Jan 23 2026,
      Last Modified=14:36:52 Jan 23 2026,
      Lrecl=32767, Recfm=V

NOTE: The file  is:
      Filename='d:\sas\MI.sas',
      Owner Name=SLC\suzie,
      File size (bytes)=0,
      Create Time=10:48:42 Jan 23 2026,
      Last Accessed=14:36:52 Jan 23 2026,
      Last Modified=14:36:52 Jan 23 2026,
      Lrecl=32767, Recfm=V

NOTE: The file  is:
      Filename='d:\sas\MN.sas',
      Owner Name=SLC\suzie,
      File size (bytes)=0,
      Create Time=10:48:42 Jan 23 2026,
      Last Accessed=14:36:52 Jan 23 2026,
      Last Modified=14:36:52 Jan 23 2026,

3                                                                                                                         Altair SLC

      Lrecl=32767, Recfm=V

NOTE: 14 records were written to file
      The minimum record length was 11
      The maximum record length was 49
NOTE: The data step took :
      real time : 0.010
      cpu time  : 0.015


27
28
29        options set=PYTHONHOME "D:\py314";
30        proc python;
31        submit;
32        import subprocess
33        import concurrent.futures
34        import os
35        import time  # Add time module
36
37        def run_wps_job(job_name, script_path, log_path):
38            """Run a single WPS job"""
39            wps_exe = r"C:\Program Files\Altair\SLC\2026\bin\wps.exe"
40            cmd = [wps_exe, '-sysin', script_path, '-log', log_path]
41
42            print(f"Starting {job_name}...")
43
44            # Time the individual job
45            job_start = time.time()
46            result = subprocess.run(cmd, capture_output=True, text=True)
47            job_end = time.time()
48
49            job_duration = job_end - job_start
50            print(f"{job_name}: Completed in {job_duration:.2f} seconds")
51
52            # Check if log file was created
53            if os.path.exists(log_path):
54                print(f"{job_name}: Log file created at {log_path}")
55
56            return job_name, result.returncode, job_duration
57
58        # Define jobs
59        jobs = [
60            ("Job1", r"d:\sas\TN.sas", r"d:\log\TN.log"),
61            ("Job2", r"d:\sas\TX.sas", r"d:\log\TX.log"),
62            ("Job3", r"d:\sas\UT.sas", r"d:\log\UT.log"),
63            ("Job4", r"d:\sas\VT.sas", r"d:\log\VT.log"),
64            ("Job5", r"d:\sas\MD.sas", r"d:\log\MD.log"),
65            ("Job6", r"d:\sas\MA.sas", r"d:\log\MA.log"),
66            ("Job7", r"d:\sas\MI.sas", r"d:\log\MI.log"),
67            ("Job8", r"d:\sas\MN.sas", r"d:\log\MN.log")
68        ]
69        # Time the entire parallel execution
70        total_start = time.time()
71
72        # Run jobs in parallel using ThreadPoolExecutor (works better within SAS)
73        with concurrent.futures.ThreadPoolExecutor(max_workers=8) as executor:
74            # Submit all jobs
75            futures = [executor.submit(run_wps_job, *job) for job in jobs]
76
77            # Wait for all to complete and get results
78            for future in concurrent.futures.as_completed(futures):
79                job_name, returncode, job_duration = future.result()

4                                                                                                                         Altair SLC

80                print(f"{job_name}: Completed with return code {returncode} (took {job_duration:.2f} seconds)")
81
82        total_end = time.time()
83        total_duration = total_end - total_start
84
85        print(f"All jobs completed in  {total_duration:.2f} seconds!")
86        print(f"Parallel execution saved approximately {sum([f.result()[2] for f in futures]) - total_duration:.2f} seconds compared to sequential execution")
87        endsubmit;

NOTE: Submitting statements to Python:


88        run;
NOTE: Procedure python step took :
      real time : 1:03.399
      cpu time  : 0:00.015


89
90        libname ot wpd "e:/spde";
NOTE: Library ot assigned as follows:
      Engine:        WPD
      Physical Name: e:\spde

91
92        data states;
93         set
94           ot.MA
95           ot.MD  /*--- manually rearange in alphabetic error ---*/
96           ot.MI
97           ot.MN
98           ot.TN
99           ot.TX
100          ot.UT
101          ot.VT
102          ;
103          put stateabv= tot=;
104       run;

STATEABV=MA TOT=174.64580735
STATEABV=MD TOT=176.31501991
STATEABV=MI TOT=193.76886037
STATEABV=MN TOT=175.25450647
STATEABV=TN TOT=171.5495824
STATEABV=TX TOT=179.12361973
STATEABV=UT TOT=175.67172073
STATEABV=VT TOT=194.4996827
NOTE: 1 observations were read from "OT.MA"
NOTE: 1 observations were read from "OT.MD"
NOTE: 1 observations were read from "OT.MI"
NOTE: 1 observations were read from "OT.MN"
NOTE: 1 observations were read from "OT.TN"
NOTE: 1 observations were read from "OT.TX"
NOTE: 1 observations were read from "OT.UT"
NOTE: 1 observations were read from "OT.VT"
NOTE: Data set "WORK.states" has 8 observation(s) and 2 variable(s)
NOTE: The data step took :
      real time : 0.010
      cpu time  : 0.015


104     !     quit;
105

5                                                                                                                         Altair SLC

106       proc print data=states;
107       title "Totals by state";
108       run;quit;
NOTE: 8 observations were read from "WORK.states"
NOTE: Procedure print step took :
      real time : 0.037
      cpu time  : 0.000


ERROR: Error printed on page 1


      real time : 1:03.538
      cpu time  : 0:00.109

/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/
