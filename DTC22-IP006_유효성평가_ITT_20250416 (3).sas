
libname study 'Y:\MS\STAT\11. 기타 과제(견적 외 업무)\Analysis\현대바이오\20241031\Rawdata_20241031';

/*random code 및 sequence만들기*/
proc import datafile='Y:\MS\STAT\11. 기타 과제(견적 외 업무)\Analysis\현대바이오\20241031\Rawdata_20241031\(DTC22-IP006)무작위배정표.xlsx'
out=random_table             DBMS=xlsx REPLACE ;
sheet='sheet1';
			GETNAMES=YES;
     		DATAROW=2;
run;

data sequence;
set random_table;
by rnno;
rename subject=subjid;

keep subject rnno sequence;
run;

proc sort data=sequence; by subjid; run;
proc sort data=sequence; by rnno; run;

data sequence;
set sequence;
 if RNNO='R03031' then delete;
 if RNNO='R02016' then delete;
 if RNNO='R06003' then delete;
 if RNNO='R04042' then delete;
 if RNNO='R04149' then delete;
 if RNNO='R04182' then delete;
 if RNNO='R04146' then delete;
 run;

data study.sequence;
set sequence; run;
proc sort data=sequence; by subjid; run;
proc sort data=study.sequence; by subjid; run;

data sqp_00;
set study.sqp;
run;

data sqp_01;
set sqp_00;
rename sqptest = SQTEST sqpscore = SQSCORE;
label sqptest = SQTEST sqpscore = SQSCORE;
run;

data sq_00;
set study.sq sqp_01;
run;

proc sort data=sq_00;
by subjid visit seq;
run;

/* 적당한 시점을 기준으로 자르기 day 14까지만 필요하니까*/
data sq_01;
set sq_00;
if visit < 2005;
run;

/** 스크리닝 탈락자 제외 (근데 FAS, PP 파일이 생기면 파일 읽어와서 연동시켜야 함)**/
data ds_00;
set study.ds;
drop visit dsyn dsdtc dsdodtc dsreaso;
run;

data sq_02;
merge sq_01(in=left) ds_00;
by subjid;
if left;
if dsreas = 1 then delete;
run;

/*visit 200 이 있는 대상자 200의 수치를 100으로 대체 and DS 관련 삭제 */
data sq_03;
set sq_02;
if subjid = 'S09003' and visit=200 then visit1 = 100;
else if subjid = 'S09003' and visit=100 then delete;
else if subjid = 'S12001' and visit=200 then visit1 = 100;
else if subjid = 'S12001' and visit=100 then delete;
else if visit = 100 then visit1 = 100;
else visit1 = visit;
drop visit dsreas;
run;

data sq_04;
set sq_03;
rename visit1 = visit;
label visit1 = visit;
run;

/* SY에서 날짜 불러와서 맞추기, 두번째 열은 앞과 무조건 날짜가 같아야 하니 앞에 것만 불러옴*/
data sy_00;
set study.sy;
drop sqnd01 sqtc01 sqnd02 sqdtc02 sqtc02;
run;

data sqy_00;
set study.sqy;
drop sqpnd01 sqptc01 sqpnd02 sqpdtc02 sqptc02;
rename sqpdtc01 = sqdtc01;
label sqpdtc01 = sqdtc01;
run;

data dd_00;
set sy_00 sqy_00;
run;

data dd_01;
set dd_00;
if sqdtc01 = '' then delete;
if visit < 2005;
run;

proc sort data=dd_01;
by subjid visit;
run;

/*날짜 차이를 확인하기 위해 text 형태로 변경*/
data dd_02;
set dd_01;
sqdtc = compress(sqdtc01, '-');
drop sqdtc01;
run;

proc transpose data=dd_02 out=dd_03;
by subjid;
id visit;
var sqdtc;
run;

