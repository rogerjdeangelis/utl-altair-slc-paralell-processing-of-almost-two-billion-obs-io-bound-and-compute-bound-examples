/* State-partitioned random data generation.

   Adapted from the repo's opening DATA step, which builds one indexed
   table of ~1.6 billion rows (200e6 per state) on the WPD engine at
   e:/spde. The array-of-states + nested-do-loop + uniform() structure
   is kept exactly as written; only the output library (WORK instead of
   the external WPD libname) and the per-state row count (50 instead of
   200e6) are changed so the same code runs anywhere. */

data inp(index=(state));
   array states[8] $2 ("TN","TX","UT","VT","MD","MA","MI","MN");
   do s=1 to dim(states);
     state=states[s];
     do i=1 to 50;
       ran=uniform(65432);
       output;
     end;
   end;
   drop s i states:;
 stop;
run;

proc sql;
   select state, count(*) as n, min(ran) as min_ran, max(ran) as max_ran
   from inp
   group by state
   order by state;
quit;

proc print data=inp(obs=5);
   title "First 5 generated observations";
run;
