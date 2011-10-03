PRCFQ1 ;WISC@ALTOONA/CTB-ADDITIONAL UTILITY SUBROUTINES ;4/18/96  11:12 AM
V ;;5.1;IFCAP;;Oct 20, 2000
 ;Per VHA Directive 10-93-142, this routine should not be modified.
EX ;FINAL EXIT LINE FOR ALL FISCAL MENUS
 K PRC,PRCF,PRCFA,PRCFB Q
INIT ;INITIAL SETUP FOR ALL FISCAL MENUS
 K DIC S:$D(DTIME)["0" DTIME=300
 I $D(DUZ)["0" W !,"I don't seem to be able to identify you.  Please log in again.",$C(7) R X:3 Q
 Q
DRNG ;SELECT RANGE OF DATES
 K %DT W ! S %DT="EAT",%DT("A")="Enter Beginning Date: " D ^%DT I Y<0 K %H,%I,%DT,TO,FR,X,Y S %=0 Q
 S FR=+Y S %DT("A")="   Enter Ending Date: " D ^%DT I X["^" K %DT,%H,%I,FR,Y S %=0 Q
 I Y<0 W "??",!,$C(7) K %DT,FR G DRNG
 S TO=+Y I TO<FR W !,$C(7),"Illogical range of dates. Try again.",! G DRNG
 S %=1 K %DT,%H,%I Q
RNG ; ALLOW ENTRY OF BEGINNING AND ENDING RANGE
 S %=0,FR="",TO="z" S:'$D(DTIME) DTIME=120 W !!,"Start with "_M_": FIRST// " R FR:DTIME S:$T=0 FR="^" G:FR["^" RQ I FR["?",'$D(PRCFD) G RQ
 S:FR="" FR="@" I FR'["@" I $D(PRCFD) S %DT="ET",X=FR D ^%DT G:Y<0 RNG S FR=Y
TO W !,"Go to "_M_": LAST// " R TO:DTIME S:$T=0 TO="^" G:TO["^" RQ G:TO["?"&('$D(PRCFD)) RNG S:TO="" TO="z" I TO="z" G RQ1
 I TO'["@" I $D(PRCFD) S X=TO D ^%DT G:Y<0 TO S TO=Y
 I (FR["@")!(TO["@") S %=1 Q
 I (+FR=FR)&(+TO=TO) I FR>TO W $C(7),!,"INVALID RANGE" G RNG
 I (+FR'=FR)!(+TO'=TO) I FR]TO W $C(7),!,"INVALID RANGE" G RNG
 Q
RQ S %=0 K FR,TO,%DT,X,Y Q
RQ1 S %=1 K %DT,M,PRCFD,X,Y Q
LOCK ;LOCK GLOBAL THAT IS BEING ACCESSED BY ANOTHER USER
 L @("+"_DIC_DA_"):30") S PRCFL=$T Q:PRCFL  W !!,$C(7),"THIS ENTRY IS BEING EDITED BY ANOTHER USER.  TRY LATER." Q
 ;
VRQS ;THIS ENTRY POINT WILL INFORM USER THERE ARE VENDOR REQUESTS
 ;TO REVIEW.
 ;
 ;   ONLY USERS THAT WILL SEE THIS MESSAGE WILL BE THOSE
 ;   THAT HAVE THE 'PRCFA VENDOR EDIT' SECURITY KEY.
 ;
 N COUNT
 Q:'$D(DUZ)  ;YOU ARE UNDEFINED
 Q:'$D(^XUSEC("PRCFA VENDOR EDIT",DUZ))  ;YOU DO NOT HAVE THE SECURITY KEY
 S COUNT=$O(^PRCF(422.2,"B","123-VRQ-01",0)) Q:COUNT'>0
 S COUNT=$P($G(^PRCF(422.2,COUNT,0)),U,2) Q:COUNT'>0
 W !!,"There are VRQs for you to review."
 Q
 ;
AC ;CROSS-REFERENCE CODE FROM "AC" X-REF OF FIELD 49 (SITE) IN FILE 440.3
 N PRCX,DIC,X,DLAYGO,Y
 S PRCX=$O(^PRCF(422.2,"B","123-VRQ-01",0)) D:PRCX=""
 .  ;NEED TO SET UP ENTRY IN COUNTER FILE.
 .  K DD,DO
 .  S DIC="^PRCF(422.2,",DIC(0)="L",X="123-VRQ-01",DLAYGO=422.2
 .  D FILE^DICN S PRCX=+Y
 S $P(^PRCF(422.2,PRCX,0),U,2)=$P(^PRCF(422.2,PRCX,0),U,2)+1
 Q