data dd_04;
set dd_03;
dv0 = intck('day', input(_100,yymmdd8.),input(_100,yymmdd8.));
dv00 = intck('day', input(_100,yymmdd8.),input(_200,yymmdd8.));
dv1 = intck('day', input(_100,yymmdd8.),input(_300,yymmdd8.));
dv2 = intck('day', input(_400,yymmdd8.),input(_400,yymmdd8.))+2;
dv3 = intck('day', input(_400,yymmdd8.),input(_500,yymmdd8.))+2;
dv4 = intck('day', input(_400,yymmdd8.),input(_600,yymmdd8.))+2;
dv5 = intck('day', input(_400,yymmdd8.),input(_700,yymmdd8.))+2;
dv6 = intck('day', input(_400,yymmdd8.),input(_800,yymmdd8.))+2;
dv7 = intck('day', input(_400,yymmdd8.),input(_900,yymmdd8.))+2;
dv8 = intck('day', input(_400,yymmdd8.),input(_1000,yymmdd8.))+2;

df11 = intck('day', input(_400,yymmdd8.),input(_1001,yymmdd8.))+2;
df12 = intck('day', input(_400,yymmdd8.),input(_1002,yymmdd8.))+2;
df13 = intck('day', input(_400,yymmdd8.),input(_1003,yymmdd8.))+2;
df14 = intck('day', input(_400,yymmdd8.),input(_1004,yymmdd8.))+2;
df15 = intck('day', input(_400,yymmdd8.),input(_1005,yymmdd8.))+2;
df16 = intck('day', input(_400,yymmdd8.),input(_1006,yymmdd8.))+2;
df17 = intck('day', input(_400,yymmdd8.),input(_1007,yymmdd8.))+2;
df18 = intck('day', input(_400,yymmdd8.),input(_1008,yymmdd8.))+2;
dv14 = intck('day', input(_400,yymmdd8.),input(_2000,yymmdd8.))+2;

df21 = intck('day', input(_400,yymmdd8.),input(_2001,yymmdd8.))+2;
df22 = intck('day', input(_400,yymmdd8.),input(_2002,yymmdd8.))+2;
df23 = intck('day', input(_400,yymmdd8.),input(_2003,yymmdd8.))+2;
df24 = intck('day', input(_400,yymmdd8.),input(_2004,yymmdd8.))+2;

run;

proc transpose data=dd_04 out=dd_05;
by subjid;
var dv0 dv00 dv1 dv2 dv3 dv4 dv5 dv6 dv7 dv8
df11 df12 df13 df14 df15 df16 df17 df18 dv14
df21 df22 df23 df24;
run;

/*14일 이상은 유효성 평가 제외*/
data dd_06;
set dd_05;
if sqdtc = '' then delete;
if sqdtc > 14 then delete;
run;

/*sq와 join을 위해 원래 visit으로 바꿔줌*/
data dd_07;
set dd_06;
if _NAME_ = 'dv0' then visit = 100;
if _NAME_ = 'dv00' then visit = 200;
if _NAME_ = 'dv1' then visit = 300;
if _NAME_ = 'dv2' then visit = 400;
if _NAME_ = 'dv3' then visit = 500;
if _NAME_ = 'dv4' then visit = 600;
if _NAME_ = 'dv5' then visit = 700;
if _NAME_ = 'dv6' then visit = 800;
if _NAME_ = 'dv7' then visit = 900;
if _NAME_ = 'dv8' then visit = 1000;

if _NAME_ = 'df11' then visit = 1001;
if _NAME_ = 'df12' then visit = 1002;
if _NAME_ = 'df13' then visit = 1003;
if _NAME_ = 'df14' then visit = 1004;
if _NAME_ = 'df15' then visit = 1005;
if _NAME_ = 'df16' then visit = 1006;
if _NAME_ = 'df17' then visit = 1007;
if _NAME_ = 'df18' then visit = 1008;
if _NAME_ = 'dv14' then visit = 2000;

if _NAME_ = 'df21' then visit = 2001;
if _NAME_ = 'df22' then visit = 2002;
if _NAME_ = 'df23' then visit = 2003;
if _NAME_ = 'df24' then visit = 2004;

run;

data dd_08;
set dd_07;
drop _NAME_;
rename sqdtc = day;
label sqdtc = day;
run;

proc sort data=dd_08;
by subjid visit;
run;

proc sort data=sq_04;
by subjid visit;
run;

/* 점수와 방문(day) join */
data sqdd_00;
merge sq_04(in=left) dd_08(in=right);
by subjid visit;
if left;
run;

data sqdd_01;
set sqdd_00;
if day=. then delete;
run;


/*오후를 day에 0.5 추가하고 seq를 맞춤*/
data sqdd_02;
set sqdd_01;
if SEQ > 12 then day = day + 0.5;

