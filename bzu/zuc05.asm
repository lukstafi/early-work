.VERS "ST6263"
.ROMSIZE 2
;;; analogowy pomiar B z opcja zatrzasku do pamieci, histereza + dl. impulsu + opozn. puszczenia + wersja wyjscia proby
;;; pomiar pradu stalego, wykazywanie poziomu pomiaru, opcje:
;;; (0) test kwantylowy (hipoteza: zmiana poziomu, test kwantylowy rzedu BEZWLAD/OKRES, test medianowy dla OKRES = 2*BEZWLAD)
;;; (1) dlugosc impulsu + opoznienie (dlugosc impulsu: CZASPOMB, opoznienie OPZNDIOD)
;;; (2) dlugosc impulsu + glosowanie (test medianowy, dlugosc impulsu: CZASPOMB)
;;; stan awaryjny: piki odfiltrowywane dlugoscia impulsu, (spadki odfiltrowywac?)
;;; synchronizacja progu 5 i diody B, histereza PROG5 / PUSCB na progu 5
;;; opcja wyjscia proby

;;; pomiar zasilania:
;;; wejscie:	PC4 (pin 18) analogowe
;;; pomiar z histereza ZASILANIE / ZASICHWYC
;;; pomiar B:
;;; wejscie:	PC3 (pin 19) analogowe
;;; wyjscia:	PB0 (pin 1) -- ledP i przekaznik; PB1 -- ledB, PA3 -- ledM; PB2, PB3, PB6, PB7, PA0, PA1, PA2 -- progi
;;; wyjscia push-pull
;;; pomiar B opcja zatrzask:
;;; zatrzask po impulsie dlugosci CZASPOMB na poziomie PROG5, zapis do pamieci EEPROM
;;; dlugosc impulsu dla kasowania TRZYMAJB * 255
;;; pomiar B opcja bez zatrzasku:	
;;; pomiar z histereza PROG5 / PUSCB, dlugosc impulsu CZASPOMB,
;;; dlugosc impulsu dla puszczenia TRZYMAJB * 255, zatrzask diody ledM
;;; funkcja ledM:
;;; w opcji z zatrzaskiem, ledM wykazuje przywrocenie zatrzasku zapamietanego przed resetem (zanikiem napiecia)
;;; w opcji bez zatrzasku, ledM wykazuje wystapienie pomiaru awaryjnego i nie gasnie az do skasowania
;;; w wersji bez ledM w opcji bez zatrzasku dioda M, kasowanie i pamiec EEPROM sa nieaktywne
;;; kasowanie zatrzasku:
;;; wejscie:	PC2 (pin 20) cyfrowe, zboczem opadajacym
;;; dlugosc impulsu KTRLKAS * 255, w opcji bez zatrzasku kasuje ledM
;;; kasowanie jest nieaktywne w trybie wyjscia proby
;;; opcja zatrzasku:
;;; wejscie:	PA3 (pin 13) analogowe,
;;; wlaczenie stanem ponizej POMZATRZ dlugosc impulsu wlaczajacego/wylaczajacego CZASZATRZ
;;; pomiar dokonywany okresowo (okres KTRLZAT * 255), dopiero w czasie kontroli impulsu w kazdym obiegu petli
;;; po restarcie pomiar dokonywany przed wejsciem do petli
;;; pamiec zatrzasku:
;;; wyjscie:	PA3 (pin 13) -- ledM
;;; jesli po restarcie opcja zatrzasku jest wlaczona i jest zapamietany zatrzask,
;;; jest on wlaczany i zapalana ledM
;;; przelaczanie opcji i dioda M:
;;; przy wlaczaniu opcji zatrzasku dioda M jest gaszona
;;; przy wylaczaniu opcji zatrzasku i swiecacej B (jest zatrzask) dioda M jest zaswiecana
;;; przy powrocie napiecia w opcji z zatrzaskiem, jesli przed zanikiem swiecila M, wchodzi zatrzask, swieca B i M
;;; wersja z wyjsciem proby:
;;; wejscie: PC2 (w trybie wejscia), wyjscie: PC2 (w trybie wysylania proby), PA3 (ledM)
;;; po sygnale na PC2 dlugosci WYJPROBY * 255 przelacza PC2 w wyjscie w stanie wysokim na czas DLPROBY * 255
;;; jednoczesnie mruga dioda ledM z okresem SYGPROBY * 255 * 2
;;; opoznienie startu:
;;; dodatkowa petla przed rozpoczeciem pomiarow (OPOZST)
;;; opoznienie po powrocie zasilania:
;;; OPOZAS dobrych pomiarow dopiero przywraca prace

;;; port C:	2 wej cyfrowe (wyjscie push-pull w trybie proby) 3,4 wej analogowe
;;; port B:	0-3, 6, 7 wyjscia push-pull
;;; port A:	0-3 wyjscia push-pull, 3 okresowo wejscie analogowe

LEDM		.equ	1	; funkcjonalnosc ledM (0 -- wylaczona)
DEBUG		.equ	0	; zawsze ustawiac DEBUG .equ 0
PROBA		.equ	1	; 1 -- wlaczona opcja proby, 0 -- wylaczana
TYPDIOD	.equ	2	; 0 -- test kwantylowy, 1 -- dlugosc impulsu + opoznienie, 2 -- dlugosc impulsu + glosowanie
OPOZST		.equ	100	; opoznienie startu - musi byc wieksze niz zero
KTRLKAS		.equ	3	; kontrola kasowania (starszy bajt) (1 bez opoznienia)- jak dlugo wcisniete, zeby uwzglednic
	.IFC NE PROBA
