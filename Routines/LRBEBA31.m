LRBEBA31 ;DALOI/JAH/FHS - ORDERING AND RESULTING OUTPATIENT ;8/10/04
 ;;5.2;LAB SERVICE;**291**;Sep 27, 1994
 ;
DADD(LRODT,LRSN,LRBETN,LRXDA,LRTS,LRBERF) ; Take care of ADDs to accession
 N LRBEALO,LRBEAALO,LRBEFN,LRBEX,LRBEVAL,LRBEXD,LRBEQT,LRBESPEC,LRBESAMP
 Q:'$$CIDC^IBBAPI(DFN)
 S LRBERF=$G(LRBERF)
 S LRBEVAL=$D(^XUSEC("PROVIDER",DUZ))
 S LRBEFN="O",LRBEDFN=DFN
 S X=^LRO(69,LRODT,1,LRSN,0),LRBESAMP=$P(X,"^",3) K X
 S LRBESPEC=$O(^LRO(69,LRODT,1,LRSN,4,0))
 S LRBESPEC=$S(LRBESPEC>0:$P(^LRO(69,LRODT,1,LRSN,4,LRBESPEC,0),"^",1),1:"")
 I LRBERF=1 D
 . D QRYADD^LRBEBA3(LRODT,LRSN,LRBETN,LRBEDFN,LRBESAMP,LRBESPEC,LRTS,.LRBEX)
 . D SACC^LRBEBA2(LRODT,LRSN,LRXDA,LRBESAMP,LRBESPEC,LRTS,.LRBEX)
 I LRBEVAL,LRBERF=0 D
 . D ELIG^LRBEBA3(LRBEDFN)
 . S LRBEQT=$$QUES^LRBEBA(LRBEDFN,LRBESAMP,LRBESPEC,LRTS,LRODT,.LRBEX)
 . D:'LRBEQT SACC^LRBEBA2(LRODT,LRSN,LRXDA,LRBESAMP,LRBESPEC,LRTS,.LRBEX)
 Q
 ;
SBA(LRDFN,LRBEX,LRBEQT,LROT) ; billing questions
 N LRBECNT,LRBEST,LRBEDFN,LRBESMP,LRBESPC,LRBEY,LRBETN,LRBEQT
 N LRBEOT,LRBETS,LRBEMSG,LRBEPTDT
 I '$D(DFN) S LRBEDFN=$$GET1^DIQ(63,LRDFN,.03,"I")
 S:$D(DFN) LRBEDFN=DFN
 D:$G(LRBEAT)=1 ELIG^LRBEBA3(LRBEDFN)
 S LRBEST=1,LRBEQT=0
 S LRBESMP="" F  S LRBESMP=$O(LROT(LRBESMP)) Q:LRBESMP=""!(LRBEQT)  D
 .S LRBESPC="" F  S LRBESPC=$O(LROT(LRBESMP,LRBESPC)) Q:LRBESPC=""  D
 ..S LRBEY="" F  S LRBEY=$O(LROT(LRBESMP,LRBESPC,LRBEY)) Q:LRBEY=""  D
 ...S LRBEOT(LRBEY,LRBESMP,LRBESPC)=""
 S LRBEY="" F  S LRBEY=$O(LRBEOT(LRBEY)) Q:LRBEY=""  D
 .S LRBESMP="" F  S LRBESMP=$O(LRBEOT(LRBEY,LRBESMP)) Q:LRBESMP=""!(LRBEQT)  D
 ..S LRBESPC="" F  S LRBESPC=$O(LRBEOT(LRBEY,LRBESMP,LRBESPC)) Q:LRBESPC=""  D
 ...S LRBEPTDT=$G(LROT(LRBESMP,LRBESPC,LRBEY)),LRBETS=$P(LRBEPTDT,U,1)
 ...S LRBETN=$$GET1^DIQ(60,LRBETS_",",.01)
 ...S LRBEMSG="Enter information for "_LRBETN D EN^DDIOL(LRBEMSG,"","!")
 ...S:$G(LRBEAT)'=1 LRBEALO=1
 ...S LRBEQT=$$QUES^LRBEBA(LRBEDFN,LRBESMP,LRBESPC,LRBETS,LRODT,.LRBEX)
 ...S:LRBEQT LRBEST=0 Q:LRBEQT
 ...D EN^DDIOL("","","!")
 Q LRBEST