if SEQ > 12 then SEQ1 = SEQ-12;
else SEQ1 = SEQ;
run;

data sqdd_03;
set sqdd_02;
drop SEQ VISIT SQTEST;
run;

data sqdd_04;
set sqdd_03;
rename SEQ1 = SEQ;
label SEQ1 = SEQ;
run;

data sqdd_04;
retain subjid seq day sqscore;
set sqdd_04;
run;

proc sort data=sqdd_04;
by subjid seq day;
run;

data sqdd_05;
set sqdd_04;
run;

/*가로 변환 해서 LOCF 대상 찾기 */
proc transpose data=sqdd_05 out=sqdd_06;
by subjid seq;
id day;
var sqscore;
run;

/*LOCF 대상 찾기 */
data sqdd_06_need_locf;
set sqdd_06;
if _0=. or _2=. or _2D5=. or _3=. or _3D5=. or _4=. or _4D5=.
or _5=. or _5D5=. or _6=. or _6D5=. or _7=. or _7D5=.
or _8=. or _8D5=. or _9=. or _9D5=. or _10=. or _10D5=.
or _11=. or _11D5=. or _12=. or _12D5=. or _13=. or _13D5=. or _14=. or _14D5=.;
run;

/* LOCF 대상 수동으로 LOCF 하기 */
data sqdd_06_locf;
set sqdd_06;
/* S01042 */
if subjid = 'S01042' then _2D5 = _2;
if subjid = 'S01042' then _3D5 = _2;
if subjid = 'S01042' then _4D5 = _2;
if subjid = 'S01042' then _5D5 = _2;
if subjid = 'S01042' then _6D5 = _2;
if subjid = 'S01042' then _7D5 = _2;
if subjid = 'S01042' then _8D5 = _2;
if subjid = 'S01042' then _9D5 = _2;
if subjid = 'S01042' then _10D5 = _2;
if subjid = 'S01042' then _11D5 = _2;
if subjid = 'S01042' then _12D5 = _2;
if subjid = 'S01042' then _13D5 = _2;
if subjid = 'S01042' then _14D5 = _2;

if subjid = 'S01042' then _3 = _2;
if subjid = 'S01042' then _4 = _2;
if subjid = 'S01042' then _5 = _2;
if subjid = 'S01042' then _6 = _2;
if subjid = 'S01042' then _7 = _2;
if subjid = 'S01042' then _8 = _2;
if subjid = 'S01042' then _9 = _2;
if subjid = 'S01042' then _10 = _2;
if subjid = 'S01042' then _11 = _2;
if subjid = 'S01042' then _12 = _2;
if subjid = 'S01042' then _13 = _2;
if subjid = 'S01042' then _14 = _2;

/* S11006 */
if subjid = 'S11006' then _2D5 = _2;
if subjid = 'S11006' then _3D5 = _2;
if subjid = 'S11006' then _4D5 = _2;
if subjid = 'S11006' then _5D5 = _2;
if subjid = 'S11006' then _6D5 = _2;
if subjid = 'S11006' then _7D5 = _2;
if subjid = 'S11006' then _8D5 = _2;
if subjid = 'S11006' then _9D5 = _2;
if subjid = 'S11006' then _10D5 = _2;
if subjid = 'S11006' then _11D5 = _2;
if subjid = 'S11006' then _12D5 = _2;
if subjid = 'S11006' then _13D5 = _2;
if subjid = 'S11006' then _14D5 = _2;

if subjid = 'S11006' then _3 = _2;
if subjid = 'S11006' then _4 = _2;
if subjid = 'S11006' then _5 = _2;
if subjid = 'S11006' then _6 = _2;
if subjid = 'S11006' then _7 = _2;
if subjid = 'S11006' then _8 = _2;
if subjid = 'S11006' then _9 = _2;
if subjid = 'S11006' then _10 = _2;
if subjid = 'S11006' then _11 = _2;
if subjid = 'S11006' then _12 = _2;
if subjid = 'S11006' then _13 = _2;
if subjid = 'S11006' then _14 = _2;

if subjid = 'S11011' then delete;
if subjid = 'S09031' then delete;
if subjid = 'S09014' then delete;
if subjid = 'S02040' then delete;
if subjid = 'S02017' then delete;
if subjid = 'S02007' then delete;
if subjid = 'S01076' then delete;
run;