WYJPROBY		.equ	20	; dlugosc stanu wysokiego na PC2 wyprowadzajaca probe
DLPROBY		.equ	10	; dlugosc trwania proby
SYGPROBY		.equ	2	; polowa okresu mrugania ledM w trybie wyjscia proby
	.ENDC
KTRLZAT		.equ	10	; kontrola opcji zatrzasku (starszy bajt)
ZASILANIE	.equ	118	; 118 = czesc calkowita z 256 * 0.49 * 4.7 / 5 (jest 14,6V~tj.0,60Uz)
ZASICHWYC	.equ	168   ; 168 =                   256 * 0.7 * 4.7 / 5 (ok.0,75Uz)
OPOZAS		.equ	100	; opoznienie przy powrocie zasilania
POMZATRZ	.equ	50	; ok 1V prog wylaczenia zatrzasku
CZASZATRZ	.equ	100	; dlugosc impulsu dla opcji zatrzasku
TRZYMAJB	.equ	3	; opoznienie puszczenia B (starszy bajt)
CZASPOMB	.equ	90	; wymagany czas pomiaru B (dlugosc impulsu)(90x0,6ms=54ms)
	.IFC EQ TYPDIOD
OKRES		.equ	100	; suma pomiarow na zmiane stanu diod
BEZWLAD	.equ	70	; ilosc pomiarow pozwalajacych na zmiane,grawitacja
	.ENDC
	.IFC EQ TYPDIOD-1
OPZNDIOD	.equ	100	; opoznienie powrotu do poprzedniego poziomu diod
	.ENDC
	.IFC EQ TYPDIOD-2
KWORUM	.equ	4		; ilosc impulsow przyp. na glosowanie (powinna byc parzysta!)
BEZWLAD	.equ	(KWORUM/2)+1
	.ENDC
	;; (hipoteza: zmiana poziomu, test kwantylowy rzedu BEZWLAD/OKRES)
PROG1		.equ	5	; progi pomiarowe
PROG2		.equ	8
PROG3		.equ	23
PROG4		.equ	56
PUSCB		.equ	80
PROG5		.equ	82
PROG6		.equ	121
PROG7		.equ	147

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; struktura programu:
; 1. definicje stalych programu
; 2. definicje adresow zmiennych i rejestrow
; 3. tekst informujacy o ustawieniach
; 4. INIT: poczatek programu, inicjalizacja zmiennych i ustawien rejestrow
; 5. OPOZST1: opoznienie wejscia do petli glownej
; 6. ZATRZOPC-ZATRZKON: pomiar opcji zatrzasku, inicjalizacja ledM z pamieci
; filtrowanie: ktora opcja pierwsza przekroczy CZASZATRZ pomiarow
; 7. PETLA-USTAWB: petla glowna, kontrola zasilania, powrot z braku zasilania
; 8. PRACA: czesc robocza petli
; 9. ROBPOM1-RMNIEJ: pomiar B z okresleniem poziomu na pasku diod
; 9a. HISTEREZA-DOPAMIECI: synchronizacja pomiaru B z poziomem 5, zatrzask pomiaru B
; 10. JUZSWIEC-POZMIANIE: wyswietlenie stanu na pasku diod (tylko w cyklach, w ktorych zmiana)
; 11. TESTGUZIK-POTESCIE: obsluga guzika kasowania, przeprowadzenie kasowania i wysylanie proby
; 11a. KROKPROBA-KONPROBY: obsluga wysylania proby
; 12. OPOZNIENIE-OPOZN3: opoznienie chwycenia przekaznika i zgaszenia ledB
; 13. DOZMZATRZ-NIECZYSC: pomiar opcji zatrzasku i obsluga przelaczenia opcji zatrzasku
; 14. DO4PETLI: zapetlij
; 15. PISZPAMV-CZYTPAMA: funkcje pomocnicze
; PRZYWRM: zaswieca ledM wtw gdy MSTAN
; 16. ADCINT-NMINT: przerwania	
; 17. ustawienie przerwan (i poczatku programu - przerwanie RESET)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


A	.def 0ffh		; akumulator
X     .def 080h			; rejestr adresowy
Y	.def 081h		; rejestr adresowy
V     .def 082h		; rejestr danych
W     .def 083h		; rejestr danych
GUST	.def 084h	; starszy bajt licznika przycisku kasowania (czy dosc dlugo trzymany) liczy w gore
GUML	.def 085h	; mlodszy bajt przycisku kasowania (odlicza w dol)
PBST	.def 086h	; starszy bajt opoznienia puszczenia B
PBML	.def 087h	; mlodszy bajt opoznienia puszczenia B
BTRZ	.def 088h	; znacznik trzymania blednego pomiaru (tzn. ledB swieci, Pk nie trzyma)
POMB	.def 089h	; bajt odliczania w dol blednych pomiarow B
ZATRZ	.def 08ah		; opcja z zatrzaskiem czy bez
	.IFC EQ TYPDIOD
WIEKSZ	.def 08bh	; ilosc przekroczen ponad POZIOM
MNIEJ	.def 08ch	; ilosc spadkow ponizej POZIOM
CZAS	.def 08dh	; licznik petli - odmierza "okresy" pomiarowe
	.ENDC
	.IFC EQ TYPDIOD-1
