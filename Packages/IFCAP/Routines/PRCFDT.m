PRCFDT ;WISC/LEM-PROVIDE 'NET' PERCENT TRANSFORMS ;8/11/95  09:35
V ;;5.1;IFCAP;;Oct 20, 2000
 ;Per VHA Directive 10-93-142, this routine should not be modified.
INPUT N X0 S X0=$TR(X,"net","NET")
 I X]"",$E("NET",1,$L(X0))=X0 S X=0 Q
 ; Native FileMan Input Transform follows:
 K:+X'=X!(X>99.999)!(X<0)!(X?.E1"."4N.N) X
 Q
OUTPUT I Y?1"0"."."."0" S Y="NET"
 Q
 N DA S DA(1)=$G(PRCF("CIDA")) Q:DA(1)=""
 N NODE S NODE=$G(^PRCF(421.5,DA(1),5,0))
 I NODE="" S ^PRCF(421.5,DA(1),5,0)=U_$P(^DD(421.5,41,0),U,2)
 N CTR,I S (CTR,I)=0 F  S I=$O(PRCFD(I)) Q:I'>0  D
 . S CTR=$S(I=991:CTR,1:CTR+1),CTR=$S(CTR=991:992,1:CTR)
 . N DIC S DIC="^PRCF(421.5,"_DA(1)_",5,",DIC(0)="L"
 . S X=$P(PRCFD(I),U,1),AMT=+$P(PRCFD(I),U,2)
 . K DD,DO D FILE^DICN I Y'>0 W "ERROR" Q
 . N DIE S DIE=DIC,DA=+Y,FMSL=$S(I=991:991,1:CTR)
 . N DR S DR="1////^S X=AMT;2////^S X=FMSL" D ^DIE
 . Q
 Q
DISC ; COMPUTE FMS LINE LIQ AMT FROM TOTAL AMT & DISCOUNT TERMS
 ; INPUT: PRCF("CIDA") - IEN FOR PAYMENT/INVOICE TRACKING RECORD
 ;        PRCFA("LAMT") - AMOUNT CERTIFIED FOR THIS INVOICE
 ; OUTPUT: PRCFA("LIQ") - FMS COMPUTED LIQUIDATION AMOUNT
 Q:'$D(PRCF("CIDA"))!'$D(PRCFA("LAMT"))
 N I,DISC,HIGHDISC S (HIGHDISC,I)=0
 F  S I=$O(^PRCF(421.5,PRCF("CIDA"),6,I)) Q:+I'=I  D
 . S DISC=+$P($G(^PRCF(421.5,PRCF("CIDA"),6,I,0)),U,3)
 . I DISC>HIGHDISC S HIGHDISC=DISC
 . Q
 S PRCFA("LIQ")=$FN(1-(HIGHDISC/100)*PRCFA("LAMT"),"",2)
 Q
SUM ;
 ; INPUT: PRCF("CIDA") - IEN FOR PAYMENT/INVOICE TRACKING RECORD
 ;        PRCFA("CAMT") - TOTAL INVOICE AMOUNT CERTIFIED FOR PAYMENT
 ; OUTPUT: OK - 1 IF SUM OF LINE AMOUNTS = TOTAL AMOUNT CERTIFIED
 ;            - 0 IF AMOUNTS NOT EQUAL
 Q:'$D(PRCF("CIDA"))!'$D(PRCF("CAMT"))
 N I,LAMT S (I,OK,PRCF("TAMT"))=0
 F  S I=$O(^PRCF(421.5,PRCF("CIDA"),5,I)) Q:+I'=I  D
 . S LAMT=+$P($G(^PRCF(421.5,PRCF("CIDA"),5,I,0)),U,2)
 . S PRCF("TAMT")=PRCF("TAMT")+LAMT
 . Q
 I PRCF("CAMT")/100=PRCF("TAMT") S OK=1
 Q
SCREEN ; CHECK BOC
 I $G(X) I $D(PRCFX("SA",+X))
 Q
OBLIG(PRCA) ; Check for an original entry SO or MO on the P.O.
 S PRCA="" Q:'$D(PRCF("PODA")) 0 Q:'$D(^PRC(442,PRCF("PODA"))) 0
 N DOC,PRCI,X S PRCI=0
 F  S PRCI=$O(^PRC(442,PRCF("PODA"),10,PRCI)) Q:+PRCI'=PRCI  D  Q:PRCA>0
 . S DOC=$P($G(^PRC(442,PRCF("PODA"),10,PRCI,0)),".",1,2)
 . I DOC="SO.E"!(DOC="MO.E") S PRCA=PRCI Q
 . I $P(DOC,".")=921,";00;01;02;03;04;05;06;08;09;10;11;12;13;14;15;16;18;20;21;22;23;24;25;26;27;60;41;51;53;71;91;93;97;"[(";"_$P(DOC,".",2)_";") S PRCA=PRCI Q
 . I ";1;2;"[(";"_$P($G(^PRC(442,PRCF("PODA"),0)),U,19)_";"),DOC="SO.M"!(DOC="MO.M") D
 . . S X="GECSSGET" X ^%ZOSF("TEST") Q:'$T
 . . S X=$P($G(^PRC(442,PRCF("PODA"),10,PRCI,0)),U,4) Q:X=""
 . . N GECSDATA
 . . D DATA^GECSSGET(X,0) Q:'$G(GECSDATA)
 . . I $G(GECSDATA(2100.1,GECSDATA,4,"E"))["Supply Fund Conversion Modification" S PRCA=PRCI Q
 . . I $G(GECSDATA(2100.1,GECSDATA,4,"E"))["General Post Fund Conversion Modification" S PRCA=PRCI Q
 . Q
 Q $S(PRCA>0:1,1:0)
LOOKUP(X,PARTIAL) ; X = STA-PAT # - LOOKUP returns next available PARTIAL #.
 N DIC S DIC="^PRCF(421.9,",DIC(0)="O" K DD,DO D ^DIC
 I Y<0 D FILE^DICN
 I +Y,$P(Y,U,3)=1 S PARTIAL="01",$P(^PRCF(421.9,+Y,0),U,2)="01" Q
 S P=$P($G(^PRCF(421.9,+Y,0)),U,2),P=P+1
 S P="00"_P,P=$E(P,$L(P)-1,$L(P))
 S PARTIAL=P,$P(^PRCF(421.9,+Y,0),U,2)=P
 Q