/*계산을 위해 행렬변환 */
proc transpose data=sqdd_06_locf out=sqdd_07;
by subjid seq;
var _0 _2  _3 _4 _5 _6 _7 _8 _9 _10 _11 _12 _13 _14
_2D5 _3D5 _4D5 _5D5 _6D5 _7D5 _8D5 _9D5 _10D5 _11D5 _12D5 _13D5 _14D5;
run;

data sqdd_08;
set sqdd_07;
day1 = compress(_NAME_, '_');

if day1 = '2D5' then day = 2.5;
else if day1 = '3D5' then day = 3.5;
else if day1 = '4D5' then day = 4.5;
else if day1 = '5D5' then day = 5.5;
else if day1 = '6D5' then day = 6.5;
else if day1 = '7D5' then day = 7.5;
else if day1 = '8D5' then day = 8.5;
else if day1 = '9D5' then day = 9.5;
else if day1 = '10D5' then day = 10.5;
else if day1 = '11D5' then day = 11.5;
else if day1 = '12D5' then day = 12.5;
else if day1 = '13D5' then day = 13.5;
else if day1 = '14D5' then day = 14.5;
else day = day1;

run;

data sqdd_09;
set sqdd_08;
drop _NAME_ day1;
run;

/* 점수 구하기 */
/* 1차 유효성 평가 - 48시간 이상 유지 */

data sq48b2_00;
set sqdd_06_locf;
run;

data sq48b2_01;
set sq48b2_00;
D4 = _2+_2D5+_3+_3D5+_4;
D4D5=_2D5+_3+_3D5+_4+_4D5;
D5=_3+_3D5+_4+_4D5+_5;
D5D5=_3D5+_4+_4D5+_5+_5D5;
D6=_4+_4D5+_5+_5D5+_6;
D6D5=_4D5+_5+_5D5+_6+_6D5;
D7=_5+_5D5+_6+_6D5+_7;
D7D5=_5D5+_6+_6D5+_7+_7D5;
D8=_6+_6D5+_7+_7D5+_8;
D8D5=_6D5+_7+_7D5+_8+_8D5;
D9=_7+_7D5+_8+_8D5+_9;
D9D5=_7D5+_8+_8D5+_9+_9D5;
D10=_8+_8D5+_9+_9D5+_10;
D10D5=_8D5+_9+_9D5+_10+_10D5;
D11=_9+_9D5+_10+_10D5+_11;
D11D5=_9D5+_10+_10D5+_11+_11D5;
D12=_10+_10D5+_11+_11D5+_12;
D12D5=_10D5+_11+_11D5+_12+_12D5;
D13=_11+_11D5+_12+_12D5+_13;
D13D5=_11D5+_12+_12D5+_13+_13D5;
D14=_12+_12D5+_13+_13D5+_14;
D14D5=_12D5+_13+_13D5+_14+_14D5;
run;