DIKIER	.def 08bh	; kierunek zmian na diodach: 1 -- wzrost, 2 -- spadek
DIPOMZM	.def 08ch	; zliczanie dlugosci impulsu w kierunku zmiany
DIOPOZ	.def 08dh	; licznik opoznienia na diodach
DIPOMPZ	.def 08eh	; zliczanie dlugosci impulsu dla pozostania na wykazywanym pozmiomie
	.ENDC
	.IFC EQ TYPDIOD-2
WIEKSZ	.def 08bh	; ilosc impulsow ponad POZIOM
MNIEJ	.def 08ch	; ilosc impulsow ponizej POZIOM
CZAS	.def 08dh	; licznik petli - zlicza impulsy
DIWIEKSZ	.def 08eh	; zliczanie dlugosci impulsu ponad POZIOM
DIMNIEJ	.def 08fh	; zliczanie dlugosci impulsu ponizej POZIOM
	.ENDC
POZIOM	.def 090h	; aktualnie wykazywany poziom
MSTAN	.def 091h		; stan diody M (tzn. 3, DRA)
ZASOPOZ .def 092h		; licznik opoznienia przy powrocie zasilania
JESTZAT	.def 093h		; licznik pomiarow na wlaczenie zatrzasku (ponizej progu)
NIEZAT	.def 094h		; licznik pomiarow na wylaczenie zatrzasku (powyzej progu)
ZATST	.def 095h		; starszy bajt licznika kontroli opcji zatrzasku
ZATML	.def 096h		; mlodszy --||--
STANORC	.def 097h	; aktualne ustawienie portu C
ORCWYJPR	.equ 100b	; mozliwe wartosci opcji portu C
ORCKAS	.equ 0		;
	.IFC NE PROBA
PROBST	.def 098h	; starszy bajt licznika wyprowadzania proby (jako mlodszy bajt KAML)
PROBML	.def 099h
MIGMST	.def 09ah	; licznik mrugania ledM w czasie wyprowadzania proby
	.ENDC
	.IFC NE DEBUG		; wersja DEBUGgera
DBZASIL	.def 09dh		; wartosc pomiaru zasilania
DBPOMB	.def 09eh		; wartosc pomiaru B
DBZATRZ	.def 09fh		; wartosc pomiaru trybu zatrzasku
DBGUZIK	.def 0a0h		; stan guzika kasowania
	.ENDC
	
PAMIEC	.def 000h		; pamiec zatrzasku (jesli =/= 0 byl zatrzask)


DRA   .def 0c0h		; pierwszy port
DDRA	.def 0c4h		
ORA	.def 0cch
DRB	.def 0c1h      ; drugi port
DDRB	.def 0c5h
ORB	.def 0cdh
DRC	.def 0c2h      ; trzeci port
DDRC	.def 0c6h
ORC	.def 0ceh
ADCR	.def 0d1h		; przetwornik A/D
ADR	.def 0d0h
WDR	.def 0d8h		; watchdog - resetowanie przy pozostawaniu poza petla
IOR	.def 0c8h		; rejestr przerwan
DRBR	.def 0e8h	; Data RAM/EEPROM Bank Register
EECTL	.def 0eah	; EEPROM Control Register
			
	.ORG 0880H
	.IFC NE DEBUG
	.ASCII "TEST "
	.DISPLAY "NIE NAGRYWAC TEJ WERSJI! TO WERSJA TESTOWA."
	.ELSE
	.ASCII "ZUC05 "
	.ENDC
   .IFC EQ LEDM
   .ASCII "nM "
   .DISPLAY "BZU-O5 WERSJA BEZ DIODY M. "
   .ELSE
   .ASCII "M "
   .DISPLAY "BZU-05 WERSJA LED-M. "
   .ENDC
   .IFC EQ PROBA
   .ASCII "nPR "
   .DISPLAY "Bez opcji proby."
   .ELSE
   .ASCII "PR "
   .DISPLAY "Z opcja proby."
   .ENDC
   .IFC EQ TYPDIOD
   .ASCII "KW"
   .DISPLAY "Z filtrowaniem diod przez test kwantylowy."
   .ENDC
   .IFC EQ TYPDIOD-1
   .ASCII "IO"
   .DISPLAY "Z filtrowaniem diod przez dlugosc impulsu i opoznienie."
   .ENDC
   .IFC EQ TYPDIOD-2
   .ASCII "IG"
   .DISPLAY "Z filtrowaniem diod przez dlugosc impulsu i glosowanie."
   .ENDC
   
	.ORG 0890H		; adres poczatku programu

