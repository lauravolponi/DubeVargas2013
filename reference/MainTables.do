clear matrix
clear mata
clear
capture log close
set matsize 7000
set more off


glo dir "..."  /*directory to recover data*/

glo tab "..." /* directory to store tables*/
cd  "${tab}"


************************************************
* 	TABLE I: Summary Statistics of Key Variables
************************************************

cap log close
log using "Main_descriptive_statistics.log", replace

	clear
	use "${dir}\origmun_violence_commodities"
	
	*** panel level variables
	# delimit; 
	univar gueratt paratt clashes casualties govatt parmass guermass  guerkidpol  parkidpol  lpop lcaprev coca, dec(3); 

	*** municipal level variables
	# delimit; 
	univar   cofint  oilprod88      coalprod04 coalres78  goldprod04  mining78  coca94ind   coca94 evercoca  rainfall  temperature  yrspropara if year==1996, dec(3); 

	*** annual level variables
	# delimit; 
	univar linternalp lop  lcoalp lgoldp lsilverp lplatp	ltop3cof  ltop3coal if origmun==5002, dec(3);
	# delimit cr

	*** individual level variables
	clear
	use "${dir}\origmun_wages_commodities.dta"
	univar lwage, dec(3)    
	
	clear
	use "${dir}\origmun_hours_commodities.dta"
	univar lhours, dec(3)


	clear
	use "${dir}\origmun_migrant_commodities.dta"
	univar migrant, dec(3)

cap log close



*******************************************************************
* 	TABLE II: The Effect of the Coffee and Oil Shocks on Violence
*******************************************************************

	clear
	use "${dir}\origmun_violence_commodities"

	# delimit; 
	tsset origmun year, yearly; 
		xi: xtivreg2 gueratt    lpop    _Y*          _R*  coca94indxyear
		(cofintxlinternalp   = rxltop3cof txltop3cof  rtxltop3cof) 
		oilprod88xlop     
		   , cluster(department) partial(_R* _Y*)  fe first; 
		outreg2  cofintxlinternalp  oilprod88xlop         using  table2.xls, replace se  bdec(3) tdec(3) nocons nor noni; 
	# delimit; 
	foreach var of varlist paratt clashes casualties  {; 
	tsset origmun year, yearly; 
		xi: xtivreg2 `var'    lpop    _Y*        		_R*  coca94indxyear
		(cofintxlinternalp   = rxltop3cof txltop3cof  rtxltop3cof ) 
		 oilprod88xlop      
		   , cluster(department) partial(_R* _Y*)  fe ; 
		outreg2  cofintxlinternalp  oilprod88xlop         using  table2.xls, se bdec(3) tdec(3) nocons nor noni; 
	}; 


***************************************************************
* 	TABLE III: The Opportunity Cost and Rapacity Mechanisms
***************************************************************

	*  Log wage
	# delimit;
	clear;  
	use "${dir}\origmun_wages_commodities";
	
	# delimit; 
		xi: ivreg2   lwage   gender  age agesq  married edyrs      _R*  _Y*  _O*       coca94indxyear
		  (cofintxlinternalp  = rxltop3cof txltop3cof  rtxltop3cof)  oilprod88xlop    [pw=pweight], cluster(department)  partial (_R* _Y* _O*); 
		 outreg2  cofintxlinternalp  oilprod88xlop         using  table3.xls,   replace se  bdec(3) tdec(3) nocons nor noni; 
	
	
	*  Log hours
	# delimit;
	clear;  
	use "${dir}\origmun_hours_commodities";
	
	# delimit; 
		xi: ivreg2  lhours    gender  age agesq  married edyrs     _R*   _Y*   _O*    coca94indxyear
		(cofintxlinternalp  = rxltop3cof txltop3cof  rtxltop3cof )  oilprod88xlop  [pw=pweight], cluster(department) partial (_R* _Y* _O*);
		outreg2  cofintxlinternalp  oilprod88xlop         using  table3.xls,    se  bdec(3) tdec(3) nocons nor noni;
	 
	 
	*  Log capital revenue 	 
	# delimit;
	clear;  
	use "${dir}\origmun_violence_commodities"; 

	# delimit; 
	tsset origmun year, yearly; 
		xi: xtivreg2   lcaprev  lpop    _Y*        _R*  coca94indxyear
		(cofintxlinternalp   = rxltop3cof txltop3cof  rtxltop3cof)
		oilprod88xlop       
		      , cluster(department) partial(_R* _Y*)  fe ; 
		outreg2  cofintxlinternalp  oilprod88xlop         using  table3.xls,  se  bdec(3) tdec(3) nocons nor noni; 


	*  Paramilitary and Guerrilla political kidnaps
	# delimit; 
	foreach var of varlist parkidpol  guerkidpol {; 
	# delimit; 
	tsset origmun year, yearly; 
		xi: xtivreg2   `var'  lpop    _Y*        _R*  coca94indxyear
		(cofintxlinternalp   = rxltop3cof txltop3cof  rtxltop3cof)
		oilprod88xlop       
		      , cluster(department) partial(_R* _Y*)  fe ; 
		outreg2  cofintxlinternalp  oilprod88xlop         using  table3.xls,  se  bdec(3) tdec(3) nocons nor noni; 
		}; 
		
	