data sq48b2_02;
set sq48b2_01;
if (_0>1) and (D4=< 5 ) and (_2<2) and (_0D5<2) and (_3<2) and (_3D5<2) and (_4<2) then DD4=1; else if (_0<2) and (D4=0 ) then DD4=1; else DD4=0 ;
if (_0>1) and (D4D5=< 5 ) and (_2D5<2) and (_3<2) and (_3D5<2) and (_4<2) and (_4D5<2) then DD4D5=1; else if (_0<2) and (D4D5=0 ) then DD4D5=1; else DD4D5=0 ;
if (_0>1) and (D5=< 5 ) and (_3<2) and (_3D5<2) and (_4<2) and (_4D5<2) and (_5<2) then DD5=1; else if (_0<2) and (D5=0 ) then DD5=1; else DD5=0 ;
if (_0>1) and (D5D5=< 5 ) and (_3D5<2) and (_4<2) and (_4D5<2) and (_5<2) and (_5D5<2) then DD5D5=1; else if (_0<2) and (D5D5=0 ) then DD5D5=1; else DD5D5=0 ;
if (_0>1) and (D6=< 5 ) and (_4<2) and (_4D5<2) and (_5<2) and (_5D5<2) and (_6<2) then DD6=1; else if (_0<2) and (D6=0 ) then DD6=1; else DD6=0 ;
if (_0>1) and (D6D5=< 5 ) and (_4D5<2) and (_5<2) and (_5D5<2) and (_6<2) and (_6D5<2) then DD6D5=1; else if (_0<2) and (D6D5=0 ) then DD6D5=1; else DD6D5=0 ;
if (_0>1) and (D7=< 5 ) and (_5<2) and (_5D5<2) and (_6<2) and (_6D5<2) and (_7<2) then DD7=1; else if (_0<2) and (D7=0 ) then DD7=1; else DD7=0 ;
if (_0>1) and (D7D5=< 5 ) and (_5D5<2) and (_6<2) and (_6D5<2) and (_7<2) and (_7D5<2) then DD7D5=1; else if (_0<2) and (D7D5=0 ) then DD7D5=1; else DD7D5=0 ;
if (_0>1) and (D8=< 5 ) and (_6<2) and (_6D5<2) and (_7<2) and (_7D5<2) and (_8<2) then DD8=1; else if (_0<2) and (D8=0 ) then DD8=1; else DD8=0 ;
if (_0>1) and (D8D5=< 5 ) and (_6D5<2) and (_7<2) and (_7D5<2) and (_8<2) and (_8D5<2) then DD8D5=1; else if (_0<2) and (D8D5=0 ) then DD8D5=1; else DD8D5=0 ;
if (_0>1) and (D9=< 5 ) and (_7<2) and (_7D5<2) and (_8<2) and (_8D5<2) and (_9<2) then DD9=1; else if (_0<2) and (D9=0 ) then DD9=1; else DD9=0 ;
if (_0>1) and (D9D5=< 5 ) and (_7D5<2) and (_8<2) and (_8D5<2) and (_9<2) and (_9D5<2) then DD9D5=1; else if (_0<2) and (D9D5=0 ) then DD9D5=1; else DD9D5=0 ;
if (_0>1) and (D10=< 5 ) and (_8<2) and (_8D5<2) and (_9<2) and (_9D5<2) and (_10<2) then DD10=1; else if (_0<2) and (D10=0 ) then DD10=1; else DD10=0 ;
if (_0>1) and (D10D5=< 5 ) and (_8D5<2) and (_9<2) and (_9D5<2) and (_10<2) and (_10D5<2) then DD10D5=1; else if (_0<2) and (D10D5=0 ) then DD10D5=1; else DD10D5=0 ;
if (_0>1) and (D11=< 5 ) and (_9<2) and (_9D5<2) and (_10<2) and (_10D5<2) and (_11<2) then DD11=1; else if (_0<2) and (D11=0 ) then DD11=1; else DD11=0 ;
if (_0>1) and (D11D5=< 5 ) and (_9D5<2) and (_10<2) and (_10D5<2) and (_11<2) and (_11D5<2) then DD11D5=1; else if (_0<2) and (D11D5=0 ) then DD11D5=1; else DD11D5=0 ;
if (_0>1) and (D12=< 5 ) and (_10<2) and (_10D5<2) and (_11<2) and (_11D5<2) and (_12<2) then DD12=1; else if (_0<2) and (D12=0 ) then DD12=1; else DD12=0 ;
if (_0>1) and (D12D5=< 5 ) and (_10D5<2) and (_11<2) and (_11D5<2) and (_12<2) and (_12D5<2) then DD12D5=1; else if (_0<2) and (D12D5=0 ) then DD12D5=1; else DD12D5=0 ;
if (_0>1) and (D13=< 5 ) and (_11<2) and (_11D5<2) and (_12<2) and (_12D5<2) and (_13<2) then DD13=1; else if (_0<2) and (D13=0 ) then DD13=1; else DD13=0 ;
if (_0>1) and (D13D5=< 5 ) and (_11D5<2) and (_12<2) and (_12D5<2) and (_13<2) and (_13D5<2) then DD13D5=1; else if (_0<2) and (D13D5=0 ) then DD13D5=1; else DD13D5=0 ;
if (_0>1) and (D14=< 5 ) and (_12<2) and (_12D5<2) and (_13<2) and (_13D5<2) and (_14<2) then DD14=1; else if (_0<2) and (D14=0 ) then DD14=1; else DD14=0 ;
if (_0>1) and (D14D5=< 5 ) and (_12D5<2) and (_13<2) and (_13D5<2) and (_14<2) and (_14D5<2) then DD14D5=1; else if (_0<2) and (D14D5=0 ) then DD14D5=1; else DD14D5=0 ;
run;

