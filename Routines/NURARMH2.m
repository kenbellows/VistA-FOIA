NURARMH2 ;HIRMFO/MD,FT-CONTINUATION OF DRIVER TO PRINT AMIS 1106 MANHOURS REPORTS ;8/9/96  12:40
 ;;4.0;NURSING SERVICE;;Apr 25, 1997
PERTOT ;TOTAL SUBROUTINE FOR MONTHLY QUARTERLY AND YEARLY MANHOURS TOTALS
 K NBED S NDATA=$S($D(^NURSA(213.4,NDA,0)):^(0),1:""),(NPWARD,YY(0))=$E($P(NDATA,U),9,99) Q:$G(^NURSF(211.4,NPWARD,0))=""  D EN6^NURSAUTL S YY("W")=$S(NPWARD'="":NPWARD,1:"  BLANK"),NTCEN=0 I 'NHOSPSW,YY(0)'=NURSWARD Q
 I 'NURMDSW S NURFAC(2)=" BLANK"
 I NURMDSW S NURFAC(2)=$$EN12^NURSUT3($G(YY(0))) Q:$G(NURFAC(2))=""
 I NURMDSW,$G(NURFAC)=0 Q:$G(NURFAC(1))'=$G(NURFAC(2))
 F D1=0:0 S D1=$O(^NURSA(213.4,NDA,1,D1)) Q:D1'>0  S NBED(D1)=$S($D(^NURSA(213.4,NDA,1,D1,0)):^(0),1:""),NCEN=$P(NBED(D1),U,2)+$P(NBED(D1),U,3)+$P(NBED(D1),U,4)+$P(NBED(D1),U,5),NBED(D1)=NCEN_U_NBED(D1),NTCEN=NTCEN+NCEN
 I 'NTCEN S:'$D(^TMP($J,"NURBED",NURFAC(2),"  BLANK",YY("W"))) ^(YY("W"))="0^0^0" S:'$D(^TMP("NURBDSM",$J,"MANHOURS/NO BEDSECTION")) ^("MANHOURS/NO BEDSECTION")="" D
 .  F NURI=1:1:3 D
 .  .  S $P(^TMP($J,"NURBED",NURFAC(2),"  BLANK",YY("W")),U,NURI)=$P(^TMP($J,"NURBED",NURFAC(2),"  BLANK",YY("W")),U,NURI)+$J($P(NDATA,U,(NURI+1)),0,2)
 .  .  S $P(^TMP("NURBDSM",$J,"MANHOURS/NO BEDSECTION"),U,NURI)=$P(^TMP("NURBDSM",$J,"MANHOURS/NO BEDSECTION"),U,NURI)+$J($P(NDATA,U,(NURI+1)),0,2)
 .  .  Q
 .  Q
 I NTCEN F D1=0:0 S D1=$O(NBED(D1)) Q:D1'>0  D ADDTOT
 Q
ADDTOT ;ACCUMULATE PERIOD TOTAL IN TMP GLOBAL
 S YY=$P(NBED(D1),U,2),YY("B")=$S('$D(^NURSF(213.3,YY,0)):"  BLANK",$P(^(0),U)'="":$P(^(0),U),1:"  BLANK")
 I '(YY=NBDSECT!'NBDSECT) Q
 I '$D(^TMP($J,"NURBED",NURFAC(2),YY("B"),YY("W"))) S ^TMP($J,"NURBED",NURFAC(2),YY("B"),YY("W"))="0^0^0"
 S NCEN=$P(NBED(D1),U),NPERC=NCEN/NTCEN
 F Y=1:1:3 S $P(^TMP($J,"NURBED",NURFAC(2),YY("B"),YY("W")),U,Y)=$P(^TMP($J,"NURBED",NURFAC(2),YY("B"),YY("W")),U,Y)+$S(Y=1:$J(NPERC*$P(NDATA,U,2),0,2),Y=2:$J(NPERC*$P(NDATA,U,3),0,2),Y=3:$J(NPERC*$P(NDATA,U,4),0,2),1:"")
 I NURMDSW,+$G(NURFAC),NHOSPSW,YY("B")'="" D
 .  S:'$D(^TMP("NURBDSM",$J,YY("B"))) ^(YY("B"))="0^0^0"
 .  F Z=1:1:3 S $P(^TMP("NURBDSM",$J,YY("B")),U,Z)=($P(^(YY("B")),U,Z)+$J($P(NDATA,U,(Z+1)),0,2))
 .  Q
 Q
PERRPT ;PERIOD REPORT
 S NURFAC(2)="" F  S NURFAC(2)=$O(^TMP($J,"NURBED",NURFAC(2))) Q:NURFAC(2)=""  D:'$G(NURSUMSW) HEADER^NURARMH1 Q:NUROUT  D P0 Q:NUROUT  I NURMDSW,NHOSPSW D FACTL^NURARMH1 Q:NUROUT
 Q
P0 S YY("B")="" F NF1=0:0 S YY("B")=$O(^TMP($J,"NURBED",NURFAC(2),YY("B"))) Q:YY("B")=""  W:'$G(NURSUMSW) !,$S(YY("B")'="  BLANK":YY("B"),1:"TOTAL MANHOURS WHEN NO ACUITY DATA IS PRESENT:") D P1 Q:NUROUT  I '$G(NURSUMSW) D BRK^NURARMH1
 Q
P1 S YY("W")="" F NF1=0:0 S YY("W")=$O(^TMP($J,"NURBED",NURFAC(2),YY("B"),YY("W"))) Q:YY("W")=""  D WRITE Q:NUROUT
 Q
WRITE ;
 I ($Y>(IOSL-6))!(NURMDSW(1)) D HEADER^NURARMH1 Q:NUROUT
 S TL=^TMP($J,"NURBED",NURFAC(2),YY("B"),YY("W")),TL("RN")=$P(TL,U),TL("LPN")=$P(TL,U,2),TL("NA")=$P(TL,U,3)
 S RNTL=$P(TL,U,1),LPNTL=$P(TL,U,2),NATL=$P(TL,U,3)
 I YY("B")="  BLANK",'+TL("RN"),'+TL("LPN"),'+TL("NA") Q
 I '$G(NURSUMSW) W !,?6,YY("W"),?42,$J(RNTL,7,2),?54,$J(LPNTL,7,2),?67,$J(NATL,7,2)
 S NT("RN")=NT("RN")+RNTL,NT("LPN")=NT("LPN")+LPNTL,NT("NA")=NT("NA")+NATL,FNT("RN")=FNT("RN")+RNTL,FNT("LPN")=FNT("LPN")+LPNTL,FNT("NA")=FNT("NA")+NATL,FT("RN")=FT("RN")+RNTL,FT("LPN")=FT("LPN")+LPNTL,FT("NA")=FT("NA")+NATL,NURMDSW(1)=0
 Q