************************************************
* 	TABLE IV: Alternative Accounts
************************************************

***  PANEL 4A: Migration, enforcement and paramilitary protection 
	
	* Migration
	# delimit;
	clear; 
	use "${dir}\origmun_migrant_commodities.dta"; 
		 
	xi: ivreg2  migrant    gender  age   agesq  married edyrs       _R*  _Y*   _O*  coca94indxyear 	
		(cofintxlinternalp  = rxltop3cof txltop3cof  rtxltop3cof ) oilprod88xlop  [pw=pweight], cluster(department)  partial(_R* _Y* _O*) ; 
		 outreg2  cofintxlinternalp  oilprod88xlop         using  table4a.xls,  replace se  bdec(3) tdec(3) nocons nor noni; 
	
	* Government attacks, paramilitary and guerrilla massacres 
	# delimit;
	clear;  
	use "${dir}\origmun_violence_commodities"; 

	# delimit; 
	tsset origmun year, yearly; 
		xi: xtivreg2  govatt   lpop    _Y*    _R*  coca94indxyear
		(cofintxlinternalp   = rxltop3cof txltop3cof  rtxltop3cof ) 
		oilprod88xlop      
		      , cluster(department) partial(_R* _Y*)  fe ; 
		outreg2  cofintxlinternalp  oilprod88xlop         using   table4a.xls, se  bdec(3) tdec(3) nocons nor noni; 
	# delimit; 
	foreach var of varlist  parmass guermass  {; 
	# delimit; 
	tsset origmun year, yearly; 
		xi: xtivreg2 `var'  lpop    _Y*        _R*  coca94indxyear
		(cofintxlinternalp   = rxltop3cof txltop3cof  rtxltop3cof ) 
		 oilprod88xlop     
		       , cluster(department) partial(_R* _Y*)  fe ; 
		outreg2  cofintxlinternalp  oilprod88xlop         using   table4a.xls,  se  bdec(3) tdec(3) nocons nor noni; 
	}; 


*** PANEL 4B: Political Collusion 

	# delimit; 
	tsset origmun year, yearly; 
		xi: xtivreg2 gueratt    lpop    _Y*           _R*  coca94indxyear
		 (cofintxlinternalp   = rxltop3cof txltop3cof  rtxltop3cof) 
		 oilprod88xlop     
		 yrsproparaxoil88xlop    yrsproparaxlop  
		    if year>=1994  , cluster(department) partial(_R* _Y*)  fe ; 
		outreg2  cofintxlinternalp  oilprod88xlop     yrsproparaxoil88xlop     yrsproparaxlop  using  table4b.xls, replace se  bdec(3) tdec(3) nocons nor noni; 
	# delimit; 
	foreach var of varlist paratt clashes casualties {; 
	tsset origmun year, yearly; 
		xi: xtivreg2  `var'   lpop    _Y*          		_R*   coca94indxyear
		 (cofintxlinternalp   = rxltop3cof txltop3cof  rtxltop3cof) 
		  oilprod88xlop     
		  yrsproparaxoil88xlop    yrsproparaxlop  
		   if year>=1994    , cluster(department) partial(_R* _Y*)  fe ; 
		outreg2  cofintxlinternalp  oilprod88xlop      yrsproparaxoil88xlop     yrsproparaxlop  using  table4b.xls,  se  bdec(3) tdec(3) nocons nor noni; 
		}; 
	

************************************************
* 	TABLE V: Accounting for Coca
************************************************