data sq48b2_03;
set sq48b2_02;
DDD4=DD4*DD4D5*DD5*DD5D5*DD6*DD6D5*DD7*DD7D5*DD8*DD8D5*DD9*DD9D5*DD10*DD10D5*DD11*DD11D5*DD12*DD12D5*DD13*DD13D5*DD14*DD14D5;
DDD4D5=DD4D5*DD5*DD5D5*DD6*DD6D5*DD7*DD7D5*DD8*DD8D5*DD9*DD9D5*DD10*DD10D5*DD11*DD11D5*DD12*DD12D5*DD13*DD13D5*DD14*DD14D5;
DDD5=DD5*DD5D5*DD6*DD6D5*DD7*DD7D5*DD8*DD8D5*DD9*DD9D5*DD10*DD10D5*DD11*DD11D5*DD12*DD12D5*DD13*DD13D5*DD14*DD14D5;
DDD5D5=DD5D5*DD6*DD6D5*DD7*DD7D5*DD8*DD8D5*DD9*DD9D5*DD10*DD10D5*DD11*DD11D5*DD12*DD12D5*DD13*DD13D5*DD14*DD14D5;
DDD6=DD6*DD6D5*DD7*DD7D5*DD8*DD8D5*DD9*DD9D5*DD10*DD10D5*DD11*DD11D5*DD12*DD12D5*DD13*DD13D5*DD14*DD14D5;
DDD6D5=DD6D5*DD7*DD7D5*DD8*DD8D5*DD9*DD9D5*DD10*DD10D5*DD11*DD11D5*DD12*DD12D5*DD13*DD13D5*DD14*DD14D5;
DDD7=DD7*DD7D5*DD8*DD8D5*DD9*DD9D5*DD10*DD10D5*DD11*DD11D5*DD12*DD12D5*DD13*DD13D5*DD14*DD14D5;
DDD7D5=DD7D5*DD8*DD8D5*DD9*DD9D5*DD10*DD10D5*DD11*DD11D5*DD12*DD12D5*DD13*DD13D5*DD14*DD14D5;
DDD8=DD8*DD8D5*DD9*DD9D5*DD10*DD10D5*DD11*DD11D5*DD12*DD12D5*DD13*DD13D5*DD14*DD14D5;
DDD8D5=DD8D5*DD9*DD9D5*DD10*DD10D5*DD11*DD11D5*DD12*DD12D5*DD13*DD13D5*DD14*DD14D5;
DDD9=DD9*DD9D5*DD10*DD10D5*DD11*DD11D5*DD12*DD12D5*DD13*DD13D5*DD14*DD14D5;
DDD9D5=DD9D5*DD10*DD10D5*DD11*DD11D5*DD12*DD12D5*DD13*DD13D5*DD14*DD14D5;
DDD10=DD10*DD10D5*DD11*DD11D5*DD12*DD12D5*DD13*DD13D5*DD14*DD14D5;
DDD10D5=DD10D5*DD11*DD11D5*DD12*DD12D5*DD13*DD13D5*DD14*DD14D5;
DDD11=DD11*DD11D5*DD12*DD12D5*DD13*DD13D5*DD14*DD14D5;
DDD11D5=DD11D5*DD12*DD12D5*DD13*DD13D5*DD14*DD14D5;
DDD12=DD12*DD12D5*DD13*DD13D5*DD14*DD14D5;
DDD12D5=DD12D5*DD13*DD13D5*DD14*DD14D5;
DDD13=DD13*DD13D5*DD14*DD14D5;
DDD13D5=DD13D5*DD14*DD14D5;
DDD14=DD14*DD14D5;
DDD14D5=DD14D5;
run;

data sq48b2_04;
set sq48b2_03;
if DDD14D5=0 then censored=1; else censored=0;
if sum(_0,_2,_2D5,_3,_3D5,_4,_4D5,_5,_5D5,_6,_6D5,_7,_7D5,_8,_8D5,_9,_9D5,_10,_10D5,_11,_11D5,_12,_12D5, _13,_13D5,_14,_14D5)=0 then included = 0; else included = 1;
run;