INIT
	LDI WDR, 11111110b		; watchdog
	LDI ADCR, 10010000b      ; wlacz przetwornik A/D, pozwol mu sie ustabilizowac
	NOP        
	NOP
	LDI DDRA,   00000111b      ; PA0-2 5-7 prog, PA3 pomiar opcji zatrzasku
	LDI ORA,    00001111b   
	LDI DRA,    00001000b		; zgas diody
	LDI DDRB,   11001111b		; PB0 ledP, PB1 ledB, PB2-3 PB6-7 1-4 prog
	LDI ORB,    11001111b		; 
	LDI DRB,    00000000b		; 
	LDI DDRC,   00000000b		;
	LDI ORC,    00000000b		;
	LDI STANORC, ORCKAS			; = 0
	LDI DRC,    00011100b		; PC2 wej kas bez pull-up, PC3 pom B, PC4 zasilanie
	LDI DRBR, 01h		; EEPROM Page 0
	LDI EECTL, 00000000b		; pozwol na czytanie z EEPROM
	LDI ZATST, KTRLZAT		; znacznik przerwania
	LDI ZATML, 255
	LDI GUST, 0
	LDI GUML, 0
	
	LDI IOR,	00010000b		; uwzglednij przerwanie budzace po pomiarze napiecia
	LDI X,		0
	LDI V,		0
	LDI W,		OPOZST

	LDI POMB,	CZASPOMB
	LDI PBST,	TRZYMAJB		; nie chwytaj od razu
	LDI PBML,	255
	LDI BTRZ,	0
	LDI MSTAN, 0
	LDI POZIOM, 0		; wyzeruj poziom pomiaru
	.IFC EQ TYPDIOD
	LDI WIEKSZ, 0
	LDI MNIEJ, 0
	LDI CZAS, OKRES	; co ile aktualizuje diody (zatrzask wykazywania odfiltrowuje spadki)
	.ENDC
	.IFC EQ TYPDIOD-1
	LDI DIKIER, 1	; kierunek zmian na diodach: 1 -- wzrost, 2 -- spadek
	LDI DIPOMZM, CZASPOMB	; zliczanie dlugosci impulsu w kierunku zmiany
   LDI DIOPOZ, OPZNDIOD		; licznik opoznienia na diodach
	LDI DIPOMPZ,	CZASPOMB		; zliczanie dlugosci impulsu dla pozostania na wykazywanym pozmiomie
	.ENDC
	.IFC EQ TYPDIOD-2
	LDI WIEKSZ, 0
	LDI MNIEJ, 0
	LDI CZAS, KWORUM	; co ile aktualizuje diody (zatrzask wykazywania odfiltrowuje spadki)
	LDI DIWIEKSZ, CZASPOMB	; zliczanie dlugosci impulsu
	LDI DIMNIEJ, CZASPOMB	; zliczanie dlugosci impulsu
	.ENDC
	LDI JESTZAT, 0
	LDI NIEZAT, 0
	.IFC NE PROBA
	LDI PROBST, 0			; PROB > 0 oznacza tryb wysylania proby
	LDI PROBML, 0
	LDI MIGMST, 0
	.ENDC
	.IFC NE DEBUG
	;; wartosci poczatkowe wejsc
	LDI DBZASIL, 0
	LDI DBZATRZ, 0
	LDI DBGUZIK, 0
	LDI DBPOMB, 0
	.ENDC

	RETI

OPOZST1 ; petla opoznienia wejscia do petli glownej
	LDI WDR, 11111110b		; watchdog
	DEC W
	JRZ DAJW
	LDI V, 255
OPOZST2
	DEC V				; odliczanie
	JRNZ OPOZST2
	JP OPOZST1
DAJW
	LDI W, 0

ZATRZOPC			; pomiar opcji zatrzasku
	LDI WDR, 11111110b		; watchdog
	SET 3, ORA		; ustaw PA3 do przetwarzania A/D
	NOP
	NOP
	NOP
	NOP
	LDI ADCR, 10110000b
	.IFC EQ DEBUG
	WAIT		; Czekaj na wynik pomiaru - wczytany do akumulatora
	.ELSE
	LD A, DBZATRZ		; DEBUG
	.ENDC
	
	CPI A, POMZATRZ		; sprawdz czy napiecie na wlasciwym poziomie
	JRC PONIZAT
	INC NIEZAT
	LDI JESTZAT, 0
	JP ZATRZSPR
PONIZAT
	INC JESTZAT
	LDI NIEZAT, 0
ZATRZSPR
	LD A, JESTZAT
	CPI A, CZASZATRZ
	JRNC ZATJEST
	LD A, NIEZAT
	CPI A, CZASZATRZ
	JRNC ZATNIE
	JP ZATRZOPC
ZATJEST
	LDI ZATRZ, 255
	JP ZATRZKON
ZATNIE
	LDI ZATRZ, 0
	.IFC EQ LEDM		; wersja bez ledM -- czysc pamiec
	CALL CZYTPAMA
	JRZ ZATRZKON
	LDI V, 0
	CALL PISZPAMV
	.ENDC
	
ZATRZKON
	LDI JESTZAT, 0
	LDI NIEZAT, 0
	RES 3, ORA		; PA3 ledM
	SET 3, DDRA
	SET 3, ORA
	RES 3, DRA		; zgas ledM
	CLR MSTAN
	.IFC EQ LEDM		; wersja bez pamieci
	JRS 0, ZATRZ, ROBZATRZ
	JP PETLA
ROBZATRZ
	.ENDC
	;; sprawdzenie czy zatrzask w pamieci
	CALL CZYTPAMA
	JRNZ ZASWIECM
	JP PETLA
ZASWIECM
	SET 3, DRA		; zaswiec M
	LDI MSTAN, 255
	.IFC NE LEDM		; wersja z ledM wymaga sprawdzenia opcji
	JRR 0, ZATRZ, PETLA
	.ENDC
	LDI BTRZ, 255
	SET 1, DRB		; przywroc swiecenie B (zatrzasniete)
	LDI PBST, 0		; wylacz opoznienie (ktore by skasowalo zatrzask)
	LDI PBML, 0
	
