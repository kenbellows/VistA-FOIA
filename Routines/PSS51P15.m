PSS51P15 ;BIR/LDT - API FOR INFORMATION FROM FILE 51.15; 5 Sep 03
 ;;1.0;PHARMACY DATA MANAGEMENT;**85**;9/30/97
 ;
 ;Reference to ^PS(51.15 is supported by DBIA #2132
 ;
ALL(PSSIEN,PSSFT,LIST) ;
 ;PSSIEN - IEN of entry in ADMINISTRATION SHIFT file (#51.15).
 ;PSSFT - Free Text name in ADMINISTRATION SHIFT file (#51.15).
 ;LIST - Subscript of ^TMP array in the form ^TMP($J,LIST,Field Number where Field Number is the Field Number
 ;       of the data piece being returned.
 ;Returns NAME field (#.01), ABBREVIATION field (#1), STANDARD START/STOP TIMES field (#2), PACKAGE field (#4),
 ;HOSPITAL LOCATION multiple (#51.153), HOSPITAL LOCATION field (#.01), and START/STOP TIMES field (#1)
 ;of ADMINISTRATION SHIFT file (#51.15).
 N DIERR,ZZERR,PSS5115,PSS
 I $G(LIST)']"" Q
 K ^TMP($J,LIST)
 I +$G(PSSIEN)'>0,($G(PSSFT)']"") S ^TMP($J,LIST,0)=-1_"^"_"NO DATA FOUND" Q
 I +$G(PSSIEN)>0 N PSSIEN2 S PSSIEN2=$$FIND1^DIC(51.15,"","A","`"_PSSIEN,,,"") D
 .I +PSSIEN2'>0 S ^TMP($J,LIST,0)=-1_"^"_"NO DATA FOUND" Q
 .S ^TMP($J,LIST,0)=1
 .D GETS^DIQ(51.15,+PSSIEN2,".01;1;2;4;3*","IE","PSS5115") S PSS(1)=0
 .S PSSIEN=+PSSIEN2 F  S PSS(1)=$O(PSS5115(51.15,PSS(1))) Q:'PSS(1)  D SETZRO S (CNT,PSS(2))=0 D
 ..F  S PSS(2)=$O(PSS5115(51.153,PSS(2))) Q:'PSS(2)  D SETLOC S CNT=CNT+1
 ..S ^TMP($J,LIST,+PSSIEN,"HOSP",0)=$S($G(CNT)>0:CNT,1:"-1^NO DATA FOUND")
 I +$G(PSSIEN)'>0,$G(PSSFT)]"" D
 .I PSSFT["??" D LOOP(1) Q
 .D FIND^DIC(51.15,,"@;.01;1","QP",PSSFT,,"B",,,"")
 .I +$G(^TMP("DILIST",$J,0))=0 S ^TMP($J,LIST,0)=-1_"^"_"NO DATA FOUND" Q
 .S ^TMP($J,LIST,0)=+^TMP("DILIST",$J,0) N PSSXX S PSSXX=0 F  S PSSXX=$O(^TMP("DILIST",$J,PSSXX)) Q:'PSSXX  D
 ..S PSSIEN=+^TMP("DILIST",$J,PSSXX,0) K PSS5115 D GETS^DIQ(51.15,+PSSIEN,".01;1;2;4;3*","IE","PSS5115") S PSS(1)=0
 ..F  S PSS(1)=$O(PSS5115(51.15,PSS(1))) Q:'PSS(1)  D SETZRO S (CNT,PSS(2))=0 D
 ...F  S PSS(2)=$O(PSS5115(51.153,PSS(2))) Q:'PSS(2)  D SETLOC S CNT=CNT+1
 ...S ^TMP($J,LIST,+PSSIEN,"HOSP",0)=$S($G(CNT)>0:CNT,1:"-1^NO DATA FOUND")
 K ^TMP("DILIST",$J)
 Q
 ;
ACP(PSSPK,PSSABR,LIST) ;
 ;PSSPK - PACKAGE field (#4) of ADMINISTRATION SHIFT file (#51.15).
 ;PSSABR - ABBREVIATION field (#1) of ADMINISTRATION SHIFT file (#51.15).
 ;LIST - Subscript of ^TMP array in the form ^TMP($J,LIST,Field Number where Field Number is the Field Number
 ;       of the data piece being returned.
 ;Returns NAME field (#.01), ABBREVIATION field (#1), and PACKAGE field (#4)
 ;of ADMINISTRATION SHIFT file (#51.15).
 N DIERR,ZZERR,PSS5115,PSS
 I $G(LIST)']"" Q
 K ^TMP($J,LIST)
 I $G(PSSPK)']""!($G(PSSABR)']"") S ^TMP($J,LIST,0)=-1_"^"_"NO DATA FOUND" Q
 I $G(PSSPK)]"",$G(PSSABR)]"" D
 .;Naked reference below refers to ^PS(51.15,+Y,0)
 .S SCR("S")="I $P(^(0),""^"",4)=PSSPK"
 .D FIND^DIC(51.15,,"@;.01;1","QP",PSSABR,,"C",SCR("S"),,"")
 .I +$G(^TMP("DILIST",$J,0))=0 S ^TMP($J,LIST,0)=-1_"^"_"NO DATA FOUND" Q
 .S ^TMP($J,LIST,0)=+^TMP("DILIST",$J,0) N PSSXX S PSSXX=0 F  S PSSXX=$O(^TMP("DILIST",$J,PSSXX)) Q:'PSSXX  D
 ..S PSSIEN=+^TMP("DILIST",$J,PSSXX,0) K PSS5115 D GETS^DIQ(51.15,+PSSIEN,".01;1;4","IE","PSS5115") S PSS(1)=0
 ..F  S PSS(1)=$O(PSS5115(51.15,PSS(1))) Q:'PSS(1)  D SETZRO2
 K ^TMP("DILIST",$J)
 Q
 ;
SETZRO ;
 S ^TMP($J,LIST,+PSS(1),.01)=$G(PSS5115(51.15,PSS(1),.01,"I"))
 S ^TMP($J,LIST,"B",$G(PSS5115(51.15,PSS(1),.01,"I")),+PSS(1))=""
 S ^TMP($J,LIST,+PSS(1),1)=$G(PSS5115(51.15,PSS(1),1,"I"))
 S ^TMP($J,LIST,+PSS(1),2)=$G(PSS5115(51.15,PSS(1),2,"I"))
 S ^TMP($J,LIST,+PSS(1),4)=$G(PSS5115(51.15,PSS(1),4,"I"))
 Q
 ;
SETLOC ;
 S ^TMP($J,LIST,+PSS(1),"HOSP",+PSS(2),.01)=$S($G(PSS5115(51.153,PSS(2),.01,"I"))="":"",1:PSS5115(51.153,PSS(2),.01,"I")_"^"_PSS5115(51.153,PSS(2),.01,"E"))
 S ^TMP($J,LIST,+PSS(1),"HOSP",+PSS(2),1)=$G(PSS5115(51.153,PSS(2),1,"I"))
 Q
 ;
SETZRO2 ;
 S ^TMP($J,LIST,+PSS(1),.01)=$G(PSS5115(51.15,PSS(1),.01,"I"))
 S ^TMP($J,LIST,"ACP",PSSPK,$G(PSS5115(51.15,PSS(1),.01,"I")),+PSS(1))=""
 S ^TMP($J,LIST,+PSS(1),1)=$G(PSS5115(51.15,PSS(1),1,"I"))
 S ^TMP($J,LIST,+PSS(1),4)=$G(PSS5115(51.15,PSS(1),4,"I"))
 Q
 ;
LOOP(PSS) ;
 N CNT,CNT2 S (CNT2,CNT)=0
 S PSSIEN=0 F  S PSSIEN=$O(^PS(51.15,PSSIEN)) Q:'PSSIEN  D @(PSS)
 K ^TMP("DILIST",$J)
 Q
 ;
1 ;
 D GETS^DIQ(51.15,+PSSIEN,".01;1;2;4;3*","IE","PSS5115") S PSS(1)=0
 F  S PSS(1)=$O(PSS5115(51.15,PSS(1))) Q:'PSS(1)  D SETZRO S (CNT,PSS(2))=0,CNT2=CNT2+1 D
 .F  S PSS(2)=$O(PSS5115(51.153,PSS(2))) Q:'PSS(2)  D SETLOC S CNT=CNT+1
 .S ^TMP($J,LIST,PSSIEN,"HOSP",0)=$S($G(CNT)>0:CNT,1:"-1^NO DATA FOUND")
 S ^TMP($J,LIST,0)=$S($G(CNT2)>0:CNT2,1:"-1^NO DATA FOUND")
 Q