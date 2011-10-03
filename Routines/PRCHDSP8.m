PRCHDSP8 ;WISC/DJM-PRINT AMENDMENT,ROUTINE #5 ;12/12/95  8:55 AM
V ;;5.1;IFCAP;;Oct 20, 2000
 ;Per VHA Directive 10-93-142, this routine should not be modified.
 ;
E34 ;AUTHORITY Edit PRINT
 ;N CHANGE,CHANGES,OLD,NEW,LCNT,DATA,DT2,I
 S CHANGE=0 D LCNT^PRCHPAM5(.LCNT)
 F  S CHANGE=$O(^PRC(442,PRCHPO,6,PRCHAM,3,"AC",AMEND,3,CHANGE)) Q:CHANGE'>0  D
 .S CHANGES=$G(^PRC(442,PRCHPO,6,PRCHAM,3,CHANGE,0)),OLD=$G(^PRC(442,PRCHPO,6,PRCHAM,3,CHANGE,1,1,0))
 .S NEW=$P($G(^PRC(442,PRCHPO,6,PRCHAM,0)),U,4)
 .D LINE^PRCHPAM5(.LCNT,2)
 .I OLD=0 S DATA=" *ADDED THROUGH AMENDMENT*" D DATA^PRCHPAM5(.LCNT,DATA) D
 ..S DATA="Authority Edit is",DT2=$P(^PRCD(442.2,NEW,0),U,2) D  D DATA^PRCHPAM5(.LCNT,DATA) Q
 ...I $L(DATA)+$L(DT2)>239 S DATA=DATE_":" D DATA^PRCHPAM5(.LCNT,DATA) S DATA=DT2 Q
 ...S DATA=DATA_" "_DT2
 .I OLD>0 S DATA="Authority Edit " D  D DATA^PRCHPAM5(.LCNT,DATA)
 ..F I=1:1:3 S DT2=$S(I=1:$P(^PRCD(442.2,OLD,0),U,2),I=2:" has been changed to ",I=3:$P(^PRCD(442.2,NEW,0),U,2)) D CHK(.DATA,DT2)
 .D LCNT1^PRCHPAM5(LCNT)
 .Q
 Q
 ;
CHK(DATA,DT2) ;
 I $L(DATA)+$L(DT2)<241 S DATA=DATA_DT2 Q
 D DATA^PRCHPAM5(.LCNT,DATA) S DATA=DT2
 Q
E35 ;F.O.B. Point PRINT
 Q
 ;N CHANGE,OLD,NEW
 S CHANGE=0 D LCNT^PRCHPAM5(.LCNT)
 F  S CHANGE=$O(^PRC(442,PRCHPO,6,PRCHAM,3,"AC",AMEND,6.4,CHANGE)) Q:CHANGE'>0  D
 .S OLD=$G(^PRC(442,PRCHPO,6,PRCHAM,3,CHANGE,1,1,0)),NEW=$P($G(^PRC(442,PRCHPO,1)),U,6)
 .D LINE^PRCHPAM5(.LCNT,2)
 .S DATA="F.O.B. Point "_OLD_" has been changed to "_NEW D DATA^PRCHPAM5(.LCNT,DATA)
 .D LCNT1^PRCHPAM5(LCNT)
 .Q
 Q
 ;