PETLA
	LDI WDR, 11111110b		; watchdog

	; Kontrola zrodla zasilania **********************************************

	LD A, STANORC
	COM A
	ANDI A, 11101111b
	COM A
	LD ORC, A		; ustaw PC4 do przetwarzania A/D
	NOP
	NOP
	NOP
	NOP
	LDI ADCR, 10110000b	; zacznij przetwarzanie napiecia zasilajacego
	.IFC EQ DEBUG
	WAIT		; Czekaj na wynik pomiaru - wczytany do akumulatora
	.ELSE
	LD A, DBZASIL		; DEBUG
	.ENDC
	CPI A, ZASILANIE		; sprawdz czy napiecie na wlasciwym poziomie
	JRC POWER
	JP PRACA
POWER
	LDI WDR, 11111110b		; watchdog
	;LD A, DRA		; zapamietaj ledM
	;LD W, A
	LDI DRA, 00000000b	; Jesli slabe napiecie zgas wszystkie diody
	LDI DRB, 00000000b	; 

	LD A, STANORC
	COM A
	ANDI A, 11101111b
	COM A
	LD ORC, A		; ustaw PC4 do przetwarzania A/D
	NOP
	NOP
	NOP
	NOP
	LDI ADCR, 10110000b	; zacznij przetwarzanie
	.IFC EQ DEBUG
	WAIT		; Czekaj na wynik pomiaru - wczytany do akumulatora
	.ELSE
	LD A, DBZASIL		; DEBUG
	.ENDC
	CPI A, ZASICHWYC		; sprawdz czy napiecie na wlasciwym poziomie
	JRNC ZASOK
	LDI ZASOPOZ, OPOZAS
	JP POWER
ZASOK
	DEC ZASOPOZ
	JRZ PRZYWROT
	JP POWER
PRZYWROT
	LDI ZASOPOZ, OPOZAS
	.IFC NE LEDM
	JRR 0, ZATRZ, PRZYWR2
	CALL PRZYWRM
PRZYWR2
	.ENDC
	LDI POMB, CZASPOMB	; anuluj rezultaty sprzed spadku
	LDI NIEZAT, 0
	LDI PBST, 0				; jesli potrzebne opoznienie, ustawione ponizej
	LDI PBML, 0
	LD A, BTRZ
	AND A, ZATRZ
	JRNZ USTAWB
	LDI PBST, TRZYMAJB	; wymus opoznienie po powrocie napiecia
	LDI PBML, 255
	LD A, BTRZ 				; opoznienie chwycenia Pk nawet gdy ledB nie swieci
	JRNZ USTAWB
	JP JUZSWIEC
USTAWB
	SET 1, DRB		; przywroc swiecenie B (zatrzasniete lub opoznione)
	JP JUZSWIEC
PRACA

	LDI WDR, 11111110b		; watchdog

	
RODBPOMB1
	;; impuls przekraczajacy ustawi nr progu
	LD A, STANORC
	COM A 
   ANDI A, 11110111b			; ustaw PC3 do przetwarzania A/D
	COM A
	LD ORC, A
	NOP
	NOP
	NOP
	NOP
	LDI ADCR, 10110000b	; zacznij konwersje
	.IFC EQ DEBUG
	WAIT		; Czekaj na wynik pomiaru - wczytany do akumulatora
	.ELSE
	LD A, DBPOMB
	.ENDC


	;;porownaj z progami pomiarowymi
	LDI W, 0
	CPI A, PROG1
	JRNC POMIAR2
	JP FINDOBRY
POMIAR2
	INC W
	CPI A, PROG2
	JRNC POMIAR3
	JP FINDOBRY
POMIAR3
	INC W
	CPI A, PROG3
	JRNC POMIAR4
	JP FINDOBRY
POMIAR4
	INC W
	CPI A, PROG4
	JRNC POMIAR5
	JP FINDOBRY
POMIAR5
	INC W
	JRR 0, BTRZ, BEZHIST
	CPI A, PUSCB
	JRNC HISTEREZA
	JP FINDOBRY
HISTEREZA			; synchronizacja progu 5 i ledB
	LD X, A
	DEC POMB
	JRZ ZATRZYMAJ
	JP POMIAR6
ZATRZYMAJ			; przekroczenie progu 5 powoduje zatrzask
	LDI POMB, CZASPOMB
	LDI PBST, 0	; zapomnij o kasowaniu w opcji z zatrzaskiem
	LDI PBML, 0
	;; diody juz swieca
	JRS 0, ZATRZ, POMIAR6
	LDI PBST, TRZYMAJB	; opoznienie B startuje za kazdym zlym pomiarem
	LDI PBML, 255			; opoznienie B - mniej znaczacy rejestr
	JP POMIAR6		; omijanie zapisu do pamieci, jesli opcja bez zatrzasku
BEZHIST
	CPI A, PROG5
	JRNC AWARYJNY
	JP FINDOBRY
AWARYJNY			; synchronizacja progu 5 i ledB
	;;przed pomiarem uwzglednic zatrzask -- prog 5 przekroczony
	LD X, A		; X przechowuje wynik pomiaru (do wznowienia porownan w POMIAR6)
	DEC POMB
	JRZ ZATRZASK
	JP FINISZ
ZATRZASK			; przekroczenie progu 5 powoduje zatrzask
	LDI POMB, CZASPOMB
	LDI BTRZ, 255	; zapomnij o kasowaniu
	LDI PBST, 0
	LDI PBML, 0
	RES 0, DRB		; zgas LED-P
	SET 1, DRB		; wlacz LED-B
	JRS 0, ZATRZ, DOPAMIECI
	;; w trybie bez zatrzasku:
	LDI PBST, TRZYMAJB	; opoznienie B startuje za kazdym zlym pomiarem
	LDI PBML, 255			; opoznienie B - mniej znaczacy rejestr
	.IFC EQ LEDM		; wersja bez ledM
	JP POMIAR6
	.ENDC
	SET 3, DRA		; pamietaj awaryjny pomiar
	LDI MSTAN, 255
