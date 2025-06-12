***********************************************************************
**Code to retrieve Common Mental Disorders from inpatient registers**
***********************************************************************
		
split diagnos


drop if indatuma==.	

*Generic mental index 
gen mental_index=0  
foreach var of varlist hdia diagnos1-diagnos30{
  replace `var'=substr(`var',2,5) if substr(`var',1,1)=="-"
  replace mental_index= 1 ///
  if inlist(substr(`var',1,3),"291","292","293","294","295") | inlist(substr(`var',1,3),"296","297","298","299","300","301","302","303")| ///
   inlist(substr(`var',1,3),"304","305","306","307","308","309","310","311") | inlist(substr(`var',1,3),"312","313","314","315","316","317","318","319") | ///
  inlist(substr(`var',1,2),"F1","F2","F3","F4") | inlist(substr(`var',1,2),"F5","F6","F7","F8","F9")
  } 
 

   
*SUD (except F17 tobacco)
  gen sud=0  
  foreach var of varlist hdia diagnos1-diagnos30 {
  replace `var'=substr(`var',2,5) if substr(`var',1,1)=="-"
  replace sud= 1 ///
  if inlist(substr(`var',1,3), "291", "303", "305") | (inlist(substr(`var',1,3),"F10", "F11", "F12", "F13", "F14", "F15", "F16", "F18", "F19"))
  }

*Psychosis / Schizophrenia
  gen psychosis=0  
  foreach var of varlist hdia diagnos1-diagnos30 {
  replace `var'=substr(`var',2,5) if substr(`var',1,1)=="-"
  replace psychosis= 1 ///
  if inlist(substr(`var',1,3), "295", "297", "298")  | (inlist(substr(`var',1,2),"F2"))
  }
  
*Affective Disorders (should be include manic/bipolar? Other studies don't...mark it just in case)
 gen affective=0  
  foreach var of varlist hdia diagnos1-diagnos30 {
  replace `var'=substr(`var',2,5) if substr(`var',1,1)=="-"
  replace affective= 1 ///
  if inlist(substr(`var',1,3), "296", "311", "301") | (inlist(substr(`var',1,2),"F3"))
  }

gen bipolar=0  
  foreach var of varlist hdia diagnos1-diagnos30 {
  replace `var'=substr(`var',2,5) if substr(`var',1,1)=="-"
  replace bipolar= 1 ///
  if inlist(substr(`var',1,3), "296") | (inlist(substr(`var',1,3),"F30", "F31"))
  }
  
*Stress & Anxiety
 gen stress=0  
  foreach var of varlist hdia diagnos1-diagnos30 {
  replace `var'=substr(`var',2,5) if substr(`var',1,1)=="-"
  replace stress= 1 ///
  if (inlist(substr(`var',1,3),"300", "306", "308", "309")) | (inlist(substr(`var',1,2),"F4"))
  }
  
//F5: behavioural syndromes associated with physiological disturbances (e.g. eating disorder, sleep, etc.); F6: Personality disorders; F7: mental retardation; F8; learning disorders, autism; F9: Behavioural/emotional disorders with onset in childhood & adolescence (ADHD, conduct separation anxiety, stuttering...). 
  
  *Other behavioural/personality disorders (without retardation/learning disorders)
 gen other=0  
foreach var of varlist hdia diagnos1-diagnos30 {
  replace `var'=substr(`var',2,5) if substr(`var',1,1)=="-"
  replace other= 1 ///
  if inlist(substr(`var',1,3), "307", "302", "312", "313")  | (inlist(substr(`var',1,2),"F5","F6","F9")) 
  }
  
 *Self-harm
  gen selfharm=0  
  foreach var of varlist ekod1-ekod5{
  replace `var'=substr(`var',2,5) if substr(`var',1,1)=="-"
  replace selfharm= 1 ///
  if (inlist(substr(`var',1,3),"E95")) | (inlist(substr(`var',1,2),"X6", "X7")) ///
  | (inlist(substr(`var',1,3),"X80","X81","X82", "X83","X84")) 
  }
  
  *Events of undetermined intent (poisonings, falling, gunshot, etc)
 gen undetermined=0  
  foreach var of varlist ekod1-ekod5{
  replace `var'=substr(`var',2,5) if substr(`var',1,1)=="-"
  replace undetermined= 1 ///
  if inlist(substr(`var',1,3), "E98") ///
  | (inlist(substr(`var',1,3),"Y10", "Y11", "Y12", "Y13", "Y14", "Y15")) ///
  | (inlist(substr(`var',1,3), "Y16", "Y17", "Y18", "Y19")) ///
  | (inlist(substr(`var',1,3), "Y20", "Y21" "Y22", "Y23", "Y24" )) ///
  | (inlist(substr(`var',1,3), "Y25", "Y26", "Y27" "Y28", "Y29")) /// 
  | (inlist(substr(`var',1,3), "Y30", "Y31", "Y32", "Y33","Y34")) 
  } 
  
*Eating disorders ("F50")  
gen eating=0  
foreach var of varlist hdia diagnos1-diagnos30{
  replace `var'=substr(`var',2,5) if substr(`var',1,1)=="-"
  replace eating= 1 ///
  if inlist(substr(`var',1,3), "307") | (inlist(substr(`var',1,2),"F5")) 
  }
  
  

*Drop duplicates (in two rounds, keeping the one with VTID information)
duplicates tag lopnr ar indatuma, gen(dup)
bysort lopnr indatuma: egen X = max(vtid) if dup!=0
drop if dup!=0 & vtid!=X

drop X dup 
duplicates tag lopnr ar indatuma, gen(dup)
bysort lopnr indatuma: gen X = _n if dup!=0
drop if dup!=0 & X!=1
drop X dup 