E36 ;ITEM DISCOUNT Add/Edit PRINT
 N CHANGE,CHANGES,FIELD,OLD,NEW,ITEMD,ITEMD0,NEWI,NEWP,LCNT,DATA,DIS,DIS1,DIS2,PCT,PCT1,PCT2,FLAGDISC
 S FIELD=0 K ITEMD D LCNT^PRCHPAM5(.LCNT)
 F  S FIELD=$O(^PRC(442,PRCHPO,6,PRCHAM,3,"AC",AMEND,FIELD)) Q:FIELD'>0  D
 .S CHANGE=0 F  S CHANGE=$O(^PRC(442,PRCHPO,6,PRCHAM,3,"AC",AMEND,FIELD,CHANGE)) Q:CHANGE'>0  D
 ..S CHANGES=$G(^PRC(442,PRCHPO,6,PRCHAM,3,CHANGE,0))
 ..S OLD=$G(^PRC(442,PRCHPO,6,PRCHAM,3,CHANGE,1,1,0))
 ..K DIS2,PCT2 ;Remove old values before they get reset in the loop.
 ..S:FIELD=.01 DIS2=OLD
 ..S:FIELD=1 PCT2=OLD
 ..S FLAGDISC=$S(OLD=0:0,1:1) ;FLAGDISC=0 means a new entry, FLAGDISC=1 means a change to an existing entry.
 ..S ITEMD=$P(CHANGES,U,4) Q:$D(ITEMD(ITEMD))  S ITEMD(ITEMD)=1
 ..S ITEMD0=$G(^PRC(442,PRCHPO,3,ITEMD,0)) I ITEMD0="" Q
 ..;If an entry is found in 'AC' x-ref for PERCENT/DOLLAR AMOUNT field #1,then lookup for the ITEM field #.01 and for same item define var DIS2
 ..;I FIELD=1 S DIS=0 F  S DIS=$O(^PRC(442,PRCHPO,6,PRCHAM,3,"AC",36,.01,DIS)) Q:DIS'>0  S DIS1=$P($G(^PRC(442,PRCHPO,6,PRCHAM,3,DIS,0)),U,4) I DIS1=ITEMD D  Q
 ..;.S DIS2=$G(^PRC(442,PRCHPO,6,PRCHAM,3,DIS,1,1,0)) Q
 ..;If an entry is found in 'AC' x-ref for ITEM field #.01,then lookup for the PERCENT/DOLLAR AMOUNT field #1 and for same item define var PCT2
 ..I FIELD=.01 S PCT=0 F  S PCT=$O(^PRC(442,PRCHPO,6,PRCHAM,3,"AC",36,1,PCT)) Q:PCT'>0  S PCT1=$P($G(^PRC(442,PRCHPO,6,PRCHAM,3,PCT,0)),U,4) I PCT1=ITEMD D  Q
 ...S PCT2=$G(^PRC(442,PRCHPO,6,PRCHAM,3,PCT,1,1,0)) Q
 ..S NEW=$G(^PRC(442,PRCHPO,3,ITEMD,0)),NEWP=$P(NEW,U,2),NEWI=$P(NEW,U)
 ..D LINE^PRCHPAM5(.LCNT,2)
 ..S DIS2=$G(DIS2),PCT2=$G(PCT2)
 ..I FLAGDISC=0 S DATA=" *ADDED THROUGH AMENDMENT*" D DATA^PRCHPAM5(.LCNT,DATA) D  Q
 ...S DATA=$S(NEWP["$":NEWP,1:NEWP_"%")_" Discount For Item(s): "_NEWI D DATA^PRCHPAM5(.LCNT,DATA) Q
 ..;The new entry is completed with FLAGDISC=0, the existing entries will be dealt with the follwing conditional code.
 ..;If both fields ITEM #.01 and PERCENT/DOLLAR AMOUNT #1 are changed.
 ..I DIS2]"",PCT2]"" S DATA=$S(PCT2["$":PCT2,1:PCT2_"%")_" Discount For Item(s): "_DIS2 D DATA^PRCHPAM5(.LCNT,DATA) D  Q
 ...S DATA=" Will now be AMENDED to read "_$S(NEWP["$":NEWP,1:NEWP_"%")_" discount for an item(s): "_NEWI D DATA^PRCHPAM5(.LCNT,DATA) Q
 ..;If only field PERCENT/DOLLAR AMOUNT #1 is changed.
 ..I PCT2]"" S DATA=" The discount on item(s) "_NEWI_" will now be AMENDED to read "_$S(NEWP["$":NEWP,1:NEWP_"%") D DATA^PRCHPAM5(.LCNT,DATA) Q
 ..;If only field ITEM #.01 is changed.
 ..I DIS2]"" S DATA=" The item(s) "_DIS2_" will now be AMENDED to read "_NEWI D DATA^PRCHPAM5(.LCNT,DATA) Q
 .Q
 D LCNT1^PRCHPAM5(LCNT)
 Q
 ;
E37 ;ITEM DISCOUNT Delete PRINT
 ;N CHANGE,CHANGES,OLD,LCNT,DATA,DIS,ITEMD,ITEMD0
 S FIELD=0 K ITEMD D LCNT^PRCHPAM5(.LCNT)
 F  S FIELD=$O(^PRC(442,PRCHPO,6,PRCHAM,3,"AC",AMEND,FIELD)) Q:FIELD'>0  D
 .S CHANGE=0 F  S CHANGE=$O(^PRC(442,PRCHPO,6,PRCHAM,3,"AC",AMEND,FIELD,CHANGE)) Q:CHANGE'>0  D
 ..S CHANGES=$G(^PRC(442,PRCHPO,6,PRCHAM,3,CHANGE,0)),OLD=$G(^PRC(442,PRCHPO,6,PRCHAM,3,CHANGE,1,1,0))
 ..S ITEMD=$P(CHANGES,U,4)
 ..S ITEMD0=$G(^PRC(442,PRCHPO,3,ITEMD,0)) I ITEMD="" Q
 ..S DIS=$P($G(^PRC(442,PRCHPO,3,ITEMD,0)),U)
 ..D LINE^PRCHPAM5(.LCNT,2)
 ..S DATA=" *DELETED THROUGH AMENDMENT*" D DATA^PRCHPAM5(.LCNT,DATA)
 ..S DATA=$S(OLD["$":OLD,1:OLD_"%")_" Discount For Items: "_DIS_" is DELETED" D DATA^PRCHPAM5(.LCNT,DATA),LCNT1^PRCHPAM5(LCNT)
 ..Q
 .Q
 Q