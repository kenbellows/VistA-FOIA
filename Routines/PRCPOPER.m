PRCPOPER ;WISC/RFJ/DGL-distribution order error report; ; 3/17/00 3:23pm
V ;;5.1;IFCAP;;Oct 20, 2000
 ;Per VHA Directive 10-93-142, this routine should not be modified.
 Q
 ;
 ;
CHECKORD ;  check order for errors (called from prcpopl protocol)
 D VARIABLE^PRCPOPU
 D EN^VALM("PRCP DIST ORDER CHECK ITEMS")
 D INIT^PRCPOPL
 S VALMBCK="R"
 Q
 ;
 ;
INIT       ;  check order for errors and build array
 N DATA,ERROR,ITEMDA,QTYORDER,STATUS,QTYOH
 K ^TMP($J,"PRCPOPER")
 S VALMCNT=0
 I 'PRCPPRIM D SET^PRCPOPL("PRIMARY INVENTORY SOURCE MISSING.  PLEASE RE-EDIT THE ORDER FIRST.") Q
 I 'PRCPSECO D SET^PRCPOPL("SECONDARY INVENTORY POINT IS MISSING, PLEASE RE-EDIT THE ORDER FIRST.") Q
 ;
 S STATUS=$P(^PRCP(445.3,ORDERDA,0),"^",6)
 ;  check items on order
 S ITEMDA=0 F  S ITEMDA=$O(^PRCP(445.3,ORDERDA,1,ITEMDA)) Q:'ITEMDA  S DATA=^(ITEMDA,0) D
 .   S QTYORDER=$P(DATA,"^",2)
 .   I 'QTYORDER D BLDARRAY^PRCPOPL,SET^PRCPOPL("     ** THERE IS NO QUANTITY ORDERED, ITEM SHOULD BE DELETED FROM ORDER **") Q
 .   S ERROR=$$ITEMCHK(PRCPPRIM,PRCPSECO,ITEMDA)
 .   S X=$G(^PRCP(445,PRCPPRIM,1,ITEMDA,0))
 .   I X]"" D
 .   .   S QTYOH=+$P(X,"^",7)
 .   .   I PRCP("DPTYPE")'="S",QTYOH<QTYORDER S ERROR=ERROR_$S(ERROR="":"",1:"^")_"     ** QTY ORDERED ("_QTYORDER_") IS MORE THAN PRIMARY QTY ON HAND ("_QTYOH_") **"
 .   .   Q
 .   I ERROR="" Q
 .   D BLDARRAY^PRCPOPL(PRCPPRIM,PRCPSECO,ITEMDA,QTYORDER,STATUS)
 .   F %=1:1 Q:$P(ERROR,"^",%,99)=""  I $P(ERROR,"^",%)'="" D SET^PRCPOPL($P(ERROR,"^",%))
 ;
 I VALMCNT=0 S VALMQUIT=1,VALMSG="* * * NO ERRORS FOUND * * *"
 Q
 ;
 ;
EXIT ;  exit and clean up
 K ^TMP($J,"PRCPOPER")
 Q
 ;
 ;
EEITEMS ;  called from protocol file to enter/edit invpt items
 D
 .   N PRC,PRCP
 .   S PRCP("DPTYPE")="PS"
 .   D ^PRCPEILM
 D INIT
 S VALMBCK="R"
 I $G(VALMQUIT) K VALMBCK
 Q
 ;
 ;
ITEMCHK(PRCPPRIM,PRCPSECO,ITEMDA) ;  check items
 ;  returns errors delimited by ^ or ""
 N ITEMDATA,ERROR,VDATA
 S ERROR=""
 S ITEMDATA=$G(^PRCP(445,PRCPPRIM,1,ITEMDA,0))
 I ITEMDATA="" S ERROR="    ** ITEM NOT STORED IN PRIMARY INVENTORY POINT ** ^     Either add item to primary or delete item from order."
 I '$D(^PRCP(445,PRCPSECO,1,ITEMDA,0)) S ERROR=ERROR_$S(ERROR="":"",1:"^")_"    ** ITEM NOT STORED IN SECONDARY INVENTORY POINT **"
 ;
 S VDATA=$$GETVEN^PRCPUVEN(PRCPSECO,ITEMDA,PRCPPRIM_";PRCP(445,",1)
 I 'VDATA S ERROR=ERROR_$S(ERROR="":"",1:"^")_"    ** PRIMARY INVENTORY POINT IS NOT LISTED AS A SOURCE **"
 I $P(VDATA,"^",2,3)'=($P(ITEMDATA,"^",5)_"^"_$P(ITEMDATA,"^",14)) S ERROR=ERROR_$S(ERROR="":"",1:"^")_"    ** SECONDARY UNIT PER RECEIPT DOES NOT EQUAL PRIMARY UNIT PER ISSUE **"
 Q ERROR