data sq48b2_05;
set sq48b2_04;
rec = 15-0.5*sum(DDD4,DDD4D5,DDD5,DDD5D5,DDD6,DDD6D5,DDD7,DDD7D5,DDD8,DDD8D5,DDD9,DDD9D5,DDD10,DDD10D5,DDD11,DDD11D5,DDD12,DDD12D5,DDD13,DDD13D5,DDD14,DDD14D5,censored)-1.5;
run;


data sq48b2_all;
set sq48b2_05;
keep subjid seq rec censored included;
run;
data sq48b2_no1_00;
set sq48b2_all;
if included = 1;
run;

data sq48b2_no1_00;
set sq48b2_no1_00;
if subjid='S02008' then rec=rec-1;
run;

proc sql;
  create table sq48b2_max_subjid as
    select subjid, 
           max(rec) AS day,
		   max(censored) as censored
    from   sq48b2_no1_00 
    group 
       by  subjid;
quit;

/*유효성 1차 평가*/
/*층화요인*/
data age00;
set study.dm;
keep subjid age;
run;

data nh00;
set study.nh;
keep subjid nhnor;
if visit = 100;
run;

data pe1_d00;
merge sq48b2_max_subjid(in=left) age00(in=right) nh00(in=right);
by subjid;
if left;
run;

data pe1_d01;
set pe1_d00;
if age < 65 then st_age = 0;
if age >= 65 then st_age = 1;
if nhnor =2 then st_nh = 0;
if nhnor =3 then st_nh = 1;
run;

data rn_00;
set study.rn;
keep subjid rnno;
run;

proc sort data=rn_00;
by rnno;
run;

proc sort data=random_table;
by rnno;
run;

data rn_01;
merge rn_00 random_table;
by rnno;
run;

proc sort data=rn_01;
by subjid;
run;

data pe1_d02;
merge pe1_d01(in=left) rn_01(in=right);
by subjid;
if left;
run;

data pe1_final;
retain subjid rnno sequence day censored st_age st_nh;
set pe1_d02;
run;


/***** Analysis Set (PPS) *********************/
proc import datafile='Y:\MS\STAT\11. 기타 과제(견적 외 업무)\Analysis\현대바이오\20241031\Rawdata_20241031\real_random.xlsx'
out=pps_ex             DBMS=xlsx REPLACE ;
sheet="pps";
			GETNAMES=YES;
     		DATAROW=2;
run;

proc sort data=pps_ex; by subjid; run;

data pps00;
set pps_ex;
keep subjid rnno pps;
run;


/***** Analysis Set (MITT) *********************/
proc import datafile='Y:\MS\STAT\11. 기타 과제(견적 외 업무)\Analysis\현대바이오\20241031\Rawdata_20241031\real_random.xlsx'
out=MITT_ex             DBMS=xlsx REPLACE ;
sheet="MITT";
			GETNAMES=YES;
     		DATAROW=2;
run;

proc sort data=MITT_ex; by subjid; run;

data Mitt00;
set MITT_ex;
keep subjid  mITT1 mITT2;
run;


/***** Analysis Set merge *********************/
proc sql;
create table pe1_final_set as
select a.*, 'Y' as FAS
			, case when PPS eq '' 	then 'Y' else 'N' end as PPS 
			, case when mITT1 eq '' 	then 'Y' else 'N' end as mITT1 
			, case when mITT2 eq '' 	then 'Y' else 'N' end as mITT2 
																													from pe1_final as a 	left join pps00 	as b on a.SUBJID=b.SUBJID
																																					left join mitt00 	as c on a.SUBJID=c.SUBJID
;quit;


/*FAS*/
TITLE4 "1차 유효성 기술통계: FAS";
 proc tabulate data=pe1_final_set;
  where FAS eq 'Y';
  var day;
  /*by seq;*/
  class sequence;
  table day*(n mean std median min max)
          ,  sequence all ;
run;

TITLE4 "1차 유효성 Cox Regression Model: FAS";
proc phreg data=pe1_final_set;
where FAS eq 'Y';
class sequence(ref="R");
model day*censored(1) = sequence age nhnor / risklimits;
ods output parameterEstimates=pe1_final_out;
run;

/*PPS*/
TITLE4 "1차 유효성 기술통계: PPS";
 proc tabulate data=pe1_final_set;
 where PPS eq 'Y';
  var day;
  /*by seq;*/
  class sequence;
  table day*(n mean std median min max)
          ,  sequence all ;