*** Panel VA: testing the coca substitution hypothesis

	# delimit;
	clear; 
	use "${dir}\origmun_violence_commodities"; 
	
	* Coca 
	# delimit; 
	tsset origmun year, yearly; 
		xi: xtivreg2 coca   lpop    _Y*         _R*  
		(cofintxlinternalp   = rxltop3cof txltop3cof  rtxltop3cof ) 
		oilprod88xlop      
			, cluster(department) partial(_R* _Y*)  fe first; 
		outreg2  cofintxlinternalp  oilprod88xlop         using  table5a.xls,  replace se  bdec(3) tdec(3) nocons nor noni; 
	 
	* Violence 
	# delimit;
	foreach var of varlist gueratt paratt clashes casualties  {; 
	tsset origmun year, yearly; 
		xi: xtivreg2 `var'    lpop    _Y*      oilprod88xlop     _R*  coca94indxyear
		(cofintxlinternalp   = rxltop3cof txltop3cof  rtxltop3cof) 
			if  coca~=., cluster(department) partial(_R* _Y*)  fe ; 
		outreg2  cofintxlinternalp  oilprod88xlop         using    table5a.xls, se bdec(3) tdec(3) nocons nor noni; 
	}; 

*** Panel VB: Controlling for coca intensity interacted with year effects 

	# delimit; 
	tsset origmun year, yearly; 
		xi: xtivreg2 gueratt    lpop    _Y*      oilprod88xlop     i.year*coca94      _R*  
		(cofintxlinternalp   = rxltop3cof txltop3cof  rtxltop3cof) 
		     , cluster(department) partial(_R* _Y*)  fe first; 
		outreg2  cofintxlinternalp  oilprod88xlop       using  table5b.xls, replace se  bdec(3) tdec(3) nocons nor noni; 
	# delimit;
	foreach var of varlist paratt clashes casualties  {; 
	tsset origmun year, yearly; 
		xi: xtivreg2 `var'    lpop    _Y*      oilprod88xlop      i.year*coca94     _R*  
		(cofintxlinternalp   = rxltop3cof txltop3cof  rtxltop3cof) 
		  , cluster(department) partial(_R* _Y*)  fe ; 
		outreg2  cofintxlinternalp  oilprod88xlop     using   table5b.xls, se bdec(3) tdec(3) nocons nor noni; 
	}; 

*** Panel VC: Removing every coca municipality 
	
	# delimit; 
	tsset origmun year, yearly; 
		xi: xtivreg2 gueratt    lpop    _Y*     _R*  
		(cofintxlinternalp   = rxltop3cof txltop3cof  rtxltop3cof )
		oilprod88xlop     
		if    evercoca==0 , cluster(department) partial(_R* _Y*)  fe first; 
		outreg2  cofintxlinternalp  oilprod88xlop         using  table5c.xls, replace se  bdec(3) tdec(3) nocons nor noni; 
	# delimit;
	foreach var of varlist paratt clashes casualties  {; 
	tsset origmun year, yearly; 
		xi: xtivreg2 `var'    lpop    _Y*        _R*  
		(cofintxlinternalp   = rxltop3cof txltop3cof  rtxltop3cof )
		oilprod88xlop       
		if    evercoca==0  , cluster(department) partial(_R* _Y*)  fe; 
		outreg2  cofintxlinternalp  oilprod88xlop         using    table5c.xls, se bdec(3) tdec(3) nocons nor noni; 
	}; 



*******************************************************************************
* 	TABLE VI: The Effect of Other Natural Resource Price Shocks on Violence
*******************************************************************************

	# delimit;
	clear; 
	use "${dir}\origmun_violence_commodities"; 

	# delimit; 
	tsset origmun year, yearly; 
		xi: xtivreg2  gueratt   lpop    _Y*     _R*  coca94indxyear  
		oilprod88xlop   
		(coalprod04xlcoalp  goldprod04xlgoldp   	= 	coalres78xltop3coal  mining78xlgoldp)	
		mining78xlsilverp  mining78xlplatp  
			, cluster(department) partial(_R* _Y*)  fe first; 
		outreg2    oilprod88xlop   coalprod04xlcoalp 	goldprod04xlgoldp  using  table6.xls, replace se bdec(3) tdec(3) nocons nor noni; 

	# delimit; 
	foreach var of varlist  paratt clashes casualties  {; 
	tsset origmun year, yearly; 
		xi: xtivreg2 `var'    lpop    _Y*      _R*  coca94indxyear   
		oilprod88xlop   
		(coalprod04xlcoalp  goldprod04xlgoldp  	= 	coalres78xltop3coal  mining78xlgoldp)
		mining78xlsilverp  mining78xlplatp 
		    , cluster(department) partial(_R* _Y*)  fe ; 
		outreg2    oilprod88xlop   coalprod04xlcoalp 	goldprod04xlgoldp  using  table6.xls, se bdec(3) tdec(3) nocons nor noni; 
	};

	

# delimit cr
