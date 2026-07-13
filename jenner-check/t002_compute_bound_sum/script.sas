/* Compute-bound per-state accumulation.

   Adapted from the repo's compute-bound example, which sums
   PDF('BETA', uniform(), 0.1, 0.9)/10e5 over 200e6 draws per state and
   reports one running total per state with put state= tot=. The array
   of states, the nested do-loops, the PDF/uniform accumulation and the
   per-state reset are kept as written; only the inner loop count is
   scaled from 200e6 to 1000 so the same arithmetic runs quickly. */

data _null_;
   array states[8] $2 ("TN","TX","UT","VT","MD","MA","MI","MN");
   tot=0;
   do s=1 to dim(states);
     state=states[s];
     do rec=1 to 1000;
        x=PDF('BETA', uniform(1254), 0.1, 0.9)/10e5;
        tot =  tot + x;
     end;
     put state= tot=;
     tot=0;
   end;
 stop;
run;