run;

TITLE4 "1차 유효성 Cox Regression Model: PPS";
proc phreg data=pe1_final_set;
where PPS eq 'Y';
class sequence(ref="R");
model day*censored(1) = sequence age nhnor / risklimits;
ods output parameterEstimates=pe1_final_out;
run;


/***********************mitt***********************/
data pe1_final2_set;
set pe1_final_set;
/*************병용으로 날짜 조정 *******************/
if subjid='S09029' then day=6;
if subjid='S01007' then day=-2;
if subjid='S01019' then day=-3;
if subjid='S01085' then day=0;
if subjid='S02001' then day=-2;
if subjid='S02005' then day=-2;
if subjid='S02013' then day=0;
if subjid='S02042' then day=-2;
if subjid='S04001' then day=-2;
if subjid='S07004' then day=-2;
if subjid='S01003' then day=12;
if subjid='S01005' then day=1;
if subjid='S01023' then day=2;

if subjid='S02008' then day=2;
if subjid='S02010' then day=2;
if subjid='S02014' then day=7;
if subjid='S02026' then day=3;
if subjid='S02032' then day=4;
if subjid='S02046' then day=2;
if subjid='S02060' then day=2;
if subjid='S02064' then day=3;
if subjid='S02071' then day=4;
if subjid='S02083' then day=1;
if subjid='S02102' then day=3;
if subjid='S02105' then day=1;
if subjid='S07005' then day=3;
if subjid='S12002' then day=3;

/****** S01124 대상자는 day=4 에 회복됨
if subjid='S01124' then day=4;
if subjid='S01124' then censored=1;
*****/

if subjid='S09029' then censored=1;
if subjid='S01007' then censored=1;
if subjid='S01019' then censored=1;
if subjid='S01085' then censored=1;
if subjid='S02001' then censored=1;
if subjid='S02005' then censored=1;
if subjid='S02013' then censored=1;
if subjid='S02042' then censored=1;
if subjid='S04001' then censored=1;
if subjid='S07004' then censored=1;
if subjid='S01003' then censored=1;
if subjid='S01005' then censored=1;
if subjid='S01023' then censored=1;

if subjid='S02008' then censored=1;
if subjid='S02010' then censored=1;
if subjid='S02014' then censored=1;
if subjid='S02026' then censored=1;
if subjid='S02032' then censored=1;
if subjid='S02046' then censored=1;
if subjid='S02060' then censored=1;
if subjid='S02064' then censored=1;
if subjid='S02071' then censored=1;
if subjid='S02083' then censored=1;
if subjid='S02102' then censored=1;
if subjid='S02105' then censored=1;
if subjid='S07005' then censored=1;
if subjid='S12002' then censored=1;

/**************** 중도탈락 *************************/
if subjid='S01042' then day=0.5;
if subjid='S11006' then day=0.5;

if subjid='S01042' then censored=1;
if subjid='S11006' then censored=1;
run;

data pe1_final3_set;
set pe1_final2_set;
if day < 0.5 then day=0;
run;

/*Mitt1*/
TITLE4 "1차 유효성 기술통계: Mitt1";
 proc tabulate data=pe1_final3_set;
 where Mitt1 eq 'Y';
  var day;
  /*by seq;*/
  class sequence;
  table day*(n mean std median min max)
          ,  sequence all ;
run;

TITLE4 "1차 유효성 Cox Regression Model: Mitt1";
proc phreg data=pe1_final3_set;
where Mitt1 eq 'Y';
class sequence(ref="R");
model day*censored(1) = sequence age nhnor / risklimits ties=efron;
ods output parameterEstimates=pe1_final_out;
run;


/*Mitt2*/
TITLE4 "1차 유효성 기술통계: Mitt1";
 proc tabulate data=pe1_final3_set;
 where Mitt2 eq 'Y';
  var day;
  /*by seq;*/
  class sequence;
  table day*(n mean std median min max)
          ,  sequence all ;
run;

TITLE4 "1차 유효성 Cox Regression Model: Mitt2";
proc phreg data=pe1_final3_set;
where Mitt2 eq 'Y';
class sequence(ref="R");
model day*censored(1) = sequence age nhnor / risklimits ties=efron;
ods output parameterEstimates=pe1_final_out;
run;