DOPAMIECI
	LDI V, 255
	CALL PISZPAMV
	;;wlasciwy pomiar 6
POMIAR6
	INC W
	LD A, X
	CPI A, PROG6
	JRNC POMIAR7
	JP FINISZ
POMIAR7
	INC W
 	CPI A, PROG7
	JRNC POMPROG7
	JP FINISZ
POMPROG7
	INC W
	JP FINISZ
FINDOBRY
	LDI POMB, CZASPOMB
FINISZ
	LD A, POZIOM
	CP A, W
	JRNC MWIEKSZN
	JP MWIEKSZ
MWIEKSZN
	JRZ MMNIEJN
	JP MMNIEJ
MMNIEJN
       ; *** Pozostanie na tym samym poziomie
	.IFC EQ TYPDIOD
	JP KROK
	.ENDC

   .IFC EQ TYPDIOD-1
	LDI DIPOMZM, CZASPOMB
	DEC DIPOMPZ
	JRZ DIREOPZN
	JP TESTGUZIK
DIREOPZN
	LDI DIPOMPZ, CZASPOMB
	LDI DIOPOZ, OPZNDIOD
	JP TESTGUZIK
	.ENDC

	.IFC EQ TYPDIOD-2
	LDI DIWIEKSZ, CZASPOMB
	LDI DIMNIEJ, CZASPOMB
	JP TESTGUZIK	
	.ENDC
	
MWIEKSZ
		; *** Wzrost poziomu
	.IFC EQ TYPDIOD
	INC WIEKSZ
	JP KROK
	.ENDC
	
	.IFC EQ TYPDIOD-1
	LD A, DIKIER
	CPI A, 1
	JRZ ZGODWIEK
	LDI DIPOMZM, CZASPOMB
	DEC DIOPOZ
	JRZ WZROST
	JP TESTGUZIK
ZGODWIEK
	LDI DIOPOZ, OPZNDIOD
	DEC DIPOMZM
	JRZ WZROST
	JP TESTGUZIK
WZROST
	LDI DIPOMZM, CZASPOMB
	LDI DIOPOZ, OPZNDIOD
	LDI DIPOMPZ, CZASPOMB
	LDI DIKIER, 1
	INC POZIOM
	JP JUZSWIEC
	.ENDC
	
	.IFC EQ TYPDIOD-2
	LDI DIMNIEJ, CZASPOMB
	DEC DIWIEKSZ
	JRZ WZROST
	JP TESTGUZIK
WZROST
	LDI DIWIEKSZ, CZASPOMB
	INC WIEKSZ
	DEC CZAS
	JRZ DODIZM
	JP TESTGUZIK
DODIZM
	JP ZMIANA
	.ENDC
	
MMNIEJ
		; Spadek poziomu
	.IFC EQ TYPDIOD
	INC MNIEJ
KROK
	DEC CZAS
	JRZ ZMIANA
	JP TESTGUZIK
ZMIANA
	LDI CZAS, OKRES
	LD A, WIEKSZ
	CPI A, BEZWLAD
	JRNC RWIEKSZ	; ruch w strone wiekszych
	LD A, MNIEJ
	CPI A, BEZWLAD
	JRC NIEMNIEJ
	JP RMNIEJ	; ruch w strone mniejszych
NIEMNIEJ
	JP POZMIANIE
RWIEKSZ
	INC POZIOM
	JP JUZSWIEC
RMNIEJ
	DEC POZIOM
   .ENDC
   
	.IFC EQ TYPDIOD-1
	LD A, DIKIER
	CPI A, 2
	JRZ ZGODMNIEJ
	LDI DIPOMZM, CZASPOMB
	DEC DIOPOZ
	JRZ SPADEK
	JP TESTGUZIK
ZGODMNIEJ
	LDI DIOPOZ, OPZNDIOD
	DEC DIPOMZM
	JRZ SPADEK
	JP TESTGUZIK
SPADEK
	LDI DIPOMZM, CZASPOMB
	LDI DIOPOZ, OPZNDIOD
	LDI DIPOMPZ, CZASPOMB
	LDI DIKIER, 2
	DEC POZIOM
   .ENDC
   
	.IFC EQ TYPDIOD-2
	LDI DIWIEKSZ, CZASPOMB
	DEC DIMNIEJ
	JRZ SPADEK
	JP TESTGUZIK
SPADEK
	LDI DIMNIEJ, CZASPOMB
	INC MNIEJ
	DEC CZAS
	JRZ ZMIANA
	JP TESTGUZIK
ZMIANA
	LDI CZAS, KWORUM
	LD A, WIEKSZ
	CPI A, BEZWLAD
	JRNC RWIEKSZ	; ruch w strone wiekszych
	LD A, MNIEJ
	CPI A, BEZWLAD
	JRC NIEMNIEJ
	JP RMNIEJ	; ruch w strone mniejszych
NIEMNIEJ
	JP POZMIANIE
RWIEKSZ
	INC POZIOM
	JP JUZSWIEC
RMNIEJ
	DEC POZIOM	
	.ENDC

JUZSWIEC
	;; czyszczenie diod
 	LD A, DRB
 	ANDI A, 00000011b
 	LD DRB, A
 	RES 0, DRA
 	RES 1, DRA
 	RES 2, DRA
 	;; swiecenie
 	LD A, POZIOM
 	DEC A
 	JRNZ POZI2
 	SET 2, DRB		; 1 prog
 	JP POZMIANIE
POZI2
 	DEC A
 	JRNZ POZI3
 	SET 3, DRB
 	JP POZMIANIE
POZI3
 	DEC A
 	JRNZ POZI4
 	SET 6, DRB
 	JP POZMIANIE
POZI4
 	DEC A
 	JRNZ POZI5
 	SET 7, DRB
 	JP POZMIANIE
POZI5
 	DEC A
 	JRNZ POZI6
 	SET 0, DRA
 	JP POZMIANIE
POZI6
 	DEC A
 	JRNZ POZI7
 	SET 1, DRA
 	JP POZMIANIE
POZI7
 	DEC A
 	JRNZ POZMIANIE
 	SET 2, DRA
POZMIANIE
	.IFC EQ TYPDIOD
	LDI WIEKSZ, 0
	LDI MNIEJ, 0
	.ENDC
	
	
	.IFC EQ TYPDIOD-2
	LDI WIEKSZ, 0
	LDI MNIEJ, 0
	.ENDC
	
TESTGUZIK
	;;jesli trwa wyjscie proby, omin sprawdzanie
	.IFC NE PROBA
	LD A, PROBST
	JRZ POMGUZIK
	JP KROKPROBA
POMGUZIK
	.ENDC
	.IFC EQ DEBUG
	LD A, DRC
	ANDI A, 00000100b	; testowanie PC2
	.ELSE
	LD A, DBGUZIK		; DEBUG
	.ENDC
	JRNZ GUZIK1
	JP GUZIK0
GUZIK1
	LD A, GUST
	JRZ STARTGUZ
	DEC GUML
	JRZ KROKGUZ
	JP POTESCIE
STARTGUZ
	LDI GUST, 1
	LDI GUML, 255
	JP POTESCIE
KROKGUZ
	LDI GUML, 255
	INC GUST
	.IFC NE PROBA
	LD A, GUST
	CPI A, WYJPROBY
	JRNC WYSLPROBE
	.ENDC
	JP POTESCIE
	.IFC NE PROBA
WYSLPROBE
	LDI PROBST, DLPROBY
	LDI PROBML, 255
	LDI MIGMST, SYGPROBY
	LDI GUST, 0
	LDI GUML, 0
	;; przelacz w wyjscie push-pull stan wysoki
	LDI DRC,    00011000b
	LDI DDRC,   00000100b		;
	LDI ORC,    ORCWYJPR		; = 100b (PC2)
	LDI STANORC, ORCWYJPR
	LDI DRC,    00011100b
	JP POTESCIE
	.ENDC
GUZIK0
	LD A, GUST
	CPI A, KTRLKAS
	JRNC KASUJ
	LDI GUST, 0
	LDI GUML, 0
	JP POTESCIE
KASUJ
	;; kasuje ledM i pozwala na skasowanie zatrzasku po opoznieniu pomiaru
	LDI GUST, 0
	LDI GUML, 0
	RES 3, DRA
	CLR MSTAN
	.IFC NE LEDM	; dioda M = (mozliwa) pamiec
	JRS 0, BTRZ, NIEKASPAM
	LDI V, 0
	CALL PISZPAMV
NIEKASPAM
	.ENDC
	JRS 0, ZATRZ, KASZATRZ
	JP POTESCIE
KASZATRZ
	LDI PBST, TRZYMAJB	; opoznienie B -- jesli bedzie OK skasuje zatrzask
	LDI PBML, 255			; opoznienie B - mniej znaczacy rejestr
	JP POTESCIE

KROKPROBA
	DEC PROBML
	JRZ ROBKROK
	JP POTESCIE
ROBKROK
	LDI PROBML, 255
	DEC MIGMST
	JRNZ ROB2KROK
	LDI MIGMST, SYGPROBY
	JRR 3, DRA, PRSWIECM
	RES 3, DRA
	JP ROB2KROK
PRSWIECM
	SET 3, DRA
ROB2KROK
	DEC PROBST
	JRZ KONPROBY
	JP POTESCIE
KONPROBY
	LDI MIGMST, 0
	LDI DRC,    00011000b		; PC2 wej kas bez pull-up, PC3 pom B, PC4 zasilanie
	LDI ORC, ORCKAS				; = 0
	LDI STANORC, ORCKAS
	LDI DDRC,   00000000b		;
	LDI DRC,    00011100b		; PC2 wej kas bez pull-up, PC3 pom B, PC4 zasilanie
	CALL PRZYWRM
	
POTESCIE
	; JRR 0, ZATRZ, OPOZNIENIE
	; LD A, BTRZ
	; JRNZ OPOZNIENIE		; opoznienie chwycenia w opcji zatrzasku
	; JP DOZMZATRZ
	
OPOZNIENIE
	LD A, PBST
	JRNZ OPOZNIAJ
	JP DOZMZATRZ
OPOZNIAJ
	DEC PBML
	JRZ OPOZN2
	JP DOZMZATRZ
OPOZN2
	LDI PBML, 255
	DEC PBST
	JRZ OPOZN3
	JP DOZMZATRZ
OPOZN3
	LDI BTRZ, 0
	RES 1, DRB		; zgas ledB
	SET 0, DRB		; swiec ledP
	;; nie kasuj pamieci, jesli nie bylo kasowania
	JRR 0, ZATRZ, DOZMZATRZ
	LDI V, 0			; zeruj pamiec
	CALL PISZPAMV

DOZMZATRZ
	LD A, JESTZAT
	JRNZ DO2ZMZATRZ
	LD A, NIEZAT
	JRNZ DO2ZMZATRZ
	DEC ZATML
	JRZ ZATML0
	JP PETLA
DO2ZMZATRZ
	JP ZMZATRZ
ZATML0
	LDI ZATML, 255
	DEC ZATST
	JRZ ZMZATRZ
	JP PETLA
ZMZATRZ
	LDI ZATST, KTRLZAT
	;LD A, DRA
	;LD W, A

	LD A, STANORC
	LD ORC, A		; zeby nie doprowadzic do zwarcia na pomiarze A/D!!!
	RES 3, ORA
	RES 3, DDRA
	SET 3, DRA
	SET 3, ORA		; ustaw PA3 do przetwarzania A/D
	NOP
	NOP
	NOP
	NOP
	LDI ADCR, 10110000b
	.IFC EQ DEBUG
	WAIT		; Czekaj na wynik pomiaru - wczytany do akumulatora
	.ELSE
	LD A, DBZATRZ		; DEBUG
	.ENDC
	RES 3, ORA		; PA3 ledM (nie uzywaj akumulatora)
	SET 3, DDRA
	SET 3, ORA
	CPI A, POMZATRZ		; sprawdz czy napiecie na wlasciwym poziomie
	JRNC PONI1NIE
	CALL PRZYWRM
	;LD A, W
	;LD DRA, A
	JP PONI1ZAT
PONI1NIE
	CALL PRZYWRM
	;LD A, W
	;LD DRA, A
	INC NIEZAT
	LDI JESTZAT, 0
	LD A, ZATRZ
	JRZ ZATRZ1NIE
	JP ZATRZ1SPR
ZATRZ1NIE
	LDI NIEZAT, 0
	JP PETLA
PONI1ZAT
	INC JESTZAT
	LDI NIEZAT, 0
	LD A, ZATRZ
	JRZ ZATRZ1SPR
	LDI JESTZAT, 0
	JP PETLA
ZATRZ1SPR
	LD A, JESTZAT
	CPI A, CZASZATRZ
	JRNC ZAT1JEST
	LD A, NIEZAT
	CPI A, CZASZATRZ
	JRC DOPETLI
	JP ZAT1NIE
DOPETLI
	JP PETLA
ZAT1JEST
	LDI ZATRZ, 255
	LDI JESTZAT, 0
	.IFC NE LEDM		; wersja z ledM
	JRS 0, BTRZ, ZATCHWYC
	RES 3, DRA
	CLR MSTAN
	CALL CZYTPAMA
	JRZ DO3PETLI
	LDI V, 0
	CALL PISZPAMV
	.ENDC
	JP PETLA
ZATCHWYC
	LDI PBST, 0
	LDI PBML, 0
DO3PETLI
	JP PETLA
ZAT1NIE
	LDI ZATRZ, 0
	LDI NIEZAT, 0
	.IFC EQ LEDM		; wersja bez ledM -- czysc pamiec
	CALL CZYTPAMA
	JRZ NIECZYSC
	LDI V, 0
	CALL PISZPAMV
NIECZYSC
	.ENDC
	JRR 0, BTRZ, DO4PETLI	
	LDI PBST, TRZYMAJB
	LDI PBML, 255
	.IFC EQ LEDM		; wersja bez ledM
	RES 3, DRA		; kasuj ledM
	CLR MSTAN
	.ELSE
	SET 3, DRA		; ustaw ledM w opcji bez zatrzasku (?)
	LDI MSTAN, 255
	.ENDC
DO4PETLI	
	JP PETLA	; zapetl od nowa

PISZPAMV
	LDI WDR, 11111110b		; watchdog
CZEKAJ5PAM			; czysc pamiec zatrzasku
	LDI A, 10b		; sprawdz 2 bit EECTL -- E2BUSY
	AND A, EECTL
	JRNZ CZEKAJ5PAM
	LDI EECTL, 00000001b	; pozwol na pisanie do pamieci (bit 0 -- E2ENA)
	LD A, V
	LD PAMIEC, A		; zmien zatrzask w pamieci
CZEKAJ6PAM
	LDI A, 10b		; sprawdz 2 bit EECTL -- E2BUSY
	AND A, EECTL
	JRNZ CZEKAJ6PAM
	LDI EECTL, 0		; wylacz pisanie do pamieci
	RET
PRZYWRM
	JRS 0, MSTAN, MSWIECI
	RES 3, DRA
	RET
MSWIECI
	SET 3, DRA
	RET

CZYTPAMA
	LDI WDR, 11111110b		; watchdog
CZEKAJ7PAM
	LDI A, 10b		; sprawdz 2 bit EECTL -- E2BUSY
	AND A, EECTL
	JRNZ CZEKAJ7PAM
	LD A, PAMIEC
	RET

ADCINT
	LDI ADCR, 00010000b	; zeby nie zapetlal przerwania 
	LD A, ADR	; wczytywanie pomiaru
	RETI
TIMINT
	RETI
PAINT
	RETI
PBINT
	RETI
NMINT
	RETI
		
.ORG 0FF0H
	JP ADCINT	; budzenie po pomiarze
	JP TIMINT	; timer
	JP PAINT		; przerwanie na porcie A
	JP PBINT		; przerwanie na porcie B
.ORG 0FFCH
	JP NMINT		; przerwanie NMI
   JP INIT     ; obsluga RESET
.END
